import 'package:flutter/foundation.dart';

class AuthController extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _rememberMe = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get rememberMe => _rememberMe;

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  Future<bool> login({
    required String usernameOrPhone,
    required String password,
  }) async {
    // Demo-only: treat any non-empty credentials as success.
    if (usernameOrPhone.trim().isEmpty || password.isEmpty) return false;

    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
