import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  AuthService(this._prefs);

  final SharedPreferences _prefs;
  static const _uuid = Uuid();

  Box<String> get _usersBox => Hive.box<String>(AppConstants.usersBox);
  Box<String> get _resetTokensBox =>
      Hive.box<String>(AppConstants.resetTokensBox);

  String _generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(values);
  }

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode('$password$salt');
    return sha256.convert(bytes).toString();
  }

  AppUser? get currentUser {
    final userId = _prefs.getString(AppConstants.sessionKey);
    if (userId == null) return null;
    return _getUserById(userId);
  }

  AppUser? _getUserById(String id) {
    final json = _usersBox.get(id);
    if (json == null) return null;
    return AppUser.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  AppUser? _getUserByEmail(String email) {
    for (final json in _usersBox.values) {
      final user = AppUser.fromJson(jsonDecode(json) as Map<String, dynamic>);
      if (user.email.toLowerCase() == email.toLowerCase()) {
        return user;
      }
    }
    return null;
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty) return 'Name is required';
    if (email.trim().isEmpty) return 'Email is required';
    if (password.length < 6) return 'Password must be at least 6 characters';

    if (_getUserByEmail(email) != null) {
      return 'An account with this email already exists';
    }

    final salt = _generateSalt();
    final user = AppUser(
      id: _uuid.v4(),
      name: name.trim(),
      email: email.trim().toLowerCase(),
      passwordHash: _hashPassword(password, salt),
      salt: salt,
      createdAt: DateTime.now(),
    );

    await _usersBox.put(user.id, jsonEncode(user.toJson()));
    await _prefs.setString(AppConstants.sessionKey, user.id);
    return null;
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final user = _getUserByEmail(email);
    if (user == null) return 'Invalid email or password';

    final hash = _hashPassword(password, user.salt);
    if (hash != user.passwordHash) return 'Invalid email or password';

    await _prefs.setString(AppConstants.sessionKey, user.id);
    return null;
  }

  Future<void> logout() async {
    await _prefs.remove(AppConstants.sessionKey);
  }

  Future<String?> updateProfile({
    required String userId,
    required String name,
  }) async {
    if (name.trim().isEmpty) return 'Name is required';

    final user = _getUserById(userId);
    if (user == null) return 'User not found';

    user.name = name.trim();
    await _usersBox.put(user.id, jsonEncode(user.toJson()));
    return null;
  }

  Future<String?> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    if (newPassword.length < 6) {
      return 'New password must be at least 6 characters';
    }

    final user = _getUserById(userId);
    if (user == null) return 'User not found';

    final hash = _hashPassword(currentPassword, user.salt);
    if (hash != user.passwordHash) return 'Current password is incorrect';

    user.passwordHash = _hashPassword(newPassword, user.salt);
    await _usersBox.put(user.id, jsonEncode(user.toJson()));
    return null;
  }

  Future<String?> requestPasswordReset(String email) async {
    final user = _getUserByEmail(email);
    if (user == null) {
      return 'No account found with this email';
    }

    final token = _uuid.v4();
    await _resetTokensBox.put(
      token,
      jsonEncode({
        'userId': user.id,
        'expiresAt': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      }),
    );
    return token;
  }

  Future<String?> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    if (newPassword.length < 6) {
      return 'Password must be at least 6 characters';
    }

    final tokenData = _resetTokensBox.get(token);
    if (tokenData == null) return 'Invalid or expired reset token';

    final data = jsonDecode(tokenData) as Map<String, dynamic>;
    final expiresAt = DateTime.parse(data['expiresAt'] as String);
    if (DateTime.now().isAfter(expiresAt)) {
      await _resetTokensBox.delete(token);
      return 'Reset token has expired';
    }

    final userId = data['userId'] as String;
    final user = _getUserById(userId);
    if (user == null) return 'User not found';

    user.passwordHash = _hashPassword(newPassword, user.salt);
    await _usersBox.put(user.id, jsonEncode(user.toJson()));
    await _resetTokensBox.delete(token);
    return null;
  }
}
