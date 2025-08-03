import 'package:shared_preferences/shared_preferences.dart';

/// JWT 토큰을 저장하고 불러오는 역할을 하는 클래스
/// 로그인 성공 시 토큰을 저장
/// 이후 앱을 실행했을 때 자동 로그인 등에 사용할 수 있음

class TokenStorage {
  // SharedPreferences에 저장될 키 값 (고정 문자열)
  static const _jwtKey = 'jwt';

  /// JWT 토큰을 저장하는 메서드
  /// [token] 매개변수는 서버에서 발급받은 JWT 문자열
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_jwtKey, token);
    print('[TokenStorage] 토큰 저장 완료: $token');
  }

  /// 저장된 JWT 토큰을 불러오는 메서드
  /// 반환값은 JWT 문자열이며, 저장된 토큰이 없으면 null을 반환
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_jwtKey);
    print('[TokenStorage] 저장된 토큰 불러오기: $token');
    return token;
  }

  /// JWT 토큰을 삭제하는 메서드
  /// 로그아웃 시 호출하여 저장된 토큰을 제거
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_jwtKey);
  }
}
