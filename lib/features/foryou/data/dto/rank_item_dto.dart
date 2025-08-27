// lib/features/foryou/data/dto/rank_item_dto.dart

/// 추천된 카테고리 하나에 대한 정보 (서버 응답의 단일 아이템)
/// → 서버 응답: [{ "category": "cat_001", "score": 0.78 }, ...]
class RankItemDto {
  final String category; // 카테고리 ID 또는 이름
  final double score; // LinUCB 점수 (0.0 이상, 정렬 기준)

  RankItemDto({required this.category, required this.score});

  /// 서버 응답 JSON → 객체로 변환
  factory RankItemDto.fromJson(Map<String, dynamic> j) => RankItemDto(
    category: j["category"],
    score: (j["score"] as num).toDouble(), // num → double 캐스팅
  );
}
