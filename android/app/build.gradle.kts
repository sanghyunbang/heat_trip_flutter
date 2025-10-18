import java.util.Properties
import java.io.FileInputStream

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
    
    // ----- 서명 설정: key.properties 읽기 -----
    // key.properties 읽기
    val keystoreProps = Properties()
    val keystoreFile = rootProject.file("key.properties")
    if (keystoreFile.exists()) {
        FileInputStream(keystoreFile).use { fis ->
            keystoreProps.load(fis)
        }
    } else {
        throw GradleException("Missing android/key.properties for release signing")
    }


    signingConfigs {
        // 출시 전까지 debug로 임시 서명하던 것을, release 서명으로 대체
        create("release") {
            // key.properties가 있으면 값 적용
            if (keystoreProps.isNotEmpty()) {
                storeFile = file(keystoreProps["storeFile"] as String)
                storePassword = keystoreProps["storePassword"] as String
                keyAlias = keystoreProps["keyAlias"] as String
                keyPassword = keystoreProps["keyPassword"] as String
            } else {
                // 안전장치: 없으면 빌드 실패 유도(스토어 제출 전 반드시 설정해야 함)
                throw GradleException("Missing android/key.properties for release signing")
            }
        }
    }

    buildTypes {
        // 개발 단계: 축소 기능 OFF (에러 차단)
        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
            // 디버그 빌드에서는 디버그 서명 그대로 사용
            signingConfig = signingConfigs.getByName("debug")
        }

        // 출시(릴리스): 반드시 release 키로 서명 + 축소/리소스 제거 ON
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            isDebuggable = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        // getByName("release") {
        //     // 지금은 임시로 debug 키로 서명해도 됨(출시 전)
        //     signingConfig = signingConfigs.getByName("debug")
        //     isMinifyEnabled = false
        //     isShrinkResources = false
        //     // 출시 직전에는:
        //     //   - release 서명키 연결
        //     //   - isMinifyEnabled = true, isShrinkResources = true
        //     //   - proguardFiles(...) 설정
        // }
    }
}

flutter {
    source = "../.."
}