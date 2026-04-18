import 'package:flutter/material.dart';

import '../models/asset_class.dart';

/// Tiny colored pill that labels a row or header with its asset class.
///
/// Used next to ticker symbols everywhere mixed asset classes surface:
/// search rows, holdings list, stock detail header. Visual spec: 18pt
/// height, 10pt text.
///
/// On white/light rows (default), the background is the asset-class brand
/// color at 15% opacity. On colored headers like the detail-page AppBar,
/// pass [onColoredBackground] to get a solid white background with the
/// brand color as text — preserves contrast when the header and the chip
/// tint would otherwise collide (e.g. green stock chip on green AppBar).
class AssetClassChip extends StatelessWidget {
  final AssetClass assetClass;
  final bool onColoredBackground;

  const AssetClassChip({
    super.key,
    required this.assetClass,
    this.onColoredBackground = false,
  });

  /// Build a chip from a raw backend/JSON asset-class value. Falls back to
  /// [AssetClass.stock] when the value is null or unrecognized — matches
  /// the Holding model migration default so legacy data and unexpected
  /// backend shapes never crash the render.
  factory AssetClassChip.fromRaw(
    Object? raw, {
    Key? key,
    bool onColoredBackground = false,
  }) {
    return AssetClassChip(
      key: key,
      assetClass: AssetClassParse.fromString(raw) ?? AssetClass.stock,
      onColoredBackground: onColoredBackground,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = assetClass.color;
    final bg = onColoredBackground
        ? Colors.white
        : color.withValues(alpha: 0.15);
    return Container(
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        assetClass.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
          height: 1.0,
        ),
      ),
    );
  }
}
