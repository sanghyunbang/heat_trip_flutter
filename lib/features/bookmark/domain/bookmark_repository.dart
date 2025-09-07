abstract class BookmarkRepository {
  /// 서버가 내려준 '순서' 그대로의 목록 (최신순 기대)
  Future<List<String>> fetchAllOrdered();

  /// 하위 호환용(선택): 필요 없다면 제거해도 됨
  // @Deprecated('Use fetchAllOrdered() to preserve order')
  // Future<Set<String>> fetchAll() => fetchAllOrdered().then((l) => l.toSet());

  Future<void> add(String contentId, {String? collectionId});
  Future<void> remove(String contentId);

  // 이미지 URL 배치/단건 조회
  Future<Map<String, String>> fetchImagesBatch(List<String> contentIds);
  Future<String?> fetchImage(String contentId);
}
