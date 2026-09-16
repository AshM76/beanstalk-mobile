// lib/services/contest/recap_service.dart
//
// Fetches and models the Cash-narrated contest recap.
//
// The backend (beanstalk-api) assembles a deterministic recap INPUT from a
// concluded contest, has Claude narrate it in Cash's voice, and stores the
// result. An admin reviews and publishes it; only then does
// GET /api/contests/:id/recap return it (404 while it's an unreviewed draft or
// absent). See Design/Contest-Recap-Generation-Spec.md.
//
// This service turns that response into a typed [ContestRecap]. The three
// states callers care about:
//   - failure   → `!isOk`                (show an error/retry state)
//   - not ready → ok with `null`         (published recap doesn't exist yet)
//   - data      → ok with a ContestRecap (render it)

import 'package:flutter/foundation.dart';

import '../api/api_service.dart';

class RecapService {
  static ApiService get _api => ApiService();

  /// Fetch the published recap for [contestId], or null when none is published.
  static Future<ApiResult<ContestRecap?>> fetch(String contestId) async {
    final r = await _api.getContestRecap(contestId);
    if (!r.isOk) {
      debugPrint('[RecapService.fetch] $contestId → ${r.error}');
      return ApiResult.fail(r.error, statusCode: r.statusCode);
    }
    final record = r.data;
    if (record == null) return const ApiResult.ok(null); // not published yet
    try {
      return ApiResult.ok(ContestRecap.fromRecord(record));
    } catch (e) {
      debugPrint('[RecapService.fetch] parse error for $contestId: $e');
      return const ApiResult.fail('Recap could not be read');
    }
  }

  /// Fetch the signed-in user's private mini-recap, or null when there isn't
  /// one (group recap not published yet, or they weren't in the contest).
  static Future<ApiResult<PersonalRecap?>> fetchPersonal(String contestId) async {
    final r = await _api.getMyContestRecap(contestId);
    if (!r.isOk) {
      debugPrint('[RecapService.fetchPersonal] $contestId → ${r.error}');
      return ApiResult.fail(r.error, statusCode: r.statusCode);
    }
    final record = r.data;
    if (record == null) return const ApiResult.ok(null);
    try {
      return ApiResult.ok(PersonalRecap.fromRecord(record));
    } catch (e) {
      debugPrint('[RecapService.fetchPersonal] parse error for $contestId: $e');
      return const ApiResult.fail('Recap could not be read');
    }
  }
}

/// A published contest recap (the OUTPUT the app renders). Mirrors the backend
/// recap OUTPUT schema, wrapped in its storage record (`status`, timestamps).
class ContestRecap {
  final String headline;
  final String marketRecap;
  final List<RecapHighlight> highlights;
  final RecapScoreboard scoreboard;
  final List<String> lessons;
  final String cashSignoff;
  final DateTime? generatedAt;

  const ContestRecap({
    required this.headline,
    required this.marketRecap,
    required this.highlights,
    required this.scoreboard,
    required this.lessons,
    required this.cashSignoff,
    this.generatedAt,
  });

  /// Parse the full record: `{ status, recap: {...}, generated_at, ... }`.
  factory ContestRecap.fromRecord(Map<String, dynamic> record) {
    final body = (record['recap'] as Map?)?.cast<String, dynamic>() ?? const {};
    return ContestRecap(
      headline: (body['headline'] as String?)?.trim() ?? '',
      marketRecap: (body['market_recap'] as String?)?.trim() ?? '',
      highlights: [
        for (final h in (body['highlights'] as List? ?? const []))
          if (h is Map) RecapHighlight.fromJson(h.cast<String, dynamic>()),
      ],
      scoreboard: RecapScoreboard.fromJson(
        (body['benchmark_scoreboard'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      lessons: [
        for (final l in (body['lessons'] as List? ?? const []))
          if (l is String && l.trim().isNotEmpty) l.trim(),
      ],
      cashSignoff: (body['cash_signoff'] as String?)?.trim() ?? '',
      generatedAt: DateTime.tryParse('${record['generated_at'] ?? ''}')?.toLocal(),
    );
  }
}

class RecapHighlight {
  final String emoji;
  final String title;
  final String body;

  const RecapHighlight({required this.emoji, required this.title, required this.body});

  factory RecapHighlight.fromJson(Map<String, dynamic> j) => RecapHighlight(
        emoji: (j['emoji'] as String?)?.trim().isNotEmpty == true
            ? (j['emoji'] as String).trim()
            : '✨',
        title: (j['title'] as String?)?.trim() ?? '',
        body: (j['body'] as String?)?.trim() ?? '',
      );
}

class RecapScoreboard {
  final String line;
  final double? beatMarketShare; // 0..1, share who beat Sammy P. (S&P 500)
  final double? beatSavingsShare; // 0..1, share who beat Piggy (savings)

  const RecapScoreboard({
    required this.line,
    this.beatMarketShare,
    this.beatSavingsShare,
  });

  factory RecapScoreboard.fromJson(Map<String, dynamic> j) => RecapScoreboard(
        line: (j['line'] as String?)?.trim() ?? '',
        beatMarketShare: _asShare(j['beat_market_share']),
        beatSavingsShare: _asShare(j['beat_savings_share']),
      );

  /// A 0..1 share as a percent string ("41%"), or null when unknown.
  static String? asPercent(double? share) =>
      share == null ? null : '${(share * 100).round()}%';

  static double? _asShare(Object? v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}

/// A private, per-kid mini-recap. Short and encouraging; the figures
/// (return, beat flags) are the server's verified numbers.
class PersonalRecap {
  final String headline;
  final String body;
  final double? yourReturnPercent;
  final bool? beatMarket; // beat Sammy P. (S&P 500); null when unknown
  final bool? beatSavings; // beat Piggy (savings); null when unknown
  final String lesson;
  final String cashSignoff;

  const PersonalRecap({
    required this.headline,
    required this.body,
    this.yourReturnPercent,
    this.beatMarket,
    this.beatSavings,
    required this.lesson,
    required this.cashSignoff,
  });

  factory PersonalRecap.fromRecord(Map<String, dynamic> record) {
    final body = (record['recap'] as Map?)?.cast<String, dynamic>() ?? const {};
    return PersonalRecap(
      headline: (body['headline'] as String?)?.trim() ?? '',
      body: (body['body'] as String?)?.trim() ?? '',
      yourReturnPercent: (body['your_return_percent'] as num?)?.toDouble(),
      beatMarket: body['beat_market'] as bool?,
      beatSavings: body['beat_savings'] as bool?,
      lesson: (body['lesson'] as String?)?.trim() ?? '',
      cashSignoff: (body['cash_signoff'] as String?)?.trim() ?? '',
    );
  }

  /// The signed return as "+12.3%" / "-4.0%", or null when unknown.
  String? get returnLabel {
    final r = yourReturnPercent;
    if (r == null) return null;
    final sign = r >= 0 ? '+' : '';
    return '$sign${r.toStringAsFixed(1)}%';
  }
}
