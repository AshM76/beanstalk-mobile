// lib/pages/contests/recap_page.dart
//
// The Cash-narrated recap for a concluded contest: headline, Cash's market
// recap, highlight cards, the benchmark scoreboard (did you beat the market or
// the piggy bank?), growth-framed takeaways, and a sign-off.
//
// Cash presents the story with the existing CashBubble component; the
// scoreboard reuses the ghost-benchmark indigo so it reads as a piece with the
// leaderboard's ghost players. See Design/Contest-Recap-Generation-Spec.md.

import 'package:flutter/material.dart';

import '../../services/contest/recap_service.dart';
import '../../widgets/cash_bubble.dart';

/// Ghost-benchmark accent (matches the leaderboard's ghost rows).
const Color _ghostAccent = Color(0xFF5C6BC0); // indigo

class RecapPage extends StatefulWidget {
  final String contestId;
  final String contestTitle;

  /// The contest's theme color, used for the hero so the recap feels like part
  /// of the same contest.
  final Color color;

  const RecapPage({
    super.key,
    required this.contestId,
    required this.contestTitle,
    required this.color,
  });

  @override
  State<RecapPage> createState() => _RecapPageState();
}

class _RecapPageState extends State<RecapPage> {
  bool _loading = true;
  String? _error;
  ContestRecap? _recap; // null + no error + not loading → not ready yet

  // The signed-in kid's private mini-recap. Loaded after the group recap; the
  // server generates it lazily so it can take a moment.
  PersonalRecap? _personal;
  bool _personalLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await RecapService.fetch(widget.contestId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.isOk) {
        _recap = res.data;
      } else {
        _error = res.error ?? 'Something went wrong';
      }
    });
    // Only fetch a personal recap once the group recap is live (the server
    // gates it on that anyway); skip the round-trip otherwise.
    if (res.isOk && res.data != null) _loadPersonal();
  }

  Future<void> _loadPersonal() async {
    setState(() => _personalLoading = true);
    final res = await RecapService.fetchPersonal(widget.contestId);
    if (!mounted) return;
    setState(() {
      _personalLoading = false;
      if (res.isOk) _personal = res.data; // null → nothing to show, leave it out
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.color,
        foregroundColor: Colors.white,
        title: Text(widget.contestTitle, overflow: TextOverflow.ellipsis),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _CenteredMessage(
        emoji: '😕',
        title: "Couldn't load the recap",
        message: _error!,
        action: ElevatedButton(onPressed: _load, child: const Text('Try again')),
      );
    }
    if (_recap == null) {
      // Published only after an admin reviews it — expected for a fresh contest.
      return const _CenteredMessage(
        emoji: '🌱',
        title: 'The recap is still growing',
        message:
            "Cash is still putting this contest's story together. Check back "
            'soon to see how everyone did!',
      );
    }
    return _RecapContent(
      recap: _recap!,
      color: widget.color,
      personal: _personal,
      personalLoading: _personalLoading,
    );
  }
}

class _RecapContent extends StatelessWidget {
  final ContestRecap recap;
  final Color color;
  final PersonalRecap? personal;
  final bool personalLoading;

  const _RecapContent({
    required this.recap,
    required this.color,
    required this.personal,
    required this.personalLoading,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // Hero — the headline in Cash's voice.
        Container(
          width: double.infinity,
          color: color,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📊  Contest Recap',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
              const SizedBox(height: 10),
              Text(
                recap.headline,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.3,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Your recap — the signed-in kid's private mini-recap (if they were in
        // this contest). Shows a gentle placeholder while the server writes it.
        if (personalLoading && personal == null)
          const _PersonalLoadingCard()
        else if (personal != null)
          _PersonalCard(personal: personal!),

        // Market recap — Cash narrates what the market did.
        if (recap.marketRecap.isNotEmpty)
          CashBubble(message: recap.marketRecap, mood: CashMood.thinking),

        // Highlights.
        if (recap.highlights.isNotEmpty) ...[
          const _SectionHeader('Highlights'),
          for (final h in recap.highlights) _HighlightCard(highlight: h),
        ],

        // Benchmark scoreboard — the active-vs-passive story.
        _ScoreboardCard(scoreboard: recap.scoreboard),

        // Takeaways.
        if (recap.lessons.isNotEmpty) ...[
          const _SectionHeader('Takeaways'),
          for (final l in recap.lessons) _LessonRow(text: l),
        ],

        // Sign-off.
        if (recap.cashSignoff.isNotEmpty) ...[
          const SizedBox(height: 8),
          CashBubble(message: recap.cashSignoff, mood: CashMood.happy),
        ],
      ],
    );
  }
}

/// The signed-in kid's private mini-recap card. Warm green (Cash) styling, set
/// apart from the group recap so it reads as "just for you".
class _PersonalCard extends StatelessWidget {
  final PersonalRecap personal;
  const _PersonalCard({required this.personal});

