import 'package:flutter/material.dart';

// ── Contest ───────────────────────────────────────────────────────────────────

enum ContestStatus { upcoming, active, ended }

class AdminContest {
  final String id;
  String title;
  String description;
  String prize;
  int maxParticipants;
  int participants;
  DateTime startDate;
  DateTime endDate;
  ContestStatus status;
  String? winner;

  // New fields
  String? imageUrl;
  String? sponsorName;
  String? sponsorLogoUrl;
  String? sponsorTagline;
  int startingCash;
  String rules;
  String allowedStocks;
  String entryRequirement;

  AdminContest({
    required this.id,
    required this.title,
    required this.description,
    required this.prize,
    required this.maxParticipants,
    required this.participants,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.winner,
    this.imageUrl,
    this.sponsorName,
    this.sponsorLogoUrl,
    this.sponsorTagline,
    this.startingCash = 10000,
    this.rules = '',
    this.allowedStocks = 'All Stocks',
    this.entryRequirement = 'Open to All',
  });

  Color get statusColor {
    switch (status) {
      case ContestStatus.active:   return const Color(0xFF2E7D32);
      case ContestStatus.upcoming: return const Color(0xFF1565C0);
      case ContestStatus.ended:    return Colors.grey;
    }
  }

  String get statusLabel {
    switch (status) {
      case ContestStatus.active:   return 'Active';
      case ContestStatus.upcoming: return 'Upcoming';
      case ContestStatus.ended:    return 'Ended';
    }
  }
}

// ── Contest Message ───────────────────────────────────────────────────────────

class ContestMessage {
  final String id;
  final String contestId;
  final String title;
  final String body;
  final String target;   // e.g. 'All Participants', 'Top 10', etc.
  final DateTime sentAt;
  final int recipientCount;

  const ContestMessage({
    required this.id,
    required this.contestId,
    required this.title,
    required this.body,
    required this.target,
    required this.sentAt,
    required this.recipientCount,
  });
}

// ── Lesson ────────────────────────────────────────────────────────────────────

class AdminLesson {
  final String id;
  final String title;
  final String category;
  final String level;
  final int xpReward;
  final int completions;
  final int totalAttempts;
  final double avgScore;

  const AdminLesson({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.xpReward,
    required this.completions,
    required this.totalAttempts,
    required this.avgScore,
  });

  double get completionRate =>
      totalAttempts == 0 ? 0 : completions / totalAttempts;
  double get dropOffRate => 1 - completionRate;
}

// ── Notification ──────────────────────────────────────────────────────────────

class SentNotification {
  final String id;
  final String title;
  final String body;
  final String segment;
  final DateTime sentAt;
  final int recipientCount;
  final String notifType;   // 'general' | 'contest' | 'lesson' | 'promo'
  final String? imageBase64; // base64-encoded rich image (may be null)

  const SentNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.segment,
    required this.sentAt,
    required this.recipientCount,
    this.notifType = 'general',
    this.imageBase64,
  });
}

// ── Mock data store ───────────────────────────────────────────────────────────

final _now = DateTime.now();

class MockStore {
  // Contest messages (keyed by contestId)
  static final Map<String, List<ContestMessage>> contestMessages = {
    'c1': [
      ContestMessage(
        id: 'cm1', contestId: 'c1',
        title: 'Spring Trading Cup — Week 1 Update',
        body: 'Great trading this week! Top performer is up +14.2%. Keep it up!',
        target: 'All Participants',
        sentAt: _now.subtract(const Duration(days: 3)),
        recipientCount: 842,
      ),
      ContestMessage(
        id: 'cm2', contestId: 'c1',
        title: 'You haven\'t made a trade yet!',
        body: 'Hey! You joined but haven\'t traded yet. The contest ends in 22 days — jump in!',
        target: 'Haven\'t Traded Yet',
        sentAt: _now.subtract(const Duration(days: 1)),
        recipientCount: 94,
      ),
    ],
    'c2': [],
  };

