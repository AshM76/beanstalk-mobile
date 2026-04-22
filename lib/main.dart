import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'pages/lessons/lessons_page.dart';
import 'pages/stocks/stock_search_page.dart';
import 'pages/stocks/stock_detail_page.dart';
import 'pages/contests/contests_page.dart';
import 'pages/profile/profile_page.dart';
import 'pages/onboarding/onboarding_flow.dart';
import 'pages/notifications/notifications_page.dart';
import 'pages/groups/groups_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/portfolio/portfolio_service.dart';
import 'services/notification/notification_service.dart';
import 'services/group/group_service.dart';
import 'services/api/api_service.dart';
import 'services/market/market_service.dart';
import 'utils/contest_color.dart';
import 'data/cash_tips.dart';
import 'pages/auth/login_page.dart';
import 'widgets/asset_class_chip.dart';
import 'models/asset_class.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // In debug mode, clear any persisted auth so the app always boots to the
  // login screen with a fresh device identity. Prevents stale JWTs or
  // leftover user ids from earlier builds from tripping auth flows. The
  // device userId is regenerated inside ApiService().init() below.
  if (kDebugMode) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_jwt');
    await prefs.remove('api_user_id');
    await prefs.remove('api_user_name');
    debugPrint('[main] debug build — cleared persisted auth state');
  }

  // Load/persist the device-scoped userId + any cached JWT before any
  // service touches the API. Respect --dart-define=API_BASE_URL=... so the
  // demo startup script can point the sim at a local API.
  const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  await ApiService().init(
    baseUrlOverride: apiBaseUrl.isEmpty ? null : apiBaseUrl,
  );
  runApp(const BeanstalkApp());
}

class BeanstalkApp extends StatelessWidget {
  const BeanstalkApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beanstalk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/home': (_) => const HomeScreen(),
        '/login': (_) => const LoginPage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;

      // Auth gate: send unauthenticated users to login first.
      if (!ApiService().isAuthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
        return;
      }

      // Onboarding gate: send new users through age/risk profile.
      final done = await isOnboardingComplete();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => done ? const HomeScreen() : const OnboardingFlow(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF2E7D32),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🌱', style: TextStyle(fontSize: 80)),
            SizedBox(height: 16),
            Text('Beanstalk',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Learn. Trade. Compete.',
                style: TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// ── Home Screen ───────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  int _groupCount = 0;
  // Keys let us call reload() on LessonsPage and ProfilePage when their tabs
  // are selected, ensuring XP is always up-to-date without relying solely on initState.
  final _lessonsKey   = GlobalKey<LessonsPageState>();
  final _profileKey   = GlobalKey<ProfilePageState>();
  final _dashboardKey = GlobalKey<_DashboardPageState>();

  @override
  void initState() {
    super.initState();
    _loadGroupCount();
  }

  Future<void> _loadGroupCount() async {
    final count = await GroupService.joinedCount();
    if (!mounted) return;
    setState(() => _groupCount = count);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          DashboardPage(key: _dashboardKey),
          const ContestsPage(),
          const StockSearchPage(),
          LessonsPage(key: _lessonsKey),
          const GroupsPage(),
          ProfilePage(key: _profileKey),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) {
          setState(() => _index = i);
          if (i == 0) {
            debugPrint('[HomeScreen] tapping Home  dashState=${_dashboardKey.currentState}');
            _dashboardKey.currentState?.reload();
          }
          if (i == 3) _lessonsKey.currentState?.reload();
          if (i == 4) _loadGroupCount();
          if (i == 5) _profileKey.currentState?.reload();
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined),           activeIcon: Icon(Icons.home),           label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.emoji_events_outlined),   activeIcon: Icon(Icons.emoji_events),   label: 'Contests'),
          const BottomNavigationBarItem(icon: Icon(Icons.search_outlined),         activeIcon: Icon(Icons.search),         label: 'Discover'),
          const BottomNavigationBarItem(icon: Icon(Icons.school_outlined),         activeIcon: Icon(Icons.school),         label: 'Learn'),
          BottomNavigationBarItem(
            icon: _groupCount > 0
                ? Badge(
                    label: Text('$_groupCount',
                        style: const TextStyle(fontSize: 10, color: Colors.white)),
                    backgroundColor: const Color(0xFF2E7D32),
                    child: const Icon(Icons.group_outlined))
                : const Icon(Icons.group_outlined),
            activeIcon: const Icon(Icons.group),
            label: 'Groups',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline),          activeIcon: Icon(Icons.person),         label: 'Profile'),
        ],
      ),
    );
  }
}

