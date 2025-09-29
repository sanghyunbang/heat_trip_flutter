/// dto_detail_intro.dart
/// KTO detailIntro2의 item을 담는 DTO (타입별 상세: 운영/편의/문의 등)
/// ------------------------------------------------------------
/// - 값 유무가 타입(contentTypeId)에 따라 다르므로 널 허용
/// - 실패(부분 실패 허용) 시에는 `empty()`로 안전한 기본값을 공급
/// - ✅ 이미지 필드(firstImage/firstImage2/images) 추가: intro가 사진을 줄 때 반영
class DetailIntroDto {
  final String? useTime;
  final String? parking;
  final String? infoCenter;
  final String? restDate;
  final String? chkCreditCard;
  final String? chkPet;

  // ✅ 사진 관련 (intro가 제공한다고 가정)
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

  factory DetailIntroDto.fromItem(Map<String, dynamic> item) {
    // intro가 이미지 리스트를 'images' 배열로 주는 경우를 가정
    final dynamic rawImages = item['images'];
    final List<String> imgs = (rawImages is List)
        ? rawImages
              .map((e) => e?.toString())
              .whereType<String>()
              .where((s) => s.trim().isNotEmpty)
              .toList()
        : const <String>[];

    return DetailIntroDto(
      useTime: item['usetime'] as String?,
      parking: item['parking'] as String?,
      infoCenter: item['infocenter'] as String?,
      restDate: item['restdate'] as String?,
      chkCreditCard: item['chkcreditcard'] as String?,
      chkPet: item['chkpet'] as String?,

      // ✅ 사진
      firstImage: item['firstimage'] as String?,
      firstImage2: item['firstimage2'] as String?,
      images: imgs,
    );
  }

  /// ✅ 부분 실패 허용을 위한 "빈 DTO"
  factory DetailIntroDto.empty() => DetailIntroDto(
    useTime: null,
    parking: null,
    infoCenter: null,
    restDate: null,
    chkCreditCard: null,
    chkPet: null,
    firstImage: null,
    firstImage2: null,
    images: const [],
  );
}
