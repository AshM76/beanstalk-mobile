import 'package:flutter/material.dart';

/// Canonical asset class for anything tradeable in Beanstalk.
///
/// JSON form is always lowercase (`'stock' | 'etf' | 'crypto'`) so persisted
/// data stays stable, but [fromString] tolerates the backend's uppercase
/// variants (`'STOCK' | 'ETF' | 'CRYPTO'`) and Alpaca's `'us_equity'`.
enum AssetClass { stock, etf, crypto }

extension AssetClassX on AssetClass {
  String get label => switch (this) {
    AssetClass.stock => 'Stock',
    AssetClass.etf => 'ETF',
    AssetClass.crypto => 'Crypto',
  };

  /// Lowercase canonical key used for JSON persistence.
  String get jsonValue => name; // 'stock' | 'etf' | 'crypto'

  Color get color => switch (this) {
    AssetClass.stock => const Color(0xFF22C55E),  // beanstalk green
    AssetClass.etf => const Color(0xFF3B82F6),    // blue
    AssetClass.crypto => const Color(0xFFF59E0B), // orange
  };

  /// Crypto trades 24/7 — used to suppress "market closed" UI.
  bool get isAlwaysOpen => this == AssetClass.crypto;

  /// How many decimals to show in quantity displays.
  int get quantityDecimals => this == AssetClass.crypto ? 6 : 0;

  /// Whether fractional buys are allowed.
  bool get allowsFractional => this == AssetClass.crypto;
}

extension AssetClassParse on AssetClass {
  /// Parse a backend or persisted asset-class string into an [AssetClass].
  ///
  /// Accepts `'stock' | 'etf' | 'crypto'` (canonical), the backend's
  /// uppercase variants, and Alpaca's `'us_equity'` (treated as stock).
  /// Returns null on unknown input so callers can decide their default.
  static AssetClass? fromString(Object? v) {
    if (v == null) return null;
    final s = v.toString().toLowerCase().trim();
    return switch (s) {
      'stock' || 'us_equity' || 'equity' => AssetClass.stock,
      'etf' => AssetClass.etf,
      'crypto' => AssetClass.crypto,
      _ => null,
    };
  }
}
