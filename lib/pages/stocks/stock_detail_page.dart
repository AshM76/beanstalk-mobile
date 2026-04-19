import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'stock_search_page.dart';
import '../../services/portfolio/portfolio_service.dart';
import '../../services/api/api_service.dart';
import '../../services/market/market_service.dart';
import '../../utils/contest_color.dart';
import '../../widgets/asset_class_chip.dart';

final _currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');

// ── Mock price-history generator ─────────────────────────────────────────────

List<double> _generateHistory(double currentPrice, int points, double volatility) {
  final rand = Random(currentPrice.hashCode);
  // Walk backwards from current price
  final prices = <double>[currentPrice];
  for (var i = 1; i < points; i++) {
    final prev = prices.last;
    final delta = (rand.nextDouble() - 0.48) * prev * volatility;
    prices.add((prev - delta).clamp(prev * 0.5, prev * 1.5));
  }
  return prices.reversed.toList();
}

const _ranges = ['1D', '1W', '1M', '3M', '1Y'];

// ── Stock Detail Page ────────────────────────────────────────────────────────

class StockDetailPage extends StatefulWidget {
  final StockItem stock;

  /// If non-null, trades from this page are routed to the user's portfolio
  /// for this contest instead of their main portfolio. [contestName] is used
  /// only for the "Trading in: …" banner at the top.
  final String? contestId;
  final String? contestName;

  const StockDetailPage({
    super.key,
    required this.stock,
    this.contestId,
    this.contestName,
  });
  @override
  State<StockDetailPage> createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  String _range = '1M';
  double? _touchedPrice;

  double _cash       = 10000;
  double _heldShares = 0;

  // Live price from /api/market/price/:symbol. null until the first fetch
  // completes (or if the fetch fails). Used by the price header, the chart
  // current-value line, the trade sheet "Available / Estimated Total", and
  // — most importantly — as the price we send to the backend for a trade,
  // since in test mode the backend trusts the client's price.
  double? _livePrice;

  // Effective price used everywhere that previously read `s.price`.
  double get _effectivePrice => _livePrice ?? s.price;

  // Portfolio selector state. `_choices` always starts with the main portfolio
  // (id=null); joined contests are appended from SharedPreferences +
  // `/api/contests`. `_activeContestId` is the one trades will route to —
  // initialised to the incoming widget.contestId so contest deep-links still
  // default to the contest portfolio, then mutated by the chip row.
  List<_PortfolioChoice> _choices = const [
    _PortfolioChoice(id: null, label: 'My Portfolio'),
  ];
  String? _activeContestId;

  StockItem get s => widget.stock;

  @override
  void initState() {
    super.initState();
    _activeContestId = widget.contestId;
    debugPrint(
      '[StockDetailPage] open  symbol=${widget.stock.symbol} '
      'contestId=${widget.contestId ?? "<null>"} '
      'contestName=${widget.contestName ?? "<null>"}',
    );
    _loadChoicesAndPortfolio();
    _loadLivePrice();
  }

  Future<void> _loadLivePrice() async {
    final p = await MarketService.getPrice(s.symbol);
    if (!mounted || p == null) return;
    setState(() => _livePrice = p);
    debugPrint('[StockDetailPage] live price ${s.symbol}=$p');
  }

