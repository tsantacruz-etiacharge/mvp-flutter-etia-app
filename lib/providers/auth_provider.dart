import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/api_client.dart';
import '../api/auth_api.dart';
import '../models/auth_tokens.dart';
import '../models/user.dart';

enum AuthState { loading, signedIn, signedOut, restoringSession, offline }

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  final api = ref.watch(apiClientProvider);
  return AuthProvider(api: api);
});

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

  /// True once the profile fetch settled (success or 404-without-profile).
  /// The router uses it to tell "still loading" apart from "needs onboarding".
  /// Mirrors UserDto|null|undefined in UserProvider.tsx.
  bool _userLoaded = false;
  bool get userLoaded => _userLoaded;

  bool _restoring = false;

  AuthProvider({required this._api}) {
    _api.setAuthGetter(() => _accessToken);
    _api.setOnUnauthorized(_restoreSession);
    _restoreSession();
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

  Future<void> signUp(String email, String password) async {
    await _api.authApi.signUp(email, password);
  }

  Future<void> signOut() async {
    await _storage.delete(key: 'AUTH_STORAGE');
    _accessToken = '';
    _userRef = null;
    _user = null;
    _userLoaded = false;
    _authState = AuthState.signedOut;
    notifyListeners();
  }

  Future<void> restoreSession() async {
    _restoring = false;
    await _restoreSession();
  }

  Future<void> _restoreSession() async {
    if (_restoring) return;
    _restoring = true;
    _authState = AuthState.restoringSession;
    notifyListeners();

    final refreshToken = await _storage.read(key: 'AUTH_STORAGE');
    if (refreshToken == null) {
      _authState = AuthState.signedOut;
      _restoring = false;
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _storage.delete(key: 'AUTH_STORAGE');
        _authState = AuthState.signedOut;
      } else {
        _authState = AuthState.offline;
      }
    } catch (_) {
      _authState = AuthState.offline;
    } finally {
      _restoring = false;
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    await _fetchUser();
  }

  Future<void> _fetchUser() async {
    if (_userRef == null) {
      _user = null;
      _userLoaded = true;
      notifyListeners();
      return;
    }
    try {
      _user = await _api.referenceApi.findByReference(_userRef!, User.fromJson);
      _userLoaded = true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Auth exists but no profile yet -> onboarding (complete-profile).
        // Mirrors UserProvider.tsx 404 -> setUser(null).
        _user = null;
        _userLoaded = true;
      }
      // Other errors (offline, 500...): keep the previous user, same as prod
      // which swallows non-404 errors without touching state.
    } catch (_) {
      // Non-Dio errors: same, keep previous state.
    }
    notifyListeners();
  }

  Future<void> _saveTokens(AuthTokens tokens) async {
    await _storage.write(key: 'AUTH_STORAGE', value: tokens.refreshToken);
  }
}
