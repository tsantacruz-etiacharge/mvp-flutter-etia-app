plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    // Injects secrets.properties values as ${NAME} Manifest placeholders.
    id("com.google.android.libraries.mapsplatform.secrets-gradle-plugin")
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

flutter {
    source = "../.."
}