  /// Build the portfolio picker (main + joined contests) and then load the
  /// initially-selected portfolio. Mirrors the home-screen switcher in
  /// main.dart so the two stay consistent.
  Future<void> _loadChoicesAndPortfolio() async {
    final choices = <_PortfolioChoice>[
      const _PortfolioChoice(id: null, label: 'My Portfolio'),
    ];

    try {
      final prefs = await SharedPreferences.getInstance();
      final contestsRes = await ApiService().getContests();
      if (contestsRes.isOk && contestsRes.data != null) {
        for (final c in contestsRes.data!) {
          final id = c['contest_id'] as String?;
          final name = (c['name'] as String?) ?? 'Contest';
          if (id == null) continue;
          if (prefs.getBool('contest_joined_$id') == true) {
            choices.add(_PortfolioChoice(id: id, label: name));
          }
        }
      }

      // If the caller passed a contestId we haven't seen in prefs (edge
      // case: prefs flag missing but user is mid-contest), make sure it's
      // still selectable rather than silently falling back to main.
      if (widget.contestId != null &&
          !choices.any((c) => c.id == widget.contestId)) {
        choices.add(_PortfolioChoice(
          id: widget.contestId,
          label: widget.contestName ?? 'Contest',
        ));
      }
    } catch (e) {
      debugPrint('[StockDetailPage] _loadChoicesAndPortfolio failed: $e');
    }

    if (!mounted) return;
    setState(() => _choices = choices);
    await _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    final data = await PortfolioService.load(contestId: _activeContestId);
    if (!mounted) return;
    setState(() {
      _cash       = data.cash;
      _heldShares = data.holdings[s.symbol]?.quantity ?? 0;
    });
  }

  void _selectPortfolio(String? contestId) {
    if (contestId == _activeContestId) return;
    setState(() => _activeContestId = contestId);
    _loadPortfolio();
  }

  Map<String, (int points, double vol)> get _rangeConfig => const {
    '1D': (24, 0.002),
    '1W': (7, 0.01),
    '1M': (30, 0.02),
    '3M': (90, 0.035),
    '1Y': (252, 0.06),
  };

  List<double> get _prices {
    final cfg = _rangeConfig[_range]!;
    return _generateHistory(_effectivePrice, cfg.$1, cfg.$2);
  }

  Color get _accentColor =>
      s.isPositive ? const Color(0xFF2E7D32) : Colors.red;

