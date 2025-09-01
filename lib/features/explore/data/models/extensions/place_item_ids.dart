/// lib/features/explore/data/models/extensions/place_item_ids.dart
///
/// PlaceItem의 다양한 키 형태(camelCase, snake_case)를 안전하게 처리해
/// 정수 ID로 파싱해 주는 확장자 모음.
/// - UI 위젯에서 null/형변환 예외로 터지는 것을 방지.
/// - 데이터 계층 성격이므로 presentation이 아닌 data 하위에 둔다.

import '../place_item_dto.dart';

extension PlaceItemIds on PlaceItem {
  /// 콘텐츠 고유 ID 안전 반환 (없으면 0)
  int get safeContentId {
    final d = this as dynamic;
    try {
      final v = d.contentId;
      if (v != null) return int.tryParse('$v') ?? 0;
    } catch (_) {}
    try {
      final v = d.contentid;
      if (v != null) return int.tryParse('$v') ?? 0;
    } catch (_) {}
    return 0;
  }

  /// 콘텐츠 타입 ID 안전 반환 (없으면 12 = 관광지 기본 타입 등 임의 기본값)
  int get safeContentTypeId {
    final d = this as dynamic;
    try {
      final v = d.contentTypeId;
      if (v != null) return int.tryParse('$v') ?? 12;
    } catch (_) {}
    try {
      final v = d.contenttypeid;
      if (v != null) return int.tryParse('$v') ?? 12;
    } catch (_) {}
    return 12;
  }
}
