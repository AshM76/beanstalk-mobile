// lib/widgets/contest_portfolio_tab.dart
//
// The "Portfolio" tab inside a contest's detail screen (ContestDetailPage).
//
// This is the heart of the dedicated-contest-workspace model: instead of the
// user hunting for which portfolio they're looking at on the shared dashboard,
// each contest owns a themed view of *its* holdings, cash, and P/L, plus a
// trade entry that routes straight into that contest's portfolio. Everything
// here is scoped to a single contestId, so there's no ambiguity about which
// portfolio a value or a trade belongs to.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/holding.dart';
import '../services/market/market_service.dart';
import '../services/portfolio/portfolio_service.dart';
import '../services/contest/contest_service.dart';
// LeaderboardEntry lives in the contests page; importing just the type (Dart
// tolerates the resulting import cycle) lets us reuse the same merged, re-ranked
// standings the Leaderboard tab shows, so a user's rank is consistent.
import '../pages/contests/contests_page.dart' show LeaderboardEntry;
import '../pages/stocks/stock_search_page.dart';

class ContestPortfolioTab extends StatefulWidget {
  final String contestId;
  final String contestName;
  final Color accent;

  /// Whether the current user has joined this contest. A non-joined user has
  /// no contest portfolio, so we show a prompt instead of an empty $0 view.
  final bool joined;

  /// Whether the contest is currently active (trading allowed). Upcoming /
  /// ended contests hide the trade entry.
  final bool isActive;

  /// Human-readable time remaining (e.g. "5d left", "Ended"), from
  /// Contest.timeLabel — shown as a pill so a player sees urgency at a glance.
  final String timeLabel;

  const ContestPortfolioTab({
    super.key,
    required this.contestId,
    required this.contestName,
    required this.accent,
    required this.joined,
    required this.isActive,
    required this.timeLabel,
  });

  @override
  State<ContestPortfolioTab> createState() => _ContestPortfolioTabState();
}

class _ContestPortfolioTabState extends State<ContestPortfolioTab> {
  static final _currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');

  bool _loading = true;
  // Server-authoritative membership: whether the user actually has a portfolio
  // in this contest (not the device-local join flag, which misses seeded or
  // other-device joins).
  ContestPortfolioStatus _status = ContestPortfolioStatus.notJoined;
  double _cash = 0;
  Map<String, Holding> _holdings = const {};
  Map<String, double> _prices = const {};

  // Standings within the contest (best-effort; null rank = not ranked / not
  // yet available). _participants is the size of the merged leaderboard.
  int? _myRank;
  int _participants = 0;

  @override
  void initState() {
    super.initState();
    // Always ask the server whether the user has a portfolio here, regardless
    // of the local join flag — that's what fixes seeded/other-device members
    // seeing an empty tab.
    _load();
  }

