// 상세 화면에서 사용하는 장소 상세 DTO
// ------------------------------------------------------------
// 서버의 PlaceDetailDto 구조와 맞추되, 일부 필드는 optional로 둡니다.
// (서버에서 null/빈값이 올 수 있으므로 안전하게 처리)

class PlaceDetailDto {
  final int contentid;
  final String title;
  final String? overview; // 소개글
  final String? addr1;
  final String? addr2;
  final String? firstimage;
  final String? firstimage2;
  final double? mapx; // 경도 (서버가 문자열로 줄 수도 있어 safe cast)
  final double? mapy; // 위도

  PlaceDetailDto({
    required this.contentid,
    required this.title,
    this.overview,
    this.addr1,
    this.addr2,
    this.firstimage,
    this.firstimage2,
    this.mapx,
    this.mapy,
  });

  factory PlaceDetailDto.fromJson(Map<String, dynamic> json) {
    // 다양한 타입(double/num/String/null)을 모두 수용하는 변환기
    double? _toDouble(dynamic v) => v == null
        ? null
        : (v is num ? v.toDouble() : double.tryParse(v.toString()));

    return PlaceDetailDto(
      contentid: (json['contentid'] as num).toInt(),
      title: json['title'] as String,
      overview: json['overview'] as String?,
      addr1: json['addr1'] as String?,
      addr2: json['addr2'] as String?,
      firstimage: json['firstimage'] as String?,
      firstimage2: json['firstimage2'] as String?,
      mapx: _toDouble(json['mapx']),
      mapy: _toDouble(json['mapy']),
    );
  }
}
