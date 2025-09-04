class ThemeBundleDto {
  final String id; // 테마 고유 키 (라우팅/필터에 사용)
  final String title; // 카드 제목
  final String category; // 보조 라벨(예: Fashion)
  final int pinCount; // 핀 개수
  final String updatedAgo; // '5개월', '1주' 등
  final List<String> preview; // 최대 4장: 2×2 콜라주에 씀
  final int? contentTypeId; // Explore 필터 힌트
  final String? region; // Explore 필터 힌트
  final String? query; // Explore 필터 힌트

  const ThemeBundleDto({
    required this.id,
    required this.title,
    required this.category,
    required this.pinCount,
    required this.updatedAgo,
    required this.preview,
    this.contentTypeId,
    this.region,
    this.query,
  });

  factory ThemeBundleDto.fromJson(Map<String, dynamic> j) {
    final pv =
        (j['preview'] as List?)?.map((e) => e.toString()).toList() ??
        const <String>[];
    return ThemeBundleDto(
      id: j['id'] as String,
      title: (j['title'] as String?) ?? '',
      category: (j['category'] as String?) ?? '',
      pinCount: (j['pinCount'] as num?)?.toInt() ?? 0,
      updatedAgo: (j['updatedAgo'] as String?) ?? '',
      preview: pv.take(4).toList(), // [②]
      contentTypeId: (j['contentTypeId'] as num?)?.toInt(),
      region: j['region'] as String?,
      query: j['query'] as String?,
    );
  }

  /// 백엔드가 preview를 안 줄 때, 로컬 오버라이드 이미지로 대체. [③]
  ThemeBundleDto withPreviewOverrideIfEmpty(
    Map<String, List<String>> overrides,
  ) {
    if (preview.isNotEmpty) return this;
    final ov = overrides[id];
    if (ov == null || ov.isEmpty) return this;
    return ThemeBundleDto(
      id: id,
      title: title,
      category: category,
      pinCount: pinCount,
      updatedAgo: updatedAgo,
      preview: ov.take(4).toList(),
      contentTypeId: contentTypeId,
      region: region,
      query: query,
    );
  }
}
