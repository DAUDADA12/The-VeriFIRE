// This file is the app-level build.gradle.kts (Kotlin DSL)

// NOTE: We are using the idiomatic KTS method to apply plugins to force Gradle to re-evaluate the block.
plugins {
    // 1. Core Android Application plugin (MANDATORY)
    id("com.android.application")

    // 2. Kotlin Android plugin
    id("org.jetbrains.kotlin.android") 
    
    // 3. Google Services plugin (for Firebase)
    id("com.google.gms.google-services")

    // 4. Flutter Gradle plugin (must be applied after Android/Kotlin)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.vitmuteam.the_verifire"
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.vitmuteam.the_verifire"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // 🛑 FIX 1: Enable MultiDex for large applications like those using Firebase
        multiDexEnabled = true 
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies{
    // 🛑 FIX 2: Add the MultiDex dependency
    implementation("androidx.multidex:multidex:2.0.1") 

    implementation(platform("com.google.firebase:firebase-bom:34.6.0"))
    implementation("com.google.firebase:firebase-analytics")
}


flutter {
    source = "../.."
}