// android/app/build.gradle.kts  (app module)
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.cetacealab.heattrip"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.cetacealab.heattrip"   // ← 최종 패키지명
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        // 개발 단계: 축소 기능 OFF (에러 차단)
        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
        }
        getByName("release") {
            // 지금은 임시로 debug 키로 서명해도 됨(출시 전)
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
            // 출시 직전에는:
            //   - release 서명키 연결
            //   - isMinifyEnabled = true, isShrinkResources = true
            //   - proguardFiles(...) 설정
        }
    }
}

flutter {
    source = "../.."
}