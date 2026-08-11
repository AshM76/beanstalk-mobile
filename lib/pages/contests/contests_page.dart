import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notification/notification_service.dart';
import '../../services/api/api_service.dart';
import '../../services/contest/contest_service.dart';
import '../../utils/contest_color.dart';
import '../../widgets/cash_advisor_sheet.dart';
import '../stocks/stock_search_page.dart';

final _contestCurrency = NumberFormat('#,##0', 'en_US');

// ── Palette ───────────────────────────────────────────────────────────────────
// Re-export the shared contest palette under the local aliases this file has
// historically used so the rest of the file (and the Contest.fromApi mapping
// below) stays untouched.

const _kGreen = kContestGreen;

// ── Models ────────────────────────────────────────────────────────────────────

enum ContestStatus { upcoming, active, ended }

class Contest {
  final String id;
  final String title;
  final String description;
  final String prize;
  final int baseParticipants;   // seed from mock data
  final int maxParticipants;
  final DateTime startDate;
  final DateTime endDate;
  final ContestStatus status;
  final List<LeaderboardEntry> leaderboard;
  final String emoji;
  final List<String> rules;
  final Color color;
  // Sponsor & media
  final String? imageUrl;
  final String? sponsorName;
  final String? sponsorLogoUrl;
  final String? sponsorTagline;
  final int startingCash;

  const Contest({
    required this.id,
    required this.title,
    required this.description,
    required this.prize,
    required this.baseParticipants,
    required this.maxParticipants,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.leaderboard,
    required this.emoji,
    required this.rules,
    required this.color,
    this.imageUrl,
    this.sponsorName,
    this.sponsorLogoUrl,
    this.sponsorTagline,
    this.startingCash = 10000,
  });

  String get timeLabel {
    if (status == ContestStatus.ended) return 'Ended';
    if (status == ContestStatus.upcoming) {
      final d = startDate.difference(DateTime.now());
      if (d.inDays > 0) return 'Starts in ${d.inDays}d';
      return 'Starts soon';
    }
    final r = endDate.difference(DateTime.now());
    if (r.isNegative) return 'Ended';
    if (r.inDays > 0) return '${r.inDays}d left';
    if (r.inHours > 0) return '${r.inHours}h left';
    return '${r.inMinutes}m left';
  }

  /// Build a Contest from a backend payload (see src/controllers/contest.controller.js).
  /// Backend status values: 'draft' | 'active' | 'concluded' | 'cancelled'.
  ///   draft    → upcoming
  ///   active   → active
  ///   concluded/cancelled → ended
  /// UI-only fields (leaderboard, emoji, color, rules) are filled with safe
  /// defaults; they're populated by later endpoints (leaderboard, sponsors)
  /// when those land.
  factory Contest.fromApi(Map<String, dynamic> m) {
    DateTime parseDt(Object? v, {DateTime? fallback}) {
      if (v is String && v.isNotEmpty) {
        return DateTime.tryParse(v) ?? (fallback ?? DateTime.now());
      }
      if (v is Map && v['value'] is String) {
        return DateTime.tryParse(v['value'] as String) ?? (fallback ?? DateTime.now());
      }
      return fallback ?? DateTime.now();
    }

    int parseInt(Object? v, int fallback) {
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    double parseDouble(Object? v, double fallback) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? fallback;
      return fallback;
    }

    final rawStatus = (m['status'] as String?) ?? 'draft';
    final status = switch (rawStatus) {
      'active' => ContestStatus.active,
      'concluded' || 'cancelled' => ContestStatus.ended,
      _ => ContestStatus.upcoming,
    };

    // Build a readable prize string from the prizes[] array (first prize).
    final prizes = (m['prizes'] as List?) ?? const [];
    String prize = '—';
    if (prizes.isNotEmpty && prizes.first is Map) {
      final p = (prizes.first as Map).cast<String, dynamic>();
      prize = (p['prize_value'] as String?) ??
          (p['prize_description'] as String?) ??
          '—';
    }

    // Deterministic accent color per contest so the UI stays stable across
    // refreshes. Shared with the dashboard switcher and stock-detail picker
    // via utils/contest_color.dart so the same hue follows the contest
    // everywhere it's surfaced.
    final id = (m['contest_id'] as String?) ?? '';
    final color = contestColorFor(id);

    return Contest(
      id: id,
      title: (m['name'] as String?) ?? 'Contest',
      description: (m['description'] as String?) ?? '',
      prize: prize,
      // GET /api/contests returns total enrollment under `participants` (an
      // int = sum of all rankings across every age group). Older builds read
      // `current_participants`, which the list endpoint doesn't send — that's
      // why cards showed "0 players". Prefer `participants`, fall back to the
      // legacy key, then 0.
      baseParticipants:
          parseInt(m['participants'] ?? m['current_participants'], 0),
      maxParticipants: parseInt(m['max_participants'], 100),
      startDate: parseDt(m['start_date']),
      endDate: parseDt(m['end_date'], fallback: DateTime.now().add(const Duration(days: 30))),
      status: status,
      leaderboard: const [], // populated by future leaderboard endpoint
      emoji: '🏆',
      rules: ((m['rules'] as String?) ?? '')
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList(),
      color: color,
      startingCash: parseDouble(m['starting_balance'], 10000).toInt(),
      sponsorName: m['sponsor_name'] as String?,
      sponsorLogoUrl: m['sponsor_logo_url'] as String?,
      sponsorTagline: m['sponsor_tagline'] as String?,
    );
  }
}

