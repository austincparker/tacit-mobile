import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
}

val localProperties = Properties().apply {
    val localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        localPropertiesFile.inputStream().use { load(it) }
    }
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

fun buildVersionCode(): Int {
    val parts = flutterVersionName.split(".")
    val major = parts.getOrNull(0)?.toInt() ?: 0
    val minor = parts.getOrNull(1)?.toInt() ?: 0
    val patch = parts.getOrNull(2)?.toInt() ?: 0
    val code = flutterVersionCode.toInt()
    
    if (major >= 21) throw GradleException("Major version cannot exceed 20")
    if (minor >= 100) throw GradleException("Minor version cannot exceed 99")
    if (patch >= 100) throw GradleException("Patch version cannot exceed 99")
    if (code >= 10000) throw GradleException("Build number cannot exceed 9999")
    
    return (major * 100000000) + (minor * 1000000) + (patch * 10000) + code
}

android {
    namespace = "com.tacitproject.flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = System.getenv("ANDROID_NDK_VERSION") ?: "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.tacitproject.flutter"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = buildVersionCode()
        versionName = flutterVersionName
        multiDexEnabled = true
    }

    flavorDimensions += "flavor-type"
    
    productFlavors {
        create("production") {
            dimension = "flavor-type"
            applicationId = "com.tacitproject.flutter"
            resValue("string", "app_name", "Tacit Mobile")
        }
        
        create("staging") {
            dimension = "flavor-type"
            applicationId = "com.tacitproject.flutter.staging"
            resValue("string", "app_name", "Tacit Mobile (Staging)")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    lint {
        checkReleaseBuilds = false
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}