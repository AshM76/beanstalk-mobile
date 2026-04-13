import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin_models.dart';
import '../widgets/section_header.dart';
import '../widgets/status_badge.dart';

const _kPrimary = Color(0xFF2E7D32);

// ── Allowed stocks & entry requirement options ────────────────────────────────
const _kAllowedStocksOptions = [
  'All Stocks',
  'Tech Only',
  'S&P 500 Only',
  'ETFs Only',
  'Crypto Only',
  'Tech + ETFs',
  'Stocks + ETFs',
  'Custom List',
];

const _kAllowedStocksTickers = <String, String>{
  'Tech Only':     'AAPL, MSFT, GOOGL, NVDA, META, AMZN',
  'ETFs Only':     'SPY, QQQ, VTI, VOO, IWM, GLD',
  'Crypto Only':   'BTC, ETH, SOL, DOGE',
  'Tech + ETFs':   'Tech stocks + SPY, QQQ, VTI, VOO',
  'Stocks + ETFs': 'All US stocks + ETFs (no crypto)',
};

const _kEntryRequirements = [
  'Open to All',
  'Must Complete 5 Lessons',
  'Must Complete Onboarding',
];

// ── Main page ─────────────────────────────────────────────────────────────────

class ContestsAdminPage extends StatefulWidget {
  const ContestsAdminPage({super.key});

  @override
  State<ContestsAdminPage> createState() => _ContestsAdminPageState();
}

class _ContestsAdminPageState extends State<ContestsAdminPage> {
  final _fmt = DateFormat('MMM d, yyyy');
  late final List<AdminContest> _contests;

  @override
  void initState() {
    super.initState();
    _contests = List.from(MockStore.contests);
  }

  void _showCreateDialog() => _showContestDialog(null);
  void _showEditDialog(AdminContest c) => _showContestDialog(c);

  void _showContestDialog(AdminContest? existing) {
    showDialog(
      context: context,
      builder: (_) => _ContestFormDialog(
        existing: existing,
        onSave: (c) {
          setState(() {
            if (existing == null) {
              _contests.insert(0, c);
            } else {
              final i = _contests.indexWhere((x) => x.id == c.id);
              if (i >= 0) _contests[i] = c;
            }
          });
        },
      ),
    );
  }

  void _openDetail(AdminContest c) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ContestDetailPage(
          contest: c,
          onUpdate: (updated) {
            setState(() {
              final i = _contests.indexWhere((x) => x.id == updated.id);
              if (i >= 0) _contests[i] = updated;
            });
          },
        ),
      ),
    );
  }

  void _endEarly(AdminContest c) {
    final winnerCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('End "${c.title}" Early'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This will immediately end the contest and set a winner.'),
            const SizedBox(height: 16),
            TextField(
              controller: winnerCtrl,
              decoration: const InputDecoration(
                labelText: 'Winner username',
                prefixIcon: Icon(Icons.emoji_events_rounded),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(_), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                c.status = ContestStatus.ended;
                c.winner = winnerCtrl.text.trim().isEmpty ? 'TBD' : winnerCtrl.text.trim();
              });
              Navigator.pop(_);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Contest ended'),
                backgroundColor: Colors.red,
              ));
            },
            child: const Text('End Contest', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SectionHeader(title: 'All Contests'),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showCreateDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Contest'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2.5),
                1: FlexColumnWidth(1.2),
                2: FlexColumnWidth(1.0),
                3: FlexColumnWidth(1.2),
                4: FlexColumnWidth(1.4),
                5: FlexColumnWidth(1.4),
                6: FlexColumnWidth(1.8),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  children: ['Contest', 'Status', 'Participants', 'Starting Cash', 'Start', 'End', 'Actions']
                      .map((h) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Text(h,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                          ))
                      .toList(),
                ),
                ..._contests.map((c) => TableRow(
                      decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.grey.shade100))),
                      children: [
                        // Title + prize + sponsor
                        InkWell(
                          onTap: () => _openDetail(c),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: _kPrimary,
                                        decoration: TextDecoration.underline)),
                                Text(c.prize,
                                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                if (c.sponsorName != null)
                                  Text('Sponsor: ${c.sponsorName}',
                                      style: const TextStyle(
                                          color: Color(0xFF1565C0), fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                        // Status
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: StatusBadge(label: c.statusLabel, color: c.statusColor),
                        ),
                        // Participants
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${c.participants}',
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text('/ ${c.maxParticipants}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ),
                        // Starting cash
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '\$${_fmtCash(c.startingCash)}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                        // Start
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(_fmt.format(c.startDate),
                              style: const TextStyle(fontSize: 12)),
                        ),
                        // End + winner
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_fmt.format(c.endDate),
                                  style: const TextStyle(fontSize: 12)),
                              if (c.winner != null)
                                Text('🏆 ${c.winner!}',
                                    style: const TextStyle(
                                        fontSize: 11, color: Color(0xFF2E7D32))),
                            ],
                          ),
                        ),
                        // Actions
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Wrap(
                            spacing: 4,
                            children: [
                              _ActionBtn(
                                  icon: Icons.open_in_new_rounded,
                                  tooltip: 'View detail',
                                  onTap: () => _openDetail(c)),
                              _ActionBtn(
                                  icon: Icons.edit_rounded,
                                  tooltip: 'Edit',
                                  onTap: () => _showEditDialog(c)),
                              if (c.status != ContestStatus.ended)
                                _ActionBtn(
                                    icon: Icons.stop_circle_rounded,
                                    tooltip: 'End early',
                                    color: Colors.red,
                                    onTap: () => _endEarly(c)),
                            ],
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtCash(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    return '$n';
  }
}

