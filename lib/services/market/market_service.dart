// lib/services/market/market_service.dart
//
// Thin wrapper around the backend market-data endpoints (Alpaca-backed).
// The mobile app historically displayed hardcoded mock prices from
// kAllStocks; those values are now metadata-only (name, sector, symbol)
// and real prices flow through this service.
//
// A short in-memory cache keeps us from hammering Alpaca when the dashboard
// renders many rows in quick succession (e.g. RefreshIndicator pulls,
// portfolio switches). Cache is per-symbol with a short TTL because real
// prices move and we don't want trade fills to be based on a stale quote
// in test mode (the backend trusts the client price in test mode — see
// portfolio.controller.js).

import 'package:flutter/foundation.dart';

import '../../models/asset_class.dart';
import '../api/api_service.dart';

class MarketService {
  static const _ttl = Duration(seconds: 15);

  static final Map<String, _CachedPrice> _cache = {};

  static ApiService get _api => ApiService();

  /// Fetch the latest price for [symbol]. Returns null on network failure or
  /// unknown symbol — callers should fall back to whatever they had
  /// (e.g. last cached price, catalog mock, or avg cost).
  static Future<double?> getPrice(String symbol) async {
    final up = symbol.toUpperCase();
    final cached = _cache[up];
    if (cached != null && !cached.isStale) return cached.price;

    final r = await _api.getMarketPrice(up);
    if (!r.isOk || r.data == null) {
      debugPrint('[MarketService.getPrice] $up → ${r.error}');
      return cached?.price; // serve stale rather than nothing
    }
    final p = _asDouble(r.data!['price']);
    if (p == null) return cached?.price;
    _cache[up] = _CachedPrice(p, DateTime.now());
    return p;
  }

  /// Batch fetch. Returns a map of `symbol → price`. Missing symbols are
  /// omitted (not included with a null value). Single backend call.
  static Future<Map<String, double>> getPrices(List<String> symbols) async {
    if (symbols.isEmpty) return const {};

    // Start from whatever fresh values we already have, then only request
    // the symbols we actually need. Keeps Alpaca chatter down.
    final result = <String, double>{};
    final toFetch = <String>[];
    for (final s in symbols) {
      final up = s.toUpperCase();
      final cached = _cache[up];
      if (cached != null && !cached.isStale) {
        result[up] = cached.price;
      } else {
        toFetch.add(up);
      }
    }

    if (toFetch.isEmpty) return result;

    final r = await _api.getMarketPrices(toFetch);
    if (!r.isOk || r.data == null) {
      debugPrint('[MarketService.getPrices] batch → ${r.error}');
      // Fall back to stale cache for anything we had before.
      for (final s in toFetch) {
        final c = _cache[s];
        if (c != null) result[s] = c.price;
      }
      return result;
    }

    final now = DateTime.now();
    for (final entry in r.data!) {
      final sym = (entry['symbol'] as String?)?.toUpperCase();
      final price = _asDouble(entry['price']);
      if (sym == null || price == null) continue;
      _cache[sym] = _CachedPrice(price, now);
      result[sym] = price;
    }
    return result;
  }

  /// Search the backend full-universe index, optionally filtered to a
  /// specific asset class. Results are raw backend maps shaped
  /// `{symbol, name, asset_class, ...}` where `asset_class` is `'STOCK' |
  /// 'ETF' | 'CRYPTO'`. Client-side filter because the backend endpoint
  /// does not currently take an `asset_class` query param.
  static Future<List<Map<String, dynamic>>> searchTickers(
    String query, {
    AssetClass? filter,
  }) async {
    if (query.isEmpty) return const [];
    final r = await _api.searchMarket(query);
    if (!r.isOk || r.data == null) {
      debugPrint('[MarketService.searchTickers] $query → ${r.error}');
      return const [];
    }
    if (filter == null) return r.data!;
    return r.data!
        .where((m) => AssetClassParse.fromString(m['asset_class']) == filter)
        .toList();
  }

  /// Force-invalidate the cache (e.g. after a buy/sell so the next dashboard
  /// load re-fetches instead of serving a 15s-old quote).
  static void invalidate([String? symbol]) {
    if (symbol == null) {
      _cache.clear();
    } else {
      _cache.remove(symbol.toUpperCase());
    }
  }

  static double? _asDouble(Object? v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}

class _CachedPrice {
  final double price;
  final DateTime fetchedAt;
  _CachedPrice(this.price, this.fetchedAt);
  bool get isStale =>
      DateTime.now().difference(fetchedAt) > MarketService._ttl;
}
