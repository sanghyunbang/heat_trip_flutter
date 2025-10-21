import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // (= "kotlin-android")
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
    kotlinOptions { jvmTarget = "17" }

    defaultConfig {
        applicationId = "com.cetacealab.heattrip"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ==== [변경 1] 빌드 태스크가 release 인지 확인 ====
    val isReleaseTask = gradle.startParameter.taskNames.any {
        it.contains("Release", ignoreCase = true)
    }

    // ==== [변경 2] keystore 파일 유무만 체크 (경로 명확화) ====
    // 프로젝트 루트/android/key.properties 를 권장
    val keystorePath = rootProject.file("android/key.properties")
    val hasKeystore = keystorePath.exists()

    // ==== [변경 3] 필요할 때만 로드 ====
    val keystoreProps = Properties()
    if (isReleaseTask && hasKeystore) {
        FileInputStream(keystorePath).use { keystoreProps.load(it) }
    }

    signingConfigs {
        // 디버그: 안 건드려도 Android 기본 debug.keystore 사용
        getByName("debug")

        // 릴리스: 파일 있을 때만 생성
        if (hasKeystore) {
            create("release") {
                storeFile = file(keystoreProps["storeFile"] as String)
                storePassword = keystoreProps["storePassword"] as String
                keyAlias = keystoreProps["keyAlias"] as String
                keyPassword = keystoreProps["keyPassword"] as String
            }
        }
    }

    buildTypes {
        // 디버그는 항상 빌드 가능
        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("debug")
        }

        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            isDebuggable = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            // ==== [변경 4] 릴리스 시 처리 방침 ====
            if (hasKeystore) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                // (A) 로컬에서 릴리스 빌드 자체를 막기 — 권장
                throw GradleException("Missing android/key.properties for release signing")
                // (B) 또는 임시로 디버그 키로 릴리스 빌드 (스토어 제출 전 반드시 교체)
                // signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

flutter { source = "../.." }
