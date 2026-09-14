import 'package:flutter/foundation.dart';

/// Minimal debug-only logger (Fase 0).
///
/// No new dependencies on purpose: wraps [debugPrint] and is a no-op in
/// release builds so tokens / PII can never leak to production logs.
/// Do NOT log PANs, card tokens, JWTs or refresh tokens.
class AppLogger {
  const AppLogger._();

  static void debug(String message) {
    if (kDebugMode) debugPrint('[ETIA] $message');
  }

  static void info(String message) {
    if (kDebugMode) debugPrint('[ETIA:i] $message');
  }

  static void warning(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('[ETIA:w] $message${error == null ? '' : ' | $error'}');
    }
  }

  static void error(String message, [Object? error, StackTrace? stack]) {
    if (kDebugMode) {
      debugPrint('[ETIA:e] $message${error == null ? '' : ' | $error'}');
      if (stack != null) debugPrint('$stack');
    }
  }
}
