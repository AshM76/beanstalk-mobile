import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'stock_detail_page.dart';
import '../../models/asset_class.dart';
import '../../services/market/market_service.dart';
import '../../widgets/asset_class_chip.dart';
import '../../widgets/asset_class_filter.dart';

final _stockCurrency = NumberFormat.currency(locale: 'en_US', symbol: '\$');

// ── Stock Model ──────────────────────────────────────────────────────────────

class StockItem {
  final String symbol;
  final String name;
  final double price;
  final double changePercent;
  final String sector;

  const StockItem({
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePercent,
    required this.sector,
  });

  double get changeAmount => price * changePercent / 100;
  bool get isPositive => changePercent >= 0;

  String get formattedPrice => _stockCurrency.format(price);
  String get formattedChange =>
      '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%';
}

const kAllStocks = [
  StockItem(symbol: 'AAPL',  name: 'Apple Inc.',           price: 182.63, changePercent:  1.24, sector: 'Technology'),
  StockItem(symbol: 'MSFT',  name: 'Microsoft Corp.',       price: 415.20, changePercent:  0.81, sector: 'Technology'),
  StockItem(symbol: 'GOOGL', name: 'Alphabet Inc.',         price: 175.88, changePercent: -0.33, sector: 'Technology'),
  StockItem(symbol: 'NVDA',  name: 'NVIDIA Corp.',          price: 487.20, changePercent:  3.10, sector: 'Technology'),
  StockItem(symbol: 'AMZN',  name: 'Amazon.com Inc.',       price: 192.45, changePercent:  1.52, sector: 'Consumer'),
  StockItem(symbol: 'META',  name: 'Meta Platforms',        price: 527.87, changePercent:  2.14, sector: 'Technology'),
  StockItem(symbol: 'TSLA',  name: 'Tesla Inc.',            price: 248.42, changePercent: -1.83, sector: 'Consumer'),
  StockItem(symbol: 'BRK.B', name: 'Berkshire Hathaway',   price: 430.10, changePercent:  0.31, sector: 'Financials'),
  StockItem(symbol: 'JPM',   name: 'JPMorgan Chase',        price: 221.35, changePercent:  0.62, sector: 'Financials'),
  StockItem(symbol: 'V',     name: 'Visa Inc.',             price: 278.90, changePercent:  0.91, sector: 'Financials'),
  StockItem(symbol: 'JNJ',   name: 'Johnson & Johnson',     price: 145.78, changePercent: -0.44, sector: 'Healthcare'),
  StockItem(symbol: 'WMT',   name: 'Walmart Inc.',          price: 68.45,  changePercent:  0.22, sector: 'Consumer'),
  StockItem(symbol: 'DIS',   name: 'Walt Disney Co.',       price: 112.34, changePercent: -0.71, sector: 'Communication'),
  StockItem(symbol: 'NFLX',  name: 'Netflix Inc.',          price: 634.20, changePercent:  1.89, sector: 'Communication'),
  StockItem(symbol: 'SPY',   name: 'S&P 500 ETF',           price: 524.10, changePercent:  0.54, sector: 'ETF'),
  StockItem(symbol: 'QQQ',   name: 'Nasdaq-100 ETF',        price: 448.32, changePercent:  0.98, sector: 'ETF'),
  StockItem(symbol: 'XOM',   name: 'ExxonMobil Corp.',      price: 114.65, changePercent: -0.18, sector: 'Energy'),
  StockItem(symbol: 'BA',    name: 'Boeing Co.',            price: 188.20, changePercent: -0.55, sector: 'Industrials'),
  StockItem(symbol: 'COIN',  name: 'Coinbase Global',       price: 218.45, changePercent:  4.32, sector: 'Crypto'),
  StockItem(symbol: 'PYPL',  name: 'PayPal Holdings',       price: 66.78,  changePercent: -1.12, sector: 'Financials'),
];

