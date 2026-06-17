// lib/services/api/api_service.dart
//
// Single HTTP client for the Beanstalk backend.
//
// Auth model (for now): the app has no login screen, so we persist:
//   - api_user_id : a device-scoped UUID (auto-generated on first use) that
//                    stands in for an authenticated user until a real login
//                    flow exists. Call [setAuth] to replace it with the real
//                    user_id once the app has one.
//   - api_jwt     : optional bearer token, attached as Authorization header
//                    when present.
//
// The backend currently enforces `req.user.user_id === :userId` on all
// portfolio routes, so running this against a real server will 401 until a
// JWT is wired up. That's a backend/auth concern, not this client's concern.

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Result of an API call. Either a success with parsed payload, or a failure
/// with a human-readable error message. Mirrors the `null == ok, String == err`
/// contract that PortfolioService.buy/sell originally used.
class ApiResult<T> {
  final T? data;
  final String? error;
  final int? statusCode;

  const ApiResult.ok(this.data)
      : error = null,
        statusCode = 200;
  const ApiResult.fail(this.error, {this.statusCode}) : data = null;

  bool get isOk => error == null;
}

class ApiService {
  // ── Configuration ────────────────────────────────────────────────────────
  //
  // Android emulator: use http://10.0.2.2:8080
  // iOS simulator:   http://localhost:8080 works
  // Physical device: substitute the dev machine's LAN IP
  static const String _defaultBaseUrl = 'https://beanstalk-api.fly.dev';

  static const _kUserIdKey = 'api_user_id';
  static const _kJwtKey = 'api_jwt';
  static const _kUserNameKey = 'api_user_name';

  // ── Singleton setup ──────────────────────────────────────────────────────
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;
  ApiService._();

  String _baseUrl = _defaultBaseUrl;
  String? _userId;
  String? _jwt;
  String? _userName;
  bool _initialized = false;

  String get baseUrl => _baseUrl;

  /// Must be called once at app start (e.g. in main()) before using other
  /// methods. Loads the persisted userId + JWT and generates a device-scoped
  /// UUID if this is the first launch. Idempotent.
  Future<void> init({String? baseUrlOverride}) async {
    if (_initialized && baseUrlOverride == null) return;
    if (baseUrlOverride != null) _baseUrl = baseUrlOverride;

    final p = await SharedPreferences.getInstance();
    _userId = p.getString(_kUserIdKey);
    if (_userId == null || _userId!.isEmpty) {
      _userId = _generateDeviceId();
      await p.setString(_kUserIdKey, _userId!);
      debugPrint('[ApiService] generated new device userId=$_userId');
    }
    _jwt = p.getString(_kJwtKey);
    _userName = p.getString(_kUserNameKey);
    _initialized = true;
  }

  /// Set the authenticated user. Call from a real login flow when it exists.
  Future<void> setAuth({required String userId, String? jwt, String? name}) async {
    final p = await SharedPreferences.getInstance();

    // If a *different* identity is signing in than the one previously
    // persisted, clear the device-global `profile_display_name` so the new
    // user falls through to their real auth-response name instead of
    // inheriting the previous user's hand-edited nickname. The in-app
    // Logout button already does this on its own (see profile_page.dart
    // `_logout`), but that path is bypassed by:
    //   - kDebugMode auth wipes in main.dart (clears the JWT + userId but
    //     leaves profile_display_name behind),
    //   - any "sign in as someone else" flow that doesn't go through
    //     Logout first.
    // We only clear when the userId actually changed; same-user re-logins
    // keep their custom display name.
    final priorUserId = p.getString(_kUserIdKey);
    if (priorUserId == null || priorUserId.isEmpty || priorUserId != userId) {
      await p.remove('profile_display_name');
    }

    _userId = userId;
    _jwt = jwt;
    _userName = name;
    await p.setString(_kUserIdKey, userId);
    if (jwt != null) {
      await p.setString(_kJwtKey, jwt);
    } else {
      await p.remove(_kJwtKey);
    }
    if (name != null && name.isNotEmpty) {
      await p.setString(_kUserNameKey, name);
    } else {
      await p.remove(_kUserNameKey);
    }
  }

