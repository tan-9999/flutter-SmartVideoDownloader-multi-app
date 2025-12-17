plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // Flutter Gradle Plugin must be applied after Android + Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.smart_video_downloader"
    compileSdk = 35
    ndkVersion = "27.0.12077973"   // ✅ force NDK 27

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.smart_video_downloader"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
            // Temporary signing config so release builds work
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
