import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 환경변수 관리 클래스
/// .env 파일에서 설정값을 읽어와 앱 전반에서 사용할 수 있도록 제공
class Env {
  /// 메인 API 서버의 기본 URL을 반환
  ///
  /// 우선순위:
  /// 1. .env 파일의 API_BASE_URL 값
  /// 2. 기본값: 'http://10.0.2.2:8080' (Android 에뮬레이터에서 localhost:8080 접근용)
  ///
  /// 사용 예시:
  /// ```dart
  /// final response = await http.get(Uri.parse('${Env.apiBase}/users'));
  /// ```
  ///
  /// 참고: 10.0.2.2는 Android 에뮬레이터에서 호스트 머신의 localhost를 가리키는 특수 IP
  static String get apiBase =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080';

  /// 추천 시스템(Recommendation System) API 서버의 URL을 반환
  ///
  /// 우선순위:
  /// 1. .env 파일의 API_RECSYS_URL 값
  /// 2. 기본값: 'http://10.0.2.2:8000' (Android 에뮬레이터에서 localhost:8000 접근용)
  ///
  /// 사용 예시:
  /// ```dart
  /// final response = await http.post(
  ///   Uri.parse('${Env.apiRecsys}/recommend'),
  ///   body: jsonEncode(userPreferences),
  /// );
  /// ```
  ///
  /// 참고:
  /// - 메인 API(8080)와 추천 API(8000)를 분리한 마이크로서비스 아키텍처
  /// - Python FastAPI나 Flask로 구현된 추천 서버일 가능성 높음
  static String get apiRecsys =>
      dotenv.env['API_RECSYS_URL'] ?? 'http://10.0.2.2:8000';
}
