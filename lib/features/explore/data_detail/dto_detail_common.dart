/// dto_detail_common.dart
/// KTO detailCommon2의 item을 담는 DTO
/// ------------------------------------------------------------
/// - 서버에서 null/빈값이 올 수 있으므로 대부분 nullable로 정의
/// - 실패(부분 실패 허용) 시에는 `empty()`로 안전한 기본값을 공급
class DetailCommonDto {
  final int? contentId;
  final String? title;
  final String? overview;
  final String? addr1;
  final String? addr2;
  final String? firstImage;
  final String? firstImage2;
  final double? mapX; // 경도
  final double? mapY; // 위도
  final String? tel;

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
  });

  // 다양한 타입(double/num/String/null)을 모두 수용하는 변환기
  static double? _toDouble(dynamic v) => v == null
      ? null
      : (v is num ? v.toDouble() : double.tryParse(v.toString()));

  factory DetailCommonDto.fromItem(Map<String, dynamic> item) {
    return DetailCommonDto(
      contentId: (item['contentid'] as num?)?.toInt(),
      title: item['title'] as String?,
      overview: item['overview'] as String?,
      addr1: item['addr1'] as String?,
      addr2: item['addr2'] as String?,
      firstImage: item['firstimage'] as String?,
      firstImage2: item['firstimage2'] as String?,
      mapX: _toDouble(item['mapx']),
      mapY: _toDouble(item['mapy']),
      tel: item['tel'] as String?,
    );
  }

  /// ✅ 부분 실패 허용을 위한 "빈 DTO" (화면이 죽지 않도록 안전한 기본값)
  factory DetailCommonDto.empty() => DetailCommonDto(
    contentId: null,
    title: null,
    overview: null,
    addr1: null,
    addr2: null,
    firstImage: null,
    firstImage2: null,
    mapX: null,
    mapY: null,
    tel: null,
  );
}
