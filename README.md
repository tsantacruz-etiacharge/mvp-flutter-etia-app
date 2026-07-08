# ETIA Maps - Prototipo Flutter + Google Maps

Prototipo descartable (POC) para evaluar la integración del plugin oficial de Google Maps en Flutter, replicando la experiencia de la app React Native `etia-user-app`.

## Estructura del Proyecto

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # MaterialApp + TabBar + navegación
├── theme/
│   └── colors.dart                    # Colores replicados de la app RN
├── data/
│   └── mock_data.dart                 # Datos dummy de 7 chargers
├── screens/
│   ├── map_screen.dart                # Google Map + marcadores custom + InfoCard
│   ├── home_screen.dart               # Dummy: gradiente azul, créditos
│   ├── history_screen.dart            # Dummy: historial de sesiones
│   └── more_screen.dart               # Dummy: menú de opciones
└── widgets/
    ├── charger_marker.dart            # Widget circular con borde por estado
    ├── charger_info_card.dart         # Card flotante al tocar marcador
    └── my_location_button.dart        # Botón flotante "Mi Ubicación"
```

## Cómo Ejecutar

### Prerrequisitos
- Flutter SDK 3.x instalado (`flutter --version`)
- Android SDK con cmdline-tools
- Chrome (para testing en web)

### Android
```bash
cd etia_maps_prototype
flutter pub get
flutter run
# Seleccionar dispositivo/emulador Android
```

### iOS (requiere macOS)
```bash
cd etia_maps_prototype
flutter pub get
cd ios && pod install && cd ..
flutter run -d ios
```

### Web
```bash
cd etia_maps_prototype
flutter run -d chrome
```

### Build APK (Android)
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

## Configuración de Plataforma

### Android (`android/app/build.gradle.kts`)
- `minSdk = 21` (requerido por google_maps_flutter)
- `ndkVersion = flutter.ndkVersion`
- API Key en `AndroidManifest.xml`: `com.google.android.geo.API_KEY`

### iOS (`ios/Runner/AppDelegate.swift`)
- `import GoogleMaps`
- `GMSServices.provideAPIKey("AIzaSyArCO9jpPhkSizIJXufh-7aJqNTZpylIrI")`
- Podfile: `platform :ios, '14.0'`

### Web (`web/index.html`)
- Script tag con Google Maps JavaScript API en `<head>`

## Datos Dummy

7 puntos de carga en Buenos Aires:

| Nombre | Estado | Potencia |
|--------|--------|----------|
| ETIA Palermo | Disponible | 22 kW |
| ETIA Recoleta | Ocupado | 50 kW |
| ETIA San Telmo | Disponible | 11 kW |
| ETIA Puerto Madero | No disponible | 150 kW |
| ETIA Belgrano | Disponible | 22 kW |
| ETIA Almagro | Ocupado | 30 kW |
| ETIA Flores | Disponible | 22 kW |

## Funcionalidades Implementadas

- **4 tabs** con navegación (Home, Mapa, Historial, Menú)
- **Botón central circular** (simula QR scanner)
- **Google Map** interactivo centrado en Buenos Aires
- **Marcadores custom** (widget circular con borde coloreado por estado):
  - Verde = Disponible
  - Amarillo = Ocupado
  - Gris = No disponible
- **Card informativa** al tocar un marcador (nombre, dirección, potencia, estado, botones)
- **Botón "Mi Ubicación"** que centra el mapa
- **Animación** al tocar marcador (centra con zoom)
- **Pantallas dummy** replicando la estética de la app RN (gradientes azules)

## API Key

Se utiliza la misma API Key de desarrollo del proyecto React Native:
`AIzaSyArCO9jpPhkSizIJXufh-7aJqNTZpylIrI`

## Limitaciones del POC

1. **Custom markers via Overlay**: Los marcadores se renderizan usando `OverlayEntry` + `RepaintBoundary` + `toImage()`. En algunos dispositivos/emuladores podría no funcionar el renderizado a imagen. Fallback: usar `BitmapDescriptor.defaultMarkerWithHue()` con colores por estado.

2. **InfoWindow nativo**: No se usa el `InfoWindow` nativo de Google Maps Flutter (que es un popup HTML nativo). En su lugar, se muestra un `ChargerInfoCard` como widget Flutter posicionado sobre el mapa, más similar a la app RN.

3. **Sin ubicación real**: El prototipo no solicita permisos de ubicación. El botón "Mi Ubicación" centra en Buenos Aires.

4. **IndexedStack**: Se usa `IndexedStack` para preservar el estado del mapa al cambiar de tab. Esto significa que todas las pantallas se mantienen en memoria.

## Decisiones Técnicas

| Decisión | Razón |
|----------|-------|
| `google_maps_flutter` único | Evaluar solo el plugin oficial, sin wrappers adicionales |
| `IndexedStack` para tabs | Preservar estado del mapa al navegar entre tabs |
| `RepaintBoundary` + `toImage` | Crear markers custom como BitmapDescriptor sin assets externos |
| Datos hardcodeados | El foco es performance del mapa, no la lógica de negocio |
| Sin state management | No hay estado real que manejar en un POC |
| `BottomAppBar` custom | Replicar el botón central circular de la app RN |