// ── Contest Detail Page ───────────────────────────────────────────────────────

class _ContestDetailPage extends StatefulWidget {
  final AdminContest contest;
  final ValueChanged<AdminContest> onUpdate;

  const _ContestDetailPage({required this.contest, required this.onUpdate});

  @override
  State<_ContestDetailPage> createState() => _ContestDetailPageState();
}

class _ContestDetailPageState extends State<_ContestDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  late AdminContest _contest;
  late List<ContestMessage> _messages;

  // Mock participants
  late List<(String name, double ret, double value, bool traded)> _participants;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _contest = widget.contest;
    _messages = List.from(MockStore.contestMessages[_contest.id] ?? []);
    _participants = List.generate(
      _contest.participants.clamp(0, 40),
      (i) {
        final ret = 14.8 - i * 0.62 + (i % 3 == 0 ? -2.1 : 0);
        return (
          'User${1000 + i}',
          double.parse(ret.toStringAsFixed(1)),
          10000 * (1 + ret / 100),
          i > 6, // first 7 haven't traded
        );
      },
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _editContest() {
    showDialog(
      context: context,
      builder: (_) => _ContestFormDialog(
        existing: _contest,
        onSave: (c) {
          setState(() => _contest = c);
          widget.onUpdate(c);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(_contest.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: TabBar(
          controller: _tabs,
          labelColor: _kPrimary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: _kPrimary,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Participants'),
            Tab(text: 'Messaging'),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _editContest,
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: const Text('Edit Contest'),
            style: TextButton.styleFrom(foregroundColor: _kPrimary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _OverviewTab(contest: _contest),
          _ParticipantsTab(
            contest: _contest,
            participants: _participants,
            onMessage: () => _tabs.animateTo(2),
          ),
          _MessagingTab(
            contest: _contest,
            participants: _participants,
            messages: _messages,
            onSend: (msg) => setState(() => _messages.insert(0, msg)),
          ),
        ],
      ),
    );
  }
}

// ── Overview Tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final AdminContest contest;
  const _OverviewTab({required this.contest});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, yyyy');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card with image or gradient
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (contest.imageUrl != null && contest.imageUrl!.isNotEmpty)
                  _loadImage(contest.imageUrl!, height: 140,
                      fallback: () => _gradientHeader(contest))
                else
                  _gradientHeader(contest),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (contest.sponsorName != null) ...[
                        Row(
                          children: [
                            if (contest.sponsorLogoUrl != null &&
                                contest.sponsorLogoUrl!.isNotEmpty) ...[
                              _loadImage(contest.sponsorLogoUrl!, height: 20,
                                  fallback: () => const SizedBox()),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              contest.sponsorTagline ?? 'Presented by ${contest.sponsorName}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1565C0),
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                      Text(contest.description,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black54, height: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard('Status', contest.statusLabel,
                  icon: Icons.circle, iconColor: contest.statusColor),
              _StatCard('Participants',
                  '${contest.participants} / ${contest.maxParticipants}',
                  icon: Icons.group_rounded),
              _StatCard('Starting Cash',
                  '\$${_fmtNum(contest.startingCash)}',
                  icon: Icons.account_balance_wallet_rounded),
              _StatCard('Prize', contest.prize,
                  icon: Icons.emoji_events_rounded, iconColor: Colors.amber),
              _StatCard('Start Date', fmt.format(contest.startDate),
                  icon: Icons.calendar_today_rounded),
              _StatCard('End Date', fmt.format(contest.endDate),
                  icon: Icons.event_rounded),
              _StatCard('Allowed Stocks', contest.allowedStocks,
                  icon: Icons.bar_chart_rounded),
              _StatCard('Entry Req.', contest.entryRequirement,
                  icon: Icons.lock_outline_rounded),
            ],
          ),
          const SizedBox(height: 20),

          // Rules
          if (contest.rules.isNotEmpty) ...[
            const Text('Contest Rules',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: contest.rules
                      .split('\n')
                      .where((r) => r.trim().isNotEmpty)
                      .toList()
                      .asMap()
                      .entries
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  margin: const EdgeInsets.only(right: 10, top: 1),
                                  decoration: BoxDecoration(
                                    color: _kPrimary.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text('${e.key + 1}',
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: _kPrimary,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                Expanded(
                                  child: Text(e.value.trim(),
                                      style: const TextStyle(
                                          fontSize: 13, height: 1.4)),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _loadImage(String src, {required double height, required Widget Function() fallback}) {
    Widget img;
    if (src.startsWith('data:')) {
      try {
        final b64 = src.contains(',') ? src.split(',').last : src;
        img = Image.memory(base64Decode(b64), height: height, fit: BoxFit.cover);
      } catch (_) {
        return fallback();
      }
    } else {
      img = Image.network(src, height: height, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback());
    }
    // SizedBox.expand constrains width to the parent so there is no
    // horizontal overflow when the image sits inside a Card column.
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FittedBox(fit: BoxFit.cover, child: img),
    );
  }

  Widget _gradientHeader(AdminContest c) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_kPrimary, _kPrimary.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(c.title,
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }

  String _fmtNum(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard(this.label, this.value,
      {required this.icon, this.iconColor = _kPrimary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 3),
            Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ── Participants Tab ──────────────────────────────────────────────────────────

class _ParticipantsTab extends StatefulWidget {
  final AdminContest contest;
  final List<(String, double, double, bool)> participants;
  final VoidCallback onMessage;

  const _ParticipantsTab({
    required this.contest,
    required this.participants,
    required this.onMessage,
  });

  @override
  State<_ParticipantsTab> createState() => _ParticipantsTabState();
}

class _ParticipantsTabState extends State<_ParticipantsTab> {
  String _sort = 'rank';

  @override
  Widget build(BuildContext context) {
    final sorted = [...widget.participants];
    if (_sort == 'rank') {
      sorted.sort((a, b) => b.$2.compareTo(a.$2));
    } else if (_sort == 'name') {
      sorted.sort((a, b) => a.$1.compareTo(b.$1));
    }

    final half = (sorted.length / 2).ceil();
    final bottom50 = sorted.skip(half).length;
    final notTraded = sorted.where((p) => !p.$4).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary chips
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _SummaryChip(
                  label: '${widget.contest.participants} Total',
                  icon: Icons.group_rounded,
                  color: _kPrimary),
              _SummaryChip(
                  label: '$notTraded Haven\'t Traded',
                  icon: Icons.hourglass_empty_rounded,
                  color: Colors.orange),
              _SummaryChip(
                  label: '$bottom50 Bottom 50%',
                  icon: Icons.trending_down_rounded,
                  color: Colors.red),
              OutlinedButton.icon(
                onPressed: widget.onMessage,
                icon: const Icon(Icons.send_rounded, size: 15),
                label: const Text('Message Participants'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kPrimary,
                  side: const BorderSide(color: _kPrimary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Table
          Card(
            child: Column(
              children: [
                // Header
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      _TH('Rank', flex: 1),
                      _TH('Username', flex: 3, onTap: () => setState(() => _sort = 'name')),
                      _TH('Return', flex: 2, onTap: () => setState(() => _sort = 'rank')),
                      _TH('Portfolio Value', flex: 2),
                      _TH('Traded?', flex: 1),
                    ],
                  ),
                ),
                ...sorted.asMap().entries.map((e) {
                  final i = e.key;
                  final p = e.value;
                  final positive = p.$2 >= 0;
                  return Container(
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(color: Colors.grey.shade100))),
                    child: Row(
                      children: [
                        _TD(flex: 1, child: _rankBadge(i + 1)),
                        _TD(
                          flex: 3,
                          child: Text(p.$1,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500)),
                        ),
                        _TD(
                          flex: 2,
                          child: Text(
                            '${positive ? '+' : ''}${p.$2.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: positive
                                  ? const Color(0xFF2E7D32)
                                  : Colors.red,
                            ),
                          ),
                        ),
                        _TD(
                          flex: 2,
                          child: Text(
                            '\$${p.$3.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        _TD(
                          flex: 1,
                          child: Icon(
                            p.$4
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 16,
                            color: p.$4 ? _kPrimary : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (widget.contest.participants > sorted.length)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      '… and ${widget.contest.participants - sorted.length} more participants',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rankBadge(int rank) {
    if (rank <= 3) {
      return Text(['🥇', '🥈', '🥉'][rank - 1],
          style: const TextStyle(fontSize: 16));
    }
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text('$rank',
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SummaryChip(
      {required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _TH extends StatelessWidget {
  final String label;
  final int flex;
  final VoidCallback? onTap;

  const _TH(this.label, {required this.flex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Colors.grey)),
              if (onTap != null) ...[
                const SizedBox(width: 3),
                const Icon(Icons.unfold_more_rounded,
                    size: 12, color: Colors.grey),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TD extends StatelessWidget {
  final int flex;
  final Widget child;

  const _TD({required this.flex, required this.child});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: child,
      ),
    );
  }
}

// ── Messaging Tab ─────────────────────────────────────────────────────────────

class _MessagingTab extends StatefulWidget {
  final AdminContest contest;
  final List<(String, double, double, bool)> participants;
  final List<ContestMessage> messages;
  final ValueChanged<ContestMessage> onSend;

  const _MessagingTab({
    required this.contest,
    required this.participants,
    required this.messages,
    required this.onSend,
  });

  @override
  State<_MessagingTab> createState() => _MessagingTabState();
}

class _MessagingTabState extends State<_MessagingTab> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl  = TextEditingController();
  String _target   = 'All Participants';
  double _customPct = 0;
  bool _sending    = false;

  static const _targets = [
    'All Participants',
    'Top 10 Leaderboard',
    'Bottom 50% Performers',
    'Haven\'t Traded Yet',
    'Custom: Above Return %',
    'Custom: Below Return %',
  ];

  int get _recipientCount {
    final p = widget.participants;
    final sorted = [...p]..sort((a, b) => b.$2.compareTo(a.$2));
    switch (_target) {
      case 'All Participants':     return widget.contest.participants;
      case 'Top 10 Leaderboard':   return p.length.clamp(0, 10);
      case 'Bottom 50% Performers':
        return (p.length / 2).ceil();
      case 'Haven\'t Traded Yet':  return p.where((x) => !x.$4).length;
      case 'Custom: Above Return %':
        return sorted.where((x) => x.$2 >= _customPct).length;
      case 'Custom: Below Return %':
        return sorted.where((x) => x.$2 < _customPct).length;
      default:                     return 0;
    }
  }

  Future<void> _send() async {
    if (_titleCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and body are required.')),
      );
      return;
    }
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 700));
    final msg = ContestMessage(
      id: 'cm_${DateTime.now().millisecondsSinceEpoch}',
      contestId: widget.contest.id,
      title: _titleCtrl.text.trim(),
      body: _bodyCtrl.text.trim(),
      target: _target,
      sentAt: DateTime.now(),
      recipientCount: _recipientCount,
    );
    widget.onSend(msg);
    setState(() {
      _titleCtrl.clear();
      _bodyCtrl.clear();
      _target = 'All Participants';
      _sending = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Message sent to ${msg.recipientCount} participants!'),
        backgroundColor: _kPrimary,
      ));
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(builder: (_, constraints) {
        final wide = constraints.maxWidth > 760;
        final composer = _buildComposer();
        final history  = _buildHistory();
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  width: (constraints.maxWidth - 24) * 0.46,
                  child: composer),
              const SizedBox(width: 24),
              Expanded(child: history),
            ],
          );
        }
        return Column(children: [composer, const SizedBox(height: 24), history]);
      }),
    );
  }

  Widget _buildComposer() {
    final needsPct = _target.startsWith('Custom:');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Compose Message',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Target selector
                const Text('Target Audience',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _target,
                  decoration: _dec(hint: ''),
                  items: _targets
                      .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (v) => setState(() => _target = v!),
                ),
                const SizedBox(height: 6),

                // Custom % slider
                if (needsPct) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${_target.contains('Above') ? 'Above' : 'Below'} ${_customPct.toStringAsFixed(0)}% return',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  Slider(
                    value: _customPct,
                    min: -20,
                    max: 30,
                    divisions: 50,
                    activeColor: _kPrimary,
                    onChanged: (v) => setState(() => _customPct = v),
                  ),
                ],

                // Recipient count
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _kPrimary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_recipientCount} recipients',
                    style: const TextStyle(
                        fontSize: 12,
                        color: _kPrimary,
                        fontWeight: FontWeight.w600),
                  ),
                ),

                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 14),

                // Title
                const Text('Message Title',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleCtrl,
                  maxLength: 65,
                  onChanged: (_) => setState(() {}),
                  decoration: _dec(hint: 'e.g. Week 2 Update — You\'re in the lead! 🎯'),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),

                // Body
                const Text('Message Body',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _bodyCtrl,
                  maxLength: 180,
                  maxLines: 4,
                  onChanged: (_) => setState(() {}),
                  decoration: _dec(hint: 'Write your message to participants...'),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),

                // Preview
                if (_titleCtrl.text.isNotEmpty || _bodyCtrl.text.isNotEmpty) ...[
                  _NotifPreview(
                    title: _titleCtrl.text.trim().isEmpty
                        ? 'Beanstalk'
                        : _titleCtrl.text.trim(),
                    body: _bodyCtrl.text.trim().isEmpty
                        ? 'Message preview…'
                        : _bodyCtrl.text.trim(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Send button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(_sending ? 'Sending…' : 'Send to $_target'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistory() {
    final fmt = DateFormat('MMM d, h:mm a');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Message History',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('${widget.messages.length} sent',
                  style: const TextStyle(
                      fontSize: 11, color: _kPrimary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.messages.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No messages sent to this contest yet.',
                    style: TextStyle(color: Colors.grey)),
              ),
            ),
          )
        else
          Card(
            child: Column(
              children: widget.messages.asMap().entries.map((e) {
                final msg = e.value;
                final last = e.key == widget.messages.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: _kPrimary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(Icons.campaign_rounded,
                                color: _kPrimary, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(msg.title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13)),
                                    ),
                                    Text(fmt.format(msg.sentAt),
                                        style: const TextStyle(
                                            fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(msg.body,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black54),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    _MsgChip(
                                        label: msg.target,
                                        color: _kPrimary),
                                    const SizedBox(width: 6),
                                    _MsgChip(
                                        label: '${msg.recipientCount} recipients',
                                        color: const Color(0xFF1565C0)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!last) const Divider(height: 1, indent: 66),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  InputDecoration _dec({required String hint}) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        counterStyle:
            TextStyle(fontSize: 10, color: Colors.grey.shade400),
      );
}

class _MsgChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MsgChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Contest Form Dialog ───────────────────────────────────────────────────────

class _ContestFormDialog extends StatefulWidget {
  final AdminContest? existing;
  final ValueChanged<AdminContest> onSave;

  const _ContestFormDialog({required this.existing, required this.onSave});

  @override
  State<_ContestFormDialog> createState() => _ContestFormDialogState();
}

class _ContestFormDialogState extends State<_ContestFormDialog> {
  final _form     = GlobalKey<FormState>();
  final _fmt      = DateFormat('MMM d, yyyy');

  late final TextEditingController _title;
  late final TextEditingController _desc;
  late final TextEditingController _prize;
  late final TextEditingController _maxParts;
  late final TextEditingController _sponsorName;
  late final TextEditingController _sponsorTagline;
  late final TextEditingController _rules;
  late final TextEditingController _startingCash;
  late final TextEditingController _customStocks;

  // Image state — stored as raw bytes in memory, persisted as base64
  Uint8List? _contestImageBytes;
  Uint8List? _sponsorLogoBytes;
  String? _contestImageWarning;
  String? _sponsorLogoWarning;

  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate   = DateTime.now().add(const Duration(days: 8));
  ContestStatus _status          = ContestStatus.upcoming;
  String _allowedStocks          = 'All Stocks';
  String _entryRequirement       = 'Open to All';

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title          = TextEditingController(text: e?.title ?? '');
    _desc           = TextEditingController(text: e?.description ?? '');
    _prize          = TextEditingController(text: e?.prize ?? '');
    _maxParts       = TextEditingController(text: '${e?.maxParticipants ?? 500}');
    _sponsorName    = TextEditingController(text: e?.sponsorName ?? '');
    _sponsorTagline = TextEditingController(text: e?.sponsorTagline ?? '');
    _rules          = TextEditingController(text: e?.rules ?? '');
    _startingCash   = TextEditingController(text: '${e?.startingCash ?? 10000}');

    // Parse allowed stocks — 'Custom: BTC, ETH' → dropdown='Custom List', tickers='BTC, ETH'
    final existingStocks = e?.allowedStocks ?? 'All Stocks';
    if (existingStocks.startsWith('Custom:')) {
      _allowedStocks = 'Custom List';
      _customStocks  = TextEditingController(
          text: existingStocks.substring('Custom: '.length).trim());
    } else {
      _allowedStocks = _kAllowedStocksOptions.contains(existingStocks)
          ? existingStocks
          : 'All Stocks';
      _customStocks = TextEditingController();
    }

    // Decode existing base64 images if present
    if (e?.imageUrl?.startsWith('data:') == true) {
      try {
        _contestImageBytes = base64Decode(e!.imageUrl!.split(',').last);
      } catch (_) {}
    }
    if (e?.sponsorLogoUrl?.startsWith('data:') == true) {
      try {
        _sponsorLogoBytes = base64Decode(e!.sponsorLogoUrl!.split(',').last);
      } catch (_) {}
    }

    if (e != null) {
      _startDate        = e.startDate;
      _endDate          = e.endDate;
      _status           = e.status;
      _entryRequirement = e.entryRequirement;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _title, _desc, _prize, _maxParts,
      _sponsorName, _sponsorTagline, _rules, _startingCash, _customStocks,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (d != null) setState(() => isStart ? _startDate = d : _endDate = d);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final id = widget.existing?.id ?? 'c_${DateTime.now().millisecondsSinceEpoch}';

    // Persist images to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    if (_contestImageBytes != null) {
      await prefs.setString('contest_img_$id', base64Encode(_contestImageBytes!));
    }
    if (_sponsorLogoBytes != null) {
      await prefs.setString('contest_logo_$id', base64Encode(_sponsorLogoBytes!));
    }

    final effectiveStocks = _allowedStocks == 'Custom List'
        ? 'Custom: ${_customStocks.text.trim()}'
        : _allowedStocks;

    final c = AdminContest(
      id: id,
      title: _title.text.trim(),
      description: _desc.text.trim(),
      prize: _prize.text.trim(),
      maxParticipants: int.tryParse(_maxParts.text) ?? 500,
      participants: widget.existing?.participants ?? 0,
      startDate: _startDate,
      endDate: _endDate,
      status: _status,
      winner: widget.existing?.winner,
      imageUrl: _contestImageBytes != null
          ? 'data:image/jpeg;base64,${base64Encode(_contestImageBytes!)}'
          : null,
      sponsorName: _sponsorName.text.trim().isEmpty ? null : _sponsorName.text.trim(),
      sponsorLogoUrl: _sponsorLogoBytes != null
          ? 'data:image/png;base64,${base64Encode(_sponsorLogoBytes!)}'
          : null,
      sponsorTagline: _sponsorTagline.text.trim().isEmpty ? null : _sponsorTagline.text.trim(),
      startingCash: int.tryParse(_startingCash.text.replaceAll(',', '')) ?? 10000,
      rules: _rules.text.trim(),
      allowedStocks: effectiveStocks,
      entryRequirement: _entryRequirement,
    );
    widget.onSave(c);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 780),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isEdit ? 'Edit Contest' : 'Create Contest',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Basic Info ──
                        _sectionLabel('Basic Info'),
                        _field('Contest Name', _title, required: true),
                        _field('Description', _desc, maxLines: 3, required: true),
                        _field('Prize', _prize, required: true),
                        _field('Max Participants', _maxParts,
                            inputType: TextInputType.number),

                        // Starting cash
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            controller: _startingCash,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: _inputDec('Starting Virtual Cash (\$)',
                                hint: 'e.g. 10000'),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Wrap(
                            spacing: 8,
                            children: [5000, 10000, 25000, 50000]
                                .map((v) => ActionChip(
                                      label: Text('\$${ v >= 1000 ? '${v ~/ 1000}k' : v}',
                                          style: const TextStyle(fontSize: 12)),
                                      onPressed: () => setState(
                                          () => _startingCash.text = '$v'),
                                      backgroundColor:
                                          _startingCash.text == '$v'
                                              ? _kPrimary.withValues(alpha: 0.1)
                                              : null,
                                    ))
                                .toList(),
                          ),
                        ),

                        // Date pickers
                        Row(
                          children: [
                            Expanded(
                                child: _datePicker(
                                    'Start Date', _startDate, true)),
                            const SizedBox(width: 12),
                            Expanded(
                                child:
                                    _datePicker('End Date', _endDate, false)),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Status
                        DropdownButtonFormField<ContestStatus>(
                          value: _status,
                          decoration: _inputDec('Status'),
                          items: ContestStatus.values
                              .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s.name[0].toUpperCase() +
                                        s.name.substring(1)),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _status = v!),
                        ),
                        const SizedBox(height: 12),

                        // ── Rules & Access ──
                        _sectionLabel('Rules & Access'),
                        DropdownButtonFormField<String>(
                          value: _allowedStocks,
                          decoration: _inputDec('Allowed Stocks'),
                          itemHeight: null, // allows variable-height items
                          items: _kAllowedStocksOptions.map((s) {
                            final tickers = _kAllowedStocksTickers[s];
                            return DropdownMenuItem<String>(
                              value: s,
                              child: tickers != null
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(s, style: const TextStyle(fontSize: 13)),
                                        Text(tickers,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade500)),
                                      ],
                                    )
                                  : Text(s, style: const TextStyle(fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _allowedStocks = v!),
                        ),
                        // Custom ticker input
                        if (_allowedStocks == 'Custom List') ...[
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _customStocks,
                            onChanged: (_) => setState(() {}),
                            decoration: _inputDec('Custom Tickers',
                                hint: 'e.g. AAPL, TSLA, BTC, ETH'),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Enter at least one ticker symbol'
                                    : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('Comma-separated ticker symbols',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade500)),
                          ),
                        ],
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _entryRequirement,
                          decoration: _inputDec('Entry Requirement'),
                          items: _kEntryRequirements
                              .map((s) => DropdownMenuItem(
                                  value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _entryRequirement = v!),
                        ),
                        const SizedBox(height: 12),
                        _field('Contest Rules',
                            _rules,
                            maxLines: 5,
                            hint: 'One rule per line…'),

                        // ── Sponsor ──
                        _sectionLabel('Sponsor (optional)'),
                        _field('Sponsor Name', _sponsorName,
                            hint: 'e.g. Robinhood'),
                        _field('Sponsor Tagline', _sponsorTagline,
                            hint: 'e.g. Presented by Robinhood'),
                        _sectionLabel('Sponsor Logo  ·  200 × 200 px (1:1 square)'),
                        _imageUploadSection(
                          bytes: _sponsorLogoBytes,
                          warning: _sponsorLogoWarning,
                          onPick: _pickSponsorLogo,
                          onClear: () => setState(() {
                            _sponsorLogoBytes = null;
                            _sponsorLogoWarning = null;
                          }),
                          preview: _sponsorLogoBytes != null
                              ? _buildSponsorPreview(_sponsorLogoBytes!)
                              : null,
                        ),

                        // ── Contest Image ──
                        _sectionLabel('Contest Banner Image  ·  1200 × 400 px (3:1)'),
                        _imageUploadSection(
                          bytes: _contestImageBytes,
                          warning: _contestImageWarning,
                          onPick: _pickContestImage,
                          onClear: () => setState(() {
                            _contestImageBytes = null;
                            _contestImageWarning = null;
                          }),
                          preview: _contestImageBytes != null
                              ? _buildContestCardPreview(_contestImageBytes!)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0),
                      child: Text(isEdit ? 'Save Changes' : 'Create Contest'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: Colors.grey,
              letterSpacing: 0.5)),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {int maxLines = 1,
      bool required = false,
      String? hint,
      TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: inputType,
        decoration: _inputDec(label, hint: hint),
        validator: required
            ? (v) => (v == null || v.isEmpty) ? 'Required' : null
            : null,
      ),
    );
  }

  // ── Image upload section ──────────────────────────────────────────────────

  Widget _imageUploadSection({
    required Uint8List? bytes,
    required String? warning,
    required VoidCallback onPick,
    required VoidCallback onClear,
    required Widget? preview,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bytes == null)
            InkWell(
              onTap: onPick,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.upload_file_rounded,
                        color: Colors.grey.shade400, size: 22),
                    const SizedBox(height: 4),
                    Text('Click to upload  PNG / JPG',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12)),
                  ]),
                ),
              ),
            )
          else ...[
            preview!,
            const SizedBox(height: 8),
            Row(children: [
              OutlinedButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.swap_horiz_rounded, size: 15),
                label: const Text('Replace', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kPrimary,
                  side: const BorderSide(color: _kPrimary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.clear_rounded, size: 15),
                label: const Text('Remove', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade400,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ]),
          ],
          if (warning != null) ...[
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.warning_amber_rounded,
                  size: 14, color: Colors.orange.shade700),
              const SizedBox(width: 4),
              Flexible(
                child: Text(warning,
                    style: TextStyle(
                        fontSize: 11, color: Colors.orange.shade700)),
              ),
            ]),
          ],
        ],
      ),
    );
  }

  // Contest card preview — shows 3:1 banner with title overlay
  Widget _buildContestCardPreview(Uint8List bytes) {
    final title = _title.text.trim().isEmpty ? 'Contest Title' : _title.text.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(children: [
        Image.memory(bytes,
            height: 88, width: double.infinity, fit: BoxFit.cover),
        Container(
          height: 88,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black54],
            ),
          ),
        ),
        Positioned(
          bottom: 8, left: 10, right: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text('Contest card preview',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 9)),
            ],
          ),
        ),
      ]),
    );
  }

  // Sponsor logo preview — shows how it appears next to "Presented by"
  Widget _buildSponsorPreview(Uint8List bytes) {
    final name = _sponsorName.text.trim().isEmpty
        ? 'Sponsor Name'
        : _sponsorName.text.trim();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.memory(bytes, height: 24, width: 24, fit: BoxFit.contain),
        ),
        const SizedBox(width: 8),
        Text('Presented by $name',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ]),
    );
  }

  // ── File pickers ──────────────────────────────────────────────────────────

  Future<void> _pickContestImage() async {
    final bytes = await _pickImageFile();
    if (bytes == null) return;
    final warnings = await _validateImage(
        bytes, recWidth: 1200, recHeight: 400, label: '1200×400 px (3:1)');
    setState(() {
      _contestImageBytes = bytes;
      _contestImageWarning = warnings.isEmpty ? null : warnings.join('  ·  ');
    });
  }

  Future<void> _pickSponsorLogo() async {
    final bytes = await _pickImageFile();
    if (bytes == null) return;
    final warnings = await _validateImage(
        bytes, recWidth: 200, recHeight: 200, label: '200×200 px (1:1)');
    setState(() {
      _sponsorLogoBytes = bytes;
      _sponsorLogoWarning = warnings.isEmpty ? null : warnings.join('  ·  ');
    });
  }

  Future<Uint8List?> _pickImageFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
      withData: true,
    );
    return result?.files.firstOrNull?.bytes;
  }

  Future<List<String>> _validateImage(Uint8List bytes,
      {required int recWidth, required int recHeight, required String label}) async {
    final warnings = <String>[];
    // Size check
    final mb = bytes.lengthInBytes / (1024 * 1024);
    if (mb > 2) {
      warnings.add('${mb.toStringAsFixed(1)} MB — over 2 MB limit');
    }
    // Dimension check via dart:ui
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final w = frame.image.width;
      final h = frame.image.height;
      frame.image.dispose();
      codec.dispose();
      if (w != recWidth || h != recHeight) {
        warnings.add('${w}×${h} px — recommended $label');
      }
    } catch (_) {}
    return warnings;
  }

  InputDecoration _inputDec(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      );

  Widget _datePicker(String label, DateTime date, bool isStart) {
    return InkWell(
      onTap: () => _pickDate(isStart),
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          suffixIcon: const Icon(Icons.calendar_today_rounded, size: 16),
        ),
        child: Text(_fmt.format(date), style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}

// ── Notification preview widget ───────────────────────────────────────────────

class _NotifPreview extends StatelessWidget {
  final String title;
  final String body;
  const _NotifPreview({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌱', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              const Text('Beanstalk',
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
              const Spacer(),
              Text('now',
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey.shade400)),
            ],
          ),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 2),
          Text(body,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color color;

  const _ActionBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color = Colors.black54,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      );
}
