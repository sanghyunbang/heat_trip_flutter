import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1) 토큰 공급 추상화

abstract class TokenProvider {
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> clearToken();
}

// 2) 기존 TokenStorage(static)를 그대로 활용하는 어댑터
//    - TokenStorage 파일/구현은 그대로 두고, 여기서만 SharedPreferences를 직접 써도 OK.
//    - 아래 구현은 SharedPreferences를 직접 사용(토큰 키는 기존과 동일).

class SharedPrefsTokenProvider implements TokenProvider {
  static const _jwtKey = 'jwt_token';

  @override
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_jwtKey);
  }

  @override
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_jwtKey, token);
  }

  @override
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_jwtKey);
  }
}
