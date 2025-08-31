/// content_type.dart
/// 서버의 contenttypeid(12/14/15/25/28/32/38/39)를 앱에서 안전하게 다루기 위한 enum
enum ContentType {
  attraction(12), // 관광지
  culture(14), // 문화시설
  festival(15), // 행사/공연/축제
  course(25), // 여행코스
  leports(28), // 레포츠
  lodging(32), // 숙박
  shopping(38), // 쇼핑
  food(39); // 음식점

  final int id;
  const ContentType(this.id);

  static ContentType fromId(int id) {
    return ContentType.values.firstWhere(
      (t) => t.id == id,
      orElse: () => ContentType.attraction,
    );
  }
}
