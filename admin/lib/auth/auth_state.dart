import 'package:flutter/foundation.dart';

class AuthState extends ChangeNotifier {
  bool _loggedIn = false;
  String _adminEmail = '';

  bool get isLoggedIn => _loggedIn;
  String get adminEmail => _adminEmail;

  /// Returns null on success, error string on failure.
  String? login(String email, String password) {
    if (email.trim().toLowerCase() == 'admin@beanstalk.app' &&
        password == 'admin123') {
      _loggedIn = true;
      _adminEmail = email.trim().toLowerCase();
      notifyListeners();
      return null;
    }
    return 'Invalid email or password.';
  }

  void logout() {
    _loggedIn = false;
    _adminEmail = '';
    notifyListeners();
  }
}
