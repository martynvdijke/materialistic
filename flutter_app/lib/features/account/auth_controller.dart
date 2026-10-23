import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/item.dart';
import '../../core/network/hn_auth_service.dart';

/// Owns the signed-in Hacker News account and protected actions.
class AuthController extends ChangeNotifier {
  AuthController(this._service, this._storage, this._preferences);

  static const _usernameKey = 'hn_username';
  static const _passwordKey = 'hn_password';

  final HnAuthService _service;
  final FlutterSecureStorage _storage;
  final SharedPreferences _preferences;

  String? _username;
  String? _password;
  bool _loading = true;

  String? get username => _username;
  bool get isLoggedIn => _username != null;
  bool get loading => _loading;

  Future<void> restore() async {
    _username = await _storage.read(key: _usernameKey);
    _password = await _storage.read(key: _passwordKey);
    if (_username != null && _password == null) {
      _username = null;
    }
    _loading = false;
    notifyListeners();
  }

  Future<AuthResult> login({
    required String username,
    required String password,
    bool createAccount = false,
    String? email,
  }) async {
    final result = await _service.login(
      username: username,
      password: password,
      createAccount: createAccount,
      email: email,
    );
    if (result.success) {
      _username = username;
      _password = password;
      await _storage.write(key: _usernameKey, value: username);
      await _storage.write(key: _passwordKey, value: password);
      await _preferences.setString('pref_username', username);
      notifyListeners();
    }
    return result;
  }

  Future<void> logout() async {
    _username = null;
    _password = null;
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _passwordKey);
    await _preferences.remove('pref_username');
    notifyListeners();
  }

  Future<bool> vote(Item item) async {
    if (!isLoggedIn) return false;
    return _service.vote(
      username: _username!,
      password: _password!,
      itemId: item.id,
    );
  }

  Future<bool> comment(Item parent, String text) async {
    if (!isLoggedIn) return false;
    return _service.comment(
      username: _username!,
      password: _password!,
      parentId: parent.id,
      text: text,
    );
  }

  Future<bool> submit({
    required String title,
    String? url,
    String? text,
  }) async {
    if (!isLoggedIn) return false;
    return _service.submit(
      username: _username!,
      password: _password!,
      title: title,
      url: url,
      text: text,
    );
  }
}
