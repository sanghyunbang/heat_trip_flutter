// lib/features/explore/data/models/place_item_dto.dart

/// PlaceItem: 리스트 카드에서 쓰는 "요약" 엔티티(도메인 모델)
/// - 서버 키와 분리하여, 앱 내부에서는 카멜케이스/nullable을 선호합니다.
class PlaceItem {
  /// 고유 콘텐츠 ID (필수)
  final int contentid;

  /// 타입 ID (관광지=12, 문화=14, 축제=15, 코스=25, 레포츠=28, 숙박=32, 쇼핑=38, 음식=39)
  /// - 일부 백엔드/프록시가 이 값을 생략할 수 있어 nullable 로 둡니다.
  final int? contentTypeId;

  final String title;
  final String addr1;
  final String addr2;
  final String firstimage;
  final String firstimage2;

  // ▼ 스냅샷 파생 필드들(옵션)
  final String? cat3; // ex) A02020700
  final String? cat3Name; // ex) 고택
  final String? shortDesc1; // 간단 설명 1
  final String? shortDesc2; // 간단 설명 2
  final List<String> hashtags;
  final List<String> simpleTags;

  const PlaceItem({
    required this.contentid,
    required this.title,
    required this.addr1,
    required this.addr2,
    required this.firstimage,
    required this.firstimage2,
    this.contentTypeId, // ← 추가
    this.cat3,
    this.cat3Name,
    this.shortDesc1,
    this.shortDesc2,
    this.hashtags = const [],
    this.simpleTags = const [],
  });

  // (기존에 있던 getter는 사용처가 없어 보이면 삭제해도 무방)
  get category => null;
}

/// 서버 응답(JSON) ↔ 도메인 모델 간 어댑터
class PlaceItemDto extends PlaceItem {
  const PlaceItemDto({
    required super.contentid,
    required super.title,
    required super.addr1,
    required super.addr2,
    required super.firstimage,
    required super.firstimage2,
    super.contentTypeId, // ← 추가
    super.cat3,
    super.cat3Name,
    super.shortDesc1,
    super.shortDesc2,
    super.hashtags = const [],
    super.simpleTags = const [],
  });

  /// 안전한 int 변환 유틸
  static int? _toIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static List<String> _list(dynamic v) =>
      (v is List) ? v.map((e) => e.toString()).toList() : const [];

  /// 서버 → 앱
  /// - 서버 키는 보통 소문자 `contenttypeid` 입니다.
  /// - 들어오는 값이 문자열일 수 있으므로 `_toIntOrNull`로 안전 변환합니다.
  // lib/features/explore/data/models/place_item_dto.dart

  factory PlaceItemDto.fromJson(Map<String, dynamic> json) {
    int? _pickContentTypeId(Map<String, dynamic> j) {
      // 1) snake_case, 2) camelCase, 3) 혹시 모를 'content_type_id'
      final cand =
          j['contenttypeid'] ?? j['contentTypeId'] ?? j['content_type_id'];
      return _toIntOrNull(cand);
    }

    return PlaceItemDto(
      contentid: _toIntOrNull(json['contentid']) ?? 0,
      contentTypeId: _pickContentTypeId(json), // ← 보강
      title: (json['title'] as String?) ?? '',
      addr1: (json['addr1'] as String?) ?? '',
      addr2: (json['addr2'] as String?) ?? '',
      firstimage: (json['firstimage'] as String?) ?? '',
      firstimage2: (json['firstimage2'] as String?) ?? '',
      cat3: json['cat3'] as String?,
      cat3Name: json['cat3Name'] as String?,
      shortDesc1: json['shortDesc1'] as String?,
      shortDesc2: json['shortDesc2'] as String?,
      hashtags: _list(json['hashtags']),
      simpleTags: _list(json['simpleTags']),
    );
  }

  /// 앱 → 서버(혹은 캐시)
  /// - 서버에서 기대하는 키 이름(`contenttypeid`)로 내려줍니다.
  Map<String, dynamic> toJson() => {
    'contentid': contentid,
    'contenttypeid': contentTypeId, // ← 추가(키명 주의)
    'title': title,
    'addr1': addr1,
    'addr2': addr2,
    'firstimage': firstimage,
    'firstimage2': firstimage2,
    'cat3': cat3,
    'cat3Name': cat3Name,
    'shortDesc1': shortDesc1,
    'shortDesc2': shortDesc2,
    'hashtags': hashtags,
    'simpleTags': simpleTags,
  };
}
