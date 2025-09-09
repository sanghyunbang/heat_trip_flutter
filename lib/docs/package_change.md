### 1. 패키지 변경과 관련해서 경로 설정 변경

cd C:\Users\mm206\git_projects\heat_trip_flutter

# 1) com/example → com/cetacealab 로 '내용물' 이동
mkdir android\app\src\main\kotlin\com\cetacealab -ea 0
git mv -f android/app/src\main\kotlin\com\example\* `
       android/app/src\main\kotlin\com\cetacealab\

# (숨김파일이 남아 있을 수 있으니, 폴더 비었으면 지움)
git rm -r android/app/src\main\kotlin\com\example

# 2) 하위 폴더 heat_trip_flutter → heattrip
#   (이미 com\cetacealab\heattrip 가 있으면, 내용물만 이동 후 원본 제거)
if (Test-Path android/app/src\main\kotlin\com\cetacealab\heattrip) {
  git mv -f android/app/src\main\kotlin\com\cetacealab\heat_trip_flutter\* `
         android/app/src\main\kotlin\com\cetacealab\heattrip\
  git rm -r android/app/src\main\kotlin\com\cetacealab\heat_trip_flutter
} else {
  git mv android/app/src\main\kotlin\com\cetacealab\heat_trip_flutter `
        android/app/src\main\kotlin\com\cetacealab\heattrip
}

# 3) 커밋/푸시
git add -A
git commit -m "Rename folders: com/example→com/cetacealab, heat_trip_flutter→heattrip"
git push


### 2. 심볼릭 링크 설정하는 방법

cd C:\Users\mm206\git_projects\heat_trip_flutter

# 0) 기존 링크/폴더 정리
Remove-Item -Recurse -Force .\build -ErrorAction SilentlyContinue

# 1) 상위 디렉터리 준비
New-Item -ItemType Directory -Force .\build\app\outputs | Out-Null

# 2) 먼저 Gradle로 실제 APK 생성 (디버그)
cd android
.\gradlew.bat assembleDebug
cd ..

# 3) Flutter가 기대하는 경로에 '정확히' 연결
#    build/app/outputs/flutter-apk  →  android/app/build/outputs/apk/debug
New-Item -ItemType Junction `
  -Path .\build\app\outputs\flutter-apk `
  -Target .\android\app\build\outputs\apk\debug

# 4) 확인: 여기서 app-debug.apk 가 보여야 정상
Get-Item .\build\app\outputs\flutter-apk | Format-List FullName,LinkType,Target
Get-ChildItem .\build\app\outputs\flutter-apk
