/// 순수 도메인 엔티티(Flutter UI 의존 X)

class Destination {
  final String id;
  final String name;
  final String location;
  final String description;
  final String imageUrl;
  final double rating;
  final List<String> tags;
  final String category;
  final String? why; // 추천 이유(“Why this”)

  Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.tags,
    required this.category,
    this.why,
  });
}

class ForYouFeed {
  final List<Destination> items;
  final String? nextCursor; // 다음 페이지 토큰
  final bool hasNext;

  ForYouFeed({
    required this.items,
    required this.nextCursor,
    required this.hasNext,
  });
}

/// 카테고리(아이콘명은 UI 레이어에서 해석)
class CurationCategory {
  final String id; // e.g., "nature", "cafe", "museum"
  final String label; // e.g., "자연", "카페"
  final String icon; // e.g., "park", "coffee"
  const CurationCategory({
    required this.id,
    required this.label,
    required this.icon,
  });
}

/// 감정/진단 결과(옵션)
class DiagnosisResult {
  final double pleasure;
  final double arousal;
  final double dominance;
  final List<String> emotions;
  const DiagnosisResult({
    required this.pleasure,
    required this.arousal,
    required this.dominance,
    required this.emotions,
  });
}

/// 로깅 이벤트
enum CurationEventType { view, click, like, save, share }

class CurationEvent {
  final CurationEventType type;
  final String userId;
  final String contentId;
  final DateTime timestamp;
  final Map<String, dynamic>? extra;

  CurationEvent({
    required this.type,
    required this.userId,
    required this.contentId,
    required this.timestamp,
    this.extra,
  });
}
