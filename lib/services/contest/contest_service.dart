// lib/services/contest/contest_service.dart
//
// Thin wrapper around the backend contest leaderboard endpoint.
//
// The backend returns leaderboards keyed by age group:
//   { contest_id, leaderboards: { high_school: { rankings:[...] },
//     college: {...}, adults: {...} } }
// The mobile UI shows ONE unified board, so this service merges all age
// groups into a single list sorted by portfolio value (descending) and
// re-ranks 1..N. It does not tab or filter by age group.
//
// A short in-memory cache (per contest) mirrors MarketService's TTL pattern
// so rapidly switching between the Details / Leaderboard / Chat tabs doesn't
// hammer the API.

import 'package:flutter/foundation.dart';

import '../../pages/contests/contests_page.dart' show LeaderboardEntry;
import '../api/api_service.dart';

class ContestService {
  // Leaderboards move slowly relative to a tab switch; 30s keeps tab-flips
  // cheap while staying fresh enough for a live contest.
  static const _ttl = Duration(seconds: 30);

  static final Map<String, _CachedLeaderboard> _cache = {};

  static ApiService get _api => ApiService();

  /// Fetch the merged, ranked leaderboard for [contestId].
  ///
  /// Returns an [ApiResult] so callers can tell three states apart:
  ///   - failure  → `!isOk`            (show an error state)
  ///   - empty    → ok with `[]`       (show "be the first to trade" state)
  ///   - data     → ok with entries    (render the board)
  ///
  /// Entries from all three age groups are combined and sorted by portfolio
  /// value descending, then re-ranked 1..N.
  static Future<ApiResult<List<LeaderboardEntry>>> fetchLeaderboard(
    String contestId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = _cache[contestId];
      if (cached != null && !cached.isStale) {
        return ApiResult.ok(cached.entries);
      }
    }

    final r = await _api.getLeaderboard(contestId);
    if (!r.isOk) {
      debugPrint('[ContestService.fetchLeaderboard] $contestId → ${r.error}');
      return ApiResult.fail(r.error, statusCode: r.statusCode);
    }

    final entries = _mergeAndRank(r.data!);
    _cache[contestId] = _CachedLeaderboard(entries, DateTime.now());
    return ApiResult.ok(entries);
  }

  /// Total enrollment for a contest = number of ranked players across all age
  /// groups. Reads from cache when warm; otherwise null (callers fall back to
  /// the participant count already on the contest list response).
  static int? cachedPlayerCount(String contestId) =>
      _cache[contestId]?.entries.length;

  static List<LeaderboardEntry> _mergeAndRank(Map<String, dynamic> payload) {
    final boards = payload['leaderboards'];
    if (boards is! Map) return const [];

    final currentUserId = _api.currentUserId;
    final merged = <LeaderboardEntry>[];

    // Don't filter or tab by age group — flatten every group's rankings.
    for (final group in boards.values) {
      if (group is! Map) continue;
      final rankings = group['rankings'];
      if (rankings is! List) continue;
      for (final raw in rankings) {
        if (raw is! Map) continue;
        merged.add(LeaderboardEntry.fromJson(
          raw.cast<String, dynamic>(),
          currentUserId: currentUserId,
        ));
      }
    }

    // Sort by the ranking metric (portfolio value) descending, then re-rank
    // the unified list so ranks are global rather than per-age-group.
    merged.sort((a, b) => b.portfolioValue.compareTo(a.portfolioValue));
    return [
      for (var i = 0; i < merged.length; i++) merged[i].copyWith(rank: i + 1),
    ];
  }

  /// Drop cached rankings (e.g. after the user trades in a contest so the next
  /// open reflects their new portfolio value).
  static void invalidate([String? contestId]) {
    if (contestId == null) {
      _cache.clear();
    } else {
      _cache.remove(contestId);
    }
  }
}

class _CachedLeaderboard {
  final List<LeaderboardEntry> entries;
  final DateTime fetchedAt;
  _CachedLeaderboard(this.entries, this.fetchedAt);
  bool get isStale =>
      DateTime.now().difference(fetchedAt) > ContestService._ttl;
}