  // Contests
  static final List<AdminContest> contests = [
    AdminContest(
      id: 'c1', title: 'Spring Trading Cup',
      description: 'Start with \$10,000 and build the highest-returning portfolio over 30 days.',
      prize: '\$500 Gift Card', maxParticipants: 1000, participants: 842,
      startDate: _now.subtract(const Duration(days: 8)),
      endDate: _now.add(const Duration(days: 22)),
      status: ContestStatus.active,
      startingCash: 10000,
      sponsorName: 'Robinhood',
      sponsorTagline: 'Presented by Robinhood',
      rules: 'No short selling allowed.\nAll major US stocks permitted.\nPortfolio must hold at least 3 different stocks.\nNo leverage or margin trading.\nPrices are real-time market data.',
      allowedStocks: 'All Stocks',
      entryRequirement: 'Open to All',
    ),
    AdminContest(
      id: 'c2', title: 'Tech Sector Showdown',
      description: 'Trade only tech stocks for 2 weeks. Best return wins.',
      prize: '\$200 + Trophy Badge', maxParticipants: 500, participants: 394,
      startDate: _now.subtract(const Duration(days: 2)),
      endDate: _now.add(const Duration(days: 12)),
      status: ContestStatus.active,
      startingCash: 10000,
      rules: 'Tech stocks only (NASDAQ listed).\nMinimum 2 trades required.\nNo short selling.\nAll trades final.',
      allowedStocks: 'Tech Only',
      entryRequirement: 'Must Complete 5 Lessons',
    ),
    AdminContest(
      id: 'c3', title: 'Crypto Challenge',
      description: 'Virtual crypto trading contest. Highest portfolio value wins.',
      prize: '\$150 + Crypto Badge', maxParticipants: 200, participants: 12,
      startDate: _now.add(const Duration(days: 3)),
      endDate: _now.add(const Duration(days: 17)),
      status: ContestStatus.upcoming,
      startingCash: 5000,
      rules: 'Crypto assets only.\nStarting balance \$5,000.\nMust complete onboarding to enter.\nNo wash trading.',
      allowedStocks: 'All Stocks',
      entryRequirement: 'Must Complete Onboarding',
    ),
    AdminContest(
      id: 'c5', title: 'ETF Index Challenge',
      description: 'Build the best ETF-only portfolio over 21 days.',
      prize: '\$100 Amazon Voucher', maxParticipants: 300, participants: 0,
      startDate: _now.add(const Duration(days: 10)),
      endDate: _now.add(const Duration(days: 31)),
      status: ContestStatus.upcoming,
      startingCash: 50000,
      sponsorName: 'Fidelity',
      sponsorTagline: 'Presented by Fidelity',
      rules: 'ETFs and index funds only.\nStarting balance \$50,000.\nMaximum 10 positions.\nNo leveraged ETFs.',
      allowedStocks: 'S&P 500 Only',
      entryRequirement: 'Open to All',
    ),
    AdminContest(
      id: 'c4', title: 'March Madness Markets',
      description: 'The completed 30-day challenge. All stocks allowed.',
      prize: '\$250 Gift Card (awarded)', maxParticipants: 1500, participants: 1247,
      startDate: _now.subtract(const Duration(days: 45)),
      endDate: _now.subtract(const Duration(days: 15)),
      status: ContestStatus.ended,
      winner: 'AlphaAlpha (+31.2%)',
      startingCash: 10000,
      rules: 'All stocks permitted.\nNo short selling.\nMinimum 5 trades to qualify.\nReal-time prices.',
      allowedStocks: 'All Stocks',
      entryRequirement: 'Open to All',
    ),
  ];

