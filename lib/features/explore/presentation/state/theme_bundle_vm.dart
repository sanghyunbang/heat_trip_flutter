// ViewModel 클래스: ChangeNotifier를 상속받아 상태 변화 감지 및 알림 가능
import 'package:flutter/foundation.dart';

// ThemeBundleDto: 테마 번들의 데이터 전송 객체 (DTO)
import '../../data/models/theme_bundle_dto.dart';
// IThemeBundleRepository: 테마 번들 데이터를 불러오는 Repository 인터페이스
import '../../data/repositories/theme_bundle_repository.dart';

/// ThemeBundleVM 클래스
/// 역할: 테마 번들 리스트 데이터를 로드하고 UI에 제공하는 ViewModel
/// 로딩 상태, 에러 처리, 페이지네이션(무한스크롤)을 함께 관리함
class ThemeBundleVM extends ChangeNotifier {
  // Repository 의존성 주입 (인터페이스를 주입하여 테스트 가능하게)
  final IThemeBundleRepository repo;

  // 생성자에서 repo를 받아 저장
  ThemeBundleVM(this.repo);

  // 현재까지 로드된 테마 번들 리스트
  final List<ThemeBundleDto> items = [];

  // 로딩 중 여부 플래그 — 중복 요청 방지
  bool loading = false;

  // 에러 메시지 — UI에 보여주기 위한 용도
  String? error;

  // 페이지 번호 (0부터 시작)
  int _page = 0;

  // 더 이상 가져올 데이터가 없는지 여부 (EOF = End Of File)
  bool _eof = false;

  /// 초기 데이터 로딩 메서드 (예: 화면 진입 시 1회 호출)
  Future<void> loadInitial() async {
    // 이미 로딩 중이면 중복 호출 방지
    if (loading) return;

    // 로딩 시작 상태 설정
    loading = true;
    error = null;
    notifyListeners(); // UI에 변경 사항 알림

    try {
      // 페이지 및 EOF 상태 초기화
      _page = 0;
      _eof = false;
      items.clear(); // 기존 데이터 초기화

      // 첫 번째 페이지의 데이터 요청
      final res = await repo.list(page: _page);

      // 데이터 저장
      items.addAll(res);
    } catch (e) {
      // 오류 발생 시 error 메시지 저장 (UI에서 처리 가능)
      error = e.toString();
    } finally {
      // 로딩 종료 및 UI에 변경 알림
      loading = false;
      notifyListeners();
    }
  }

  /// 추가 데이터 로딩 (스크롤 끝 도달 시 호출)
  Future<void> loadMore() async {
    // 현재 로딩 중이거나 이미 EOF라면 요청 중단
    if (loading || _eof) return;

    loading = true;
    notifyListeners(); // 로딩 상태 변경 알림

    try {
      // 페이지 번호 증가 후 다음 페이지 요청
      _page += 1;
      final res = await repo.list(page: _page);

      // 가져온 데이터가 없으면 EOF로 간주
      if (res.isEmpty) _eof = true;

      // 새 데이터 추가
      items.addAll(res);
    } catch (e) {
      // 오류 메시지 저장
      error = e.toString();
    } finally {
      // 로딩 종료 및 UI 갱신
      loading = false;
      notifyListeners();
    }
  }
}
