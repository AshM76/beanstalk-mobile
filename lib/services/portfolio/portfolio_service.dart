// lib/services/portfolio/portfolio_service.dart
//
// Backend-backed portfolio service. Replaces the previous SharedPreferences
// implementation: cash balance, holdings, buys and sells now round-trip
// through the Beanstalk API. SharedPreferences is still used for *local
// preferences* (notification flags), never for portfolio state.
//
// Callers have not changed — load() / buy() / sell() keep their signatures.
// buy() and sell() gained an optional contestId parameter so trades can be
// routed to the right portfolio; when omitted, the user's main portfolio is
// used (matching the backend's default).

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/holding.dart';
import '../api/api_service.dart';
import '../notification/notification_service.dart';

// ── Service ───────────────────────────────────────────────────────────────────

class PortfolioService {
  // Local-only flag: has the user ever made a trade? (drives first-trade
  // notification — pure UI concern, no portfolio state.)
  static const _firstTradeKey = 'first_trade_done';

  static ApiService get _api => ApiService();

  /// Load cash balance and all holdings.
  ///
  /// [contestId] — when non-null, returns the user's portfolio for that
  /// contest instead of their main portfolio. Both paths hit
  /// GET /api/portfolio/:userId (with or without the contest_id query
  /// parameter) and return a uniform response shape.
  ///
  /// On network failure we fall back to an empty portfolio with the starting
  /// $10,000 so the UI stays usable offline; errors are logged via debugPrint.
  static Future<({double cash, Map<String, Holding> holdings})> load({
    String? contestId,
  }) async {
    final userId = _api.currentUserId;

    final r = contestId == null
        ? await _api.getMainPortfolio(userId)
        : await _api.getContestPortfolio(userId, contestId);

    if (!r.isOk) {
      debugPrint('[Portfolio.load] API error: ${r.error} — falling back to empty');
      return (cash: 10000.0, holdings: <String, Holding>{});
    }

    final data = r.data!;
    final cash = _num(data['current_balance']) ?? _num(data['starting_balance']) ?? 10000.0;
    final positions = (data['positions'] as List?) ?? const [];

    final holdings = <String, Holding>{};
    for (final raw in positions) {
      if (raw is! Map) continue;
      final h = Holding.fromJson(raw.cast<String, dynamic>());
      if (h.symbol.isEmpty || h.quantity <= 0) continue;
      holdings[h.symbol] = h;
    }

    debugPrint(
      '[Portfolio.load] cash=$cash  keys=${holdings.keys.toList()}  '
      'contest=${contestId ?? "main"}',
    );
    return (cash: cash, holdings: holdings);
  }

  /// Buy shares. Returns null on success, error string on failure.
  ///
  /// [contestId] — when non-null, the trade runs against the user's contest
  /// portfolio for that contest rather than their main portfolio.
  static Future<String?> buy({
    required String symbol,
    required String name, // kept for signature compat; backend ignores
    required double price,
    required num quantity,
    String? contestId,
  }) async {
    debugPrint(
      '[Portfolio.buy] START  symbol=$symbol qty=$quantity price=$price '
      'contest=${contestId ?? "main"}',
    );

    final userId = _api.currentUserId;
    final r = await _api.executeTrade(
      userId: userId,
      symbol: symbol,
      action: 'buy',
      quantity: quantity,
      price: price,
      contestId: contestId,
    );

    if (!r.isOk) {
      debugPrint('[Portfolio.buy] FAIL ${r.statusCode} ${r.error}');
      return r.error ?? 'Trade failed';
    }

    debugPrint('[Portfolio.buy] OK  response=${r.data}');
    await _maybeFireFirstTradeNotification(symbol);
    return null;
  }

  /// Sell shares. Returns null on success, error string on failure.
  static Future<String?> sell({
    required String symbol,
    required double price,
    required num quantity,
    String? contestId,
  }) async {
    debugPrint(
      '[Portfolio.sell] START  symbol=$symbol qty=$quantity price=$price '
      'contest=${contestId ?? "main"}',
    );

    final userId = _api.currentUserId;
    final r = await _api.executeTrade(
      userId: userId,
      symbol: symbol,
      action: 'sell',
      quantity: quantity,
      price: price,
      contestId: contestId,
    );

    if (!r.isOk) {
      debugPrint('[Portfolio.sell] FAIL ${r.statusCode} ${r.error}');
      return r.error ?? 'Trade failed';
    }

    debugPrint('[Portfolio.sell] OK  response=${r.data}');
    return null;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static Future<void> _maybeFireFirstTradeNotification(String symbol) async {
    final p = await SharedPreferences.getInstance();
    final done = p.getBool(_firstTradeKey) ?? false;
    if (done) return;
    await p.setBool(_firstTradeKey, true);
    await NotificationService.addForFirstTrade(symbol);
  }

  static double? _num(Object? v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}
