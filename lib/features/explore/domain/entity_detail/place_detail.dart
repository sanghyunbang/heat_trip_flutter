/// place_detail.dart
/// 화면에서 사용하는 '병합된' 도메인 엔티티
import '../../domain_detail/content_type.dart';

class Review {
  final String id;
  final String author;
  final int rating; // 1~5
  final String comment;
  final String date;
  final int helpful;
  Review({
    required this.id,
    required this.author,
    required this.rating,
    required this.comment,
    required this.date,
    required this.helpful,
  });
}

class PlaceDetail {
  final int contentId;
  final ContentType contentType;
  final String title;
  final String? firstImage;
  final String? address; // addr1 + addr2
  final String? overview; // HTML 포함 가능
  final double? lon; // mapx
  final double? lat; // mapy

  // 선택(리스트/상세 공통 메타)
  final String? distanceText;
  final double? rating;
  final String? estimatedTimeText;
  final String? priceTier;

  // UI 보조 데이터(선택)
  final List<String> tags;
  final List<String> specialFeatures;
  final List<String> images;
  final Map<String, String> hours;
  final List<String> amenities;
  final List<Review> reviews;

  // 타입별 상세 원본(가변 키 사용)
  final Map<String, dynamic> detailRaw;

  PlaceDetail({
    required this.contentId,
    required this.contentType,
    required this.title,
    required this.detailRaw,
    this.firstImage,
    this.address,
    this.overview,
    this.lon,
    this.lat,
    this.distanceText,
    this.rating,
    this.estimatedTimeText,
    this.priceTier,
    this.tags = const [],
    this.specialFeatures = const [],
    this.images = const [],
    this.hours = const {},
    this.amenities = const [],
    this.reviews = const [],
  });
}
