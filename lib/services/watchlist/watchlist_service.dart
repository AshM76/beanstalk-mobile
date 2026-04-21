// lib/services/watchlist/watchlist_service.dart
//
// Local-only watchlist store. Holds the set of symbols the user has
// bookmarked from detail pages. Uses SharedPreferences under a single
// key (`watchlist_symbols`) so any surface that wants to read membership
// — the bookmark icon on a detail page today, a Watchlist tab later —
// goes through the same source of truth and can't drift.

import 'package:shared_preferences/shared_preferences.dart';

class WatchlistService {
  static const _key = 'watchlist_symbols';

  static Future<Set<String>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? const <String>[]).toSet();
  }

  static Future<bool> contains(String symbol) async {
    final set = await _load();
    return set.contains(symbol.toUpperCase());
  }

  /// Adds [symbol] to the watchlist. Returns true if it was newly added,
  /// false if it was already present.
  static Future<bool> add(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    final set = (prefs.getStringList(_key) ?? const <String>[]).toSet();
    final added = set.add(symbol.toUpperCase());
    if (added) await prefs.setStringList(_key, set.toList());
    return added;
  }

  /// Removes [symbol] from the watchlist. Returns true if it was present
  /// and removed, false if it wasn't in the list.
  static Future<bool> remove(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    final set = (prefs.getStringList(_key) ?? const <String>[]).toSet();
    final removed = set.remove(symbol.toUpperCase());
    if (removed) await prefs.setStringList(_key, set.toList());
    return removed;
  }
}
