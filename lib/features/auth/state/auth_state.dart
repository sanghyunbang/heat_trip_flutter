import 'package:flutter/foundation.dart';
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';

/// AuthState
/// ─────────────────────────────────────────────────────────────────
/// - 앱 전역의 '인증 상태(로그인 여부)'를 관리하는 ChangeNotifier입니다.
/// - 내부적으로 저장소(TokenStorage)에 JWT가 있는지를 확인해
///   `loggedIn` 플래그를 갱신하고, 변경 시 구독자(위젯)에게 알립니다.
/// - Provider/Riverpod 등 상태 관리에서 주입하여 사용하기 좋습니다.
///
/// 사용 예(Provider):
///   ChangeNotifierProvider(
///     create: (_) => AuthState()..refresh(), // 앱 시작 시 초기 상태 동기화
///     child: MyApp(),
///   )
///
///   final auth = context.watch<AuthState>();
///   if (auth.loggedIn) ... // 로그인 UI 분기
class AuthState extends ChangeNotifier {
  /// 현재 로그인 여부를 나타내는 내부 상태 값.
  /// - 외부에서는 getter(`loggedIn`)로만 접근하도록 캡슐화.
  bool _loggedIn = false;

  /// 읽기 전용 게터: 현재 로그인 여부
  bool get loggedIn => _loggedIn;

  /// refresh(): 저장소의 토큰 존재 여부를 기준으로 로그인 상태를 재평가
  /// ─────────────────────────────────────────────────────────────
  /// - TokenStorage.getToken()이 null이 아니면 로그인 상태(true),
  ///   null이면 비로그인 상태(false)로 간주합니다.
  /// - 상태가 바뀌었을 수 있으므로 항상 notifyListeners() 호출.
  /// - 앱 시작/재개 시점, 토큰이 갱신된 이후 등에 호출하여
  ///   UI와 상태를 동기화합니다.
  Future<void> refresh() async {
    _loggedIn = (await TokenStorage.getToken()) != null;
    notifyListeners();
  }

  /// setToken(token): 토큰 저장 후 상태 갱신
  /// ─────────────────────────────────────────────────────────────
  /// - 로그인 성공 직후 서버로부터 받은 액세스 토큰을 저장합니다.
  /// - 저장이 끝나면 refresh()를 호출해 로그인 상태를 true로 반영하고
  ///   구독자들에게 알립니다.
  /// - 필요 시 이 지점에서 만료 시각, 사용자 정보 로드 등
  ///   후속 초기화 로직을 추가할 수 있습니다.
  Future<void> setToken(String token) async {
    await TokenStorage.save(token);
    await refresh();
  }

  /// logout(): 토큰 삭제 후 상태 갱신
  /// ─────────────────────────────────────────────────────────────
  /// - 로그아웃 시 호출합니다.
  /// - 저장소에서 토큰을 제거하고, refresh()로 상태를 false로 만들며
  ///   구독자들에게 변경 사실을 알립니다.
  /// - 필요 시 서버로 로그아웃 API 호출, 캐시 정리 등의 부가 작업을
  ///   이 메서드에 추가할 수 있습니다.
  Future<void> logout() async {
    await TokenStorage.clear();
    await refresh();
  }
}