class LeaderboardEntry {
  final int rank;
  final String username;
  final String avatarEmoji;
  final double returnPercent;
  final double portfolioValue;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.username,
    required this.avatarEmoji,
    required this.returnPercent,
    required this.portfolioValue,
    this.isCurrentUser = false,
  });

  /// Parse a single ranking entry from the backend leaderboard payload
  /// (one element of `leaderboards.<age_group>.rankings`). The `rank` here is
  /// the per-group rank as the backend returned it; callers that merge age
  /// groups re-rank the combined list (see [copyWith]).
  ///
  /// Backend data-quality note: `username` currently comes back as a raw UUID.
  /// We don't fix that server-side tonight — instead [_displayName] renders a
  /// friendly "Player abc123…" fallback so the board doesn't read like a
  /// database dump.
  factory LeaderboardEntry.fromJson(
    Map<String, dynamic> j, {
    String? currentUserId,
  }) {
    final userId = (j['user_id'] as String?) ?? '';
    final rawName = (j['username'] as String?) ?? '';

    double toD(Object? v) =>
        v is num ? v.toDouble() : double.tryParse('$v') ?? 0.0;
    int toI(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

    return LeaderboardEntry(
      rank: toI(j['rank']),
      username: _displayName(rawName, userId),
      avatarEmoji: _avatarEmojiFor(userId.isNotEmpty ? userId : rawName),
      returnPercent: toD(j['return_percent']),
      portfolioValue: toD(j['portfolio_value']),
      isCurrentUser:
          currentUserId != null && userId.isNotEmpty && userId == currentUserId,
    );
  }

  LeaderboardEntry copyWith({int? rank}) => LeaderboardEntry(
        rank: rank ?? this.rank,
        username: username,
        avatarEmoji: avatarEmoji,
        returnPercent: returnPercent,
        portfolioValue: portfolioValue,
        isCurrentUser: isCurrentUser,
      );

  /// A username that looks like a UUID (has hyphens and is 32+ chars) is a raw
  /// backend id, not a real handle — show "Player abc123…" instead.
  static bool _looksLikeUuid(String s) => s.contains('-') && s.length >= 32;

  static String _displayName(String rawName, String userId) {
    if (rawName.isNotEmpty && !_looksLikeUuid(rawName)) return rawName;
    final seed = userId.isNotEmpty ? userId : rawName;
    final short = seed.replaceAll('-', '');
    if (short.isEmpty) return 'Player';
    return 'Player ${short.substring(0, short.length < 6 ? short.length : 6)}…';
  }

  /// Deterministic avatar emoji so a given player keeps the same face across
  /// refreshes without the backend supplying one.
  static String _avatarEmojiFor(String seed) {
    const faces = ['🦊', '🐻', '🐼', '🦁', '🐯', '🐨', '🐸', '🦉', '🐧', '🦄'];
    if (seed.isEmpty) return faces.first;
    var h = 0;
    for (final c in seed.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return faces[h % faces.length];
  }
}

class ChatMessage {
  final String username;
  final String text;
  final DateTime time;
  final bool isCurrentUser;

  const ChatMessage({
    required this.username,
    required this.text,
    required this.time,
    required this.isCurrentUser,
  });

  Map<String, dynamic> toJson() => {
    'u': username, 't': text,
    'ts': time.millisecondsSinceEpoch, 'me': isCurrentUser,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
    username:      j['u'] as String,
    text:          j['t'] as String,
    time:          DateTime.fromMillisecondsSinceEpoch(j['ts'] as int),
    isCurrentUser: j['me'] as bool? ?? false,
  );
}


// ── SharedPreferences helpers ─────────────────────────────────────────────────

String _joinKey(String id)     => 'contest_joined_$id';
String _notifyKey(String id)   => 'contest_notify_$id';
String _partKey(String id)     => 'contest_participants_$id';
String _chatKey(String id)     => 'contest_chat_$id';

// ── Contests Page ─────────────────────────────────────────────────────────────

class ContestsPage extends StatefulWidget {
  const ContestsPage({super.key});
  @override
  State<ContestsPage> createState() => _ContestsPageState();
}

class _ContestsPageState extends State<ContestsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  // Remote contest list (populated by GET /api/contests).
  List<Contest> _contests = const [];
  bool _loadError = false;
  String? _loadErrorMessage;

  // Client-side state.
  //   _joined       — set of contest_ids the user has joined (backend source of truth;
  //                   SharedPreferences holds a cache so the detail page's existing
  //                   reads of 'contest_joined_<id>' continue to work).
  //   _notified     — local-only reminder flags (no backend equivalent yet).
  //   _participants — per-contest participant count, updated from API responses and
  //                   optimistically bumped on a successful join.
  final Set<String> _joined   = {};
  final Set<String> _notified = {};
  final Map<String, int> _participants = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _loadState();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadState() async {
    final api = ApiService();
    final r = await api.getContests();

    if (!r.isOk) {
      if (!mounted) return;
      setState(() {
        _loaded = true;
        _loadError = true;
        _loadErrorMessage = r.error;
      });
      return;
    }

    final contests = r.data!
        .map((m) {
          try {
            return Contest.fromApi(m);
          } catch (_) {
            return null;
          }
        })
        .whereType<Contest>()
        .toList();

    // Reconstruct client-side caches from SharedPreferences (only for notify
    // flags — join state gets hydrated from the contests list below).
    final p = await SharedPreferences.getInstance();
    final notified = <String>{};
    final joined   = <String>{};
    final parts    = <String, int>{};
    for (final c in contests) {
      if (p.getBool(_notifyKey(c.id)) == true) notified.add(c.id);
      if (p.getBool(_joinKey(c.id)) == true)   joined.add(c.id);
      parts[c.id] = c.baseParticipants; // current_participants from the API
    }

    if (!mounted) return;
    setState(() {
      _contests = contests;
      _joined
        ..clear()
        ..addAll(joined);
      _notified
        ..clear()
        ..addAll(notified);
      _participants
        ..clear()
        ..addAll(parts);
      _loaded = true;
      _loadError = false;
      _loadErrorMessage = null;
    });
  }

  Future<void> _join(Contest c) async {
    // The backend has no "leave" endpoint yet and contest joins carry a real
    // portfolio side-effect, so this is a one-way operation. If already
    // joined, no-op.
    if (_joined.contains(c.id)) return;

    // Age group is required by POST /api/contests/:id/join. Onboarding stores
    // the display label (e.g. 'High School', 'Young Professional') under
    // 'profile_age_group'; the backend expects its snake_case enum
    // ('high_school' | 'college' | 'adults'). Translate here, and fall back to
    // 'adults' when the user never completed onboarding or stored an unknown
    // value — 'adults' is the most permissive bucket and is always in a
    // contest's age_groups by default.
    final prefs = await SharedPreferences.getInstance();
    final storedAge = prefs.getString('profile_age_group') ?? '';
    final ageGroup = switch (storedAge) {
      'High School'         => 'high_school',
      'College'             => 'college',
      'Young Professional'  => 'adults',
      'Adult'               => 'adults',
      _                     => 'adults',
    };

    final api = ApiService();
    final r = await api.joinContest(api.currentUserId, c.id, ageGroup: ageGroup);
    if (!mounted) return;

    if (!r.isOk) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not join: ${r.error ?? "unknown error"}'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }

    // The backend's joinContest handler creates an isolated contest portfolio
    // via portfolioService.createPortfolio('contest', contestId), so no
    // second API call is needed here. Update local cache + UI state.
    final p = await SharedPreferences.getInstance();
    await p.setBool(_joinKey(c.id), true);
    final current = _participants[c.id] ?? c.baseParticipants;
    await p.setInt(_partKey(c.id), current + 1);
    await NotificationService.addForContestJoin(c.title);

    if (!mounted) return;
    setState(() {
      _joined.add(c.id);
      _participants[c.id] = current + 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Joined "${c.title}"! Good luck 🌱'),
      backgroundColor: _kGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _toggleNotify(Contest c) async {
    HapticFeedback.lightImpact();
    final p         = await SharedPreferences.getInstance();
    final notifying = !_notified.contains(c.id);
    await p.setBool(_notifyKey(c.id), notifying);
    if (!mounted) return;
    setState(() {
      if (notifying) _notified.add(c.id); else _notified.remove(c.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(notifying
          ? '🔔 You\'ll be notified when "${c.title}" starts'
          : '🔕 Notifications off for "${c.title}"'),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _openDetail(Contest c) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContestDetailPage(
          contest:      c,
          joined:       _joined.contains(c.id),
          notified:     _notified.contains(c.id),
          participants: _participants[c.id] ?? c.baseParticipants,
          onJoinToggle: () => _join(c),
          onNotifyToggle: () => _toggleNotify(c),
        ),
      ),
    ).then((_) => _loadState()); // re-sync on return
  }

  List<Contest> _byStatus(ContestStatus s) =>
      _contests.where((c) => c.status == s).toList();

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: _kGreen,
          foregroundColor: Colors.white,
          title: const Text('Contests',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text(
                  'Could not load contests\n${_loadErrorMessage ?? ""}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _loaded = false;
                      _loadError = false;
                    });
                    _loadState();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: _kGreen,
        foregroundColor: Colors.white,
        title: const Text('Contests',
            style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Ended'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _ContestList(
            contests:     _byStatus(ContestStatus.active),
            joined:       _joined,
            notified:     _notified,
            participants: _participants,
            onJoin:       _join,
            onNotify:     null,
            onTap:        _openDetail,
          ),
          _ContestList(
            contests:     _byStatus(ContestStatus.upcoming),
            joined:       _joined,
            notified:     _notified,
            participants: _participants,
            onJoin:       null,
            onNotify:     _toggleNotify,
            onTap:        _openDetail,
          ),
          _ContestList(
            contests:     _byStatus(ContestStatus.ended),
            joined:       _joined,
            notified:     _notified,
            participants: _participants,
            onJoin:       null,
            onNotify:     null,
            onTap:        _openDetail,
          ),
        ],
      ),
    );
  }
}