  /// Display name from the last successful auth response, or null if the user
  /// authenticated before name capture was wired up (legacy sessions).
  String? get userName => _userName;

  /// True when the user has authenticated (JWT is present).
  bool get isAuthenticated => _jwt != null && _jwt!.isNotEmpty;

  /// Current user id (device-scoped UUID until a real login is wired up).
  String get currentUserId {
    assert(_initialized, 'ApiService.init() must be called before use');
    return _userId!;
  }

  // ── Auth endpoints ──────────────────────────────────────────────────────

  /// Register a new account. On success, persists the returned JWT + userId
  /// so subsequent API calls are authenticated. Returns null on success or
  /// an error string on failure.
  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final r = await _post('/api/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    if (!r.isOk) return r.error ?? 'Registration failed';
    final d = r.data as Map;
    await setAuth(
      userId: d['user_id'] as String,
      jwt: d['token'] as String?,
      name: d['name'] as String?,
    );
    return null;
  }

  /// Log in with email + password. On success, persists the JWT + userId.
  /// Returns null on success or an error string on failure.
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final r = await _post('/api/auth/login', {
      'email': email,
      'password': password,
    });
    if (!r.isOk) return r.error ?? 'Login failed';
    final d = r.data as Map;
    await setAuth(
      userId: d['user_id'] as String,
      jwt: d['token'] as String?,
      name: d['name'] as String?,
    );
    return null;
  }

  /// Sign out — clears persisted credentials.
  Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    _jwt = null;
    _userId = null;
    _userName = null;
    await p.remove(_kJwtKey);
    await p.remove(_kUserIdKey);
    await p.remove(_kUserNameKey);
  }

  // ── HTTP core ────────────────────────────────────────────────────────────

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_jwt != null && _jwt!.isNotEmpty) 'Authorization': 'Bearer $_jwt',
      };

  Uri _url(String path, [Map<String, dynamic>? query]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final base = Uri.parse('$_baseUrl$cleanPath');
    if (query == null || query.isEmpty) return base;

    // Drop null entries; http package accepts Map<String, String> or
    // Map<String, Iterable<String>>. We stringify everything for simplicity.
    final cleaned = <String, String>{};
    query.forEach((k, v) {
      if (v == null) return;
      cleaned[k] = v.toString();
    });
    return base.replace(queryParameters: cleaned);
  }

  Future<ApiResult<dynamic>> _get(
    String path, {
    Map<String, dynamic>? query,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final resp = await http.get(_url(path, query), headers: _headers).timeout(timeout);
      return _parse(resp);
    } on TimeoutException {
      return const ApiResult.fail('Network timeout');
    } catch (e) {
      return ApiResult.fail('Network error: $e');
    }
  }

  Future<ApiResult<dynamic>> _post(
    String path,
    Object? body, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final resp = await http
          .post(_url(path), headers: _headers, body: jsonEncode(body ?? {}))
          .timeout(timeout);
      return _parse(resp);
    } on TimeoutException {
      return const ApiResult.fail('Network timeout');
    } catch (e) {
      return ApiResult.fail('Network error: $e');
    }
  }

  ApiResult<dynamic> _parse(http.Response resp) {
    dynamic decoded;
    try {
      decoded = resp.body.isEmpty ? null : jsonDecode(resp.body);
    } catch (_) {
      decoded = resp.body;
    }

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return ApiResult.ok(decoded);
    }
    String errMsg;
    if (decoded is Map && decoded['error'] is String) {
      errMsg = decoded['error'] as String;
    } else if (decoded is String && decoded.isNotEmpty) {
      errMsg = decoded;
    } else {
      errMsg = 'HTTP ${resp.statusCode}';
    }
    return ApiResult.fail(errMsg, statusCode: resp.statusCode);
  }

  // ── Portfolio endpoints ──────────────────────────────────────────────────

  /// GET /api/portfolio/:userId
  Future<ApiResult<Map<String, dynamic>>> getMainPortfolio(String userId) async {
    final r = await _get('/api/portfolio/$userId');
    if (!r.isOk) return ApiResult.fail(r.error, statusCode: r.statusCode);
    return ApiResult.ok((r.data as Map).cast<String, dynamic>());
  }

  /// GET /api/portfolio/:userId?contest_id=:contestId
  ///
  /// Returns the user's portfolio for a specific contest (same response
  /// shape as getMainPortfolio — cash balance, positions, portfolio_id,
  /// portfolio_type, contest_id, etc.). Backend 404s if the user hasn't
  /// joined the contest.
  Future<ApiResult<Map<String, dynamic>>> getContestPortfolio(
    String userId,
    String contestId,
  ) async {
    final r = await _get(
      '/api/portfolio/$userId',
      query: {'contest_id': contestId},
    );
    if (!r.isOk) return ApiResult.fail(r.error, statusCode: r.statusCode);
    return ApiResult.ok((r.data as Map).cast<String, dynamic>());
  }

  /// POST /api/portfolio/:userId/trade
  ///
  /// [action] must be 'buy' or 'sell'. When [contestId] is non-null the
  /// backend routes the trade to that user's contest portfolio instead of
  /// their main portfolio. [portfolioId] takes precedence over [contestId]
  /// when both are provided.
  Future<ApiResult<Map<String, dynamic>>> executeTrade({
    required String userId,
    required String symbol,
    required String action,
    required num quantity,
    double? price,
    String? contestId,
    String? portfolioId,
  }) async {
    assert(action == 'buy' || action == 'sell');
    final body = <String, dynamic>{
      'action': action,
      'symbol': symbol,
      'quantity': quantity,
      if (price != null) 'price': price,
      if (contestId != null) 'contest_id': contestId,
      if (portfolioId != null) 'portfolio_id': portfolioId,
    };
    final r = await _post('/api/portfolio/$userId/trade', body);
    if (!r.isOk) return ApiResult.fail(r.error, statusCode: r.statusCode);
    return ApiResult.ok((r.data as Map).cast<String, dynamic>());
  }

  // ── Market data endpoints (Alpaca-backed) ───────────────────────────────

  /// GET /api/market/price/:symbol → latest Alpaca price for one symbol.
  /// Returns `{ok, symbol, price, timestamp}`.
  Future<ApiResult<Map<String, dynamic>>> getMarketPrice(String symbol) async {
    final r = await _get('/api/market/price/${symbol.toUpperCase()}');
    if (!r.isOk) return ApiResult.fail(r.error, statusCode: r.statusCode);
    return ApiResult.ok((r.data as Map).cast<String, dynamic>());
  }

  /// POST /api/market/prices → batch fetch. Returns `{ok, prices:[{symbol,price,timestamp}]}`.
  /// Preferred over N individual calls when loading the dashboard.
  Future<ApiResult<List<Map<String, dynamic>>>> getMarketPrices(
    List<String> symbols,
  ) async {
    if (symbols.isEmpty) return const ApiResult.ok(<Map<String, dynamic>>[]);
    final r = await _post('/api/market/prices', {
      'symbols': symbols.map((s) => s.toUpperCase()).toList(),
    });
    if (!r.isOk) return ApiResult.fail(r.error, statusCode: r.statusCode);
    final prices = ((r.data as Map)['prices'] as List?) ?? const [];
    return ApiResult.ok(
      prices.whereType<Map>().map((m) => m.cast<String, dynamic>()).toList(),
    );
  }

  /// GET /api/market/search?q=:query → Alpaca full-universe symbol/name
  /// search. Returns `{ok, results:[{symbol,name,exchange,...}]}`.
  Future<ApiResult<List<Map<String, dynamic>>>> searchMarket(String query) async {
    if (query.isEmpty) return const ApiResult.ok([]);
    final r = await _get('/api/market/search', query: {'q': query});
    if (!r.isOk) return ApiResult.fail(r.error, statusCode: r.statusCode);
    final results = ((r.data as Map)['results'] as List?) ?? const [];
    return ApiResult.ok(
      results.whereType<Map>().map((m) => m.cast<String, dynamic>()).toList(),
    );
  }

  // ── Contest endpoints ────────────────────────────────────────────────────

  /// GET /api/contests
  Future<ApiResult<List<Map<String, dynamic>>>> getContests({
    String? status,
    String? ageGroup,
    int limit = 20,
    int offset = 0,
  }) async {
    final r = await _get('/api/contests', query: {
      if (status != null) 'status': status,
      if (ageGroup != null) 'age_group': ageGroup,
      'limit': limit,
      'offset': offset,
    });
    if (!r.isOk) return ApiResult.fail(r.error, statusCode: r.statusCode);
    final payload = r.data;
    // Backend may return either a bare array or { contests: [...] }.
    List<dynamic> raw;
    if (payload is List) {
      raw = payload;
    } else if (payload is Map && payload['contests'] is List) {
      raw = payload['contests'] as List;
    } else {
      raw = const [];
    }
    return ApiResult.ok(raw.map((c) => (c as Map).cast<String, dynamic>()).toList());
  }

  /// POST /api/contests/:contestId/join
  Future<ApiResult<Map<String, dynamic>>> joinContest(
    String userId,
    String contestId, {
    String? ageGroup,
  }) async {
    final r = await _post('/api/contests/$contestId/join', {
      'user_id': userId,
      if (ageGroup != null) 'age_group': ageGroup,
    });
    if (!r.isOk) return ApiResult.fail(r.error, statusCode: r.statusCode);
    return ApiResult.ok((r.data as Map).cast<String, dynamic>());
  }

  // ── AI Advisor endpoints ─────────────────────────────────────────────────

  /// GET /api/ai/status → daily AI-advisor usage state for the current user.
  /// Backend shape: `{remaining, isPremium, usedToday}` (with snake_case
  /// fallbacks tolerated by the caller).
  Future<ApiResult<Map<String, dynamic>>> getAiStatus() async {
    final r = await _get('/api/ai/status');
    if (!r.isOk) return ApiResult.fail(r.error, statusCode: r.statusCode);
    return ApiResult.ok((r.data as Map).cast<String, dynamic>());
  }

  /// POST /api/ai/chat → next assistant reply for the running conversation.
  /// 429 propagates up so the caller can distinguish rate-limit from other
  /// failures.
  Future<ApiResult<Map<String, dynamic>>> sendAiChat(
    List<Map<String, dynamic>> messages,
  ) async {
    final r = await _post('/api/ai/chat', {'messages': messages});
    if (!r.isOk) return ApiResult.fail(r.error, statusCode: r.statusCode);
    return ApiResult.ok((r.data as Map).cast<String, dynamic>());
  }

  // ── Utilities ────────────────────────────────────────────────────────────

  // RFC 4122 v4 UUID using Random.secure(). Avoids pulling in the `uuid`
  // package just for device-id generation.
  String _generateDeviceId() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 10
    String h(int i) => bytes[i].toRadixString(16).padLeft(2, '0');
    return '${h(0)}${h(1)}${h(2)}${h(3)}-'
        '${h(4)}${h(5)}-'
        '${h(6)}${h(7)}-'
        '${h(8)}${h(9)}-'
        '${h(10)}${h(11)}${h(12)}${h(13)}${h(14)}${h(15)}';
  }
}
