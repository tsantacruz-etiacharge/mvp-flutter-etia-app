import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../config/env.dart';
import '../utils/force_update.dart';
import 'auth_provider.dart';

/// Mirrors ForceUpdateProvider.tsx in etia-user-app.
///
/// Watches the `x-app-supported-range` header on every API response (wired
/// via [ApiClient.onSupportedRange]) plus an initial `GET /`, and latches
/// [isForceUpdateRequired] when [Env.appVersion] falls outside the range.
/// Once latched it never unsets (only an app update fixes it).
final forceUpdateProvider =
    ChangeNotifierProvider<ForceUpdateProvider>((ref) {
  final api = ref.watch(apiClientProvider);
  return ForceUpdateProvider(api: api);
});

class ForceUpdateProvider extends ChangeNotifier {
  final ApiClient _api;

  bool _required = false;
  bool get isForceUpdateRequired => _required;

  ForceUpdateProvider({required this._api}) {
    _api.onSupportedRange = processSupportedRange;
    _checkInitial();
  }

  void processSupportedRange(String range) {
    if (range.trim().isEmpty || _required) return;
    if (!isVersionSupported(Env.appVersion, range)) {
      _required = true;
      notifyListeners();
    }
  }

  Future<void> _checkInitial() async {
    // Header (if any) is processed by the ApiClient response interceptor.
    try {
      await _api.dio.get('/');
    } catch (_) {
      // Swallowed on purpose, same as the TS original.
    }
  }
}
