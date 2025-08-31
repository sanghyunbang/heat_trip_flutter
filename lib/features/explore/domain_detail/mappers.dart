/// mappers.dart
/// DTO(공통/인트로) → 도메인(PlaceDetail) 변환
import 'package:heat_trip_flutter/features/explore/domain/entity_detail/place_detail.dart';

import 'content_type.dart';
import '../data_detail/dto_detail_common.dart';
import '../data_detail/dto_detail_intro.dart';

double? _toDouble(String? s) =>
    (s == null || s.trim().isEmpty) ? null : double.tryParse(s.trim());

PlaceDetail mergeDetail(DetailCommonDto c, DetailIntroDto i) {
  final ct = ContentType.fromId(c.contentTypeId);

  final address = [
    if ((c.addr1 ?? '').isNotEmpty) c.addr1,
    if ((c.addr2 ?? '').isNotEmpty) c.addr2,
  ].join(' ').trim();

  return PlaceDetail(
    contentId: c.contentId,
    contentType: ct,
    title: c.title,
    firstImage: c.firstimage ?? c.firstimage2,
    address: address.isEmpty ? null : address,
    overview: c.overview,
    lon: _toDouble(c.mapx),
    lat: _toDouble(c.mapy),
    detailRaw: i.raw,

    // 아래 메타/보조 필드는 필요 시 주입(리스트에서 넘어오면 합치기)
    distanceText: null,
    rating: null,
    estimatedTimeText: null,
    priceTier: null,
  );
}