  // Lessons
  static final List<AdminLesson> lessons = [
    const AdminLesson(id: 'l1',  title: 'What is a Stock?',               category: 'Basics',    level: 'Beginner',     xpReward: 80, completions: 1840, totalAttempts: 2100, avgScore: 82.4),
    const AdminLesson(id: 'l2',  title: 'How Markets Work',               category: 'Basics',    level: 'Beginner',     xpReward: 75, completions: 1620, totalAttempts: 1900, avgScore: 78.1),
    const AdminLesson(id: 'l3',  title: 'Reading a Stock Chart',          category: 'Basics',    level: 'Beginner',     xpReward: 75, completions: 1480, totalAttempts: 1850, avgScore: 74.6),
    const AdminLesson(id: 'l4',  title: 'Bid/Ask & Spreads',              category: 'Basics',    level: 'Beginner',     xpReward: 70, completions: 1210, totalAttempts: 1700, avgScore: 71.2),
    const AdminLesson(id: 'l5',  title: 'Diversification',                category: 'Portfolio', level: 'Beginner',     xpReward: 80, completions: 1340, totalAttempts: 1600, avgScore: 80.5),
    const AdminLesson(id: 'l6',  title: 'Risk vs Return',                 category: 'Portfolio', level: 'Beginner',     xpReward: 80, completions: 1290, totalAttempts: 1580, avgScore: 77.3),
    const AdminLesson(id: 'l7',  title: 'Asset Allocation',               category: 'Portfolio', level: 'Intermediate', xpReward: 80, completions:  980, totalAttempts: 1400, avgScore: 72.8),
    const AdminLesson(id: 'l8',  title: 'ETFs & Mutual Funds',            category: 'Portfolio', level: 'Intermediate', xpReward: 80, completions:  920, totalAttempts: 1350, avgScore: 76.1),
    const AdminLesson(id: 'l9',  title: 'Real Estate Investing 101',      category: 'Portfolio', level: 'Intermediate', xpReward: 85, completions:  870, totalAttempts: 1280, avgScore: 69.4),
    const AdminLesson(id: 'l10', title: 'REITs & Commercial Real Estate', category: 'Portfolio', level: 'Intermediate', xpReward: 80, completions:  740, totalAttempts: 1200, avgScore: 67.9),
    const AdminLesson(id: 'l11', title: 'Dollar-Cost Averaging',          category: 'Strategy',  level: 'Beginner',     xpReward: 75, completions: 1100, totalAttempts: 1420, avgScore: 79.2),
    const AdminLesson(id: 'l12', title: 'Value vs Growth Investing',      category: 'Strategy',  level: 'Intermediate', xpReward: 80, completions:  820, totalAttempts: 1240, avgScore: 73.5),
    const AdminLesson(id: 'l13', title: 'Dividend Investing',             category: 'Strategy',  level: 'Intermediate', xpReward: 75, completions:  790, totalAttempts: 1180, avgScore: 75.8),
    const AdminLesson(id: 'l14', title: 'Technical Analysis Intro',       category: 'Strategy',  level: 'Intermediate', xpReward: 85, completions:  680, totalAttempts: 1120, avgScore: 68.2),
    const AdminLesson(id: 'l15', title: 'Options Basics',                 category: 'Advanced',  level: 'Advanced',     xpReward: 90, completions:  410, totalAttempts:  920, avgScore: 62.4),
    const AdminLesson(id: 'l16', title: 'Short Selling',                  category: 'Advanced',  level: 'Advanced',     xpReward: 85, completions:  380, totalAttempts:  870, avgScore: 61.8),
    const AdminLesson(id: 'l17', title: 'Margin Trading',                 category: 'Advanced',  level: 'Advanced',     xpReward: 85, completions:  350, totalAttempts:  840, avgScore: 60.3),
    const AdminLesson(id: 'l18', title: 'Crypto Fundamentals',            category: 'Crypto',    level: 'Intermediate', xpReward: 80, completions:  920, totalAttempts: 1180, avgScore: 74.1),
    // ── Money Fundamentals (new) ──
    const AdminLesson(id: 'l19', title: 'Budgeting Basics',               category: 'Money',     level: 'Beginner',     xpReward: 75, completions:  640, totalAttempts:  810, avgScore: 84.2),
    const AdminLesson(id: 'l20', title: 'Credit Scores',                  category: 'Money',     level: 'Beginner',     xpReward: 80, completions:  580, totalAttempts:  740, avgScore: 78.9),
    const AdminLesson(id: 'l21', title: 'Taxes 101',                      category: 'Money',     level: 'Beginner',     xpReward: 80, completions:  490, totalAttempts:  690, avgScore: 71.4),
    const AdminLesson(id: 'l22', title: 'Emergency Funds',                category: 'Money',     level: 'Beginner',     xpReward: 70, completions:  620, totalAttempts:  760, avgScore: 86.1),
    const AdminLesson(id: 'l23', title: 'Compound Interest',              category: 'Money',     level: 'Beginner',     xpReward: 80, completions:  710, totalAttempts:  880, avgScore: 82.7),
    const AdminLesson(id: 'l24', title: 'Inflation',                      category: 'Money',     level: 'Beginner',     xpReward: 75, completions:  530, totalAttempts:  700, avgScore: 77.3),
    const AdminLesson(id: 'l25', title: 'Banking Basics',                 category: 'Money',     level: 'Beginner',     xpReward: 70, completions:  590, totalAttempts:  730, avgScore: 83.5),
    const AdminLesson(id: 'l26', title: 'Student Loans',                  category: 'Money',     level: 'Intermediate', xpReward: 80, completions:  460, totalAttempts:  650, avgScore: 74.8),
  ];

  // Sent notifications
  static final List<SentNotification> sentNotifications = [
    SentNotification(
      id: 'n1', title: 'Spring Trading Cup is LIVE! 🌱',
      body: 'The Spring Trading Cup has started. Join now and compete for \$500!',
      segment: 'All Users', sentAt: _now.subtract(const Duration(days: 8)), recipientCount: 4821,
    ),
    SentNotification(
      id: 'n2', title: 'New lesson: Options Basics 🎯',
      body: 'Master options trading with our new advanced lesson. Earn 90 XP!',
      segment: 'College', sentAt: _now.subtract(const Duration(days: 3)), recipientCount: 1240,
    ),
    SentNotification(
      id: 'n3', title: 'Crypto Challenge starts in 3 days 🪙',
      body: 'Get ready for the Crypto Challenge! 200 spots available.',
      segment: 'Young Professional', sentAt: _now.subtract(const Duration(hours: 12)), recipientCount: 1893,
    ),
  ];

  // Dashboard metrics
  static int get totalUsers => 4821;
  static int get activeContests => contests.where((c) => c.status == ContestStatus.active).length;
  static int get lessonsCompletedToday => 287;
  static int get totalTrades => 18432;
  static int get notificationsSent => sentNotifications.fold(0, (s, n) => s + n.recipientCount);

  // User growth (last 7 days, Mon→Sun)
  static const List<double> userGrowth = [4620, 4658, 4690, 4714, 4742, 4780, 4821];
  static const List<String> growthLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // Daily active users (last 7 days)
  static const List<double> dau = [312, 284, 341, 398, 421, 387, 356];

  // Segment counts
  static const Map<String, int> segmentCounts = {
    'All Users':          4821,
    'High School':         842,
    'College':            1240,
    'Young Professional': 1893,
    'Adult':               846,
  };
}