// ── Dashboard Page ────────────────────────────────────────────────────────────

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

/// Lightweight descriptor used by the dashboard's portfolio switcher.
/// `id` is null for the main portfolio, or a contest_id for a contest.
class _PortfolioChoice {
  final String? id;
  final String label;
  const _PortfolioChoice({required this.id, required this.label});
  bool get isMain => id == null;
}

/// Fractional-aware quantity formatting for a holding. Uses the asset's
/// `quantityDecimals` (4 for stocks/ETFs, 6 for crypto) and trims trailing
/// zeros so "5.0000" renders as "5" and "0.5000" as "0.5".
String _fmtHoldingQty(Holding h) {
  final s = h.quantity.toStringAsFixed(h.assetClass.quantityDecimals);
  if (!s.contains('.')) return s;
  return s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

/// Unit suffix for a holding row: " share", " shares" for stocks/ETFs
/// (fractional-aware — "0.5 shares"), " BTC" etc. for crypto.
String _holdingUnit(Holding h) {
  if (h.assetClass == AssetClass.crypto) return ' ${h.symbol}';
  return ' share${h.quantity == 1 ? '' : 's'}';
}

class _DashboardPageState extends State<DashboardPage> {
  static const _featured = ['AAPL', 'MSFT', 'GOOGL', 'NVDA', 'SPY'];
  static final _currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');

  double _cash          = 10000;
  double _holdingsValue = 0;
  double _todayGain     = 0;
  Map<String, Holding> _holdings = {};
  int _unreadNotifs = 0;
  // First name from the auth response (ApiService.userName). Null until the
  // user has logged in on a build that captures it — falls back to the
  // 'Beanstalk' app-bar title in that case.
  String? _firstName;

  // Live prices keyed by symbol, populated from MarketService on every
  // portfolio reload. Anything not in this map falls back to the catalog
  // price in kAllStocks (stale) or the holding's avg cost as a last resort.
  Map<String, double> _livePrices = const {};

  // Portfolio switcher state.
  //   _choices      — always starts with the Main portfolio, then one entry
  //                   per contest the user has joined (read from the
  //                   SharedPreferences cache maintained by contests_page).
  //   _selectedIdx  — index into _choices; 0 = main.
  List<_PortfolioChoice> _choices = const [_PortfolioChoice(id: null, label: 'My Portfolio')];
  int _selectedIdx = 0;

  _PortfolioChoice get _selected => _choices[_selectedIdx];

  @override
  void initState() {
    super.initState();
    _loadChoicesAndPortfolio();
    _loadUnreadCount();
    _loadFirstName();
  }

  Future<void> _loadFirstName() async {
    final full = ApiService().userName;
    if (full == null || full.trim().isEmpty) return;
    final first = full.trim().split(RegExp(r'\s+')).first;
    if (!mounted) return;
    setState(() => _firstName = first);
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> reload() async {
    await _loadChoicesAndPortfolio();
    await _loadUnreadCount();
  }

  /// Rebuild the portfolio switcher from scratch (picks up newly-joined
  /// contests) and then reload whichever portfolio is currently selected.
  /// Preserves the user's selection across reloads when possible.
  Future<void> _loadChoicesAndPortfolio() async {
    final api = ApiService();
    final prefs = await SharedPreferences.getInstance();

    final previouslySelectedId = (_choices.isNotEmpty) ? _selected.id : null;

    final choices = <_PortfolioChoice>[
      const _PortfolioChoice(id: null, label: 'My Portfolio'),
    ];

    // Fetch contests once and filter to those the user has joined. The
    // SharedPreferences `contest_joined_<id>` flag is written by
    // contests_page when a join succeeds, so it's the fastest way to derive
    // "my contests" without a dedicated backend endpoint.
    final contestsRes = await api.getContests();
    if (contestsRes.isOk) {
      for (final c in contestsRes.data!) {
        final id = c['contest_id'] as String?;
        final name = (c['name'] as String?) ?? 'Contest';
        if (id == null) continue;
        if (prefs.getBool('contest_joined_$id') == true) {
          choices.add(_PortfolioChoice(id: id, label: name));
        }
      }
    }

    // Preserve selection if the same contest is still present.
    var nextIdx = 0;
    if (previouslySelectedId != null) {
      final i = choices.indexWhere((c) => c.id == previouslySelectedId);
      if (i != -1) nextIdx = i;
    }

    if (!mounted) return;
    setState(() {
      _choices = choices;
      _selectedIdx = nextIdx;
    });
    await _loadPortfolio();
  }

  void _selectPortfolio(int idx) {
    if (idx == _selectedIdx) return;
    setState(() => _selectedIdx = idx);
    _loadPortfolio();
  }

  Future<void> _loadUnreadCount() async {
    final count = await NotificationService.unreadCount();
    if (!mounted) return;
    setState(() => _unreadNotifs = count);
  }

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsPage()),
    );
    // Refresh badge after returning
    _loadUnreadCount();
  }

  Future<void> _loadPortfolio() async {
    final contestId = _selected.id;
    debugPrint('[Dashboard._loadPortfolio] called  mounted=$mounted  contest=${contestId ?? "main"}');
    final data = await PortfolioService.load(contestId: contestId);
    if (!mounted) {
      debugPrint('[Dashboard._loadPortfolio] BAILED — not mounted');
      return;
    }

    debugPrint('[Dashboard._loadPortfolio] cash=${data.cash}  holdingsCount=${data.holdings.length}  keys=${data.holdings.keys.toList()}');

    // Fetch live prices for every symbol we're about to render: all holdings
    // (for valuations and today's gain) and the featured row (for Market
    // Today). Batched into a single backend call.
    final neededSymbols = <String>{
      ...data.holdings.keys,
      ..._featured,
    }.toList();
    final livePrices = await MarketService.getPrices(neededSymbols);
    if (!mounted) return;

    double holdingsValue = 0;
    double todayGain     = 0;
    for (final holding in data.holdings.values) {
      final live = livePrices[holding.symbol];
      final catalog = kAllStocks
          .where((s) => s.symbol == holding.symbol)
          .firstOrNull;
      final price = live ?? catalog?.price ?? holding.avgCost;
      holdingsValue += holding.quantity * price;
      // Today's gain still relies on the catalog's mock changePercent (we
      // don't have an intraday delta from Alpaca here). When a live price
      // is present, scale the catalog's percentage against it so the
      // number at least moves with the real price.
      if (catalog != null) {
        todayGain += holding.quantity * (price * catalog.changePercent / 100);
      }
      debugPrint(
        '[Dashboard._loadPortfolio]   → ${holding.symbol} '
        'qty=${holding.quantity} live=${live ?? "<miss>"} price=$price',
      );
    }

    setState(() {
      _cash          = data.cash;
      _holdings      = data.holdings;
      _holdingsValue = holdingsValue;
      _todayGain     = todayGain;
      _livePrices    = livePrices;
    });
    debugPrint('[Dashboard._loadPortfolio] setState done  _holdings.length=${_holdings.length}');
  }

  double get _totalValue => _cash + _holdingsValue;

  @override
  Widget build(BuildContext context) {
    final gainPositive = _todayGain >= 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: Text(
          _firstName != null && _firstName!.isNotEmpty
              ? '$_greeting, $_firstName! 🌱'
              : 'Beanstalk',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: _openNotifications,
              ),
              if (_unreadNotifs > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: IgnorePointer(
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF2E7D32), width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _unreadNotifs > 9 ? '9+' : '$_unreadNotifs',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadChoicesAndPortfolio,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Portfolio switcher — only shown once the user has joined at
            // least one contest (otherwise the single "My Portfolio" chip
            // is redundant).
            if (_choices.length > 1) ...[
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _choices.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) {
                    final c = _choices[i];
                    final selected = i == _selectedIdx;
                    // Per-contest accent so the chip visually matches the
                    // contest's card on the contests page and the picker on
                    // stock detail. Main portfolio falls back to green.
                    final accent = contestColorFor(c.id);
                    return ChoiceChip(
                      label: Text(c.label),
                      selected: selected,
                      avatar: Icon(
                        c.isMain ? Icons.account_balance_wallet : Icons.emoji_events,
                        size: 16,
                        color: selected ? Colors.white : accent,
                      ),
                      selectedColor: accent,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: selected ? accent : Colors.grey.shade300,
                      ),
                      onSelected: (_) => _selectPortfolio(i),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Portfolio card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selected.isMain
                        ? 'Portfolio Value'
                        : '${_selected.label} · Portfolio Value',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currency.format(_totalValue),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${gainPositive ? '+' : ''}${_currency.format(_todayGain)} today',
                    style: TextStyle(
                        color: gainPositive
                            ? Colors.greenAccent.shade100
                            : Colors.red.shade200,
                        fontSize: 13),
                  ),
                  if (_holdings.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _portfolioChip(
                            'Cash', _currency.format(_cash)),
                        const SizedBox(width: 10),
                        _portfolioChip(
                            'Invested', _currency.format(_holdingsValue)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Holdings section — always rendered so empty state is visible
            const SizedBox(height: 20),
            const Text('Your Holdings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            if (_holdings.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: const Center(
                  child: Text('No holdings yet — buy a stock to get started',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ),
              )
            else
              ..._holdings.values.map((h) {
                final stock = kAllStocks
                    .where((s) => s.symbol == h.symbol)
                    .firstOrNull;
                // Prefer live Alpaca price; fall back to catalog then avg
                // cost so the row still renders if the network is down.
                final price = _livePrices[h.symbol] ?? stock?.price ?? h.avgCost;
                final value = h.quantity * price;
                final gain  = h.unrealizedGain(price);
                final pos   = gain >= 0;
                return _holdingRow(h, price, value, gain, pos);
              }),
            // Cash daily tip
            const SizedBox(height: 8),
            _cashTipCard(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Market Today',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const StockSearchPage())),
                  child: const Text('See all',
                      style: TextStyle(color: Color(0xFF2E7D32))),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ..._featured.map((sym) {
              final stock = kAllStocks.where((s) => s.symbol == sym).firstOrNull;
              if (stock == null) return const SizedBox.shrink();
              // Overlay the live price on top of the static catalog entry
              // so symbol/name/sector/changePercent still come from the
              // catalog (we have no intraday % from Alpaca here yet).
              final live = _livePrices[sym];
              final effective = live == null
                  ? stock
                  : StockItem(
                      symbol: stock.symbol,
                      name: stock.name,
                      price: live,
                      changePercent: stock.changePercent,
                      sector: stock.sector,
                    );
              return _stockRow(context, effective);
            }),
          ],
        ),
      ),
    );
  }

  Widget _portfolioChip(String label, String value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white60, fontSize: 10)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _holdingRow(
      Holding h, double price, double value, double gain, bool pos) {
    final gainPct = h.avgCost > 0
        ? ((price - h.avgCost) / h.avgCost * 100)
        : 0.0;
    return GestureDetector(
      onTap: () {
        final stock =
            kAllStocks.where((s) => s.symbol == h.symbol).firstOrNull;
        if (stock != null) {
          Navigator.push(context,
              MaterialPageRoute(
                  builder: (_) => StockDetailPage(stock: stock)))
              .then((_) => _loadPortfolio());
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10)),
              child: Center(
                child: Text(
                  h.symbol.substring(0, h.symbol.length.clamp(0, 2)),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF2E7D32)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(h.symbol,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        const SizedBox(width: 6),
                        AssetClassChip(assetClass: h.assetClass),
                      ],
                    ),
                    Text(
                      '${_fmtHoldingQty(h)}${_holdingUnit(h)}'
                      '  ·  avg ${_currency.format(h.avgCost)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(_currency.format(value),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              Text(
                '${pos ? '+' : ''}${_currency.format(gain)} (${gainPct.toStringAsFixed(1)}%)',
                style: TextStyle(
                    fontSize: 11,
                    color: pos ? const Color(0xFF2E7D32) : Colors.red),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _cashTipCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA5D6A7), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Cash avatar — circle container so full face is always visible
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.hardEdge,
            child: SvgPicture.asset(
              'assets/images/cash/cash_thinking.svg',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // Tip content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text("Cash's Daily Tip",
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32))),
                ),
                const SizedBox(height: 6),
                Text(
                  CashTips.getDailyTip(),
                  style: const TextStyle(
                      fontSize: 13, height: 1.5, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stockRow(BuildContext context, StockItem stock) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => StockDetailPage(stock: stock)))
          .then((_) => _loadPortfolio()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10)),
              child: Center(
                child: Text(
                  stock.symbol.substring(0, stock.symbol.length.clamp(0, 2)),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF2E7D32)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stock.symbol,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(stock.name,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(stock.formattedPrice,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: stock.isPositive
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(stock.formattedChange,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: stock.isPositive
                            ? const Color(0xFF2E7D32)
                            : Colors.red)),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

