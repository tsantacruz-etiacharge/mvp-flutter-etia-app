# ETIA User App — Flutter

Cliente Flutter de la app ETIA. Paridad funcional con `etia-user-app` (Expo React Native, producción).
Backend REST compartido. Pagos: Mercado Pago Checkout Pro vía backend (`POST {user}/credits → {url}`).

## Requisitos

- Flutter SDK 3.x (`flutter --version`)
- Android SDK con cmdline-tools / Xcode en macOS para iOS
- Acceso al backend REST (ver `API_URL`)

## Configuración inicial (una vez)

```bash
flutter pub get

# Android: claves nativas (no commitear)
cp android/secrets.properties.example android/secrets.properties
# editar android/secrets.properties con valores reales

# iOS: claves nativas (no commitear)
cp ios/Flutter/Secrets.xcconfig.example ios/Flutter/Secrets.xcconfig
# editar ios/Flutter/Secrets.xcconfig con valores reales
cd ios && pod install && cd ..
```

`android/secrets.properties` y `ios/Flutter/Secrets.xcconfig` están en `.gitignore`.
En Dart las mismas claves llegan por `--dart-define` (ver `lib/config/env.dart`).

## Cómo ejecutar

```bash
# Dev (scheme etia-dev)
flutter run --dart-define=APP_VARIANT=dev \
  --dart-define=API_URL=https://etia-backend-ubes5.ondigitalocean.app/rest \
  --dart-define=GOOGLE_MAPS_API_KEY=TU_KEY \
  --dart-define=MP_PUBLIC_KEY=TU_MP_PUBLIC_KEY

# Preview / producción (scheme etia)
flutter run --dart-define=APP_VARIANT=preview --dart-define=API_URL=...
flutter run --dart-define=APP_VARIANT=production --dart-define=API_URL=...
```

En VS Code hay configuraciones listas en `.vscode/launch.json` (completar con la URL del backend).

| Variante   | `APP_VARIANT` | Scheme    | Application ID (Android) |
| ---------- | ------------- | --------- | ------------------------ |
| dev        | `dev`         | `etia-dev`| `io.etiaapp.app` (+`.dev` con flavors, Fase 6) |
| preview    | `preview`     | `etia`    | `io.etiaapp.app` (+`.prev` con flavors, Fase 6) |
| production | `production`  | `etia`    | `io.etiaapp.app`         |

Versión alineada con producción: `3.2.1+10037` (`pubspec.yaml`, cf. `app.config.ts`).
El force-update compara esta versión contra el rango que expone el backend.

## Estructura

```
lib/
├── main.dart            # Entry point (EasyLocalization + ProviderScope)
├── app.dart             # MaterialApp.router + MessageOverlay
├── config/env.dart      # Env por --dart-define (API_URL, APP_VARIANT, keys)
├── router/app_router.dart # GoRouter + guards por AuthState
├── api/                 # Dio + ApiClient (timeout, retry 401 single-flight) + APIs por dominio
├── models/              # DTOs (fromJson manual)
├── providers/           # Riverpod: auth, session, companies, message
├── screens/             # Pantallas (auth, home, map, history, more, unlock, charging…)
├── widgets/             # Design system reutilizable
└── utils/               # validators, maps, week_time, app_logger
android/
├── secrets.properties.example  # plantilla (copiar a secrets.properties, no commit)
ios/Flutter/
├── Secrets.xcconfig.example    # plantilla (copiar a Secrets.xcconfig, no commit)
```

## Convenciones Fase 0

- Env: nunca hardcodear URLs/keys en Dart; usar `Env.*` (`lib/config/env.dart`).
- Red: timeouts en `ApiClient`; 401 con single-flight y sin retry en `/auth/*`;
  logs solo en debug con `AppLogger` (nunca PANs, tokens ni JWTs).
- Deep link reservado: `etia://payment-result` (retorno de pago, Fase 4).
- Lints: `avoid_print` activo (usar `AppLogger`).

## Estado de la migración

Ver auditoría inicial: pantallas/auth/mapa/unlock/historial/perfil conectados al backend real.
Pendiente: `complete-profile`, `force-update`, `CountryApi`, compra de créditos/MP (Fases 1 y 4),
polling de carga, hardening de release (signing, flavors `.dev`/`.prev`, ofuscación).