  @override
  Widget build(BuildContext context) {
    final prices = _prices;
    final minY = prices.reduce(min);
    final maxY = prices.reduce(max);
    final spots = prices
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    final displayPrice = _touchedPrice ?? _effectivePrice;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(s.symbol,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(width: 8),
                AssetClassChip.fromRaw(s.sector, onColoredBackground: true),
              ],
            ),
            Text(s.name,
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added to Watchlist')),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // ── Contest banner ────────────────────────────────────────────────
          if (widget.contestId != null)
            Container(
              width: double.infinity,
              color: const Color(0xFFFFF3E0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Color(0xFFE65100), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Trading in: ${widget.contestName ?? "Contest"}',
                      style: const TextStyle(
                        color: Color(0xFFE65100),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // ── Price header ──────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _currency.format(displayPrice),
                      style: const TextStyle(
                          fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    _SectorChip(sector: s.sector),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        // Scale the catalog's mock intraday % against the
                        // effective price so the dollar amount is coherent
                        // with what we're displaying, even after a live
                        // price comes in. (Alpaca's getLatestBar doesn't
                        // give an intraday delta — hooking that up is a
                        // separate task.)
                        '${s.isPositive ? '+' : ''}\$${(_effectivePrice * s.changePercent / 100).abs().toStringAsFixed(2)}  '
                        '(${s.formattedChange})',
                        style: TextStyle(
                            color: _accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('Today',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),

          // ── Chart ─────────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: (spots.length - 1).toDouble(),
                      minY: minY * 0.998,
                      maxY: maxY * 1.002,
                      clipData: const FlClipData.all(),
                      lineTouchData: LineTouchData(
                        touchCallback:
                            (FlTouchEvent event, LineTouchResponse? resp) {
                          if (resp == null || resp.lineBarSpots == null) {
                            setState(() => _touchedPrice = null);
                            return;
                          }
                          setState(() => _touchedPrice =
                              resp.lineBarSpots!.first.y);
                        },
                        getTouchedSpotIndicator: (barData, spotIndexes) =>
                            spotIndexes
                                .map((i) => TouchedSpotIndicatorData(
                                      FlLine(
                                          color: _accentColor.withValues(alpha: 0.5),
                                          strokeWidth: 1,
                                          dashArray: [4, 4]),
                                      FlDotData(
                                        getDotPainter: (_, __, ___, ____) =>
                                            FlDotCirclePainter(
                                          radius: 5,
                                          color: _accentColor,
                                          strokeWidth: 2,
                                          strokeColor: Colors.white,
                                        ),
                                      ),
                                    ))
                                .toList(),
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: _accentColor.withValues(alpha: 0.85),
                          getTooltipItems: (spots) => spots
                              .map((s) => LineTooltipItem(
                                    '\$${s.y.toStringAsFixed(2)}',
                                    const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ))
                              .toList(),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: (maxY - minY) / 4,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: Colors.grey.shade100,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 52,
                            interval: (maxY - minY) / 4,
                            getTitlesWidget: (value, _) => Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                '\$${value.toStringAsFixed(0)}',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade500),
                              ),
                            ),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.35,
                          color: _accentColor,
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                _accentColor.withValues(alpha: 0.18),
                                Colors.transparent,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 250),
                  ),
                ),
                const SizedBox(height: 12),
                // Range selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _ranges.map((r) {
                    final sel = r == _range;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _range = r;
                        _touchedPrice = null;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: sel ? _accentColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(r,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: sel ? Colors.white : Colors.grey)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Key Metrics ───────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Key Metrics',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                _metricsGrid(s),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── About ─────────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('About',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Text(
                  '${s.name} (${s.symbol}) is a publicly traded company in the '
                  '${s.sector} sector. This data is for educational purposes '
                  'and simulates real market behavior to help you learn how '
                  'to read stock charts and analyse performance over time.',
                  style: const TextStyle(
                      fontSize: 14, color: Colors.black87, height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),

      // ── Trade Button ───────────────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0x14000000))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Portfolio picker — lets the user explicitly choose which
            // portfolio the next trade will hit. Only rendered when the user
            // has more than one choice (main + joined contests); otherwise
            // it's just visual noise.
            if (_choices.length > 1) ...[
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _choices.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final choice = _choices[i];
                    final selected = choice.id == _activeContestId;
                    // Accent follows the contest across screens; main
                    // portfolio stays green.
                    final accent = contestColorFor(choice.id);
                    return ChoiceChip(
                      label: Text(
                        choice.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : Colors.black87,
                        ),
                      ),
                      selected: selected,
                      onSelected: (_) => _selectPortfolio(choice.id),
                      selectedColor: accent,
                      backgroundColor: const Color(0xFFF0F0F0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      showCheckmark: false,
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
            Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () => _showTradeSheet(context, isBuy: false),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade400, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Sell',
                      style: TextStyle(
                          color: Colors.red.shade400,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _showTradeSheet(context, isBuy: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Buy',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _metricsGrid(StockItem s) {
    // Derive plausible mock values from the price
    final rand = Random(_effectivePrice.hashCode + 1);
    final high52 = _effectivePrice * (1 + 0.15 + rand.nextDouble() * 0.25);
    final low52 = _effectivePrice * (0.65 + rand.nextDouble() * 0.2);
    final pe = 15 + rand.nextDouble() * 40;
    final marketCap = _effectivePrice * (1e8 + rand.nextDouble() * 1e10);
    final volume = (5e6 + rand.nextDouble() * 5e7).round();

    String fmtCap(double v) {
      if (v >= 1e12) return '\$${(v / 1e12).toStringAsFixed(2)}T';
      if (v >= 1e9) return '\$${(v / 1e9).toStringAsFixed(1)}B';
      return '\$${(v / 1e6).toStringAsFixed(0)}M';
    }

    String fmtVol(int v) {
      if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}M';
      return '${(v / 1e3).toStringAsFixed(0)}K';
    }

    final metrics = [
      ('Market Cap', fmtCap(marketCap)),
      ('P/E Ratio', pe.toStringAsFixed(1)),
      ('52W High', '\$${high52.toStringAsFixed(2)}'),
      ('52W Low', '\$${low52.toStringAsFixed(2)}'),
      ('Volume', fmtVol(volume)),
      ('Sector', s.sector),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.8,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: metrics
          .map((m) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(m.$1,
                        style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(m.$2,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ))
          .toList(),
    );
  }

  void _showTradeSheet(BuildContext context, {required bool isBuy}) {
    int shares = 1;
    final ctrl = TextEditingController(text: '1');

    // Max shares user can buy (by cash) or sell (by holdings)
    int maxShares() => isBuy
        ? (_cash / _effectivePrice).floor()
        : _heldShares.floor();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final total    = shares * _effectivePrice;
          final limit    = maxShares();
          final canTrade = limit >= 1;

          void updateShares(int val) {
            val = val.clamp(1, limit > 0 ? limit : 1);
            shares = val;
            ctrl.text = '$val';
            ctrl.selection = TextSelection.collapsed(offset: ctrl.text.length);
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(
                24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                Text('${isBuy ? 'Buy' : 'Sell'} ${s.symbol}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                // Cash / shares available subtitle
                Text(
                  isBuy
                      ? 'Available: ${_currency.format(_cash)}'
                      : 'You hold: ${_heldShares.toStringAsFixed(_heldShares % 1 == 0 ? 0 : 4)} shares',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 20),

                if (!canTrade) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      isBuy ? 'Insufficient funds to buy shares.' : 'No shares to sell.',
                      style: const TextStyle(color: Colors.red, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ] else ...[
                  // Quantity row: − | text field | +
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _QtyButton(
                          icon: Icons.remove,
                          onTap: () => setSheetState(() => updateShares(shares - 1))),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 90,
                        child: TextField(
                          controller: ctrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF2E7D32), width: 2),
                            ),
                          ),
                          onChanged: (val) {
                            final n = int.tryParse(val);
                            if (n != null && n >= 1) {
                              setSheetState(() => shares = n.clamp(1, limit));
                            }
                          },
                          onSubmitted: (val) {
                            final n = int.tryParse(val) ?? 1;
                            setSheetState(() => updateShares(n));
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      _QtyButton(
                          icon: Icons.add,
                          onTap: () => setSheetState(() => updateShares(shares + 1))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('shares', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                  const SizedBox(height: 16),
                  // Totals row
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Estimated Total',
                            style: TextStyle(color: Colors.grey)),
                        Text(_currency.format(total),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final err = isBuy
                            ? await PortfolioService.buy(
                                symbol:    s.symbol,
                                name:      s.name,
                                price:     _effectivePrice,
                                quantity:  shares,
                                contestId: _activeContestId,
                              )
                            : await PortfolioService.sell(
                                symbol:    s.symbol,
                                price:     _effectivePrice,
                                quantity:  shares,
                                contestId: _activeContestId,
                              );
                        if (!mounted) return;
                        if (err != null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(err),
                            backgroundColor: Colors.red,
                          ));
                        } else {
                          await _loadPortfolio(); // refresh cash + held
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                              '${isBuy ? 'Bought' : 'Sold'} $shares share${shares > 1 ? 's' : ''} of ${s.symbol}',
                            ),
                            backgroundColor:
                                isBuy ? const Color(0xFF2E7D32) : Colors.red,
                          ));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isBuy ? const Color(0xFF2E7D32) : Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        '${isBuy ? 'Buy' : 'Sell'} $shares share${shares > 1 ? 's' : ''} · ${_currency.format(total)}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 22),
        ),
      );
}

class _SectorChip extends StatelessWidget {
  final String sector;
  const _SectorChip({required this.sector});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(sector,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
      );
}

/// A single entry in the portfolio picker.
/// [id] is the contest_id, or null for the user's main portfolio.
class _PortfolioChoice {
  final String? id;
  final String label;
  const _PortfolioChoice({required this.id, required this.label});
}
