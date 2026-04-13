import 'package:flutter/material.dart';
import '../models/admin_models.dart';
import '../widgets/section_header.dart';

class LessonsAdminPage extends StatefulWidget {
  const LessonsAdminPage({super.key});

  @override
  State<LessonsAdminPage> createState() => _LessonsAdminPageState();
}

class _LessonsAdminPageState extends State<LessonsAdminPage> {
  String _sortBy = 'completions'; // completions | dropoff | avgScore
  String _filterCategory = 'All';

  static const _categories = ['All', 'Basics', 'Portfolio', 'Strategy', 'Advanced', 'Crypto'];

  List<AdminLesson> get _filtered {
    var list = MockStore.lessons.where((l) =>
        _filterCategory == 'All' || l.category == _filterCategory).toList();
    switch (_sortBy) {
      case 'dropoff':
        list.sort((a, b) => b.dropOffRate.compareTo(a.dropOffRate));
      case 'avgScore':
        list.sort((a, b) => a.avgScore.compareTo(b.avgScore));
      default:
        list.sort((a, b) => b.completions.compareTo(a.completions));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final lessons = _filtered;
    final totalCompletions = MockStore.lessons.fold(0, (s, l) => s + l.completions);
    final avgScore = MockStore.lessons.fold(0.0, (s, l) => s + l.avgScore) /
        MockStore.lessons.length;
    final highDropoff = MockStore.lessons
        .where((l) => l.dropOffRate > 0.35)
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              _SummaryCard(
                label: 'Total Lessons',
                value: '${MockStore.lessons.length}',
                icon: Icons.library_books_rounded,
                color: const Color(0xFF6A1B9A),
              ),
              const SizedBox(width: 16),
              _SummaryCard(
                label: 'Total Completions',
                value: _fmt(totalCompletions),
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF2E7D32),
              ),
              const SizedBox(width: 16),
              _SummaryCard(
                label: 'Avg Score',
                value: '${avgScore.toStringAsFixed(1)}%',
                icon: Icons.star_rounded,
                color: const Color(0xFFE65100),
              ),
              const SizedBox(width: 16),
              _SummaryCard(
                label: 'High Drop-off',
                value: '$highDropoff lessons',
                icon: Icons.warning_rounded,
                color: const Color(0xFFC62828),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Drop-off highlight
          const SectionHeader(title: 'Lessons Needing Attention (drop-off > 35%)'),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: () {
                final atRisk = MockStore.lessons
                    .where((l) => l.dropOffRate > 0.35)
                    .toList()
                  ..sort((a, b) => b.dropOffRate.compareTo(a.dropOffRate));
                return atRisk.asMap().entries.map((e) {
                  final l = e.value;
                  return Column(
                    children: [
                      ListTile(
                        dense: true,
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.trending_down,
                              color: Colors.red.shade400, size: 18),
                        ),
                        title: Text(l.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        subtitle: Text(
                            '${l.category} · ${l.level}',
                            style: const TextStyle(fontSize: 11)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${(l.dropOffRate * 100).toStringAsFixed(0)}% drop-off',
                              style: TextStyle(
                                  color: Colors.red.shade600,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                            Text(
                              'Avg score: ${l.avgScore.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      if (e.key < atRisk.length - 1)
                        const Divider(height: 1, indent: 56),
                    ],
                  );
                }).toList();
              }(),
            ),
          ),

          const SizedBox(height: 28),

          // Full lesson table
          SectionHeader(
            title: 'All Lessons',
            trailing: Row(
              children: [
                // Category filter
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filterCategory,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _filterCategory = v!),
                  ),
                ),
                const SizedBox(width: 16),
                // Sort
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    items: const [
                      DropdownMenuItem(
                          value: 'completions', child: Text('Sort: Completions')),
                      DropdownMenuItem(
                          value: 'dropoff', child: Text('Sort: Drop-off')),
                      DropdownMenuItem(
                          value: 'avgScore', child: Text('Sort: Avg Score')),
                    ],
                    onChanged: (v) => setState(() => _sortBy = v!),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 40,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 56,
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text('Lesson', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Level', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('XP', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                  DataColumn(label: Text('Completions', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                  DataColumn(label: Text('Attempts', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                  DataColumn(label: Text('Completion %', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                  DataColumn(label: Text('Drop-off %', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                  DataColumn(label: Text('Avg Score', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                ],
                rows: lessons.map((l) {
                  final dropHigh = l.dropOffRate > 0.35;
                  return DataRow(cells: [
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Text(l.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 13),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    DataCell(_CategoryChip(l.category)),
                    DataCell(_LevelChip(l.level)),
                    DataCell(Text('${l.xpReward}',
                        style: const TextStyle(fontSize: 13))),
                    DataCell(Text(_fmt(l.completions),
                        style: const TextStyle(fontSize: 13))),
                    DataCell(Text(_fmt(l.totalAttempts),
                        style: const TextStyle(fontSize: 13))),
                    DataCell(
                      _ProgressBar(
                        value: l.completionRate,
                        color: const Color(0xFF2E7D32),
                        label:
                            '${(l.completionRate * 100).toStringAsFixed(0)}%',
                      ),
                    ),
                    DataCell(
                      Text(
                        '${(l.dropOffRate * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: dropHigh ? FontWeight.bold : FontWeight.normal,
                          color: dropHigh ? Colors.red.shade600 : Colors.black87,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${l.avgScore.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 13,
                          color: l.avgScore < 65
                              ? Colors.orange.shade700
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(label,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;
  const _CategoryChip(this.category);

  static const _colors = {
    'Basics':    Color(0xFF1565C0),
    'Portfolio': Color(0xFF2E7D32),
    'Strategy':  Color(0xFF6A1B9A),
    'Advanced':  Color(0xFFC62828),
    'Crypto':    Color(0xFFE65100),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[category] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(category,
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _LevelChip extends StatelessWidget {
  final String level;
  const _LevelChip(this.level);

  @override
  Widget build(BuildContext context) {
    final color = level == 'Beginner'
        ? Colors.green.shade600
        : level == 'Intermediate'
            ? Colors.orange.shade700
            : Colors.red.shade600;
    return Text(level, style: TextStyle(fontSize: 12, color: color));
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final String label;

  const _ProgressBar({
    required this.value,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