  @override
  void didUpdateWidget(covariant ContestPortfolioTab old) {
    super.didUpdateWidget(old);
    // The user can join from the detail screen's bottom bar while this tab is
    // already mounted; when that flips joined false→true, load the freshly
    // created contest portfolio.
    if (widget.joined && !old.joined) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final result = await PortfolioService.loadContestPortfolio(widget.contestId);

    // Live prices only matter when the user actually holds positions.
    final prices = result.holdings.isEmpty
        ? <String, double>{}
        : await MarketService.getPrices(result.holdings.keys.toList());

    // Rank uses the same merged/re-ranked standings the Leaderboard tab shows;
    // only meaningful when the user is actually in the contest. Best-effort — a
    // failure just hides the rank number.
    int? myRank;
    int participants = 0;
    if (result.status == ContestPortfolioStatus.joined) {
      final lb = await ContestService.fetchLeaderboard(widget.contestId);
      if (lb.isOk && lb.data != null) {
        participants = lb.data!.length;
        for (final LeaderboardEntry e in lb.data!) {
          if (e.isCurrentUser) {
            myRank = e.rank;
            break;
          }
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _status = result.status;
      _cash = result.cash;
      _holdings = result.holdings;
      _prices = prices;
      _myRank = myRank;
      _participants = participants;
      _loading = false;
    });
  }

  double _priceFor(Holding h) => _prices[h.symbol] ?? h.avgCost;
  double get _marketValue =>
      _holdings.values.fold(0.0, (sum, h) => sum + h.quantity * _priceFor(h));
  double get _costBasis =>
      _holdings.values.fold(0.0, (sum, h) => sum + h.quantity * h.avgCost);
  double get _totalValue => _cash + _marketValue;
  double get _plAbs => _marketValue - _costBasis;
  double get _plPct => _costBasis > 0 ? (_plAbs / _costBasis) * 100 : 0;

  Future<void> _openTrade() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StockSearchPage(
          contestId: widget.contestId,
          contestName: widget.contestName,
        ),
      ),
    );
    _load(); // refresh after returning from a possible trade
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_status == ContestPortfolioStatus.error) {
      return _CenteredMessage(
        icon: Icons.cloud_off,
        title: 'Couldn’t load your contest portfolio',
        subtitle: 'Check your connection and try again.',
        onRetry: _load,
      );
    }
    if (_status == ContestPortfolioStatus.notJoined) {
      return const _CenteredMessage(
        icon: Icons.emoji_events_outlined,
        title: 'Join to start trading',
        subtitle:
            'Join this contest to get a fresh portfolio and start trading '
            'against other players.',
      );
    }

    final holdings = _holdings.values.toList()
      ..sort((a, b) => (b.quantity * _priceFor(b))
          .compareTo(a.quantity * _priceFor(a)));

    return RefreshIndicator(
      onRefresh: _load,
      color: widget.accent,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _metaRow(),
          const SizedBox(height: 12),
          _valueCard(),
          const SizedBox(height: 16),
          if (widget.isActive) ...[
            _tradeButton(),
            const SizedBox(height: 20),
          ],
          Row(
            children: [
              const Text('Holdings',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              Text('(${holdings.length})',
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          if (holdings.isEmpty)
            _emptyHoldings()
          else
            ...holdings.map(_holdingRow),
        ],
      ),
    );
  }

  Widget _metaRow() {
    return Row(
      children: [
        Expanded(
          child: _pill(
            icon: Icons.emoji_events,
            text: _myRank != null
                ? 'Rank #$_myRank${_participants > 0 ? ' of $_participants' : ''}'
                : 'Unranked',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _pill(icon: Icons.schedule, text: widget.timeLabel),
        ),
      ],
    );
  }

  Widget _pill({required IconData icon, required String text}) {
    final tint = Color.alphaBlend(
        widget.accent.withValues(alpha: 0.12), Colors.white);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: widget.accent),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: widget.accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _valueCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [widget.accent, Color.lerp(widget.accent, Colors.black, 0.25)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${widget.contestName} · Portfolio Value',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currency.format(_totalValue),
            style: const TextStyle(
                color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _stat('Cash', _currency.format(_cash)),
              _stat('Invested', _currency.format(_costBasis)),
            ],
          ),
          const SizedBox(height: 14),
          // P/L on its own full-width line — the string (dollars + percent) is
          // the longest and most useful figure, so it gets room to breathe.
          _plBlock(),
        ],
      ),
    );
  }

  Widget _plBlock() {
    final up = _plAbs >= 0;
    // Soft green/red that stays legible on the accent-colored card.
    final color = up ? const Color(0xFFB9F6CA) : const Color(0xFFFF8A80);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Profit / Loss',
            style: TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          '${up ? '+' : ''}${_currency.format(_plAbs)}  '
          '(${up ? '+' : ''}${_plPct.toStringAsFixed(1)}%)',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _tradeButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _openTrade,
        icon: const Icon(Icons.trending_up),
        label: const Text('Trade in this contest',
            style: TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _emptyHoldings() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.savings_outlined, color: widget.accent, size: 36),
          const SizedBox(height: 10),
          const Text('No positions yet',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            widget.isActive
                ? 'Make your first trade in this contest to see it here.'
                : 'This contest isn\'t active for trading right now.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _holdingRow(Holding h) {
    final price = _priceFor(h);
    final mv = h.quantity * price;
    final cost = h.quantity * h.avgCost;
    final pl = mv - cost;
    final plPct = cost > 0 ? (pl / cost) * 100 : 0.0;
    final up = pl >= 0;
    final plColor = up ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(h.symbol,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  '${_qty(h.quantity)} @ ${_currency.format(h.avgCost)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_currency.format(mv),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 2),
              Text(
                '${up ? '+' : ''}${_currency.format(pl)} (${up ? '+' : ''}${plPct.toStringAsFixed(1)}%)',
                style: TextStyle(color: plColor, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Whole numbers render without a trailing ".0"; fractional shares keep up to
  // four places (crypto positions can be small fractions).
  String _qty(double q) =>
      q == q.roundToDouble() ? q.toStringAsFixed(0) : q.toStringAsFixed(4);
}

class _CenteredMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Future<void> Function()? onRetry;
  const _CenteredMessage(
      {required this.icon,
      required this.title,
      required this.subtitle,
      this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54)),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
