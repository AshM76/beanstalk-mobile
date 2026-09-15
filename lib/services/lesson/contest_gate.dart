// lib/services/lesson/contest_gate.dart
//
// Evaluates a contest's learning-gate entry requirements against the user's
// local lesson progress. A contest can require a minimum total XP and/or a set
// of lessons that must be *passed* before a user may join (authored in the
// admin console, stored on the contest as entry_requirements — see
// beanstalk-api). Enforcement is client-side for now: the contest UI locks the
// Join button until the gate is met and points the user at the Learn tab.
//
// XP + lesson pass/fail live in SharedPreferences via LessonService, so a gate
// is evaluated against whatever this device knows. loadSnapshot() reads that
// once; fromSnapshot() then scores any number of contests without re-reading.

import '../../pages/lessons/lessons_page.dart' show kLessons;
import 'lesson_service.dart';

/// A point-in-time snapshot of the local learner state a gate is scored against.
class LessonSnapshot {
  final int totalXp;
  final Set<String> passedLessonIds;
  const LessonSnapshot({required this.totalXp, required this.passedLessonIds});
}

/// The result of scoring one contest's requirements against a [LessonSnapshot].
class ContestGate {
  /// Minimum total XP required (0 = no XP requirement).
  final int requiredXp;

  /// The learner's current total XP.
  final int currentXp;

  /// All lesson ids the contest requires (may be empty).
  final List<String> requiredLessonIds;

  /// Required lessons the learner has NOT yet passed, in catalog order.
  final List<String> missingLessonIds;

  const ContestGate({
    required this.requiredXp,
    required this.currentXp,
    required this.requiredLessonIds,
    required this.missingLessonIds,
  });

  /// A contest with no requirements — always unlocked.
  const ContestGate.open()
      : requiredXp = 0,
        currentXp = 0,
        requiredLessonIds = const [],
        missingLessonIds = const [];

  /// True when the contest actually gates entry on anything.
  bool get hasGate => requiredXp > 0 || requiredLessonIds.isNotEmpty;

  bool get xpMet => currentXp >= requiredXp;
  bool get lessonsMet => missingLessonIds.isEmpty;

  /// All requirements satisfied.
  bool get met => xpMet && lessonsMet;

  /// The gate exists and is not yet satisfied — the Join button should lock.
  bool get locked => hasGate && !met;

  /// XP still needed (0 when the XP requirement is met or absent).
  int get xpShortfall => requiredXp > currentXp ? requiredXp - currentXp : 0;

  int get passedRequiredCount => requiredLessonIds.length - missingLessonIds.length;

  /// Titles of the still-missing required lessons, in catalog order.
  List<String> get missingLessonTitles {
    final titleById = {for (final l in kLessons) l.id: l.title};
    return [
      for (final l in kLessons)
        if (missingLessonIds.contains(l.id)) titleById[l.id] ?? l.id,
    ];
  }

  /// One-line summary of what's left, e.g.
  ///   "Earn 120 more XP"
  ///   "Pass ‘Diversification’"
  ///   "Earn 120 more XP  ·  Pass 2 lessons"
  String get shortSummary {
    final parts = <String>[];
    if (!xpMet) parts.add('Earn $xpShortfall more XP');
    if (!lessonsMet) {
      final titles = missingLessonTitles;
      parts.add(titles.length == 1
          ? 'Pass ‘${titles.first}’'
          : 'Pass ${titles.length} lessons');
    }
    return parts.join('  ·  ');
  }

  /// Load the local learner snapshot once (one SharedPreferences read).
  static Future<LessonSnapshot> loadSnapshot() async {
    final data = await LessonService.loadAll();
    final passed = <String>{
      for (final e in data.progress.entries)
        if (e.value.passed) e.key,
    };
    return LessonSnapshot(totalXp: data.xp, passedLessonIds: passed);
  }

  /// Score a contest's requirements against an already-loaded [snapshot].
  factory ContestGate.fromSnapshot({
    required int requiredXp,
    required List<String> requiredLessonIds,
    required LessonSnapshot snapshot,
  }) {
    if (requiredXp <= 0 && requiredLessonIds.isEmpty) {
      return const ContestGate.open();
    }
    final missing = [
      for (final id in requiredLessonIds)
        if (!snapshot.passedLessonIds.contains(id)) id,
    ];
    return ContestGate(
      requiredXp: requiredXp < 0 ? 0 : requiredXp,
      currentXp: snapshot.totalXp,
      requiredLessonIds: requiredLessonIds,
      missingLessonIds: missing,
    );
  }

  /// Convenience: load the snapshot and score a single contest.
  static Future<ContestGate> evaluate({
    required int requiredXp,
    required List<String> requiredLessonIds,
  }) async {
    if (requiredXp <= 0 && requiredLessonIds.isEmpty) {
      return const ContestGate.open();
    }
    final snapshot = await loadSnapshot();
    return ContestGate.fromSnapshot(
      requiredXp: requiredXp,
      requiredLessonIds: requiredLessonIds,
      snapshot: snapshot,
    );
  }
}
