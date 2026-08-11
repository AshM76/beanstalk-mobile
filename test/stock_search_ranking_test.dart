// Verifies the Discover search ranking (issue E): an exact ticker match must
// surface first even when the local catalog is full of substring matches.

import 'package:flutter_test/flutter_test.dart';
import 'package:beanstalk/pages/stocks/stock_search_page.dart';

StockItem _s(String symbol, String name, {String sector = 'Technology'}) =>
    StockItem(
      symbol: symbol,
      name: name,
      price: 100,
      changePercent: 0,
      sector: sector,
    );

void main() {
  group('rankSearchResults', () {
    test('"T" ranks AT&T (exact) above catalog substring matches', () {
      // Local catalog rows first, remote (backend-ranked) appended — the
      // exact match arrives last, mirroring the real merge.
      final merged = [
        _s('MSFT', 'Microsoft Corp.'),
        _s('WMT', 'Walmart Inc.', sector: 'Consumer'),
        _s('TSLA', 'Tesla Inc.', sector: 'Consumer'),
        _s('NFLX', 'Netflix Inc.'),
        _s('T', 'AT&T Inc.'),
      ];
      final ranked = rankSearchResults(merged, 'T');
      expect(ranked.first.symbol, 'T');
      // Tier 1 (symbol starts with T) precedes tier 3 substring matches.
      expect(ranked[1].symbol, 'TSLA');
      // Tier 2: name starts with query comes before pure substring rows.
      expect(ranked.indexWhere((s) => s.symbol == 'TSLA'),
          lessThan(ranked.indexWhere((s) => s.symbol == 'MSFT')));
    });

    test('"A" keeps starts-with symbols above name/substring matches', () {
      final merged = [
        _s('NVDA', 'NVIDIA Corp.'),
        _s('AAPL', 'Apple Inc.'),
        _s('META', 'Meta Platforms'),
        _s('A', 'Agilent Technologies'),
        _s('AMZN', 'Amazon.com Inc.', sector: 'Consumer'),
      ];
      final ranked = rankSearchResults(merged, 'A');
      expect(ranked.first.symbol, 'A'); // exact
      expect(ranked.sublist(1, 3).map((s) => s.symbol),
          containsAll(['AAPL', 'AMZN'])); // starts-with, stable order
      expect(ranked[1].symbol, 'AAPL'); // stable within tier
      expect(ranked.last.symbol, isIn(['NVDA', 'META']));
    });

    test('"AAP" puts exact AAP above AAPL', () {
      final merged = [
        _s('AAPL', 'Apple Inc.'),
        _s('AAP', 'Advance Auto Parts'),
      ];
      final ranked = rankSearchResults(merged, 'AAP');
      expect(ranked.map((s) => s.symbol).toList(), ['AAP', 'AAPL']);
    });

    test('crypto rows rank by the same tiers and are preserved', () {
      final merged = [
        _s('COIN', 'Coinbase Global', sector: 'Financials'),
        _s('BTC', 'Bitcoin', sector: 'CRYPTO'),
        _s('WBTC', 'Wrapped Bitcoin', sector: 'CRYPTO'),
      ];
      final ranked = rankSearchResults(merged, 'BTC');
      expect(ranked.first.symbol, 'BTC'); // exact
      expect(ranked.map((s) => s.symbol), containsAll(['COIN', 'WBTC']));
    });

    test('is case-insensitive and trims the query', () {
      final merged = [
        _s('MSFT', 'Microsoft Corp.'),
        _s('T', 'AT&T Inc.'),
      ];
      expect(rankSearchResults(merged, ' t ').first.symbol, 'T');
    });

    test('empty query and single row pass through untouched', () {
      final merged = [_s('MSFT', 'Microsoft Corp.'), _s('T', 'AT&T Inc.')];
      expect(rankSearchResults(merged, '').first.symbol, 'MSFT');
      expect(rankSearchResults([_s('T', 'AT&T Inc.')], 'T').length, 1);
    });
  });
}
