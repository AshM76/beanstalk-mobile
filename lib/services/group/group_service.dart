import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/group_models.dart';

// ── GroupService ──────────────────────────────────────────────────────────────

class GroupService {
  static const _kUserGroupsKey   = 'user_groups_v1';
  static const _kPublicGroupsKey = 'public_groups_v1';
  static const _kSeededKey       = 'groups_seeded_v1';

  // ── Seed public groups ─────────────────────────────────────────────────────

  static List<AppGroup> _seedPublicGroups() {
    final now = DateTime.now();
    return [
      AppGroup(
        id: 'pg_tech_bulls',
        name: 'Tech Bulls',
        emoji: '🚀',
        isPublic: true,
        inviteCode: 'TECH42',
        memberCount: 847,
        weeklyTopReturn: 14.2,
        description: 'We live and breathe tech stocks — AAPL, NVDA, MSFT and everything in between. Share ideas, track each other\'s returns, and compete weekly.',
        members: [
          GroupMember(id: 'tb1', displayName: 'AlphaTrader',    portfolioReturn: 14.2),
          GroupMember(id: 'tb2', displayName: 'NvidiaHodler',   portfolioReturn: 11.7),
          GroupMember(id: 'tb3', displayName: 'AppleFanatic',   portfolioReturn:  9.4),
          GroupMember(id: 'tb4', displayName: 'TechBullMike',   portfolioReturn:  7.8),
          GroupMember(id: 'tb5', displayName: 'GrowthGuru',     portfolioReturn:  6.1),
          GroupMember(id: 'tb6', displayName: 'SemiconductorQ', portfolioReturn:  4.3),
          GroupMember(id: 'tb7', displayName: 'CloudChaser',    portfolioReturn:  2.9),
          GroupMember(id: 'tb8', displayName: 'ByteWatcher',    portfolioReturn:  1.1),
        ],
        recentActivity: [
          GroupActivity(id: 'ta1', memberName: 'AlphaTrader',  type: 'trade',   message: 'Bought 10 shares of NVDA at \$875',         timestamp: now.subtract(const Duration(hours: 2))),
          GroupActivity(id: 'ta2', memberName: 'NvidiaHodler', type: 'badge',   message: 'Earned the "XP Hunter" badge 🌟',            timestamp: now.subtract(const Duration(hours: 5))),
          GroupActivity(id: 'ta3', memberName: 'AppleFanatic', type: 'trade',   message: 'Sold 5 shares of AAPL at \$192 (+8.3%)',     timestamp: now.subtract(const Duration(hours: 8))),
          GroupActivity(id: 'ta4', memberName: 'TechBullMike', type: 'lesson',  message: 'Completed "Options Basics" (+90 XP)',         timestamp: now.subtract(const Duration(hours: 12))),
          GroupActivity(id: 'ta5', memberName: 'GrowthGuru',   type: 'contest', message: 'Joined the Spring Trading Cup',              timestamp: now.subtract(const Duration(days: 1))),
          GroupActivity(id: 'ta6', memberName: 'AlphaTrader',  type: 'trade',   message: 'Bought 20 shares of MSFT at \$415',          timestamp: now.subtract(const Duration(days: 1, hours: 3))),
        ],
        challenges: [
          GroupChallenge(
            id: 'tc1', title: 'Best Return This Week 📈',
            description: 'Who can achieve the highest portfolio return from Monday to Friday? Top performer gets bragging rights!',
            createdAt: now.subtract(const Duration(days: 2)),
            endsAt: now.add(const Duration(days: 5)), isActive: true,
          ),
          GroupChallenge(
            id: 'tc2', title: 'AI Stocks Showdown 🤖',
            description: 'Pick ONE AI-related stock and hold it for 2 weeks. Best % gain wins the challenge.',
            createdAt: now.subtract(const Duration(days: 5)),
            endsAt: now.add(const Duration(days: 9)), isActive: true,
          ),
          GroupChallenge(
            id: 'tc3', title: 'March Mega Challenge',
            description: 'Best overall return for the month of March.',
            createdAt: now.subtract(const Duration(days: 45)),
            endsAt: now.subtract(const Duration(days: 15)),
            isActive: false, winner: 'AlphaTrader (+31.2%)',
          ),
        ],
      ),

      AppGroup(
        id: 'pg_value_investors',
        name: 'Value Investors',
        emoji: '💎',
        isPublic: true,
        inviteCode: 'VALUE9',
        memberCount: 234,
        weeklyTopReturn: 4.8,
        description: 'Warren Buffett\'s disciples. We hunt for quality companies at fair prices and hold for the long term. No day trading, no panic selling.',
        members: [
          GroupMember(id: 'vi1', displayName: 'BuffettFan',    portfolioReturn: 4.8),
          GroupMember(id: 'vi2', displayName: 'LongTermLisa',  portfolioReturn: 3.9),
          GroupMember(id: 'vi3', displayName: 'ValueHunter',   portfolioReturn: 3.1),
          GroupMember(id: 'vi4', displayName: 'PatientPete',   portfolioReturn: 2.7),
          GroupMember(id: 'vi5', displayName: 'MoatMaster',    portfolioReturn: 2.2),
          GroupMember(id: 'vi6', displayName: 'DividendDave',  portfolioReturn: 1.8),
        ],
        recentActivity: [
          GroupActivity(id: 'va1', memberName: 'BuffettFan',   type: 'lesson', message: 'Completed "Value vs Growth Investing"',      timestamp: now.subtract(const Duration(hours: 4))),
          GroupActivity(id: 'va2', memberName: 'LongTermLisa', type: 'trade',  message: 'Bought 8 shares of BRK at \$362',            timestamp: now.subtract(const Duration(hours: 9))),
          GroupActivity(id: 'va3', memberName: 'ValueHunter',  type: 'badge',  message: 'Earned "Bookworm" badge 📚',                  timestamp: now.subtract(const Duration(hours: 18))),
          GroupActivity(id: 'va4', memberName: 'PatientPete',  type: 'trade',  message: 'Bought 15 shares of KO at \$61',             timestamp: now.subtract(const Duration(days: 1))),
        ],
        challenges: [
          GroupChallenge(
            id: 'vc1', title: 'Best Dividend Portfolio 💰',
            description: 'Build a portfolio of dividend stocks with the highest combined yield. Share your picks!',
            createdAt: now.subtract(const Duration(days: 3)),
            endsAt: now.add(const Duration(days: 11)), isActive: true,
          ),
          GroupChallenge(
            id: 'vc2', title: 'Find a Hidden Gem 🔍',
            description: 'Identify an undervalued stock and present your thesis to the group. Community votes on the best analysis.',
            createdAt: now.subtract(const Duration(days: 1)),
            endsAt: now.add(const Duration(days: 13)), isActive: true,
          ),
        ],
      ),

      AppGroup(
        id: 'pg_crypto_curious',
        name: 'Crypto Curious',
        emoji: '🪙',
        isPublic: true,
        inviteCode: 'CRYPT0',
        memberCount: 1203,
        weeklyTopReturn: 22.6,
        description: 'Exploring crypto, blockchain, and the future of finance. From Bitcoin basics to DeFi deep-dives. Always learning, always curious.',
        members: [
          GroupMember(id: 'cc1', displayName: 'SatoshiFan',     portfolioReturn: 22.6),
          GroupMember(id: 'cc2', displayName: 'EthereumEllie',  portfolioReturn: 18.1),
          GroupMember(id: 'cc3', displayName: 'DeFiDave',       portfolioReturn: 15.4),
          GroupMember(id: 'cc4', displayName: 'HODLHero',       portfolioReturn: 12.3),
          GroupMember(id: 'cc5', displayName: 'AltcoinAlex',    portfolioReturn:  9.7),
          GroupMember(id: 'cc6', displayName: 'BlockchainBob',  portfolioReturn:  7.2),
          GroupMember(id: 'cc7', displayName: 'NFTNovice',      portfolioReturn:  4.8),
          GroupMember(id: 'cc8', displayName: 'CryptoCarla',    portfolioReturn:  2.1),
          GroupMember(id: 'cc9', displayName: 'TokenTracy',     portfolioReturn: -1.4),
        ],
        recentActivity: [
          GroupActivity(id: 'ca1', memberName: 'SatoshiFan',    type: 'trade',   message: 'Simulated BTC buy at \$68,420',              timestamp: now.subtract(const Duration(hours: 1))),
          GroupActivity(id: 'ca2', memberName: 'EthereumEllie', type: 'lesson',  message: 'Completed "Crypto Fundamentals" (+80 XP)',   timestamp: now.subtract(const Duration(hours: 3))),
          GroupActivity(id: 'ca3', memberName: 'DeFiDave',      type: 'badge',   message: 'Earned "Crypto Curious" badge 🪙',           timestamp: now.subtract(const Duration(hours: 7))),
          GroupActivity(id: 'ca4', memberName: 'HODLHero',      type: 'trade',   message: 'Simulated ETH sell at \$3,820 (+18.4%)',     timestamp: now.subtract(const Duration(hours: 11))),
          GroupActivity(id: 'ca5', memberName: 'AltcoinAlex',   type: 'contest', message: 'Joined the Crypto Challenge',                timestamp: now.subtract(const Duration(hours: 14))),
          GroupActivity(id: 'ca6', memberName: 'SatoshiFan',    type: 'trade',   message: 'Simulated SOL buy at \$164',                 timestamp: now.subtract(const Duration(days: 1))),
        ],
        challenges: [
          GroupChallenge(
            id: 'crc1', title: 'Crypto Cup ☕',
            description: 'Best % return on crypto positions this week. Highest return takes the crown!',
            createdAt: now.subtract(const Duration(days: 1)),
            endsAt: now.add(const Duration(days: 6)), isActive: true,
          ),
          GroupChallenge(
            id: 'crc2', title: 'Altcoin Prediction Game 🎯',
            description: 'Pick an altcoin you think will outperform BTC over the next 7 days. Closest prediction wins!',
            createdAt: now.subtract(const Duration(hours: 6)),
            endsAt: now.add(const Duration(days: 7)), isActive: true,
          ),
        ],
      ),
    ];
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Load the user's personal groups.
  static Future<List<AppGroup>> loadUserGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUserGroupsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return AppGroup.decodeList(raw);
    } catch (_) { return []; }
  }

  /// Load public/discover groups (seeded on first call).
  static Future<List<AppGroup>> loadPublicGroups() async {
    final prefs  = await SharedPreferences.getInstance();
    final seeded = prefs.getBool(_kSeededKey) ?? false;
    final raw    = prefs.getString(_kPublicGroupsKey);
    if (!seeded || raw == null) {
      final groups = _seedPublicGroups();
      await prefs.setString(_kPublicGroupsKey, AppGroup.encodeList(groups));
      await prefs.setBool(_kSeededKey, true);
      return groups;
    }
    try {
      return AppGroup.decodeList(raw);
    } catch (_) {
      return _seedPublicGroups();
    }
  }

  /// Create a new group and add to user's groups.
  static Future<AppGroup> createGroup({
    required String name,
    required String emoji,
    required bool isPublic,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final code  = _generateCode();
    final group = AppGroup(
      id: 'ug_${DateTime.now().millisecondsSinceEpoch}',
      name: name, emoji: emoji, isPublic: isPublic,
      inviteCode: code, memberCount: 1, weeklyTopReturn: 0,
      description: '',
      members: [
        GroupMember(id: 'me', displayName: 'You',
            portfolioReturn: 0, isCurrentUser: true),
      ],
      isJoined: true,
    );
    final groups = await loadUserGroups();
    groups.insert(0, group);
    await prefs.setString(_kUserGroupsKey, AppGroup.encodeList(groups));
    return group;
  }

  /// Join a group by invite code. Searches public groups + user groups.
  /// Returns the joined group, or null if code not found.
  static Future<AppGroup?> joinByCode(String code) async {
    final prefs        = await SharedPreferences.getInstance();
    final publicGroups = await loadPublicGroups();
    final userGroups   = await loadUserGroups();

    AppGroup? found;
    for (final g in [...publicGroups, ...userGroups]) {
      if (g.inviteCode.toUpperCase() == code.toUpperCase()) {
        found = g; break;
      }
    }
    if (found == null) return null;

    // Check not already joined
    if (userGroups.any((g) => g.id == found!.id)) {
      return found; // already a member
    }

    // Add current user as member and bump count
    found.memberCount += 1;
    found.isJoined = true;
    found.members.add(GroupMember(
      id: 'me', displayName: 'You', portfolioReturn: 0, isCurrentUser: true));

    userGroups.insert(0, found);
    await prefs.setString(_kUserGroupsKey, AppGroup.encodeList(userGroups));

    // Update public groups list if it was a public group
    final pubIdx = publicGroups.indexWhere((g) => g.id == found!.id);
    if (pubIdx >= 0) {
      publicGroups[pubIdx] = found;
      await prefs.setString(_kPublicGroupsKey, AppGroup.encodeList(publicGroups));
    }
    return found;
  }

  /// Join a known public group by id.
  static Future<AppGroup> joinPublicGroup(AppGroup g) async {
    final prefs      = await SharedPreferences.getInstance();
    final userGroups = await loadUserGroups();
    if (userGroups.any((ug) => ug.id == g.id)) return g;

    g.memberCount += 1;
    g.isJoined = true;
    g.members.add(GroupMember(
      id: 'me', displayName: 'You', portfolioReturn: 0, isCurrentUser: true));

    userGroups.insert(0, g);
    await prefs.setString(_kUserGroupsKey, AppGroup.encodeList(userGroups));

    final publicGroups = await loadPublicGroups();
    final idx = publicGroups.indexWhere((pg) => pg.id == g.id);
    if (idx >= 0) {
      publicGroups[idx] = g;
      await prefs.setString(_kPublicGroupsKey, AppGroup.encodeList(publicGroups));
    }
    return g;
  }

  /// Leave a group.
  static Future<void> leaveGroup(String groupId) async {
    final prefs      = await SharedPreferences.getInstance();
    final userGroups = await loadUserGroups();
    userGroups.removeWhere((g) => g.id == groupId);
    await prefs.setString(_kUserGroupsKey, AppGroup.encodeList(userGroups));

    // Update public list
    final publicGroups = await loadPublicGroups();
    final idx = publicGroups.indexWhere((g) => g.id == groupId);
    if (idx >= 0) {
      publicGroups[idx].memberCount =
          (publicGroups[idx].memberCount - 1).clamp(0, 999999);
      publicGroups[idx].isJoined = false;
      await prefs.setString(_kPublicGroupsKey, AppGroup.encodeList(publicGroups));
    }
  }

  /// Add a challenge to a group.
  static Future<void> addChallenge({
    required String groupId,
    required String title,
    required String description,
    required DateTime endsAt,
  }) async {
    final prefs      = await SharedPreferences.getInstance();
    final userGroups = await loadUserGroups();
    final idx = userGroups.indexWhere((g) => g.id == groupId);
    if (idx < 0) return;
    userGroups[idx].challenges.insert(0, GroupChallenge(
      id: 'ch_${DateTime.now().millisecondsSinceEpoch}',
      title: title, description: description,
      createdAt: DateTime.now(), endsAt: endsAt,
    ));
    await prefs.setString(_kUserGroupsKey, AppGroup.encodeList(userGroups));
  }

  /// Count how many groups user has joined (across user + public joined).
  static Future<int> joinedCount() async {
    final groups = await loadUserGroups();
    return groups.length;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}
