import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../notification/notification_service.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class Holding {
  final String symbol;
  final String name;
  final double quantity;
  final double avgCost;

  const Holding({
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.avgCost,
  });

  double marketValue(double currentPrice) => quantity * currentPrice;
  double unrealizedGain(double currentPrice) => (currentPrice - avgCost) * quantity;
}

// ── Service ───────────────────────────────────────────────────────────────────

class PortfolioService {
  static const _cashKey     = 'portfolio_cash';
  static const _holdingsKey = 'portfolio_holdings';
  static const _startCash   = 10000.0;

  /// Load cash balance and all holdings.
  static Future<({double cash, Map<String, Holding> holdings})> load() async {
    final p           = await SharedPreferences.getInstance();
    // NOTE: do NOT call p.reload() — on iOS it races against NSUserDefaults
    // async disk sync and can return stale data even after a fresh write.
    final cash        = p.getDouble(_cashKey) ?? _startCash;
    final holdingsRaw = p.getString(_holdingsKey);
    final holdings    = _parseHoldings(holdingsRaw);
    debugPrint('[Portfolio.load] cash=$cash  keys=${holdings.keys.toList()}  raw=$holdingsRaw');
    return (cash: cash, holdings: holdings);
  }

  /// Buy shares. Returns null on success, error string on failure.
  static Future<String?> buy({
    required String symbol,
    required String name,
    required double price,
    required int quantity,
  }) async {
    final p    = await SharedPreferences.getInstance();
    final cash = p.getDouble(_cashKey) ?? _startCash;
    final cost = price * quantity;
    debugPrint('[Portfolio.buy] START  symbol=$symbol qty=$quantity price=$price cash=$cash cost=$cost');

    if (cost > cash) {
      debugPrint('[Portfolio.buy] FAIL insufficient funds');
      return 'Insufficient funds';
    }

    final newCash = cash - cost;
    final cashOk = await p.setDouble(_cashKey, newCash);
    debugPrint('[Portfolio.buy] setDouble cash=$newCash  ok=$cashOk');

    final raw = _parseRaw(p.getString(_holdingsKey));
    if (raw.containsKey(symbol)) {
      final prev    = raw[symbol]!;
      final prevQty = (prev['qty'] as num).toDouble();
      final prevAvg = (prev['avg'] as num).toDouble();
      final newQty  = prevQty + quantity;
      raw[symbol]   = {
        'name': name,
        'qty':  newQty,
        'avg':  (prevQty * prevAvg + cost) / newQty,
      };
    } else {
      raw[symbol] = {'name': name, 'qty': quantity.toDouble(), 'avg': price};
    }

    final encoded  = jsonEncode(raw);
    final stringOk = await p.setString(_holdingsKey, encoded);
    debugPrint('[Portfolio.buy] setString ok=$stringOk  saved=$encoded');

    // Verify the write immediately
    final verify = p.getString(_holdingsKey);
    debugPrint('[Portfolio.buy] VERIFY read-back=$verify');

    // Fire first-trade notification once
    final firstTradeDone = p.getBool('first_trade_done') ?? false;
    if (!firstTradeDone) {
      await p.setBool('first_trade_done', true);
      await NotificationService.addForFirstTrade(symbol);
    }

    return null;
  }

  /// Sell shares. Returns null on success, error string on failure.
  static Future<String?> sell({
    required String symbol,
    required double price,
    required int quantity,
  }) async {
    final p   = await SharedPreferences.getInstance();
    final raw = _parseRaw(p.getString(_holdingsKey));
    if (!raw.containsKey(symbol)) return 'No shares held';

    final prev    = raw[symbol]!;
    final prevQty = (prev['qty'] as num).toDouble();
    if (quantity > prevQty) return 'Not enough shares';

    final cash = p.getDouble(_cashKey) ?? _startCash;
    await p.setDouble(_cashKey, cash + price * quantity);

    final newQty = prevQty - quantity;
    if (newQty < 0.0001) {
      raw.remove(symbol);
    } else {
      raw[symbol] = {...prev, 'qty': newQty};
    }
    await p.setString(_holdingsKey, jsonEncode(raw));
    debugPrint('[Portfolio.sell] sold $quantity x $symbol');
    return null;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static Map<String, Map<String, dynamic>> _parseRaw(String? json) {
    if (json == null || json.isEmpty) return {};
    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map) return {};
      return decoded.map(
        (k, v) => MapEntry(k as String, Map<String, dynamic>.from(v as Map)),
      );
    } catch (e) {
      debugPrint('[Portfolio._parseRaw] JSON parse error: $e  input=$json');
      return {};
    }
  }

  static Map<String, Holding> _parseHoldings(String? json) {
    return _parseRaw(json).map((k, v) => MapEntry(
          k,
          Holding(
            symbol:   k,
            name:     v['name'] as String? ?? k,
            quantity: (v['qty'] as num).toDouble(),
            avgCost:  (v['avg'] as num).toDouble(),
          ),
        ));
  }
}
