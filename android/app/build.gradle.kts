// android/app/build.gradle.kts
// -----------------------------------------------------------------------------
// 목적
// - 디버그(개발) 빌드는 key.properties 없이 항상 빌드 가능
// - 릴리스 빌드(assembleRelease/bundleRelease)일 때만 서명 파일을 읽고 엄격히 검증
// - key.properties 경로와 .gitignore 정책을 표준화(android/key.properties)
// -----------------------------------------------------------------------------

import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")      // (= "kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter Gradle 플러그인
}

android {
    // ──────────────────────────────────────────────────────────────────────────
    // [앱 기본 메타]
    // ──────────────────────────────────────────────────────────────────────────
    namespace = "com.cetacealab.heattrip"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        // 자바 17 타깃
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

    // ──────────────────────────────────────────────────────────────────────────
    // [서명 파일 로딩 정책]
    //   - 구성(Configuration) 단계에서 실패하지 않도록 "조건부 로드"만 수행.
    //   - 실제 실패(throw)는 릴리스 buildType 내부에서만 일으킴.
    // ──────────────────────────────────────────────────────────────────────────

    // ① 현재 Gradle 태스크가 릴리스 계열인지(assembleRelease/bundleRelease 등) 검사
    val isReleaseTask = gradle.startParameter.taskNames.any {
        it.contains("Release", ignoreCase = true)
    }

    // ② 서명 파일 표준 경로(프로젝트 루트 기준) → android/key.properties
    //    ※ 루트에 두지 않고 android/ 아래에 두는 이유: 안드 폴더와 결합, gitignore 관리 용이
    val keystoreFile = rootProject.file("android/key.properties")
    val hasKeystore = keystoreFile.exists()

    // ③ 필요 시에만 key.properties를 로드(없거나 디버그면 로드하지 않음)
    val keystoreProps = Properties().also { props ->
        if (hasKeystore && isReleaseTask) {
            FileInputStream(keystoreFile).use(props::load)
        }
    }

    // ④ Properties 안전 접근 헬퍼 (키가 없으면 명확한 에러 메시지)
    fun Properties.req(key: String): String =
        this[key]?.toString()
            ?: throw GradleException("key.properties is missing required entry: $key")

    // ──────────────────────────────────────────────────────────────────────────
    // [Signing Configs]
    //   - debug: Android가 제공하는 기본 debug.keystore 사용
    //   - release: 파일이 있을 때만 생성(없으면 buildTypes.release에서 정책 처리)
    // ──────────────────────────────────────────────────────────────────────────
    signingConfigs {
        // 디버그: 명시만 해도 기본 debug.keystore 사용
        getByName("debug")

        // 릴리스: 키파일이 실제 존재할 때만 구성 생성
        if (hasKeystore) {
            create("release") {
                // 릴리스 태스크일 때만 로드했으므로 isReleaseTask가 false인 경우
                // 아래 req() 호출은 실행되지 않음(Gradle은 지연평가 형태로 동작)
                storeFile = file(keystoreProps.req("storeFile"))
                storePassword = keystoreProps.req("storePassword")
                keyAlias = keystoreProps.req("keyAlias")
                keyPassword = keystoreProps.req("keyPassword")
            }
        }
    }

    // ──────────────────────────────────────────────────────────────────────────
    // [Build Types]
    // ──────────────────────────────────────────────────────────────────────────
    buildTypes {
        // 개발(디버그) 빌드: 축소/리소스 제거 OFF, 디버그 키로 서명
        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("debug")
        }

        // 릴리스 빌드: 축소/리소스 제거 ON, proguard 적용
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            isDebuggable = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            when {
                // (정상경로) 키가 있으면 release 서명 구성 사용
                hasKeystore -> signingConfig = signingConfigs.getByName("release")

                // (보안 우선) 릴리스 태스크인데 키가 없음 → 의도적으로 실패
                isReleaseTask -> throw GradleException(
                    "Missing android/key.properties for release signing.\n" +
                    "Add the file or switch to a non-release task."
                )

                // (개발 편의) 릴리스 태스크가 아닌데 키가 없음 → 디버그 키로 임시 서명
                // 스토어 제출 전 반드시 위 정책으로 되돌릴 것
                else -> signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

// Flutter 소스 루트
flutter { source = "../.." }
