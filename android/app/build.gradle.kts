plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    // Injects secrets.properties values as ${NAME} Manifest placeholders.
    id("com.google.android.libraries.mapsplatform.secrets-gradle-plugin")
    // Required by the Mercado Pago card form (Compose UI).
    id("org.jetbrains.kotlin.plugin.compose")
}

secrets {
    propertiesFileName = "secrets.properties"
}

android {
    // Production ID (matches etia-user-app app.config.ts).
    // Dev/preview suffixes (.dev/.prev) come with full flavors in Fase 6.
    namespace = "io.etiaapp.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "io.etiaapp.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Deep-link scheme default (etia-dev only for dev flavor in Fase 6).
        // Mirrors etia-user-app SCHEME (app.config.ts).
        manifestPlaceholders["APP_SCHEME"] = "etia"
    }

    buildFeatures {
        compose = true
    }

    buildTypes {
        release {
            // TODO(Fase 6): replace with real release signing config.
            // Debug keys only so `flutter run --release` works locally.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    // AndroidX Activity Compose (for setContent in ComponentActivity)
    implementation("androidx.activity:activity-compose:1.9.3")

    // Compose BOM (required by MercadoPago SDK)
    implementation(platform("androidx.compose:compose-bom:2024.12.01"))
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.foundation:foundation")
    implementation("androidx.compose.ui:ui-tooling-preview")

    // Mercado Pago SDK (same versions as prueba-flutter-MP)
    implementation(platform("com.mercadopago.android.sdk:sdk-android-bom:1.0.0"))
    implementation("com.mercadopago.android.sdk:core-methods")
}

flutter {
    source = "../.."
}
