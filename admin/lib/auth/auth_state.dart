import 'package:flutter/foundation.dart';
import '../services/admin_api.dart';

/// Admin Console auth state. Delegates credential checks to the API via
/// [AdminApi.login] and gates access by email — only [_kAdminEmail] is
/// allowed in. The API itself doesn't yet expose an admin role, so we treat
/// the seeded admin account as the gate.
class AuthState extends ChangeNotifier {
  static const String _kAdminEmail = 'admin@beanstalk.app';

  final AdminApi _api = AdminApi();
  bool _loggedIn = false;
  String _adminEmail = '';

  bool get isLoggedIn => _loggedIn;
  String get adminEmail => _adminEmail;

  /// Returns null on success, error string on failure.
  Future<String?> login(String email, String password) async {
    final normalized = email.trim().toLowerCase();
    if (normalized != _kAdminEmail) {
      return 'This account is not authorized for the Admin Console.';
    }

    final err = await _api.login(normalized, password);
    if (err != null) return err;

    _loggedIn = true;
    _adminEmail = _api.email ?? normalized;
    notifyListeners();
    return null;
  }

  void logout() {
    _api.clear();
    _loggedIn = false;
    _adminEmail = '';
    notifyListeners();
  }
}