// ── Contest List ──────────────────────────────────────────────────────────────

class _ContestList extends StatelessWidget {
  final List<Contest> contests;
  final Set<String> joined;
  final Set<String> notified;
  final Map<String, int> participants;
  final Future<void> Function(Contest)? onJoin;
  final Future<void> Function(Contest)? onNotify;
  final void Function(Contest) onTap;

  const _ContestList({
    required this.contests,
    required this.joined,
    required this.notified,
    required this.participants,
    required this.onJoin,
    required this.onNotify,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (contests.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('📭', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('No contests here',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('Check back soon!', style: TextStyle(color: Colors.grey)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contests.length,
      itemBuilder: (_, i) {
        final c = contests[i];
        return _ContestCard(
          contest:      c,
          isJoined:     joined.contains(c.id),
          isNotified:   notified.contains(c.id),
          participants: participants[c.id] ?? c.baseParticipants,
          onJoin:       onJoin != null ? () => onJoin!(c) : null,
          onNotify:     onNotify != null ? () => onNotify!(c) : null,
          onTap:        () => onTap(c),
        );
      },
    );
  }
}

// ── Contest Card ──────────────────────────────────────────────────────────────

class _ContestCard extends StatelessWidget {
  final Contest contest;
  final bool isJoined;
  final bool isNotified;
  final int participants;
  final VoidCallback? onJoin;
  final VoidCallback? onNotify;
  final VoidCallback onTap;

  const _ContestCard({
    required this.contest,
    required this.isJoined,
    required this.isNotified,
    required this.participants,
    required this.onJoin,
    required this.onNotify,
    required this.onTap,
  });

  Color get _color => contest.color;

  Widget _gradientHeader() => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_color, _color.withValues(alpha: 0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      );

  String get _statusLabel {
    switch (contest.status) {
      case ContestStatus.active:   return 'LIVE';
      case ContestStatus.upcoming: return 'SOON';
      case ContestStatus.ended:    return 'ENDED';
    }
  }

  @override
  Widget build(BuildContext context) {
    final fill = (participants / contest.maxParticipants).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Stack(
                children: [
                  // Background: image or gradient. The content column below is
                  // the Stack's only non-positioned child, so it sets the band
                  // height and the background always covers the full band —
                  // the sponsor line can never spill past the colored area.
                  Positioned.fill(
                    child: contest.imageUrl != null &&
                            contest.imageUrl!.isNotEmpty
                        ? Image.network(
                            contest.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _gradientHeader(),
                          )
                        : _gradientHeader(),
                  ),
                  // Scrim so text is always readable
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.25),
                    ),
                  ),
                  // Content — minHeight keeps sponsor-less cards at the
                  // original band height.
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 90),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(contest.emoji, style: const TextStyle(fontSize: 26)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(contest.title,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  const SizedBox(height: 2),
                                  Text(contest.timeLabel,
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(_statusLabel,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        // Sponsor branding — logo in white pill + name
                        if (contest.sponsorName != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (contest.sponsorLogoUrl != null &&
                                  contest.sponsorLogoUrl!.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: contest.sponsorLogoUrl!,
                                    height: 24,
                                    width: 24,
                                    fit: BoxFit.contain,
                                    placeholder: (_, __) =>
                                        const SizedBox(width: 24, height: 24),
                                    errorWidget: (_, __, ___) =>
                                        const Icon(Icons.business,
                                            size: 18, color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ] else ...[
                                const Icon(Icons.verified_rounded,
                                    size: 16, color: Colors.white60),
                                const SizedBox(width: 6),
                              ],
                              Flexible(
                                child: Text(
                                  'Sponsored by ${contest.sponsorName}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Winner banner (ended) ─────────────────────────────────────
            if (contest.status == ContestStatus.ended &&
                contest.leaderboard.isNotEmpty)
              Container(
                color: const Color(0xFFFFF8E1),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text('🥇', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Winner: ${contest.leaderboard.first.username}  '
                        '+${contest.leaderboard.first.returnPercent.toStringAsFixed(1)}%',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFF5D4037)),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Body ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contest.description,
                      style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _InfoChip(icon: '🏆', text: contest.prize),
                      _InfoChip(icon: '👥', text: '$participants/${contest.maxParticipants}'),
                      _InfoChip(
                        icon: '💵',
                        text: '\$${_fmtCash(contest.startingCash)} start',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: fill,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation(_color),
                      minHeight: 5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildAction(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtCash(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    return '$n';
  }

  Widget _buildAction() {
    // Active
    if (contest.status == ContestStatus.active) {
      if (isJoined) {
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.leaderboard, size: 16),
            label: const Text('View Leaderboard'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _color),
              foregroundColor: _color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        );
      }
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onJoin,
          style: ElevatedButton.styleFrom(
            backgroundColor: _color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: const Text('Join Contest', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    // Upcoming
    if (contest.status == ContestStatus.upcoming) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onNotify,
              icon: Icon(isNotified ? Icons.notifications_active : Icons.notifications_outlined, size: 16),
              label: Text(isNotified ? 'Notifying Me' : 'Notify Me'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isNotified ? _color : Colors.white,
                foregroundColor: isNotified ? Colors.white : _color,
                elevation: 0,
                side: BorderSide(color: _color),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _color),
                foregroundColor: _color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text('Details'),
            ),
          ),
        ],
      );
    }

    // Ended
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.grey),
          foregroundColor: Colors.grey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: const Text('View Final Results'),
      ),
    );
  }
}

// ── Contest Detail Page ───────────────────────────────────────────────────────

class ContestDetailPage extends StatefulWidget {
  final Contest contest;
  final bool joined;
  final bool notified;
  final int participants;
  final Future<void> Function() onJoinToggle;
  final Future<void> Function() onNotifyToggle;

  const ContestDetailPage({
    super.key,
    required this.contest,
    required this.joined,
    required this.notified,
    required this.participants,
    required this.onJoinToggle,
    required this.onNotifyToggle,
  });

  @override
  State<ContestDetailPage> createState() => _ContestDetailPageState();
}

class _ContestDetailPageState extends State<ContestDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  late bool _joined;
  late bool _notified;
  late int  _participants;

  @override
  void initState() {
    super.initState();
    _tab          = TabController(length: 3, vsync: this);
    _joined       = widget.joined;
    _notified     = widget.notified;
    _participants = widget.participants;
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Contest get c => widget.contest;
  Color   get _color => c.color;

  Future<void> _handleJoinToggle() async {
    await widget.onJoinToggle();
    if (!mounted) return;
    final p = await SharedPreferences.getInstance();
    setState(() {
      _joined = p.getBool('contest_joined_${c.id}') ?? _joined;
      _participants = p.getInt('contest_participants_${c.id}') ?? _participants;
    });
  }

  Future<void> _handleNotifyToggle() async {
    await widget.onNotifyToggle();
    if (!mounted) return;
    setState(() => _notified = !_notified);
    final p = await SharedPreferences.getInstance();
    _notified = p.getBool('contest_notify_${c.id}') ?? _notified;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: _color,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                overflow: TextOverflow.ellipsis),
            Text(c.timeLabel,
                style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Leaderboard'),
            Tab(text: 'Chat'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Sponsor banner ─────────────────────────────────────────
          if (c.sponsorName != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Color.lerp(_color, Colors.black, 0.15),
              child: Row(
                children: [
                  if (c.sponsorLogoUrl != null &&
                      c.sponsorLogoUrl!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: c.sponsorLogoUrl!,
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                        placeholder: (_, __) =>
                            const SizedBox(width: 30, height: 30),
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.business,
                                size: 22, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sponsored by ${c.sponsorName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (c.sponsorTagline != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            c.sponsorTagline!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // ── Tab content ────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _DetailsTab(contest: c, participants: _participants, color: _color),
                _LeaderboardTab(contest: c, color: _color),
                _ChatTab(contestId: c.id, color: _color),
              ],
            ),
          ),
          // "Trade Stocks" lives in the body (not the bottom bar) so the
          // keyboard inset lifts it with the chat input — it stays visible
          // and tappable while typing. Only shown when the user has joined
          // AND the contest is active: trading in an upcoming contest makes
          // no sense (market hasn't opened for it); trading in an ended
          // contest is a backend 4xx.
          if (_joined && c.status == ContestStatus.active)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, -1))],
              ),
              child: _tradeStocksButton(),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget? _buildBottomBar() {
    if (c.status == ContestStatus.ended) return null;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: c.status == ContestStatus.upcoming
            ? _notifyButton()
            : _joinButton(),
      ),
    );
  }

  Widget _tradeStocksButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {
          debugPrint(
            '[ContestDetail] TradeStocks '
            'contestId=${c.id} contestName=${c.title}',
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StockSearchPage(
                contestId: c.id,
                contestName: c.title,
              ),
            ),
          );
        },
        icon: const Icon(Icons.trending_up),
        label: const Text('Trade Stocks',
            style: TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _joinButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: _joined
          ? OutlinedButton.icon(
              onPressed: _handleJoinToggle,
              icon: const Icon(Icons.exit_to_app, size: 18),
              label: Text('Leave Contest  ·  $_participants joined'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            )
          : ElevatedButton.icon(
              onPressed: _handleJoinToggle,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: Text('Join Contest  ·  $_participants/${c.maxParticipants}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
    );
  }

  Widget _notifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _handleNotifyToggle,
        icon: Icon(_notified ? Icons.notifications_active : Icons.notifications_outlined, size: 18),
        label: Text(_notified ? 'Notifications On — Tap to disable' : 'Notify Me When This Starts'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _notified ? _color : Colors.white,
          foregroundColor: _notified ? Colors.white : _color,
          elevation: 0,
          side: BorderSide(color: _color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

// ── Details Tab ───────────────────────────────────────────────────────────────

class _DetailsTab extends StatelessWidget {
  final Contest contest;
  final int participants;
  final Color color;
  const _DetailsTab({required this.contest, required this.participants, required this.color});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Hero
        Container(
          color: color,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            children: [
              Text(contest.emoji, style: const TextStyle(fontSize: 52)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatPill(label: 'Prize', value: contest.prize),
                  _StatPill(label: 'Players', value: '$participants/${contest.maxParticipants}'),
                ],
              ),
              const SizedBox(height: 12),
              if (contest.status == ContestStatus.active)
                _CountdownTimer(endDate: contest.endDate, color: color),
              if (contest.status == ContestStatus.upcoming)
                _CountdownTimer(endDate: contest.startDate, color: color, label: 'Starts in'),
            ],
          ),
        ),

        // Ask Cash — strategy entry point. Sits directly below the prize/
        // countdown block so it's the first action surface a user sees
        // after taking in the contest's stakes.
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2E1A),
            border: Border.all(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            onTap: () {
              final daysLeft =
                  contest.endDate.difference(DateTime.now()).inDays;
              final timeRem = (contest.status == ContestStatus.ended ||
                      daysLeft <= 0)
                  ? 'ending soon'
                  : daysLeft == 1
                      ? '1 day left'
                      : '$daysLeft days left';
              showCashAdvisor(
                context,
                seedMessage:
                    "I'm in the '${contest.title}' contest with $timeRem. "
                    "What should I buy with my virtual cash to have the "
                    "best shot at climbing the leaderboard?",
              );
            },
            leading: const Text('🌱', style: TextStyle(fontSize: 22)),
            title: const Text(
              'Ask Cash for contest strategy',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            subtitle: const Text(
              'Get AI-powered ideas for this contest',
              style: TextStyle(color: Color(0xFF4ADE80), fontSize: 12),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF2E7D32),
              size: 14,
            ),
          ),
        ),

        // About
        _Section(
          title: 'About this Contest',
          child: Text(contest.description,
              style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.6)),
        ),

        // Winner (ended)
        if (contest.status == ContestStatus.ended && contest.leaderboard.isNotEmpty)
          _Section(
            title: 'Winner',
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
              ),
              child: Row(
                children: [
                  const Text('🥇', style: TextStyle(fontSize: 36)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(contest.leaderboard.first.username,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(
                          '+${contest.leaderboard.first.returnPercent.toStringAsFixed(1)}% return  '
                          '·  \$${_contestCurrency.format(contest.leaderboard.first.portfolioValue)}',
                          style: const TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Rules
        _Section(
          title: 'Rules',
          child: Column(
            children: contest.rules.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, size: 16, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(r, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Countdown Timer ───────────────────────────────────────────────────────────

class _CountdownTimer extends StatefulWidget {
  final DateTime endDate;
  final Color color;
  final String label;
  const _CountdownTimer({
    required this.endDate,
    required this.color,
    this.label = 'Time remaining',
  });

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.endDate.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining = widget.endDate.difference(DateTime.now()));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining.isNegative) {
      return const Text('Contest ended',
          style: TextStyle(color: Colors.white70, fontSize: 13));
    }
    final d  = _remaining.inDays;
    final h  = _remaining.inHours % 24;
    final m  = _remaining.inMinutes % 60;
    final s  = _remaining.inSeconds % 60;

    return Column(
      children: [
        Text(widget.label,
            style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (d > 0) ...[_TimeBox(value: d, unit: 'd'), const SizedBox(width: 6)],
            _TimeBox(value: h, unit: 'h'),
            const SizedBox(width: 6),
            _TimeBox(value: m, unit: 'm'),
            const SizedBox(width: 6),
            _TimeBox(value: s, unit: 's'),
          ],
        ),
      ],
    );
  }
}

class _TimeBox extends StatelessWidget {
  final int value;
  final String unit;
  const _TimeBox({required this.value, required this.unit});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value.toString().padLeft(2, '0'),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text(unit,
                style: const TextStyle(color: Colors.white60, fontSize: 10)),
          ],
        ),
      );
}

// ── Leaderboard Tab ───────────────────────────────────────────────────────────

class _LeaderboardTab extends StatefulWidget {
  final Contest contest;
  final Color color;
  const _LeaderboardTab({required this.contest, required this.color});

  @override
  State<_LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<_LeaderboardTab> {
  Contest get contest => widget.contest;
  Color get color => widget.color;

  bool _loading = true;
  bool _error = false;
  String? _errorMessage;
  List<LeaderboardEntry> _entries = const [];
  DateTime? _asOf;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = false;
      });
    }
    final r = await ContestService.fetchLeaderboard(
      contest.id,
      forceRefresh: forceRefresh,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (r.isOk) {
        _entries = r.data ?? const [];
        _asOf = ContestService.lastUpdatedAt(contest.id);
        _error = false;
        _errorMessage = null;
      } else {
        _error = true;
        _errorMessage = r.error;
      }
    });
  }

  Widget _asOfStamp(DateTime t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.schedule, size: 13, color: Colors.grey),
          const SizedBox(width: 5),
          Text(
            'Standings as of ${_formatAsOf(t)}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// "3:42 PM" for today, "Aug 10, 3:42 PM" otherwise.
  String _formatAsOf(DateTime t) {
    final now = DateTime.now();
    final sameDay =
        t.year == now.year && t.month == now.month && t.day == now.day;
    final h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final mm = t.minute.toString().padLeft(2, '0');
    final ampm = t.hour < 12 ? 'AM' : 'PM';
    final time = '$h12:$mm $ampm';
    if (sameDay) return time;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[t.month - 1]} ${t.day}, $time';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Couldn’t load the leaderboard',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              _errorMessage ?? 'Check your connection and try again.',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => _load(forceRefresh: true),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color),
                foregroundColor: color,
              ),
              child: const Text('Retry'),
            ),
          ]),
        ),
      );
    }

    if (_entries.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('📋', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            contest.status == ContestStatus.upcoming
                ? 'Leaderboard not yet available'
                : 'No rankings yet',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            contest.status == ContestStatus.upcoming
                ? 'Rankings appear once the contest begins'
                : 'Be the first to trade!',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ]),
      );
    }

    final entries = _entries;
    final userEntry = entries.where((e) => e.isCurrentUser).firstOrNull;

    return RefreshIndicator(
      onRefresh: () => _load(forceRefresh: true),
      color: color,
      child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // When these standings were computed — refreshed on open and
        // pull-to-refresh, not a live tick, so say so honestly.
        if (_asOf != null) _asOfStamp(_asOf!),

        // Top 3 podium
        if (entries.length >= 3) _Podium(entries: entries.take(3).toList(), color: color),
        const SizedBox(height: 16),

        // Full list
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: entries.map((e) => _LeaderRow(entry: e, color: color)).toList(),
          ),
        ),

        // Your rank summary (if not in top view)
        if (userEntry != null && userEntry.rank > 10) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Text('You are ranked #${userEntry.rank}',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('+${userEntry.returnPercent.toStringAsFixed(1)}%',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
      ),
    );
  }
}

