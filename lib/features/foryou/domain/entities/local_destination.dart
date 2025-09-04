// lib/features/foryou/domain/entities/local_destination.dart
//
// 리스트/상세에 사용하는 "장소" 엔티티(프론트 표준 모델)
enum PlaceType { nature, city, coastal, cultural, cafe, healing, other }

extension PlaceTypeKo on PlaceType {
  String get label => switch (this) {
    PlaceType.nature => '자연',
    PlaceType.city => '도시',
    PlaceType.coastal => '해안',
    PlaceType.cultural => '문화',
    PlaceType.cafe => '카페',
    PlaceType.healing => '힐링',
    PlaceType.other => '기타',
  };
}

class LocalDestination {
  final String id;
  final String name;
  final String location; // '서울', '제주도' 등
  final PlaceType type;
  final double rating; // 0~5
  final int reviewCount; // 리뷰 수
  final String duration; // '1-2시간'
  final String difficulty; // 'easy'|'medium'|'hard' (UI 배지용)
  final String imageUrl;
  final List<String> tags;
  final String description;
  final String? price; // '무료', '15,000원' 등

  const LocalDestination({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    required this.rating,
    required this.reviewCount,
    required this.duration,
    required this.difficulty,
    required this.imageUrl,
    required this.tags,
    required this.description,
    this.price,
  });
}
