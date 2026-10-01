import 'package:shared_preferences/shared_preferences.dart';

/// TokenStorage
/// ─────────────────────────────────────────────────────────────────
/// - 앱 로컬(디스크 유사) 저장소인 SharedPreferences에 JWT(액세스 토큰)를
///   저장/조회/삭제하는 정적(Static) 유틸리티 클래스입니다.
/// - 간단한 키-값 저장소로 문자열, 불리언, 숫자 등을 보관할 수 있으며,
///   안드로이드/iOS/웹 각각의 안전한 영역에 저장됩니다.
///
/// ⚠️ 보안 주의:
/// - SharedPreferences는 암호화 저장소가 아닙니다. 고보안 앱(금융/의료 등)이나
///   보안 요건이 높은 경우 OS의 보안 저장소(예: flutter_secure_storage + Keychain/Keystore)
///   사용을 고려하세요. 일반 JWT 액세스 토큰은 만료를 짧게 두고, 필요시 리프레시 토큰은
///   더 안전한 저장소에 보관하는 방식이 권장됩니다.
class TokenStorage {
  /// SharedPreferences에 사용할 키 이름(네임스페이스 역할)
  /// - 앱 전역에서 중복되지 않도록 고유한 문자열을 사용합니다.
  static const _jwtKey = 'jwt_token';

  // ─────────────────────────────────────────────────────────────
  // 저장(Write)
  // ─────────────────────────────────────────────────────────────

  /// save(token): JWT 문자열을 SharedPreferences에 저장
  /// ─────────────────────────────────────────────────────────────
  /// - 권장 API 이름. (아래 saveToken은 과거 코드 호환용 별칭)
  /// - 비동기(async)로 동작: 실제 디스크 쓰기 작업이 완료될 때까지 await 권장
  /// - 사용 예:
  ///   await TokenStorage.save(newAccessToken);
  static Future<void> save(String token) async {
    // 1) SharedPreferences 인스턴스 가져오기 (싱글톤처럼 동작)
    final p = await SharedPreferences.getInstance();

    // 2) 키(_jwtKey)에 토큰 문자열 저장
    //    - 같은 키에 다시 쓰면 기존 값이 덮어써짐(업데이트)
    await p.setString(_jwtKey, token);
  }

  // ─────────────────────────────────────────────────────────────
  // 조회(Read)
  // ─────────────────────────────────────────────────────────────

  /// getToken(): 저장된 JWT 문자열을 읽어 반환
  /// ─────────────────────────────────────────────────────────────
  /// 반환:
  /// - String? : 존재하면 토큰 문자열, 없으면 null
  /// 주의:
  /// - null일 수 있으므로 사용하는 쪽에서 널 처리(if/??)를 해 주세요.
  /// - 예: final token = await TokenStorage.getToken();
  ///       if (token == null) { /* 비로그인 처리 */ }
  static Future<String?> getToken() async {
    // 1) 인스턴스 획득
    final p = await SharedPreferences.getInstance();

    // 2) 키로부터 문자열 읽기(없으면 null)
    return p.getString(_jwtKey);
  }

  // ─────────────────────────────────────────────────────────────
  // 삭제(Delete)
  // ─────────────────────────────────────────────────────────────

  /// clear(): 저장된 JWT를 삭제
  /// ─────────────────────────────────────────────────────────────
  /// - 로그아웃 시 호출하는 전형적인 메서드입니다.
  /// - remove는 해당 키만 제거합니다. (전부 삭제가 아님)
  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_jwtKey);
  }

  // ─────────────────────────────────────────────────────────────
  // 과거 코드 호환용 별칭(Alias)
  // ─────────────────────────────────────────────────────────────

  /// saveToken(token): 과거 코드 호환을 위한 별칭
  /// - 내부적으로는 권장 API인 save(token)을 호출합니다.
  static Future<void> saveToken(String token) => save(token);

  /// clearToken(): 과거 코드 호환을 위한 별칭
  /// - 내부적으로는 권장 API인 clear()를 호출합니다.
  static Future<void> clearToken() => clear();
}
