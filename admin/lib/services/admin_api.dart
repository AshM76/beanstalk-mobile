import 'dart:convert';
import 'package:http/http.dart' as http;

/// Thin HTTP client for the Admin Console. Singleton so the JWT captured at
/// login is available to any page that later needs to call the API.
class AdminApi {
  static final AdminApi _instance = AdminApi._();
  factory AdminApi() => _instance;
  AdminApi._();

  // Base URL is injected at build time via --dart-define=API_BASE_URL=...,
  // defaulting to the production Fly.io host below. The demo launcher
  // (start-demo.sh) overrides it with http://localhost:$API_PORT for local dev.
  // (The admin console is a separate Flutter package, so it can't share the
  // main app's lib/config/app_config.dart — it mirrors the same define+default.)
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://beanstalk-api.fly.dev',
  );

  String? _jwt;
  String? _email;
  String? _name;

  String get baseUrl => _baseUrl;
  String? get jwt => _jwt;
  String? get email => _email;
  String? get name => _name;
  bool get isAuthenticated => _jwt != null && _jwt!.isNotEmpty;

  /// Calls POST /api/auth/login. On success, stores the JWT + user info in
  /// memory and returns null. On failure, returns a user-facing error string.
  Future<String?> login(String email, String password) async {
    final Uri url = Uri.parse('$_baseUrl/api/auth/login');
    http.Response res;
    try {
      res = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      return 'Cannot reach API at $_baseUrl.';
    }

    Map<String, dynamic> body;
    try {
      body = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return 'Unexpected response from server (${res.statusCode}).';
    }

    if (res.statusCode != 200) {
      return (body['error'] as String?) ?? 'Login failed (${res.statusCode}).';
    }

    _jwt = body['token'] as String?;
    _email = body['email'] as String?;
    _name = body['name'] as String?;
    return null;
  }

  void clear() {
    _jwt = null;
    _email = null;
    _name = null;
  }
}
