import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../models/group_models.dart';
import '../../services/group/group_service.dart';

// ── Palette ───────────────────────────────────────────────────────────────────

const _kGreen  = Color(0xFF2E7D32);
const _kAccent = Color(0xFFE8F5E9);

// ═════════════════════════════════════════════════════════════════════════════
// GroupsPage — entry point
// ═════════════════════════════════════════════════════════════════════════════

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});
  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<AppGroup> _myGroups      = [];
  List<AppGroup> _publicGroups  = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      GroupService.loadUserGroups(),
      GroupService.loadPublicGroups(),
    ]);
    if (!mounted) return;
    setState(() {
      _myGroups     = List<AppGroup>.from(results[0] as List);
      _publicGroups = List<AppGroup>.from(results[1] as List);
      _loading      = false;
    });
  }

  // ── Create group ──────────────────────────────────────────────────────────

  Future<void> _showCreateSheet() async {
    final result = await showModalBottomSheet<AppGroup>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateGroupSheet(),
    );
    if (result != null) {
      setState(() => _myGroups.insert(0, result));
    }
  }

  // ── Join by code ──────────────────────────────────────────────────────────

  Future<void> _showJoinDialog() async {
    final result = await showDialog<AppGroup>(
      context: context,
      builder: (_) => const _JoinCodeDialog(),
    );
    if (result != null && mounted) {
      setState(() {
        if (!_myGroups.any((g) => g.id == result.id)) {
          _myGroups.insert(0, result);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Joined "${result.emoji} ${result.name}"! 🎉'),
        backgroundColor: _kGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  // ── Join public group ─────────────────────────────────────────────────────

  Future<void> _joinPublic(AppGroup g) async {
    final joined = await GroupService.joinPublicGroup(g);
    if (!mounted) return;
    setState(() {
      final idx = _publicGroups.indexWhere((pg) => pg.id == g.id);
      if (idx >= 0) _publicGroups[idx] = joined;
      if (!_myGroups.any((mg) => mg.id == g.id)) {
        _myGroups.insert(0, joined);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Joined "${g.emoji} ${g.name}"! 🎉'),
      backgroundColor: _kGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _leaveGroup(AppGroup g) async {
    await GroupService.leaveGroup(g.id);
    if (!mounted) return;
    setState(() {
      _myGroups.removeWhere((mg) => mg.id == g.id);
      final idx = _publicGroups.indexWhere((pg) => pg.id == g.id);
      if (idx >= 0) {
        _publicGroups[idx].isJoined    = false;
        _publicGroups[idx].memberCount =
            (_publicGroups[idx].memberCount - 1).clamp(0, 999999);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: _kGreen,
        foregroundColor: Colors.white,
        title: const Text('Groups', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add_outlined),
            tooltip: 'Join with code',
            onPressed: _showJoinDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create group',
            onPressed: _showCreateSheet,
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: 'My Groups${_myGroups.isEmpty ? '' : '  (${_myGroups.length})'}'),
            const Tab(text: 'Discover'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kGreen))
          : TabBarView(
              controller: _tab,
              children: [
                _buildMyGroups(),
                _buildDiscover(),
              ],
            ),
    );
  }

  // ── My Groups tab ─────────────────────────────────────────────────────────

  Widget _buildMyGroups() {
    if (_myGroups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(color: _kAccent, shape: BoxShape.circle),
                child: const Icon(Icons.group_outlined, size: 40, color: _kGreen),
              ),
              const SizedBox(height: 20),
              const Text('No groups yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _kGreen)),
              const SizedBox(height: 10),
              const Text('Create a group or join one with an invite code to start competing with friends.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showJoinDialog,
                      icon: const Icon(Icons.group_add_outlined, size: 18),
                      label: const Text('Join with code'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kGreen,
                        side: const BorderSide(color: _kGreen),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showCreateSheet,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Create'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: _kGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _myGroups.length,
        itemBuilder: (_, i) => _GroupCard(
          group: _myGroups[i],
          isJoined: true,
          onTap: () => _openDetail(_myGroups[i]),
          onJoinToggle: () => _leaveGroup(_myGroups[i]),
        ),
      ),
    );
  }

  // ── Discover tab ──────────────────────────────────────────────────────────

  Widget _buildDiscover() {
    return RefreshIndicator(
      onRefresh: _load,
      color: _kGreen,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 4),
            child: Text('Popular groups to join',
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500)),
          ),
          ..._publicGroups.map((g) {
            final alreadyJoined = _myGroups.any((mg) => mg.id == g.id);
            return _GroupCard(
              group: g,
              isJoined: alreadyJoined,
              onTap: () => _openDetail(g),
              onJoinToggle: alreadyJoined ? () => _leaveGroup(g) : () => _joinPublic(g),
            );
          }),
        ],
      ),
    );
  }

  void _openDetail(AppGroup g) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GroupDetailPage(group: g)),
    ).then((_) => _load());
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// _GroupCard
// ═════════════════════════════════════════════════════════════════════════════

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.isJoined,
    required this.onTap,
    required this.onJoinToggle,
  });

  final AppGroup group;
  final bool isJoined;
  final VoidCallback onTap;
  final VoidCallback onJoinToggle;

  @override
  Widget build(BuildContext context) {
    final ret = group.weeklyTopReturn;
    final retPositive = ret >= 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Emoji avatar
            Container(
              width: 52, height: 52,
              decoration: const BoxDecoration(
                  color: _kAccent, shape: BoxShape.circle),
              child: Center(
                child: Text(group.emoji,
                    style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(group.name,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                      if (!group.isPublic)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Private',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey.shade600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.people_outline, size: 13,
                          color: Colors.grey.shade500),
                      const SizedBox(width: 3),
                      Text('${_fmtNum(group.memberCount)} members',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                      const SizedBox(width: 12),
                      Icon(Icons.trending_up_rounded, size: 13,
                          color: retPositive ? _kGreen : Colors.red),
                      const SizedBox(width: 3),
                      Text(
                        '${retPositive ? '+' : ''}${ret.toStringAsFixed(1)}% leader',
                        style: TextStyle(
                            fontSize: 12,
                            color: retPositive ? _kGreen : Colors.red,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Join / Leave button
            GestureDetector(
              onTap: onJoinToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isJoined ? Colors.white : _kGreen,
                  borderRadius: BorderRadius.circular(20),
                  border: isJoined
                      ? Border.all(color: Colors.grey.shade300)
                      : null,
                ),
                child: Text(
                  isJoined ? 'Leave' : 'Join',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isJoined ? Colors.grey.shade600 : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtNum(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// _CreateGroupSheet
// ═════════════════════════════════════════════════════════════════════════════

class _CreateGroupSheet extends StatefulWidget {
  const _CreateGroupSheet();
  @override
  State<_CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<_CreateGroupSheet> {
  final _nameController = TextEditingController();
  String _selectedEmoji = '🌱';
  bool _isPublic = true;
  bool _creating = false;

  static const _emojis = [
    '🌱','🚀','💎','🪙','📈','🏆','⭐','🔥',
    '💰','🎯','🦁','🐂','🦅','🌍','🏦','💡',
    '🧠','🎓','⚡','🛡️',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _creating = true);
    final group = await GroupService.createGroup(
      name: name, emoji: _selectedEmoji, isPublic: _isPublic);
    if (!mounted) return;
    Navigator.pop(context, group);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 18),
          const Text('Create Group',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          // Name field
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Group name',
              filled: true, fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 18),
          // Emoji picker
          const Text('Choose an emoji',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _emojis.map((e) => GestureDetector(
              onTap: () => setState(() => _selectedEmoji = e),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _selectedEmoji == e ? _kAccent : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: _selectedEmoji == e
                      ? Border.all(color: _kGreen, width: 2) : null,
                ),
                child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
              ),
            )).toList(),
          ),
          const SizedBox(height: 18),
          // Public / Private toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.public_outlined, size: 20, color: Colors.grey),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Public group',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(_isPublic
                          ? 'Anyone can find and join'
                          : 'Invite-only — share your 6-character code',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Switch(
                  value: _isPublic,
                  onChanged: (v) => setState(() => _isPublic = v),
                  activeThumbColor: _kGreen,
                  activeTrackColor: const Color(0xFFA5D6A7),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Create button
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _creating ? null : _create,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGreen, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _creating
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5,
                          color: Colors.white))
                  : Text('Create $_selectedEmoji Group',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// _JoinCodeDialog
// ═════════════════════════════════════════════════════════════════════════════

class _JoinCodeDialog extends StatefulWidget {
  const _JoinCodeDialog();
  @override
  State<_JoinCodeDialog> createState() => _JoinCodeDialogState();
}

class _JoinCodeDialogState extends State<_JoinCodeDialog> {
  final _ctrl   = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _join() async {
    final code = _ctrl.text.trim();
    if (code.length < 4) {
      setState(() => _error = 'Enter a valid 6-character invite code');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final group = await GroupService.joinByCode(code);
    if (!mounted) return;
    if (group == null) {
      setState(() { _error = 'No group found with that code. Try again!'; _loading = false; });
    } else {
      Navigator.pop(context, group);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(children: [
        Text('👥  ', style: TextStyle(fontSize: 22)),
        Text('Join a Group', style: TextStyle(fontWeight: FontWeight.bold)),
      ]),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enter the 6-character invite code shared by your friend.',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 14),
          TextField(
            controller: _ctrl,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 6),
            decoration: InputDecoration(
              hintText: 'XXXXXX',
              hintStyle: TextStyle(color: Colors.grey.shade300, letterSpacing: 6),
              counterText: '',
              filled: true, fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              errorText: _error,
            ),
            onSubmitted: (_) => _join(),
          ),
          // Quick demo codes hint
          const SizedBox(height: 12),
          Text('Try: TECH42 · VALUE9 · CRYPT0',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _join,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kGreen, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _loading
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Join', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// GroupDetailPage
// ═════════════════════════════════════════════════════════════════════════════

class GroupDetailPage extends StatefulWidget {
  const GroupDetailPage({super.key, required this.group});
  final AppGroup group;
  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  late AppGroup _group;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    _tab   = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  void _copyInviteCode() {
    Clipboard.setData(ClipboardData(text: _group.inviteCode));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Invite code "${_group.inviteCode}" copied! 📋'),
      backgroundColor: _kGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _kGreen,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      Text(_group.emoji,
                          style: const TextStyle(fontSize: 56)),
                      const SizedBox(height: 8),
                      Text(_group.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_outline,
                              size: 14, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text('${_group.memberCount} members',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: _copyInviteCode,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.copy_outlined,
                                      size: 12, color: Colors.white70),
                                  const SizedBox(width: 4),
                                  Text(_group.inviteCode,
                                      style: const TextStyle(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          letterSpacing: 1.5)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tab,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: const [
                Tab(text: 'Leaderboard'),
                Tab(text: 'Activity'),
                Tab(text: 'Challenges'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tab,
          children: [
            _LeaderboardTab(members: _group.members),
            _ActivityTab(activities: _group.recentActivity),
            _ChallengesTab(
              group: _group,
              onChallengeAdded: (c) => setState(() => _group.challenges.insert(0, c)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Leaderboard Tab ───────────────────────────────────────────────────────────

class _LeaderboardTab extends StatelessWidget {
  const _LeaderboardTab({required this.members});
  final List<GroupMember> members;

  @override
  Widget build(BuildContext context) {
    final sorted = [...members]
      ..sort((a, b) => b.portfolioReturn.compareTo(a.portfolioReturn));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
      itemCount: sorted.length,
      itemBuilder: (_, i) {
        final m = sorted[i];
        final rank = i + 1;
        final isUser = m.isCurrentUser;
        final ret = m.portfolioReturn;
        final retPositive = ret >= 0;

        String medal = '';
        if (rank == 1) { medal = '🥇'; }
        else if (rank == 2) { medal = '🥈'; }
        else if (rank == 3) { medal = '🥉'; }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser
                ? const Color(0xFFE8F5E9)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: isUser
                ? Border.all(color: _kGreen.withValues(alpha: 0.4), width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4, offset: const Offset(0, 1)),
            ],
          ),
          child: Row(
            children: [
              // Rank
              SizedBox(
                width: 32,
                child: medal.isNotEmpty
                    ? Text(medal, style: const TextStyle(fontSize: 22))
                    : Text('#$rank',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600)),
              ),
              const SizedBox(width: 10),
              // Avatar
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: isUser ? _kAccent : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    m.displayName.isNotEmpty ? m.displayName[0].toUpperCase() : '?',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold,
                        color: isUser ? _kGreen : Colors.grey.shade700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(m.displayName,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600,
                                color: isUser ? _kGreen : const Color(0xFF1A1A1A))),
                        if (isUser) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                                color: _kGreen, borderRadius: BorderRadius.circular(6)),
                            child: const Text('You',
                                style: TextStyle(fontSize: 10, color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Return
              Text(
                '${retPositive ? '+' : ''}${ret.toStringAsFixed(1)}%',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold,
                    color: retPositive ? _kGreen : Colors.red),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Activity Tab ──────────────────────────────────────────────────────────────

class _ActivityTab extends StatelessWidget {
  const _ActivityTab({required this.activities});
  final List<GroupActivity> activities;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(
        child: Text('No activity yet.\nBe the first to make a move! 🚀',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.6)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
      itemCount: activities.length,
      itemBuilder: (_, i) {
        final a = activities[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4, offset: const Offset(0, 1)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(
                    color: _kAccent, shape: BoxShape.circle),
                child: Center(
                    child: Text(a.emoji,
                        style: const TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),
                        children: [
                          TextSpan(text: a.memberName,
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                          const TextSpan(text: '  '),
                          TextSpan(text: a.message),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(_formatTime(a.timestamp),
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    if (diff.inDays == 1)    return 'yesterday';
    return DateFormat('MMM d').format(dt);
  }
}

// ── Challenges Tab ────────────────────────────────────────────────────────────

class _ChallengesTab extends StatelessWidget {
  const _ChallengesTab({
    required this.group,
    required this.onChallengeAdded,
  });
  final AppGroup group;
  final void Function(GroupChallenge) onChallengeAdded;

  @override
  Widget build(BuildContext context) {
    final active   = group.challenges.where((c) => c.isActive).toList();
    final inactive = group.challenges.where((c) => !c.isActive).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
      children: [
        // Create button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showCreateChallenge(context),
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text('Create Challenge'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _kGreen, side: const BorderSide(color: _kGreen),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (active.isNotEmpty) ...[
          _sectionHeader('🔥 Active Challenges'),
          const SizedBox(height: 8),
          ...active.map((c) => _ChallengeCard(challenge: c)),
        ],
        if (inactive.isNotEmpty) ...[
          const SizedBox(height: 14),
          _sectionHeader('✅ Past Challenges'),
          const SizedBox(height: 8),
          ...inactive.map((c) => _ChallengeCard(challenge: c)),
        ],
        if (group.challenges.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Column(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                const Text('No challenges yet',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                        color: Colors.grey)),
                const SizedBox(height: 8),
                Text('Start the first challenge and see who rises to the top!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
              ],
            ),
          ),
      ],
    );
  }

  static Widget _sectionHeader(String label) => Text(label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
          color: Colors.grey));

  void _showCreateChallenge(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateChallengeSheet(
        groupId: group.id,
        onCreated: onChallengeAdded,
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge});
  final GroupChallenge challenge;

  @override
  Widget build(BuildContext context) {
    final daysLeft = challenge.endsAt.difference(DateTime.now()).inDays;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: challenge.isActive
            ? Border.all(color: _kGreen.withValues(alpha: 0.3))
            : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(challenge.title,
                    style: const TextStyle(fontSize: 15,
                        fontWeight: FontWeight.bold)),
              ),
              if (challenge.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _kAccent, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    daysLeft <= 0 ? 'Ends today' : '$daysLeft days left',
                    style: const TextStyle(
                        fontSize: 11, color: _kGreen, fontWeight: FontWeight.w600)),
                )
              else if (challenge.winner != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8)),
                  child: const Text('🏆 Ended',
                      style: TextStyle(fontSize: 11,
                          color: Colors.amber, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(challenge.description,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600,
                  height: 1.4)),
          if (challenge.winner != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🏆  ', style: TextStyle(fontSize: 14)),
                  Text('Winner: ${challenge.winner}',
                      style: const TextStyle(fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFAD6C00))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Create Challenge Sheet ────────────────────────────────────────────────────

class _CreateChallengeSheet extends StatefulWidget {
  const _CreateChallengeSheet({
    required this.groupId,
    required this.onCreated,
  });
  final String groupId;
  final void Function(GroupChallenge) onCreated;
  @override
  State<_CreateChallengeSheet> createState() => _CreateChallengeSheetState();
}

class _CreateChallengeSheetState extends State<_CreateChallengeSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  int _durationDays = 7;
  bool _saving = false;

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    setState(() => _saving = true);
    final endsAt = DateTime.now().add(Duration(days: _durationDays));
    await GroupService.addChallenge(
      groupId: widget.groupId,
      title: title,
      description: _descCtrl.text.trim(),
      endsAt: endsAt,
    );
    if (!mounted) return;
    widget.onCreated(GroupChallenge(
      id: 'ch_${DateTime.now().millisecondsSinceEpoch}',
      title: title, description: _descCtrl.text.trim(),
      createdAt: DateTime.now(), endsAt: endsAt,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 18),
          const Text('New Challenge 🎯',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              hintText: 'Challenge title',
              filled: true, fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Describe the challenge (optional)',
              filled: true, fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text('Duration: ', style: TextStyle(fontWeight: FontWeight.w600)),
              ...([3, 7, 14, 30]).map((d) => GestureDetector(
                onTap: () => setState(() => _durationDays = d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _durationDays == d ? _kGreen : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${d}d',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: _durationDays == d ? Colors.white : Colors.grey.shade700)),
                ),
              )),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGreen, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _saving
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Text('Launch Challenge',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
