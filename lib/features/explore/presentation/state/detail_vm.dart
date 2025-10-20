/// detail_vm.dart
/// 화면 로딩/데이터/에러 상태를 관리하는 ChangeNotifier
///
/// ✅ 주의
/// - Repository가 부분 실패 허용(빈 DTO 대체)일 경우, 여기서는 가급적
///   throw를 받지 않으므로 `error`는 null로 유지되어 화면(탭)이 항상 뜹니다.
/// - 에러 메시지를 UI에 보여주고 싶다면, Repository에서 warning을
///   도메인에 녹여 전달하거나, VM에 별도의 notice 필드를 두어 세팅하세요.

import 'package:flutter/foundation.dart';
import 'package:heat_trip_flutter/core/errors/app_exception.dart';
import 'package:heat_trip_flutter/features/explore/domain/entity_detail/place_detail.dart';
import '../../data_detail/place_detail_repository.dart';

class DetailVM extends ChangeNotifier {
  final PlaceDetailRepository repo;
  DetailVM(this.repo);

  bool loading = false;

  // UI에서 바로 출력 가능하도록 에러는 String 메시지로 관리
  String? error;

  PlaceDetail? data;

  Future<void> load({
    required int contentId,
    required int contentTypeId,
  }) async {
    loading = true;
    error = null;
    data = null;
    notifyListeners();

    try {
      data = await repo.fetch(
        contentId: contentId,
        contentTypeId: contentTypeId,
      );
      debugPrint('[DetailVM] load() success: hasData=${data != null}');
    }
    // 우리가 변환한 예외 → 사용자 메시지
    on AppException catch (e) {
      error = e.message;
      debugPrint('[DetailVM] AppException: ${e.message}');
    }
    // 혹시 누락된 비정형 오류
    catch (e, st) {
      error = '상세 정보를 불러오지 못했습니다.';
      debugPrint('[DetailVM] Unknown error: $e\n$st');
    } finally {
      loading = false;
      notifyListeners();
      debugPrint('[DetailVM] load() end: loading=$loading, error=$error');
    }
  }
}
