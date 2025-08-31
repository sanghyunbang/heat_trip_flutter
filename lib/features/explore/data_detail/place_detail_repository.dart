/// place_detail_repository.dart
/// API 두 번 호출 → DTO 파싱 → 도메인으로 병합하여 반환
import 'package:heat_trip_flutter/features/explore/domain/entity_detail/place_detail.dart';

import 'dto_detail_common.dart';
import 'dto_detail_intro.dart';
import 'place_detail_api.dart';
import '../domain_detail/mappers.dart';

class PlaceDetailRepository {
  final PlaceDetailApi api;
  PlaceDetailRepository(this.api);

  Future<PlaceDetail> fetch({
    required int contentId,
    required int contentTypeId,
  }) async {
    final commonItem = await api.fetchDetailCommonItem(contentId: contentId);
    final introItem = await api.fetchDetailIntroItem(
      contentId: contentId,
      contentTypeId: contentTypeId,
    );

    final common = DetailCommonDto.fromItem(commonItem);
    final intro = DetailIntroDto.fromItem(introItem);
    return mergeDetail(common, intro);
  }
}
