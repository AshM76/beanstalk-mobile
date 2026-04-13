import 'dart:convert';

// ── Group member ──────────────────────────────────────────────────────────────

class GroupMember {
  final String id;
  final String displayName;
  double portfolioReturn; // percentage
  final bool isCurrentUser;

  GroupMember({
    required this.id,
    required this.displayName,
    required this.portfolioReturn,
    this.isCurrentUser = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'displayName': displayName,
    'portfolioReturn': portfolioReturn, 'isCurrentUser': isCurrentUser,
  };
  factory GroupMember.fromJson(Map<String, dynamic> j) => GroupMember(
    id: j['id'] as String, displayName: j['displayName'] as String,
    portfolioReturn: (j['portfolioReturn'] as num).toDouble(),
    isCurrentUser: j['isCurrentUser'] as bool? ?? false,
  );
}

// ── Group activity ────────────────────────────────────────────────────────────

class GroupActivity {
  final String id;
  final String memberName;
  final String type;    // 'trade' | 'lesson' | 'badge' | 'contest'
  final String message;
  final DateTime timestamp;

  const GroupActivity({
    required this.id, required this.memberName,
    required this.type, required this.message, required this.timestamp,
  });

  String get emoji {
    switch (type) {
      case 'trade':   return '📈';
      case 'lesson':  return '📚';
      case 'badge':   return '🏅';
      case 'contest': return '🏆';
      default:        return '🌱';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'memberName': memberName, 'type': type,
    'message': message, 'timestamp': timestamp.toIso8601String(),
  };
  factory GroupActivity.fromJson(Map<String, dynamic> j) => GroupActivity(
    id: j['id'] as String, memberName: j['memberName'] as String,
    type: j['type'] as String, message: j['message'] as String,
    timestamp: DateTime.parse(j['timestamp'] as String),
  );
}

// ── Group challenge ───────────────────────────────────────────────────────────

class GroupChallenge {
  final String id;
  String title;
  String description;
  final DateTime createdAt;
  final DateTime endsAt;
  bool isActive;
  String? winner;

  GroupChallenge({
    required this.id, required this.title, required this.description,
    required this.createdAt, required this.endsAt,
    this.isActive = true, this.winner,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'description': description,
    'createdAt': createdAt.toIso8601String(), 'endsAt': endsAt.toIso8601String(),
    'isActive': isActive, 'winner': winner,
  };
  factory GroupChallenge.fromJson(Map<String, dynamic> j) => GroupChallenge(
    id: j['id'] as String, title: j['title'] as String,
    description: j['description'] as String,
    createdAt: DateTime.parse(j['createdAt'] as String),
    endsAt: DateTime.parse(j['endsAt'] as String),
    isActive: j['isActive'] as bool? ?? true, winner: j['winner'] as String?,
  );
}

// ── Group ─────────────────────────────────────────────────────────────────────

class AppGroup {
  final String id;
  String name;
  String emoji;
  bool isPublic;
  String inviteCode;
  int memberCount;
  double weeklyTopReturn; // % leader's return this week
  String description;
  List<GroupMember> members;
  List<GroupActivity> recentActivity;
  List<GroupChallenge> challenges;
  bool isJoined;

  AppGroup({
    required this.id,
    required this.name,
    required this.emoji,
    required this.isPublic,
    required this.inviteCode,
    required this.memberCount,
    required this.weeklyTopReturn,
    this.description = '',
    List<GroupMember>? members,
    List<GroupActivity>? recentActivity,
    List<GroupChallenge>? challenges,
    this.isJoined = false,
  })  : members        = members        ?? [],
        recentActivity = recentActivity ?? [],
        challenges     = challenges     ?? [];

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'emoji': emoji, 'isPublic': isPublic,
    'inviteCode': inviteCode, 'memberCount': memberCount,
    'weeklyTopReturn': weeklyTopReturn, 'description': description,
    'members':        members.map((m) => m.toJson()).toList(),
    'recentActivity': recentActivity.map((a) => a.toJson()).toList(),
    'challenges':     challenges.map((c) => c.toJson()).toList(),
    'isJoined': isJoined,
  };

  factory AppGroup.fromJson(Map<String, dynamic> j) => AppGroup(
    id: j['id'] as String, name: j['name'] as String, emoji: j['emoji'] as String,
    isPublic: j['isPublic'] as bool, inviteCode: j['inviteCode'] as String,
    memberCount: j['memberCount'] as int,
    weeklyTopReturn: (j['weeklyTopReturn'] as num).toDouble(),
    description: j['description'] as String? ?? '',
    members: (j['members'] as List<dynamic>?)
        ?.map((e) => GroupMember.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    recentActivity: (j['recentActivity'] as List<dynamic>?)
        ?.map((e) => GroupActivity.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    challenges: (j['challenges'] as List<dynamic>?)
        ?.map((e) => GroupChallenge.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    isJoined: j['isJoined'] as bool? ?? false,
  );

  static String encodeList(List<AppGroup> list) =>
      jsonEncode(list.map((g) => g.toJson()).toList());

  static List<AppGroup> decodeList(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => AppGroup.fromJson(e as Map<String, dynamic>)).toList();
  }
}