// ── Podium ────────────────────────────────────────────────────────────────────

class _Podium extends StatelessWidget {
  final List<LeaderboardEntry> entries; // exactly top 3
  final Color color;
  const _Podium({required this.entries, required this.color});

  @override
  Widget build(BuildContext context) {
    // Order: 2nd, 1st, 3rd
    final order = [entries[1], entries[0], entries[2]];
    final heights = [70.0, 90.0, 55.0];
    final medals  = ['🥈', '🥇', '🥉'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (i) {
        final e = order[i];
        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e.avatarEmoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Text(e.username,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center),
              Text('+${e.returnPercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                height: heights[i],
                decoration: BoxDecoration(
                  color: i == 1 ? color : color.withValues(alpha: 0.4),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Center(
                  child: Text(medals[i], style: const TextStyle(fontSize: 24)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Leaderboard Row ───────────────────────────────────────────────────────────

class _LeaderRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final Color color;
  const _LeaderRow({required this.entry, required this.color});

  @override
  Widget build(BuildContext context) {
    final isTop3 = entry.rank <= 3;
    final isUser = entry.isCurrentUser;
    final medals = ['🥇', '🥈', '🥉'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isUser ? color.withValues(alpha: 0.06) : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
          left: isUser
              ? BorderSide(color: color, width: 3)
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: isTop3
                ? Text(medals[entry.rank - 1],
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center)
                : Text('#${entry.rank}',
                    style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                    textAlign: TextAlign.center),
          ),
          const SizedBox(width: 10),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: isUser ? color.withValues(alpha: 0.15) : const Color(0xFFF0F0F0),
              shape: BoxShape.circle,
            ),
            child: Center(
                child: Text(entry.avatarEmoji,
                    style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isUser ? '${entry.username} (You)' : entry.username,
              style: TextStyle(
                  fontWeight: isUser ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                  color: isUser ? color : Colors.black87),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.returnPercent >= 0 ? '+' : ''}${entry.returnPercent.toStringAsFixed(1)}%',
                style: TextStyle(
                    color: entry.returnPercent >= 0
                        ? const Color(0xFF2E7D32)
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              Text('\$${_contestCurrency.format(entry.portfolioValue)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Chat Tab ──────────────────────────────────────────────────────────────────

class _ChatTab extends StatefulWidget {
  final String contestId;
  final Color color;
  const _ChatTab({required this.contestId, required this.color});

  @override
  State<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<_ChatTab> {
  final _ctrl       = TextEditingController();
  final _scroll     = ScrollController();
  List<ChatMessage> _messages = [];
  String _username  = 'You';
  bool   _loading   = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final p       = await SharedPreferences.getInstance();
    _username     = p.getString('profile_display_name') ?? 'You';
    final raw     = p.getString(_chatKey(widget.contestId));
    final msgs    = <ChatMessage>[];
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        msgs.addAll(list.map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e as Map))));
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() { _messages = msgs; _loading = false; });
    _scrollToBottom();
  }

  Future<void> _saveMessages(List<ChatMessage> msgs) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_chatKey(widget.contestId),
        jsonEncode(msgs.map((m) => m.toJson()).toList()));
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    final msg = ChatMessage(
      username: _username,
      text: text,
      time: DateTime.now(),
      isCurrentUser: true,
    );
    setState(() => _messages.add(msg));
    await _saveMessages(_messages);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? const Center(
                  child: Text(
                    'No messages yet — say hi! 👋',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                )
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  itemCount: _messages.length,
                  itemBuilder: (_, i) =>
                      _ChatBubble(msg: _messages[i], color: widget.color),
                ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(12, 8, 12, MediaQuery.of(context).viewInsets.bottom + 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, -1))],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Say something…',
                    hintStyle: const TextStyle(color: Colors.black26),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage msg;
  final Color color;
  const _ChatBubble({required this.msg, required this.color});

  @override
  Widget build(BuildContext context) {
    final isMe = msg.isCurrentUser;
    final timeStr = '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(msg.username,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ),
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Text(msg.username.isNotEmpty ? msg.username[0].toUpperCase() : '?',
                      style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isMe ? color : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft:     const Radius.circular(16),
                      topRight:    const Radius.circular(16),
                      bottomLeft:  Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
                  ),
                  child: Text(msg.text,
                      style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 14)),
                ),
              ),
              if (isMe) const SizedBox(width: 6),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
                top: 3, left: isMe ? 0 : 40, right: isMe ? 4 : 0),
            child: Text(timeStr,
                style: const TextStyle(fontSize: 9, color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      );
}

class _InfoChip extends StatelessWidget {
  final String icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 5),
            Text(text,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      );
}
