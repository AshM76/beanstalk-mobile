import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum CashMood { happy, excited, encouraging, thinking }

/// Cash — the friendly 🌱 investing guide character.
/// Appears as a speech bubble with his avatar on the left.
class CashBubble extends StatelessWidget {
  final String message;
  final CashMood mood;
  /// Use when the bubble sits on a dark/colored background (result screen etc.)
  final bool darkBackground;

  const CashBubble({
    super.key,
    required this.message,
    this.mood = CashMood.happy,
    this.darkBackground = false,
  });

  Color get _bubbleBg {
    if (darkBackground) return Colors.white.withValues(alpha: 0.15);
    switch (mood) {
      case CashMood.excited:     return const Color(0xFFFFF8E1);
      case CashMood.encouraging: return const Color(0xFFE3F2FD);
      case CashMood.thinking:    return const Color(0xFFF3F8FF);
      case CashMood.happy:       return const Color(0xFFE8F5E9);
    }
  }

  Color get _borderColor {
    if (darkBackground) return Colors.white.withValues(alpha: 0.3);
    switch (mood) {
      case CashMood.excited:     return const Color(0xFFFFCC02);
      case CashMood.encouraging: return const Color(0xFF90CAF9);
      case CashMood.thinking:    return const Color(0xFFBBDEFB);
      case CashMood.happy:       return const Color(0xFFA5D6A7);
    }
  }

  Color get _textColor => darkBackground ? Colors.white : Colors.black87;

  String get _moodLabel => 'Cash';

  String get _svgAsset {
    switch (mood) {
      case CashMood.excited:     return 'assets/images/cash/cash_excited.svg';
      case CashMood.encouraging: return 'assets/images/cash/cash_encouraging.svg';
      case CashMood.thinking:    return 'assets/images/cash/cash_thinking.svg';
      case CashMood.happy:       return 'assets/images/cash/cash_happy.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: darkBackground
                  ? Colors.white.withValues(alpha: 0.2)
                  : const Color(0xFFE8F5E9),
              shape: BoxShape.circle,
              border: Border.all(
                color: darkBackground ? Colors.white54 : const Color(0xFF2E7D32),
                width: 1.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: SvgPicture.asset(
              _svgAsset,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          // Bubble
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _moodLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: darkBackground
                        ? Colors.white70
                        : const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: _bubbleBg,
                    borderRadius: const BorderRadius.only(
                      topLeft:     Radius.circular(2),
                      topRight:    Radius.circular(12),
                      bottomLeft:  Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    border: Border.all(color: _borderColor, width: 1),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: _textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
