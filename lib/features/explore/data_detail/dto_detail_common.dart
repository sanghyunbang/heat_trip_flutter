/// dto_detail_common.dart
/// 공통 상세(overview, mapx/mapy, 주소, 타이틀 등) 응답 1건을 표현
class DetailCommonDto {
  final int contentId;
  final int contentTypeId;
  final String title;
  final String? firstimage;
  final String? firstimage2;
  final String? addr1;
  final String? addr2;
  final String? overview; // HTML 포함 가능
  final String? mapx; // 서버에서 문자열로 오므로 String으로 수신
  final String? mapy;

  DetailCommonDto({
    required this.contentId,
    required this.contentTypeId,
    required this.title,
    this.firstimage,
    this.firstimage2,
    this.addr1,
    this.addr2,
    this.overview,
    this.mapx,
    this.mapy,
  });

  /// 샘플 JSON 구조: response.body.items.item[0]
  factory DetailCommonDto.fromItem(Map<String, dynamic> j) {
    return DetailCommonDto(
      contentId: int.parse(j['contentid'].toString()),
      contentTypeId: int.parse(j['contenttypeid'].toString()),
      title: (j['title'] ?? '').toString(),
      firstimage: j['firstimage']?.toString(),
      firstimage2: j['firstimage2']?.toString(),
      addr1: j['addr1']?.toString(),
      addr2: j['addr2']?.toString(),
      overview: j['overview']?.toString(),
      mapx: j['mapx']?.toString(),
      mapy: j['mapy']?.toString(),
    );
  }
}