const _popularSymbols = ['AAPL', 'MSFT', 'NVDA', 'TSLA', 'SPY', 'AMZN', 'META', 'GOOGL'];

// ── Stock Search Page ────────────────────────────────────────────────────────

class StockSearchPage extends StatefulWidget {
  /// If non-null, any stock selected here opens its detail page with this
  /// contest context applied so trades route to the contest portfolio.
  final String? contestId;
  final String? contestName;

  const StockSearchPage({super.key, this.contestId, this.contestName});
  @override
  State<StockSearchPage> createState() => _StockSearchPageState();
}

class _StockSearchPageState extends State<StockSearchPage> {
  final _controller = TextEditingController();
  String _query = '';

  // Live Alpaca prices keyed by symbol.
  Map<String, double> _livePrices = const {};

  // Remote search results from Alpaca (backend). Populated when the local
  // catalog has no match, after a 400ms debounce to avoid spamming the API.
  List<StockItem> _remoteResults = const [];
  bool _remoteLoading = false;
  Timer? _debounce;

  // Active asset-class filter. null = "All".
  AssetClass? _filter;

  @override
  void initState() {
    super.initState();
    _loadLivePrices();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadLivePrices() async {
    final prices = await MarketService.getPrices(
      kAllStocks.map((s) => s.symbol).toList(),
    );
    if (!mounted || prices.isEmpty) return;
    setState(() => _livePrices = prices);
  }

  /// Overlay any known live price onto a catalog stock.
  StockItem _apply(StockItem s) {
    final live = _livePrices[s.symbol];
    if (live == null) return s;
    return StockItem(
      symbol: s.symbol,
      name: s.name,
      price: live,
      changePercent: s.changePercent,
      sector: s.sector,
    );
  }

  /// Best-effort asset class for a local catalog entry, inferred from the
  /// `sector` field. Temporary until the `StockItem`/Holding model carries
  /// an explicit `assetClass` (spec step 6).
  AssetClass _localAssetClass(StockItem s) {
    final sector = s.sector.toUpperCase();
    if (sector == 'ETF') return AssetClass.etf;
    if (sector == 'CRYPTO') return AssetClass.crypto;
    return AssetClass.stock;
  }

  /// Local catalog match.
  List<StockItem> get _localResults {
    if (_query.isEmpty) return [];
    final q = _query.toUpperCase();
    return kAllStocks
        .where((s) =>
            s.symbol.contains(q) ||
            s.name.toUpperCase().contains(q) ||
            s.sector.toUpperCase().contains(q))
        .where((s) => _filter == null || _localAssetClass(s) == _filter)
        .map(_apply)
        .toList();
  }

  /// Combined: local first, then remote (de-duped).
  List<StockItem> get _results {
    final local = _localResults;
    if (_remoteResults.isEmpty) return local;
    final localSymbols = local.map((s) => s.symbol).toSet();
    final remote = _remoteResults
        .where((s) => !localSymbols.contains(s.symbol))
        .toList();
    return [...local, ...remote];
  }

  /// Debounced backend search via GET /api/market/search.
  void _onQueryChanged(String value) {
    setState(() {
      _query = value;
      _remoteResults = const [];
    });
    _debounce?.cancel();
    if (value.isEmpty) return;
    // Fire immediately for short terms (likely tickers); debounce longer names
    final delay = value.length <= 4
        ? const Duration(milliseconds: 200)
        : const Duration(milliseconds: 400);
    _debounce = Timer(delay, () => _searchRemote(value));
  }

  Future<void> _searchRemote(String query) async {
    if (!mounted || _query != query) return; // stale
    setState(() => _remoteLoading = true);

    final raw = await MarketService.searchTickers(query, filter: _filter);
    if (!mounted || _query != query) return; // stale

    final items = <StockItem>[];
    if (raw.isNotEmpty) {
      // Fetch live prices for the remote symbols in one batch so the rows
      // render with real numbers from the start.
      final symbols = raw
          .map((m) => (m['symbol'] as String?) ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
      final prices = await MarketService.getPrices(symbols);

      for (final m in raw) {
        final sym = (m['symbol'] as String?) ?? '';
        if (sym.isEmpty) continue;
        final name = (m['name'] as String?) ?? sym;
        final assetClass = (m['asset_class'] as String?) ?? '';
        final live = prices[sym.toUpperCase()];
        items.add(StockItem(
          symbol: sym,
          name: name,
          price: live ?? 0,
          changePercent: 0,
          sector: assetClass,
        ));
      }
    }

    if (!mounted || _query != query) return;
    setState(() {
      _remoteResults = items;
      _remoteLoading = false;
    });
  }

  List<StockItem> get _popular => kAllStocks
      .where((s) => _popularSymbols.contains(s.symbol))
      .where((s) => _filter == null || _localAssetClass(s) == _filter)
      .map(_apply)
      .toList();

  void _onFilterChanged(AssetClass? filter) {
    if (_filter == filter) return;
    setState(() {
      _filter = filter;
      _remoteResults = const [];
    });
    // Re-fire remote search under the new filter if a query is active.
    if (_query.isNotEmpty) {
      _debounce?.cancel();
      _debounce = Timer(
        const Duration(milliseconds: 200),
        () => _searchRemote(_query),
      );
    }
  }

  void _openDetail(StockItem stock) {
    debugPrint(
      '[StockSearchPage] _openDetail symbol=${stock.symbol} '
      'contestId=${widget.contestId ?? "<null>"} '
      'contestName=${widget.contestName ?? "<null>"}',
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StockDetailPage(
          stock: stock,
          contestId: widget.contestId,
          contestName: widget.contestName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('Stock Search', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: TextField(
              controller: _controller,
              autofocus: false,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search symbol or company…',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _controller.clear();
                          _debounce?.cancel();
                          setState(() {
                            _query = '';
                            _remoteResults = const [];
                            _remoteLoading = false;
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _onQueryChanged,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          AssetClassFilter(selected: _filter, onChanged: _onFilterChanged),
          const SizedBox(height: 4),
          Expanded(
            child: _query.isEmpty ? _buildPopular() : _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildPopular() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Popular Stocks',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        const Text('Top picks by market cap & activity',
            style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 16),
        ..._popular.map((s) => _StockRow(stock: s, onTap: () => _openDetail(s))),
        const SizedBox(height: 24),
        const Text('All Stocks',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ...kAllStocks
            .where((s) => !_popularSymbols.contains(s.symbol))
            .where((s) => _filter == null || _localAssetClass(s) == _filter)
            .map(_apply)
            .map((s) => _StockRow(stock: s, onTap: () => _openDetail(s))),
      ],
    );
  }

  Widget _buildResults() {
    final results = _results;
    if (results.isEmpty && !_remoteLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('No results for "$_query"',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Try a different symbol or company name',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          _remoteLoading
              ? 'Searching…'
              : '${results.length} result${results.length == 1 ? '' : 's'}',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 12),
        ...results.map((s) => _StockRow(stock: s, onTap: () => _openDetail(s))),
        if (_remoteLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

// ── Reusable Stock Row ───────────────────────────────────────────────────────

class _StockRow extends StatelessWidget {
  final StockItem stock;
  final VoidCallback onTap;
  const _StockRow({required this.stock, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = stock.isPositive ? const Color(0xFF2E7D32) : Colors.red;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  stock.symbol.substring(0, stock.symbol.length.clamp(0, 2)),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF2E7D32)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name + sector
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(stock.symbol,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      const SizedBox(width: 6),
                      AssetClassChip.fromRaw(stock.sector),
                    ],
                  ),
                  Text(stock.name,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            // Price + change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(stock.formattedPrice,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(stock.formattedChange,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

