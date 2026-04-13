import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_notification.dart';

// ── NotificationService ───────────────────────────────────────────────────────

class NotificationService {
  static const _kKey         = 'app_notifications';
  static const _kSeededKey   = 'app_notifications_seeded_v2';
  static const _kBadgeState  = 'notif_badge_state'; // comma-separated earned badge ids

  // ── Seed notifications (shown on first launch) ────────────────────────────

  static List<AppNotification> _seed() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'seed_welcome',
        type: AppNotifType.general,
        title: 'Welcome to Beanstalk! 🌱',
        body: 'You\'ve completed onboarding — your investing journey starts now. Explore lessons, join contests, and grow your portfolio!',
        createdAt: now.subtract(const Duration(days: 7)),
        isRead: true,
      ),
      AppNotification(
        id: 'seed_contest',
        type: AppNotifType.contest,
        title: 'Spring Trading Cup is LIVE! 🏆',
        body: 'The Spring Trading Cup has started! Join 842 other traders competing for a \$500 gift card. Starting cash: \$10,000.',
        createdAt: now.subtract(const Duration(days: 5)),
        isRead: true,
      ),
      AppNotification(
        id: 'seed_badge',
        type: AppNotifType.badge,
        title: 'You earned the First Steps badge! 🏅',
        body: 'Congratulations! You completed your first lesson. You\'re on your way to becoming a confident investor!',
        createdAt: now.subtract(const Duration(days: 3)),
        isRead: true,
      ),
      AppNotification(
        id: 'seed_tip',
        type: AppNotifType.general,
        title: 'Cash\'s Tip of the Week 💡',
        body: 'The S&P 500 has never had a 20-year losing period in history. Time in the market beats timing the market every single time.',
        createdAt: now.subtract(const Duration(hours: 36)),
        isRead: false,
      ),
      AppNotification(
        id: 'seed_lesson',
        type: AppNotifType.lesson,
        title: 'New lesson available: Budgeting Basics 💰',
        body: 'Learn the 50/30/20 rule and build a budgeting plan that actually works. Complete it to earn 75 XP!',
        createdAt: now.subtract(const Duration(hours: 6)),
        isRead: false,
      ),
    ];
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Load all notifications; seeds on first run.
  static Future<List<AppNotification>> load() async {
    final prefs  = await SharedPreferences.getInstance();
    final seeded = prefs.getBool(_kSeededKey) ?? false;
    final raw    = prefs.getString(_kKey);

    if (!seeded || raw == null) {
      final list = _seed();
      await _save(list, prefs);
      await prefs.setBool(_kSeededKey, true);
      return list;
    }
    try {
      final list = AppNotification.decodeList(raw);
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      final list = _seed();
      await _save(list, prefs);
      return list;
    }
  }

  /// Prepend a new notification (only if no duplicate id already exists).
  static Future<void> add(AppNotification notif) async {
    final prefs = await SharedPreferences.getInstance();
    final list  = await load();
    if (list.any((n) => n.id == notif.id)) return; // dedup
    list.insert(0, notif);
    await _save(list, prefs);
  }

  static Future<void> markRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list  = await load();
    for (final n in list) {
      if (n.id == id) n.isRead = true;
    }
    await _save(list, prefs);
  }

  static Future<void> markAllRead() async {
    final prefs = await SharedPreferences.getInstance();
    final list  = await load();
    for (final n in list) {
      n.isRead = true;
    }
    await _save(list, prefs);
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list  = await load();
    list.removeWhere((n) => n.id == id);
    await _save(list, prefs);
  }

  static Future<int> unreadCount() async {
    final list = await load();
    return list.where((n) => !n.isRead).length;
  }

  // ── Convenience trigger methods ───────────────────────────────────────────

  /// Call after a lesson is successfully passed.
  static Future<void> addForLessonComplete({
    required String lessonId,
    required String lessonTitle,
    required int xp,
  }) async {
    await add(AppNotification(
      id: 'lesson_done_$lessonId',
      type: AppNotifType.lesson,
      title: 'Lesson complete: $lessonTitle ✅',
      body: 'You passed the quiz and earned $xp XP. Keep it up — every lesson makes you a smarter investor!',
      createdAt: DateTime.now(),
    ));
  }

  /// Call when a badge milestone is hit.
  static Future<void> addForBadge({
    required String badgeId,
    required String badgeEmoji,
    required String badgeTitle,
    required String description,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final earned = (prefs.getString(_kBadgeState) ?? '').split(',').toSet();
    if (earned.contains(badgeId)) return; // already notified
    earned.add(badgeId);
    await prefs.setString(_kBadgeState, earned.join(','));
    await add(AppNotification(
      id: 'badge_$badgeId',
      type: AppNotifType.badge,
      title: 'Badge unlocked: $badgeTitle $badgeEmoji',
      body: 'You earned the "$badgeTitle" badge ($description). Check your profile to see your full collection!',
      createdAt: DateTime.now(),
    ));
  }

  /// Call after first-ever successful buy order.
  static Future<void> addForFirstTrade(String symbol) async {
    await add(AppNotification(
      id: 'first_trade',
      type: AppNotifType.general,
      title: 'You made your first trade! 🎉',
      body: 'Your first \$$symbol order just went through. Welcome to the market — this is where your investing story begins!',
      createdAt: DateTime.now(),
    ));
  }

  /// Call when user joins a contest.
  static Future<void> addForContestJoin(String contestTitle) async {
    final id = 'contest_join_${contestTitle.replaceAll(' ', '_').toLowerCase()}';
    await add(AppNotification(
      id: id,
      type: AppNotifType.contest,
      title: 'You joined: $contestTitle 🏆',
      body: 'You\'re in! Trade smart, watch the leaderboard, and may the best portfolio win. Good luck!',
      createdAt: DateTime.now(),
    ));
  }

  // ── Private ───────────────────────────────────────────────────────────────

  static Future<void> _save(
      List<AppNotification> list, SharedPreferences prefs) async {
    await prefs.setString(_kKey, AppNotification.encodeList(list));
  }
}
