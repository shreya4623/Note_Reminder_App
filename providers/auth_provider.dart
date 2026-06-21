import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;

  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> init() async {
    _user = _authService.currentUser;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _error = null;
    _setLoading(true);
    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
    );
    _setLoading(false);

    if (result != null) {
      _error = result;
      notifyListeners();
      return false;
    }

    _user = _authService.currentUser;
    notifyListeners();
    return true;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _error = null;
    _setLoading(true);
    final result = await _authService.login(email: email, password: password);
    _setLoading(false);

    if (result != null) {
      _error = result;
      notifyListeners();
      return false;
    }

    _user = _authService.currentUser;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<String?> requestPasswordReset(String email) async {
    return _authService.requestPasswordReset(email);
  }

  Future<String?> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    return _authService.resetPassword(token: token, newPassword: newPassword);
  }

  Future<String?> updateProfile(String name) async {
    if (_user == null) return 'Not logged in';
    final result = await _authService.updateProfile(
      userId: _user!.id,
      name: name,
    );
    if (result == null) {
      _user = _authService.currentUser;
      notifyListeners();
    }
    return result;
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_user == null) return 'Not logged in';
    return _authService.changePassword(
      userId: _user!.id,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