  static const Color _accent = Color(0xFF2E7D32); // Cash green

  @override
  Widget build(BuildContext context) {
    final ret = personal.returnLabel;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌱', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              const Text('Your recap',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold, color: _accent)),
              const Spacer(),
              if (ret != null)
                Text(ret,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: (personal.yourReturnPercent ?? 0) >= 0
                            ? _accent
                            : const Color(0xFFC62828))),
            ],
          ),
          const SizedBox(height: 10),
          if (personal.headline.isNotEmpty)
            Text(personal.headline,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
          if (personal.body.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(personal.body,
                style: const TextStyle(fontSize: 13, height: 1.45, color: Colors.black87)),
          ],
          if (personal.beatMarket != null || personal.beatSavings != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (personal.beatMarket != null)
                  _BeatChip(label: 'Market', beat: personal.beatMarket!),
                if (personal.beatMarket != null && personal.beatSavings != null)
                  const SizedBox(width: 8),
                if (personal.beatSavings != null)
                  _BeatChip(label: 'Savings', beat: personal.beatSavings!),
              ],
            ),
          ],
          if (personal.lesson.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(personal.lesson,
                      style: const TextStyle(
                          fontSize: 13, height: 1.4, color: Colors.black54)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A small "beat / didn't beat" chip for a benchmark on the personal card.
class _BeatChip extends StatelessWidget {
  final String label;
  final bool beat;
  const _BeatChip({required this.label, required this.beat});

  @override
  Widget build(BuildContext context) {
    final color = beat ? const Color(0xFF2E7D32) : const Color(0xFF9E9E9E);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        beat ? '✅ Beat $label' : label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

/// Placeholder while the server writes the kid's personal recap.
class _PersonalLoadingCard extends StatelessWidget {
  const _PersonalLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2E7D32)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text('Cash is writing your personal recap…',
                style: TextStyle(fontSize: 13, color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final RecapHighlight highlight;
  const _HighlightCard({required this.highlight});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(highlight.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  highlight.title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                if (highlight.body.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    highlight.body,
                    style: const TextStyle(
                        fontSize: 13, height: 1.4, color: Colors.black54),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The active-vs-passive scoreboard: what share of players beat the market
/// (Sammy P.) and a savings account (Piggy). Shares come straight from the
/// server's verified numbers.
class _ScoreboardCard extends StatelessWidget {
  final RecapScoreboard scoreboard;
  const _ScoreboardCard({required this.scoreboard});

  @override
  Widget build(BuildContext context) {
    final market = RecapScoreboard.asPercent(scoreboard.beatMarketShare);
    final savings = RecapScoreboard.asPercent(scoreboard.beatSavingsShare);
    // Nothing to show if the server had no benchmark data at all.
    if (market == null && savings == null && scoreboard.line.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ghostAccent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _ghostAccent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'You vs. the ghosts',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: _ghostAccent),
          ),
          const SizedBox(height: 12),
          if (market != null)
            _ScoreRow(emoji: '📈', share: market, label: 'beat the market (Sammy P.)'),
          if (savings != null) ...[
            const SizedBox(height: 8),
            _ScoreRow(emoji: '🐷', share: savings, label: 'beat savings (Piggy)'),
          ],
          if (scoreboard.line.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              scoreboard.line,
              style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String emoji;
  final String share;
  final String label;
  const _ScoreRow({required this.emoji, required this.share, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Text(
          share,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: _ghostAccent),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

class _LessonRow extends StatelessWidget {
  final String text;
  const _LessonRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🌱', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.45, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final String emoji;
  final String title;
  final String message;
  final Widget? action;

  const _CenteredMessage({
    required this.emoji,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black54),
            ),
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
