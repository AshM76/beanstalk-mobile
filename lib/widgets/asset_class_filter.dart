import 'package:flutter/material.dart';

import '../models/asset_class.dart';

/// Horizontal row of filter chips: All · Stocks · ETFs · Crypto.
/// `selected == null` means "All". Chips use each asset class's brand color
/// as their selected tint so the filter echoes the badges shown on rows.
class AssetClassFilter extends StatelessWidget {
  final AssetClass? selected;
  final ValueChanged<AssetClass?> onChanged;

  const AssetClassFilter({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const options = <({String label, AssetClass? value})>[
      (label: 'All', value: null),
      (label: 'Stocks', value: AssetClass.stock),
      (label: 'ETFs', value: AssetClass.etf),
      (label: 'Crypto', value: AssetClass.crypto),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final opt = options[i];
          final isSelected = selected == opt.value;
          final tint = opt.value?.color ?? const Color(0xFF2E7D32);
          return FilterChip(
            label: Text(opt.label),
            selected: isSelected,
            onSelected: (_) => onChanged(opt.value),
            showCheckmark: false,
            backgroundColor: Colors.white,
            selectedColor: tint.withValues(alpha: 0.15),
            side: BorderSide(
              color: isSelected ? tint : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
            labelStyle: TextStyle(
              color: isSelected ? tint : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}
