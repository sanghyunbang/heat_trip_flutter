/// place_detail_repository.dart
/// API 두 번 호출 → DTO 파싱 → 도메인으로 병합하여 반환
///
/// ✅ 변경 요점 (탭 항상 보이기):
///  - common/intro 중 하나 실패 → 실패한 쪽은 empty() DTO로 대체
///  - 둘 다 실패여도 throw 하지 않고 **둘 다 empty()** 로 대체하여 PlaceDetail 반환
///    => vm.error 가 세팅되지 않아서 화면(탭)이 항상 렌더링됨
import 'package:heat_trip_flutter/features/explore/domain/entity_detail/place_detail.dart';

import 'dto_detail_common.dart';
import 'dto_detail_intro.dart';
import 'place_detail_api.dart';
import '../domain_detail/mappers.dart';
import 'package:heat_trip_flutter/core/errors/app_exception.dart';

class PlaceDetailRepository {
  final PlaceDetailApi api;
  PlaceDetailRepository(this.api);

  Future<PlaceDetail> fetch({
    required int contentId,
    required int contentTypeId,
  }) async {
    Map<String, dynamic>? commonItem;
    Map<String, dynamic>? introItem;

    // 첫 의미 있는 오류 메시지(선택: 추후 로깅 용)
    AppException? firstErr;

    // 1) 공통 상세(detailCommon)
    try {
      commonItem = await api.fetchDetailCommonItem(contentId: contentId);
    } on AppException catch (e) {
      firstErr ??= e;
    }

    // 2) 타입별 상세(detailIntro)
    try {
      introItem = await api.fetchDetailIntroItem(
        contentId: contentId,
        contentTypeId: contentTypeId,
      );
    } on AppException catch (e) {
      firstErr ??= e;
    }

    // 3) DTO 변환 (❗️실패한 쪽은 empty()로 대체 — 둘 다 실패해도 동일)
    final common = (commonItem != null)
        ? DetailCommonDto.fromItem(commonItem)
        : DetailCommonDto.empty();

    final intro = (introItem != null)
        ? DetailIntroDto.fromItem(introItem)
        : DetailIntroDto.empty();

    // 4) 도메인 병합 (항상 non-null 전달)
    //    contentTypeId는 라우팅에서 온 값을 그대로 전달
    final detail = mergeDetail(common, intro, contentTypeId: contentTypeId);

    // (선택) 여기서 firstErr 를 detail에 녹이고 싶다면
    // PlaceDetail에 warningMessage 같은 필드를 추가해 주입 가능.
    // 현재는 UI가 필드 비어있음을 보고 안내문을 띄우는 구조를 사용.

    return detail;
  }
}
