import 'package:shared_preferences/shared_preferences.dart';

class LessonProgress {
  final String lessonId;
  final bool completed;
  final int score;
  final int totalQuestions;
  final int xpEarned;
  final DateTime completedAt;

  const LessonProgress({
    required this.lessonId,
    required this.completed,
    required this.score,
    required this.totalQuestions,
    required this.xpEarned,
    required this.completedAt,
  });

  String get scoreLabel => '$score/$totalQuestions';
  // 60% threshold: ceil(n*0.6) = 2 for 3q, 3 for 5q — avoids 100% requirement
  // that ceil(n*0.67) creates for short quizzes (e.g. ceil(3*0.67)=3).
  bool get passed => score >= (totalQuestions * 0.6).ceil();
}

class LessonService {
  static const _prefix = 'lesson_';
  static const _xpKey = 'beanstalk_total_xp';

  static Future<void> saveProgress({
    required String lessonId,
    required int score,
    required int totalQuestions,
    required int xpEarned,
  }) async {
    final p = await SharedPreferences.getInstance();
    // Only add XP if first time passing
    final alreadyPassed = p.getBool('${_prefix}${lessonId}_passed') ?? false;
    if (!alreadyPassed && xpEarned > 0) {
      final current = p.getInt(_xpKey) ?? 0;
      await p.setInt(_xpKey, current + xpEarned);
      await p.setBool('${_prefix}${lessonId}_passed', true);
    }
    await p.setInt('${_prefix}${lessonId}_score', score);
    await p.setInt('${_prefix}${lessonId}_total', totalQuestions);
    await p.setInt('${_prefix}${lessonId}_xp', xpEarned);
    await p.setBool('${_prefix}${lessonId}_done', true);
    await p.setString('${_prefix}${lessonId}_date', DateTime.now().toIso8601String());
  }

  static Future<bool> isCompleted(String lessonId) async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('${_prefix}${lessonId}_done') ?? false;
  }

  static Future<LessonProgress?> getProgress(String lessonId) async {
    final p = await SharedPreferences.getInstance();
    final done = p.getBool('${_prefix}${lessonId}_done') ?? false;
    if (!done) return null;
    final score = p.getInt('${_prefix}${lessonId}_score') ?? 0;
    final total = p.getInt('${_prefix}${lessonId}_total') ?? 3;
    final xp = p.getInt('${_prefix}${lessonId}_xp') ?? 0;
    final dateStr = p.getString('${_prefix}${lessonId}_date') ??
        DateTime.now().toIso8601String();
    return LessonProgress(
      lessonId: lessonId,
      completed: true,
      score: score,
      totalQuestions: total,
      xpEarned: xp,
      completedAt: DateTime.parse(dateStr),
    );
  }

  /// Loads all lesson progress, XP, and completed count in a single
  /// SharedPreferences read — avoids 37+ sequential async calls.
  static Future<({Map<String, LessonProgress> progress, int xp, int count})>
      loadAll() async {
    final p = await SharedPreferences.getInstance();
    final result = <String, LessonProgress>{};
    int count = 0;

    for (var i = 1; i <= 26; i++) {
      final id = 'l$i';
      final done = p.getBool('${_prefix}${id}_done') ?? false;
      if (done) {
        count++;
        final score = p.getInt('${_prefix}${id}_score') ?? 0;
        final total = p.getInt('${_prefix}${id}_total') ?? 3;
        final xp = p.getInt('${_prefix}${id}_xp') ?? 0;
        final dateStr = p.getString('${_prefix}${id}_date') ??
            DateTime.now().toIso8601String();
        result[id] = LessonProgress(
          lessonId: id,
          completed: true,
          score: score,
          totalQuestions: total,
          xpEarned: xp,
          completedAt: DateTime.parse(dateStr),
        );
      }
    }

    final xp = p.getInt(_xpKey) ?? 0;
    return (progress: result, xp: xp, count: count);
  }

  static Future<Map<String, LessonProgress>> getAllProgress() async {
    final p = await SharedPreferences.getInstance();
    final result = <String, LessonProgress>{};
    for (var i = 1; i <= 26; i++) {
      final id = 'l$i';
      final done = p.getBool('${_prefix}${id}_done') ?? false;
      if (done) {
        final score = p.getInt('${_prefix}${id}_score') ?? 0;
        final total = p.getInt('${_prefix}${id}_total') ?? 3;
        final xp = p.getInt('${_prefix}${id}_xp') ?? 0;
        final dateStr = p.getString('${_prefix}${id}_date') ??
            DateTime.now().toIso8601String();
        result[id] = LessonProgress(
          lessonId: id,
          completed: true,
          score: score,
          totalQuestions: total,
          xpEarned: xp,
          completedAt: DateTime.parse(dateStr),
        );
      }
    }
    return result;
  }

  static Future<int> getTotalXp() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_xpKey) ?? 0;
  }

  static Future<int> getCompletedCount() async {
    final p = await SharedPreferences.getInstance();
    int count = 0;
    for (var i = 1; i <= 26; i++) {
      if (p.getBool('${_prefix}l${i}_done') == true) count++;
    }
    return count;
  }

  static Future<void> clearAll() async {
    final p = await SharedPreferences.getInstance();
    final keys = p.getKeys().where((k) => k.startsWith(_prefix) || k == _xpKey).toList();
    for (final k in keys) await p.remove(k);
  }
}
