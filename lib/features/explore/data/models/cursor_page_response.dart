// 커서 기반(무한 스크롤) 페이지 네이션 응답 모델
//=========================================

// 백엔드의 CursorPageResponse<T> Json 구조에 맞춰서 디코딩
// - items : T 아이템 배열
// - nextCursor: 다음 페이지를 청크 요청할 때 보낼 커서 (null 이면 더 없는 상태)
// - hasNext: 다음 페이지 있는지

class CursorPageResponse<T> {
  /// 현재 배치로 수신한 아이템들 목록
  final List<T> items;

  /// 다음 페이지 호출할 때, ?cursor= 로 전달할 토믄 (없으면 null)
  final String? nextCursor;

  /// 다음 배치가 더 있는 확인
  final bool hasNext;

  CursorPageResponse({
    required this.items,
    required this.nextCursor,
    required this.hasNext,
  });

  /// JSON -> CursorPageResponse<T>
  /// [ItemFromJson] : 각 아이템을 T로 바꾸는 함수

  static CursorPageResponse<T> fromJson<T>(
    Map<String, dynamic> json, {
    required T Function(Map<String, dynamic>) itemFromJson,
  }) {
    final raw = (json['items'] as List).cast<Map<String, dynamic>>();
    return CursorPageResponse<T>(
      items: raw.map(itemFromJson).toList(),
      nextCursor: json['nextCursor'] as String?,
      hasNext: json['hasNext'] as bool,
    );
  }
}
