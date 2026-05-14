// lib/models/holding.dart
//
// Single position in a portfolio. Relocated from portfolio_service.dart so
// callers that only need the model (advanced trade, benchmark) don't have
// to drag the whole service import along. No behavior change vs. the
// original definition — same fields, same constructor, same methods.
//
// PortfolioService._num was private to portfolio_service.dart and is
// referenced from Holding.fromJson. Dart enforces privacy per file, so
// the relocated factory cannot reach the original. The helper is
// duplicated here as a top-level private `_num` with identical body;
// consolidate later if a shared util file emerges.

import 'asset_class.dart';

class Holding {
  final String symbol;
  final String name;
  final double quantity;
  final double avgCost;
  final AssetClass assetClass;

  const Holding({
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.avgCost,
    this.assetClass = AssetClass.stock,
  });

  /// Parse a holding from a backend position payload. The backend writes
  /// uppercase asset-class values (`STOCK`/`ETF`/`CRYPTO`); [AssetClassParse.fromString]
  /// tolerates any case and returns null on unknown input, so this falls
  /// back to [AssetClass.stock] when the field is missing, null, or
  /// unrecognized.
  factory Holding.fromJson(Map<String, dynamic> json) {
    final symbol = (json['symbol'] as String?) ?? '';
    return Holding(
      symbol: symbol,
      name: (json['name'] as String?) ?? symbol,
      quantity: _num(json['quantity']) ?? 0.0,
      avgCost: _num(json['purchase_price']) ?? 0.0,
      assetClass:
          AssetClassParse.fromString(json['asset_class']) ?? AssetClass.stock,
    );
  }

  double marketValue(double currentPrice) => quantity * currentPrice;
  double unrealizedGain(double currentPrice) => (currentPrice - avgCost) * quantity;
}

double? _num(Object? v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}
