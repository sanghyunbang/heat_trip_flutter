// ChangeNotifier 기반의 간단한 상태관리 ViewModel
// ------------------------------------------------------------
// 역할:
// - 커서 기반 목록을 순차 로드
// - 중복 로딩 방지(loading flag)
// - 새 필터 적용 시 refresh로 처음부터 다시 로드
// - 네트워크 에러를 UI로 전달
import 'package:flutter/foundation.dart';
import 'package:heat_trip_flutter/features/explore/data/models/cursor_page_response.dart';
import 'package:heat_trip_flutter/features/explore/data/models/place_item_dto.dart';
import 'package:heat_trip_flutter/features/explore/data/remote/place_api.dart';

class ExploreScrollVM extends ChangeNotifier {
  final PlaceApi api; // API 호출과 관련한 인터페이스 (DI로 주입!)
  final ExploreFilters? filters; // 서버 필터 (지역/카테고리 등)
  final int pageSize; // 요청 단위 (size) : 한번에 가져올 데이터 개수

  ExploreScrollVM({required this.api, this.filters, this.pageSize = 20});

  // 내부 상태
  final List<PlaceItemDto> _items = []; // 현재 로드된 모든 아이템들
  String? _nextCursor; // 다음 페이지를 위한 커서
  bool _hasNext = true; // 다음 페이지가 있는지 여부
  bool _loading = false; // 현재 로딩 중인지 플래그
  Object? _error; // 네트워크 에러 메시지 (있는 경우)

  // 외부 인터페이스
  List<PlaceItemDto> get items =>
      List.unmodifiable(_items); // 현재 로드된 모든 데이터들 (수정 불가능한 복사본)
  bool get hasNext => _hasNext; // 더 불러올 데이터가 있는지 UI에서 확인
  bool get loading => _loading; // 로딩 인디케이터 표시 여부
  Object? get error => _error; // 에거 발생 시 UI에서 확인

  /// 목록 처음부터 다시
  /// - 필터 바뀌거나, 폴다운 새로 고침 시

  Future<void> refresh() async {
    _items.clear(); // 기존 데이터 모두 삭제
    _nextCursor = null; // 서버: cursor가 없으면 첫 배치로 간주
    _hasNext = true; // 데이터가 일단은 있는걸로 가정
    _error = null; // 에러 초기화
    notifyListeners(); // 상태 초기화
    await fetchNext(); // 새로고침 후 첫 페이지 로드
  }

  Future<void> fetchNext() async {
    if (_loading || !_hasNext) return; // 중복 로딩 방지

    _loading = true; // 로딩 상태 시작
    _error = null; // 이전 에러는 초기화
    notifyListeners(); // 로딩 시작 알림 --> UI 업데이트

    try {
      final CursorPageResponse<PlaceItemDto> page = await api.fetchCursor(
        filters: filters,
        cursor: _nextCursor,
        size: pageSize,
      ); // 여기서 API 호출하기!!!!!!

      _items.addAll(page.items); // 새 아이템 추가
      _nextCursor = page.nextCursor; // 다음 커서 업데이트
      _hasNext = page.hasNext; // 다음 페이지 여부 업데이트
      _error = null; // 에러 초기화
    } catch (e) {
      _error = e; // 에러 저장
    } finally {
      _loading = false;
      notifyListeners(); // 상태 변경 알림
    }
  }
}
