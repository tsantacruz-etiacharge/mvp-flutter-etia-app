// Environment / flavor configuration.
//
// Values are injected at compile time with --dart-define, e.g.:
//   flutter run --dart-define=APP_VARIANT=dev \
//     --dart-define=API_URL=https://dev-backend.../rest \
//     --dart-define=GOOGLE_MAPS_API_KEY=... \
//     --dart-define=MP_PUBLIC_KEY=...
//
// Native keys (Android secrets.properties / iOS Secrets.xcconfig) use the
// same values; see android/secrets.properties.example and
// ios/Flutter/Secrets.xcconfig.example.
// Mirrors etia-user-app variants: dev / preview / production
// (app.config.ts: EXPO_PUBLIC_APP_VARIANT).

/// Must match EXPO_PUBLIC_APP_VARIANT values in etia-user-app.
enum AppVariant { dev, preview, production }

class Env {
  const Env._();

  static const String appVariantRaw = String.fromEnvironment(
    'APP_VARIANT',
    defaultValue: 'production',
  );

  static AppVariant get appVariant {
    switch (appVariantRaw) {
      case 'dev':
        return AppVariant.dev;
      case 'preview':
      case 'prev':
        return AppVariant.preview;
      case 'production':
      case 'prod':
      default:
        return AppVariant.production;
    }
  }

  /// REST base URL. Matches EXPO_PUBLIC_API_URL in etia-user-app.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://etia-backend-ubes5.ondigitalocean.app/rest',
  );

  /// Google Maps key for Dart-side use (native keys live in
  /// secrets.properties / Secrets.xcconfig).
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  /// Mercado Pago public key (TEST-... / APP_USR-...). Never put the
  /// access token in the app. Used by Fase 4 payments.
  static const String mpPublicKey = String.fromEnvironment(
    'MP_PUBLIC_KEY',
    defaultValue: '',
  );

  /// Deep-link scheme. Mirrors app.config.ts SCHEME (etia-dev / etia).
  static String get appScheme =>
      appVariant == AppVariant.dev ? 'etia-dev' : 'etia';

  static bool get isDev => appVariant == AppVariant.dev;
  static bool get isPreview => appVariant == AppVariant.preview;
  static bool get isProduction => appVariant == AppVariant.production;
}

/// Backwards-compatible top-level constant (used by api_client.dart).
/// Prefer [Env.apiBaseUrl] in new code.
const String apiBaseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'https://etia-backend-ubes5.ondigitalocean.app/rest',
);
