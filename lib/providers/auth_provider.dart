import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';
import '../api/auth_api.dart';
import '../models/auth_tokens.dart';
import '../models/user.dart';

enum AuthState { loading, signedIn, signedOut, restoringSession, offline }

class AuthProvider extends ChangeNotifier {
  final ApiClient _api;
  final _storage = const FlutterSecureStorage();

  AuthState _authState = AuthState.loading;
  AuthState get authState => _authState;

  String? _userRef;
  String? get userRef => _userRef;

  String _accessToken = '';
  String get accessToken => _accessToken;

  User? _user;
  User? get user => _user;

  bool _restoring = false;

  AuthProvider({required ApiClient api}) : _api = api {
    _api.setAuthGetter(() => _accessToken);
    _api.setOnUnauthorized(_restoreSession);
    _init();
  }

  Future<void> _init() async {
    await _restoreSession();
  }

  Future<void> signIn(String email, String password) async {
    final tokens = await _api.authApi.signIn(email, password);
    await _saveTokens(tokens);
    _accessToken = tokens.accessToken;
    final authData = AuthApi.decodeToken(tokens.accessToken);
    _userRef = authData.user;
    await _fetchUser();
    _authState = AuthState.signedIn;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _storage.delete(key: 'AUTH_STORAGE');
    _accessToken = '';
    _userRef = null;
    _user = null;
    _authState = AuthState.signedOut;
    notifyListeners();
  }

  Future<void> _restoreSession() async {
    if (_restoring) return;
    _restoring = true;
    _authState = AuthState.restoringSession;
    notifyListeners();

    try {
      final refreshToken = await _storage.read(key: 'AUTH_STORAGE');
      if (refreshToken == null) {
        _authState = AuthState.signedOut;
        notifyListeners();
        return;
      }

      try {
        final tokens = await _api.authApi.refreshToken(refreshToken);
        await _saveTokens(tokens);
        _accessToken = tokens.accessToken;
        final authData = AuthApi.decodeToken(tokens.accessToken);
        _userRef = authData.user;
        await _fetchUser();
        _authState = AuthState.signedIn;
      } catch (e) {
        await _storage.delete(key: 'AUTH_STORAGE');
        _authState = AuthState.signedOut;
      }
    } catch (e) {
      _authState = AuthState.offline;
    } finally {
      _restoring = false;
      notifyListeners();
    }
  }

  Future<void> _fetchUser() async {
    if (_userRef == null) return;
    try {
      _user = await _api.referenceApi.findByReference(
        _userRef!,
        User.fromJson,
      );
      notifyListeners();
    } catch (e) {
      _user = null;
    }
  }

  Future<void> _saveTokens(AuthTokens tokens) async {
    await _storage.write(key: 'AUTH_STORAGE', value: tokens.refreshToken);
  }
}
