import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/lesson/lesson_service.dart';
import '../../services/api/api_service.dart';
import '../auth/login_page.dart';
import '../onboarding/onboarding_flow.dart';

// ── Badge model ───────────────────────────────────────────────────────────────

class _Badge {
  final String emoji;
  final String title;
  final String description;
  final bool earned;

  const _Badge({
    required this.emoji,
    required this.title,
    required this.description,
    required this.earned,
  });
}

// ── Page ──────────────────────────────────────────────────────────────────────

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  static const _kXpPerLevel = 500;
  static const _kPrimary    = Color(0xFF2E7D32);
  static const _kAccent     = Color(0xFFE8F5E9);

  int    _totalXp          = 0;
  int    _lessonsCompleted = 0;
  int    _contestsJoined   = 0;
  int    _totalTrades      = 0;
  double _winRate          = 0;
  String _displayName      = 'Investor';
  bool   _loading          = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Called externally (e.g. when switching tabs) to refresh data.
  Future<void> reload() => _load();

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final results = await Future.wait([
      LessonService.loadAll(),
      SharedPreferences.getInstance(),
    ]);
    if (!mounted) return;
    final data  = results[0] as ({Map<String, LessonProgress> progress, int xp, int count});
    final prefs = results[1] as SharedPreferences;
    setState(() {
      _totalXp          = data.xp;
      _lessonsCompleted = data.count;
      _contestsJoined   = prefs.getInt('profile_contests_joined') ?? 0;
      _totalTrades      = prefs.getInt('profile_total_trades') ?? 0;
      _winRate          = prefs.getDouble('profile_win_rate') ?? 0.0;
      // Prefer the user's manually-edited display name; otherwise fall back to
      // the name captured from the auth response (Sarah Chen, etc.).
      _displayName      = prefs.getString('profile_display_name')
          ?? ApiService().userName
          ?? 'Investor';
      _loading          = false;
    });
  }

  // ── Derived ───────────────────────────────────────────────────────────────

  int    get _level       => (_totalXp ~/ _kXpPerLevel) + 1;
  int    get _xpInLevel   => _totalXp % _kXpPerLevel;
  double get _xpProgress  => _xpInLevel / _kXpPerLevel;

  String get _initials {
    final parts = _displayName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (_displayName.length >= 2) return _displayName.substring(0, 2).toUpperCase();
    return _displayName.toUpperCase();
  }

  List<_Badge> get _badges => [
    _Badge(emoji: '🌱', title: 'First Steps',  description: 'Complete 1 lesson',    earned: _lessonsCompleted >= 1),
    _Badge(emoji: '📚', title: 'Bookworm',     description: 'Complete 5 lessons',   earned: _lessonsCompleted >= 5),
    _Badge(emoji: '🎓', title: 'Graduate',     description: 'Complete 10 lessons',  earned: _lessonsCompleted >= 10),
    _Badge(emoji: '🏆', title: 'Master',       description: 'Complete all 26',      earned: _lessonsCompleted >= 26),
    _Badge(emoji: '⭐', title: 'XP Hunter',    description: 'Earn 500 XP',          earned: _totalXp >= 500),
    _Badge(emoji: '💎', title: 'Diamond',      description: 'Earn 1,000 XP',        earned: _totalXp >= 1000),
    _Badge(emoji: '🚀', title: 'Rocket',       description: 'Reach Level 3',        earned: _level >= 3),
    _Badge(emoji: '🔥', title: 'On Fire',      description: 'Reach Level 5',        earned: _level >= 5),
  ];

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  _buildAvatarSection(),
                  const SizedBox(height: 14),
                  _buildXpBar(),
                  const SizedBox(height: 10),
                  _buildStatsGrid(),
                  const SizedBox(height: 10),
                  _buildBadgesShelf(),
                  const SizedBox(height: 10),
                  _buildSettings(),
                ],
              ),
            ),
    );
  }

  // ── Avatar ────────────────────────────────────────────────────────────────

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: _kAccent,
                shape: BoxShape.circle,
                border: Border.all(color: _kPrimary, width: 3),
              ),
              child: Center(
                child: Text(
                  _initials,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: _kPrimary,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: _kPrimary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  'Lv $_level',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _displayName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          'Level $_level Investor  •  $_totalXp XP total',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  // ── XP bar ────────────────────────────────────────────────────────────────

  Widget _buildXpBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level $_level → ${_level + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                '$_xpInLevel / $_kXpPerLevel XP',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _xpProgress,
              minHeight: 8,
              backgroundColor: _kAccent,
              valueColor: const AlwaysStoppedAnimation<Color>(_kPrimary),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_kXpPerLevel - _xpInLevel} XP until Level ${_level + 1}',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ── Stats grid ────────────────────────────────────────────────────────────

  Widget _buildStatsGrid() {
    final cards = [
      _statCard('Lessons Done', '$_lessonsCompleted / 26', Icons.school_rounded),
      _statCard('Contests',     '$_contestsJoined',        Icons.emoji_events_rounded),
      _statCard('Total Trades', '$_totalTrades',           Icons.bar_chart_rounded),
      _statCard('Win Rate',
          _winRate > 0 ? '${_winRate.toStringAsFixed(1)}%' : '—',
          Icons.trending_up_rounded),
    ];
    return Column(
      children: [
        Row(children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 8),
          Expanded(child: cards[1]),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: cards[2]),
          const SizedBox(width: 8),
          Expanded(child: cards[3]),
        ]),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _kAccent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: _kPrimary, size: 13),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
                Text(label,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Badges shelf ──────────────────────────────────────────────────────────

  Widget _buildBadgesShelf() {
    final badges = _badges;
    final earnedCount = badges.where((b) => b.earned).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Badges',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('$earnedCount / ${badges.length}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: badges.map(_badgeTile).toList(),
          ),
        ],
      ),
    );
  }

  Widget _badgeTile(_Badge badge) {
    return Tooltip(
      message: badge.description,
      child: Opacity(
        opacity: badge.earned ? 1.0 : 0.28,
        child: SizedBox(
          width: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: badge.earned ? _kAccent : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: badge.earned
                      ? Border.all(
                          color: _kPrimary.withOpacity(0.4), width: 1.5)
                      : null,
                ),
                child: Center(
                    child: Text(badge.emoji,
                        style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(height: 5),
              Text(
                badge.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 9, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Settings ──────────────────────────────────────────────────────────────

  Widget _buildSettings() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: const Icon(Icons.person_outline_rounded, color: _kPrimary, size: 20),
            title: const Text('Display Name',
                style: TextStyle(fontSize: 13)),
            subtitle: Text(_displayName,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 12)),
            trailing: const Icon(Icons.edit_outlined,
                size: 16, color: Colors.grey),
            onTap: _editDisplayName,
          ),
          const Divider(height: 1, indent: 52, endIndent: 16),
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: const Icon(Icons.play_circle_outline_rounded,
                color: Colors.orange, size: 20),
            title: const Text('Test Onboarding',
                style: TextStyle(fontSize: 13, color: Colors.orange)),
            subtitle: const Text('Dev only — restart welcome flow',
                style: TextStyle(fontSize: 11)),
            onTap: _testOnboarding,
          ),
          const Divider(height: 1, indent: 52, endIndent: 16),
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: const Icon(Icons.delete_outline_rounded,
                color: Colors.red, size: 20),
            title: const Text('Reset Progress',
                style: TextStyle(fontSize: 13, color: Colors.red)),
            onTap: _confirmReset,
          ),
          const Divider(height: 1, indent: 52, endIndent: 16),
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: const Icon(Icons.logout_rounded,
                color: Colors.red, size: 20),
            title: const Text('Sign Out',
                style: TextStyle(fontSize: 13, color: Colors.red)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _logout() async {
    await ApiService().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  Future<void> _testOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('onboarding_complete');
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingFlow()),
      (_) => false,
    );
  }

  Future<void> _editDisplayName() async {
    final controller = TextEditingController(text: _displayName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Display Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 24,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Your name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_display_name', result);
      setState(() => _displayName = result);
    }
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text(
            'This will delete all lesson progress and XP. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await LessonService.clearAll();
      _load();
    }
  }
}
