// mappers.dart
// DTO(공통/인트로) → 도메인(PlaceDetail) 변환
//
// 변경 사항
// - DetailCommonDto에는 contentTypeId가 없으므로, 매퍼가 contentTypeId를
//   추가 인자로 받음.
// - contentId가 null일 수 있으므로 기본값(0)으로 보정.
// - ✅ 사진은 common/intro 양쪽에서 수집해 firstImage + images 리스트 구성.

import 'package:heat_trip_flutter/features/explore/domain/entity_detail/place_detail.dart';

import 'content_type.dart';
import '../data_detail/dto_detail_common.dart';
import '../data_detail/dto_detail_intro.dart';

PlaceDetail mergeDetail(
  DetailCommonDto c,
  DetailIntroDto i, {
  required int contentTypeId, // ✅ repository에서 넘겨줌
}) {
  // contentTypeId는 라우팅/VM에서 내려온 값을 그대로 사용
  final ct = ContentType.fromId(contentTypeId);

  // 주소 결합
  final address = [
    if ((c.addr1 ?? '').isNotEmpty) c.addr1,
    if ((c.addr2 ?? '').isNotEmpty) c.addr2,
  ].join(' ').trim();

  // ✅ 대표 이미지 우선순위: common.firstImage → common.firstImage2 → intro.firstImage → intro.firstImage2
  String? pickFirstImage() {
    for (final s in [
      c.firstImage,
      c.firstImage2,
      i.firstImage,
      i.firstImage2,
    ]) {
      if (s != null && s.trim().isNotEmpty) return s;
    }
    return null;
  }

  // ✅ 이미지 리스트: common/intro 양쪽에서 모아 중복 제거
  final images = <String>{
    if ((c.firstImage ?? '').isNotEmpty) c.firstImage!,
    if ((c.firstImage2 ?? '').isNotEmpty) c.firstImage2!,
    if ((i.firstImage ?? '').isNotEmpty) i.firstImage!,
    if ((i.firstImage2 ?? '').isNotEmpty) i.firstImage2!,
    ...i.images.where((s) => s.trim().isNotEmpty),
  }.toList();

  return PlaceDetail(
    contentId: c.contentId ?? 0,
    contentType: ct,
    title: c.title ?? '',
    firstImage: pickFirstImage(),
    address: address.isEmpty ? null : address,
    overview: c.overview,
    lon: c.mapX,
    lat: c.mapY,

    // 도메인이 Map<String,dynamic>을 요구한다면 빈 맵으로 보정
    detailRaw: const <String, dynamic>{},

    // ✅ 스크린에서 쓰는 갤러리용 리스트
    images: images,

    // 보조 메타
    distanceText: null,
    rating: null,
    estimatedTimeText: null,
    priceTier: null,
  );
}
