import 'package:flutter/material.dart';

/// Deterministic accent color for a given contest_id.
///
/// Keeping this in one place means the contests list, contest detail, the
/// dashboard portfolio switcher, and the stock detail portfolio selector all
/// agree on the same hue for a given contest — so the user sees a consistent
/// visual identity as they move between screens.
///
/// Main-portfolio green is the app's primary brand accent and doubles as the
/// "neutral" fallback when [contestId] is null. It is intentionally excluded
/// from [kContestPalette] so no contest ever collides visually with the main
/// portfolio — otherwise the dashboard switcher and stock-detail picker
/// couldn't distinguish "My Portfolio" from a contest by color alone.

const Color kContestGreen  = Color(0xFF2E7D32); // main portfolio only
const Color kContestBlue   = Color(0xFF1565C0);
const Color kContestPurple = Color(0xFF6A1B9A);
const Color kContestTeal   = Color(0xFF00796B);
const Color kContestOrange = Color(0xFFE65100);

/// Palette used for contest accents. Must not include [kContestGreen].
const List<Color> kContestPalette = [
  kContestBlue,
  kContestPurple,
  kContestTeal,
  kContestOrange,
];

/// Returns the accent color for [contestId], or [kContestGreen] when
/// [contestId] is null (main portfolio).
Color contestColorFor(String? contestId) {
  if (contestId == null || contestId.isEmpty) return kContestGreen;
  return kContestPalette[contestId.hashCode.abs() % kContestPalette.length];
}
