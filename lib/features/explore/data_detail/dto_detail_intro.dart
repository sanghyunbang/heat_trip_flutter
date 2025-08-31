/// dto_detail_intro.dart
/// 타입별(가변 필드) 상세 응답 1건. 키가 자주 바뀌므로 Map 원본 그대로 보관.
class DetailIntroDto {
  final int contentId;
  final int contentTypeId;
  final Map<String, dynamic> raw;

  DetailIntroDto({
    required this.contentId,
    required this.contentTypeId,
    required this.raw,
  });

  factory DetailIntroDto.fromItem(Map<String, dynamic> j) {
    return DetailIntroDto(
      contentId: int.parse(j['contentid'].toString()),
      contentTypeId: int.parse(j['contenttypeid'].toString()),
      raw: j,
    );
  }
}
