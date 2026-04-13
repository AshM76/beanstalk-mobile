import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/admin_models.dart';
import '../widgets/metric_card.dart';
import '../widgets/section_header.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const _kPrimary = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Metric cards ─────────────────────────────────────────────────
          LayoutBuilder(builder: (_, constraints) {
            final cols = constraints.maxWidth > 800 ? 4 : 2;
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.6,
              children: [
                MetricCard(
                  title: 'Total Users',
                  value: '${MockStore.totalUsers.toLocale()}',
                  icon: Icons.people_rounded,
                  color: _kPrimary,
                  delta: '+41 this week',
                  deltaPositive: true,
                ),
                MetricCard(
                  title: 'Active Contests',
                  value: '${MockStore.activeContests}',
                  icon: Icons.emoji_events_rounded,
                  color: const Color(0xFF1565C0),
                  delta: '${MockStore.contests.where((c) => c.status == ContestStatus.active).fold(0, (s, c) => s + c.participants)} participants',
                  deltaPositive: true,
                ),
                MetricCard(
                  title: 'Lessons Completed Today',
                  value: '${MockStore.lessonsCompletedToday}',
                  icon: Icons.school_rounded,
                  color: const Color(0xFF6A1B9A),
                  delta: '+12% vs yesterday',
                  deltaPositive: true,
                ),
                MetricCard(
                  title: 'Total Trades',
                  value: '${MockStore.totalTrades.toLocale()}',
                  icon: Icons.bar_chart_rounded,
                  color: const Color(0xFFE65100),
                  delta: '+234 today',
                  deltaPositive: true,
                ),
              ],
            );
          }),

          const SizedBox(height: 28),

          // ── Charts row ───────────────────────────────────────────────────
          LayoutBuilder(builder: (_, constraints) {
            final side = (constraints.maxWidth - 16) / 2;
            final wide = constraints.maxWidth > 720;
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: side, child: _UserGrowthChart()),
                  const SizedBox(width: 16),
                  SizedBox(width: side, child: _DauChart()),
                ],
              );
            }
            return Column(children: [
              _UserGrowthChart(),
              const SizedBox(height: 16),
              _DauChart(),
            ]);
          }),

          const SizedBox(height: 28),

          // ── Recent activity ──────────────────────────────────────────────
          const SectionHeader(title: 'Recent Activity'),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _ActivityRow(icon: Icons.person_add_rounded, color: _kPrimary,
                    text: '12 new users signed up',          time: '2 min ago'),
                _ActivityRow(icon: Icons.school_rounded,      color: const Color(0xFF6A1B9A),
                    text: 'Options Basics lesson: 8 completions', time: '14 min ago'),
                _ActivityRow(icon: Icons.emoji_events_rounded, color: const Color(0xFF1565C0),
                    text: 'Tech Sector Showdown: 5 new joins', time: '31 min ago'),
                _ActivityRow(icon: Icons.notifications_rounded, color: const Color(0xFFE65100),
                    text: 'Push notification sent to 1,893 users', time: '12 hr ago'),
                _ActivityRow(icon: Icons.bar_chart_rounded,   color: Colors.teal,
                    text: '234 virtual trades executed today', time: 'Today', last: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── User Growth Chart ─────────────────────────────────────────────────────────

class _UserGrowthChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spots = MockStore.userGrowth
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('User Growth (7 days)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text('${MockStore.totalUsers.toLocale()} total users',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: LineChart(LineChartData(
                minX: 0, maxX: 6,
                minY: 4580, maxY: 4860,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey.shade100, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= MockStore.growthLabels.length) return const SizedBox.shrink();
                        return Text(MockStore.growthLabels[i],
                            style: const TextStyle(fontSize: 10, color: Colors.grey));
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFF2E7D32),
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2E7D32).withValues(alpha: 0.15),
                          const Color(0xFF2E7D32).withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
}

// ── DAU Chart ─────────────────────────────────────────────────────────────────

class _DauChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daily Active Users (7 days)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            const Text('Unique users who opened the app',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: BarChart(BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 500,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey.shade100, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= MockStore.growthLabels.length) return const SizedBox.shrink();
                        return Text(MockStore.growthLabels[i],
                            style: const TextStyle(fontSize: 10, color: Colors.grey));
                      },
                    ),
                  ),
                ),
                barGroups: MockStore.dau.asMap().entries.map((e) =>
                    BarChartGroupData(x: e.key, barRods: [
                      BarChartRodData(
                        toY: e.value,
                        color: const Color(0xFF1565C0),
                        width: 18,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      )
                    ])).toList(),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Activity Row ──────────────────────────────────────────────────────────────

class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final String time;
  final bool last;

  const _ActivityRow({
    required this.icon,
    required this.color,
    required this.text,
    required this.time,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color, size: 16),
          ),
          title: Text(text, style: const TextStyle(fontSize: 13)),
          trailing: Text(time,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ),
        if (!last) const Divider(height: 1, indent: 56),
      ],
    );
  }
}

extension on int {
  String toLocale() {
    final s = toString();
    final result = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) result.write(',');
      result.write(s[i]);
    }
    return result.toString();
  }
}
