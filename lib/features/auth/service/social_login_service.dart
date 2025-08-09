import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'token_storage.dart';

/// 소셜 로그인 기능을 담당하는 클래스
/// 이 클래스는 외부 브라우저를 열어 소셜 로그인 후 앱으로 돌아오는 기능을 제공합니다.
/// 또한, URL에 포함된 JWT 토큰을 추출하여 SharedPreferences에 저장

class SocialLoginService {
  /// [provide]에는 'google', 'kakao', 'naver' 중 하나의 문자열이 들어갑니다.
  /// 예 : signIn('google' or 'kakao' or 'naver') -> 백엔드의 /oauth2/authorize 엔드포인트로 리다이렉트

  static Future<bool> signIn(String provider) async {
    print("소셜 로그인 시작");

    final baseUrl = dotenv.env['API_BASE_URL'];

    try {
      // 1. 백엔드에 정의된 소셜 로그인 시작 URL을 생성 (0731 기준 여기서 먼저 정함 -> 이후 백단에서 이걸로 설정)
      // Spring Boot에서 DefaultOAuth2AuthroizationRequestRedirectionFilter 가 /oauth2/authorize/* 경로를 가로채서 동작
      final url = "$baseUrl/oauth2/authorization/$provider";

      // 2. 외부 브라우저를 열어 소셜 로그인 페이지로 이동
      // 로그인이 완료되면 앱으로 돌아오는 딥링크 스킴은 "heattrip"으로 지정

      final result = await FlutterWebAuth2.authenticate(
        url: url,
        callbackUrlScheme: "heattrip",
      );

      // 3. 브라우저에서 로그인 완료하면, 앱으로 리디렉션된 URL에서 JWT 토큰 추출
      // 예: heattrip://login-callback?token=eyJhbGciOi... 라면
      // result == 'heattrip://login-callback?token=...'
      print("[디버그] Returned result URL: $result"); // 여기에 뭐가 나오는지 확인

      final token = Uri.parse(result).queryParameters['token'];

      if (token != null) {
        // 4. 추출한 JWT 토큰을 SharedPreferences에 저장
        await TokenStorage.saveToken(token);
        print('Token saved successfully: $token');
        return true;
      } else {
        // 예외 처리: 토큰이 없을 경우
        print('No token found in the URL');
        return false;
      }
    } catch (e) {
      // 예외 처리: URL 생성 실패 시
      print('Error creating URL: $e');
      return false;
    }
  }
}
