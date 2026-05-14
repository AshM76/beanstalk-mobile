import 'package:flutter_test/flutter_test.dart';

import 'package:beanstalk/models/asset_class.dart';
import 'package:beanstalk/models/holding.dart';

void main() {
  // Shared base payload — tests vary only the asset_class field. Pass
  // include: false to omit the field entirely (see 'missing field' test).
  Map<String, dynamic> payload({Object? assetClass, bool include = true}) => {
        'symbol': 'AAPL',
        'name': 'Apple Inc.',
        'quantity': 1,
        'purchase_price': 100.0,
        if (include) 'asset_class': assetClass,
      };

  group('Holding.fromJson asset_class parsing', () {
    test('lowercase "stock" parses to AssetClass.stock', () {
      expect(
        Holding.fromJson(payload(assetClass: 'stock')).assetClass,
        AssetClass.stock,
      );
    });

    test('uppercase "STOCK" (backend default) parses to AssetClass.stock', () {
      expect(
        Holding.fromJson(payload(assetClass: 'STOCK')).assetClass,
        AssetClass.stock,
      );
    });

    test('"ETF" parses to AssetClass.etf', () {
      expect(
        Holding.fromJson(payload(assetClass: 'ETF')).assetClass,
        AssetClass.etf,
      );
    });

    test('"CRYPTO" parses to AssetClass.crypto', () {
      expect(
        Holding.fromJson(payload(assetClass: 'CRYPTO')).assetClass,
        AssetClass.crypto,
      );
    });

    test('missing asset_class field falls back to AssetClass.stock', () {
      expect(
        Holding.fromJson(payload(include: false)).assetClass,
        AssetClass.stock,
      );
    });

    test('unrecognized value falls back to AssetClass.stock', () {
      expect(
        Holding.fromJson(payload(assetClass: 'garbage_value')).assetClass,
        AssetClass.stock,
      );
    });
  });
}
