// android/app/build.gradle

// ✅ أضف Google Services plugin
plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // ← أضف هذا السطر
}

android {
    // ✅ تأكد من أن الـ namespace يطابق الـ package name في Firebase
    namespace = "com.example.frontend"  // ← هذا يجب أن يطابق ما في Firebase
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // ✅ هذا هو الـ Application ID المهم جداً
        applicationId = "com.example.frontend"  // ← يجب أن يطابق ما في Firebase
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // ✅ تأكد من أن minSdk لا يقل عن 21 لدعم Firebase
        minSdk = 21  // أو flutter.minSdkVersion
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
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

// ✅ (اختياري) يمكنك إضافة هذا للتأكد من أن google-services.json موجود
tasks.whenTaskAdded {
    if (name == "processDebugGoogleServices" || name == "processReleaseGoogleServices") {
        dependsOn(":app:copyGoogleServices")
    }
}