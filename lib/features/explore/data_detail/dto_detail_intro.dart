/// dto_detail_intro.dart
/// KTO detailIntro2의 item을 담는 DTO (타입별 상세: 운영/편의/문의 등)
/// ─────────────────────────────────────────────────────────────────────────────
/// [개요]
/// - intro2도 숫자처럼 보이는 값이 문자열로 올 수 있으므로 동일한 안전 파싱을 적용합니다. [③]
/// - 값 유무가 contentTypeId에 따라 다르므로 널 허용.
/// - 실패(부분 실패 허용) 시 `empty()`로 안전한 기본값 공급.
/// - ⚠️ intro2는 "이미지 리스트"를 주지 않는 경우가 대부분입니다.
///   images/firstimage(2)는 실제로 common 쪽에서 오는 편입니다.
///   그래도 호환성을 위해 필드를 두되, 존재할 때만 흡수하는 방식을 취합니다. [④]

class DetailIntroDto {
  // 운영/편의/문의
  final String? useTime; // usetime
  final String? parking; // parking
  final String? infoCenter; // infocenter
  final String? restDate; // restdate
  final String? chkCreditCard; // chkcreditcard
  final String? chkPet; // chkpet

  // (옵션) 이미지 - 실제로는 common에서 오는 경우가 많음
  final String? firstImage;
  final String? firstImage2;
  final List<String> images;

  DetailIntroDto({
    this.useTime,
    this.parking,
    this.infoCenter,
    this.restDate,
    this.chkCreditCard,
    this.chkPet,
    this.firstImage,
    this.firstImage2,
    this.images = const [],
  });

  // [③] 안전 파싱 유틸 (common과 동일)
  static String? _asString(dynamic v, {bool emptyAsNull = false}) {
    if (v == null) return null;
    final s = v.toString();
    if (emptyAsNull && s.trim().isEmpty) return null;
    return s;
  }

  // [④] images가 배열로 올 때만 수용. 아니면 빈 리스트.
  static List<String> _asStringList(dynamic v) {
    if (v is! List) return const <String>[];
    return v
        .map((e) => e?.toString())
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }

  factory DetailIntroDto.fromItem(Map<String, dynamic> item) {
    return DetailIntroDto(
      useTime: _asString(item['usetime'], emptyAsNull: true),
      parking: _asString(item['parking'], emptyAsNull: true),
      infoCenter: _asString(item['infocenter'], emptyAsNull: true),
      restDate: _asString(item['restdate'], emptyAsNull: true),
      chkCreditCard: _asString(item['chkcreditcard'], emptyAsNull: true),
      chkPet: _asString(item['chkpet'], emptyAsNull: true),

      // (옵션) 이미지 - intro가 제공하면 흡수, 없으면 null/빈값
      firstImage: _asString(item['firstimage'], emptyAsNull: true),
      firstImage2: _asString(item['firstimage2'], emptyAsNull: true),
      images: _asStringList(item['images']),
    );
  }

  /// 부분 실패 허용을 위한 "빈 DTO"
  factory DetailIntroDto.empty() => DetailIntroDto();
}
