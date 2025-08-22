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
  final PlaceApi api; // DI: Mock → HTTP 구현 교체 가능
  final ExploreFilters? filters; // 서버 필터 (지역/카테고리 등)
  final int pageSize; // 요청 단위 (size)

  ExploreScrollVM({required this.api, this.filters, this.pageSize = 20});

  // 내부 상태
  final List<PlaceItemDto> _items = []; // 현재 로드된 아이템들
  String? _nextCursor; // 다음 페이지 커서
  bool _hasNext = true; // 다음 페이지가 있는지 여부
  bool _loading = false; // 현재 로딩 중인지 플래그
  Object? _error; // 네트워크 에러 메시지 (있는 경우)

  // 외부 인터페이스
  List<PlaceItemDto> get items => List.unmodifiable(_items);
  bool get hasNext => _hasNext;
  bool get loading => _loading;
  Object? get error => _error;

  /// 목록 처음부터 다시
  /// - 필터 바뀌거나, 폴다운 새로 고침 시

  Future<void> refresh() async {
    _items.clear();
    _nextCursor = null; // 서버: cursor가 없으면 첫 배치로 간주
    _hasNext = true;
    _error = null;
    notifyListeners(); // 상태 초기화
    await fetchNext(); // 새로고침 후 첫 페이지 로드
  }

  Future<void> fetchNext() async {
    if (_loading || !_hasNext) return; // 중복 로딩 방지

    _loading = true;
    _error = null;
    notifyListeners(); // 로딩 시작 알림

    try {
      final CursorPageResponse<PlaceItemDto> page = await api.fetchCursor(
        filters: filters,
        cursor: _nextCursor,
        size: pageSize,
      );

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
