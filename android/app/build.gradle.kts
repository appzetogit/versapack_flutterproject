import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// The Google Maps key is needed at manifest-merge time, long before Dart runs,
// so it is read here from the same `config/keys.env` that feeds --dart-define
// and the iOS xcconfig. One source, three consumers, no key text duplicated.
val appKeys = Properties().apply {
    val keysFile = rootProject.file("../config/keys.env")
    if (keysFile.exists()) {
        keysFile.inputStream().use { load(it) }
    } else {
        logger.warn(
            "config/keys.env not found — maps will render blank. " +
                "Copy config/keys.example.env to config/keys.env."
        )
    }
}

android {
    namespace = "com.quick.commerce"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Must match `package_name` in android/app/src/google-services.json and
        // the package restriction on the Google Maps key.
        applicationId = "com.quick.commerce"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Consumed by AndroidManifest.xml as the MAPS_API_KEY placeholder.
        manifestPlaceholders["MAPS_API_KEY"] =
            appKeys.getProperty("MAPS_API_KEY") ?: ""
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
