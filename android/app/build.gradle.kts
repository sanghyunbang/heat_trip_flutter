// android/app/build.gradle.kts

import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
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

    // 현재 실행 중인 태스크가 릴리스인지 판별
    val isReleaseTask = gradle.startParameter.taskNames.any { it.contains("Release", ignoreCase = true) }

    // 후보 경로 두 곳 모두 탐색
    val keyPropCandidates = listOf(
        rootProject.file("android/key.properties"),
        rootProject.file("key.properties") // 과거 호환
    )
    val keyPropFile = keyPropCandidates.firstOrNull { it.exists() }
    val hasKeystore = keyPropFile != null

    signingConfigs {
        getByName("debug")

        if (hasKeystore) {
            create("release") {
                // ← 여기서 '즉시' 로드하여 설정 단계 NPE/예외 방지
                val props = Properties().also { p ->
                    FileInputStream(keyPropFile!!).use(p::load)
                }
                fun Properties.req(k: String) =
                    this[k]?.toString() ?: throw GradleException("key.properties is missing: $k")

                // storeFile 경로는 app 모듈 기준 상대경로 권장 (예: app/keystore.jks)
                storeFile = file(props.req("storeFile"))
                storePassword = props.req("storePassword")
                keyAlias = props.req("keyAlias")
                keyPassword = props.req("keyPassword")
            }
        }
    }

    buildTypes {
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

            when {
                hasKeystore -> signingConfig = signingConfigs.getByName("release")
                isReleaseTask -> throw GradleException(
                    "Missing android/key.properties (or root key.properties) for release signing.\n" +
                    "Add the file or switch to a non-release task."
                )
                else -> signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

flutter { source = "../.." }
