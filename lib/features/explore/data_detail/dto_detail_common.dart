/// dto_detail_common.dart
/// KTO detailCommon2의 item을 담는 DTO
/// ─────────────────────────────────────────────────────────────────────────────
/// [개요]
/// - KTO 응답은 숫자처럼 보이는 값도 "문자열"로 자주 옵니다. (예: "128.2049", "6")
/// - 따라서 모든 필드는 "안전 파싱" 유틸을 거쳐서 String/Double/Int로 변환합니다. [①]
/// - 서버에서 null/빈값이 올 수 있으므로 대부분 nullable로 정의합니다.
/// - 실패(부분 실패 허용) 시에는 `empty()`로 안전한 기본값을 공급합니다.
///
/// [주의]
/// - KTO의 키 이름은 모두 소문자입니다. (예: contentid, firstimage, firstimage2)
///   오탈자/대소문자 불일치가 가장 흔한 매핑 실패 원인입니다.

class DetailCommonDto {
  final int? contentId;
  final String? title;
  final String? overview;
  final String? addr1;
  final String? addr2;
  final String? firstImage;
  final String? firstImage2;
  final double? mapX; // 경도 (x)
  final double? mapY; // 위도 (y)
  final String? tel;
  final String? homepage; // [②] 자주 쓰는 필드 추가

  DetailCommonDto({
    this.contentId,
    this.title,
    this.overview,
    this.addr1,
    this.addr2,
    this.firstImage,
    this.firstImage2,
    this.mapX,
    this.mapY,
    this.tel,
    this.homepage,
  });

  // ────────────────────────────────────────────────────────────────────────────
  // [①] 안전 파싱 유틸: 어떤 타입이 와도 최대한 온건하게 변환
  // ────────────────────────────────────────────────────────────────────────────
  static String? _asString(dynamic v, {bool emptyAsNull = false}) {
    if (v == null) return null;
    final s = v.toString();
    if (emptyAsNull && s.trim().isEmpty) return null;
    return s;
  }

  static double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return double.tryParse(s); // parse 실패 시 null
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return int.tryParse(s);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // KTO detailCommon2 → DTO 변환
  //  - 키는 응답 JSON의 "소문자" 키와 1:1로 매핑합니다.
  //  - 절대 (item['mapx'] as num?) 처럼 강제 캐스팅하지 않습니다. [문자열 대응]
  // ────────────────────────────────────────────────────────────────────────────
  factory DetailCommonDto.fromItem(Map<String, dynamic> item) {
    return DetailCommonDto(
      contentId: _asInt(item['contentid']),
      title: _asString(item['title'], emptyAsNull: true),
      overview: _asString(item['overview'], emptyAsNull: true),
      addr1: _asString(item['addr1'], emptyAsNull: true),
      addr2: _asString(item['addr2'], emptyAsNull: true),
      firstImage: _asString(item['firstimage'], emptyAsNull: true),
      firstImage2: _asString(item['firstimage2'], emptyAsNull: true),
      mapX: _asDouble(item['mapx']),
      mapY: _asDouble(item['mapy']),
      tel: _asString(item['tel'], emptyAsNull: true),
      homepage: _asString(item['homepage'], emptyAsNull: true), // [②]
    );
  }

  /// 부분 실패 허용을 위한 "빈 DTO" (화면이 죽지 않도록 안전한 기본값)
  factory DetailCommonDto.empty() => DetailCommonDto();
}
