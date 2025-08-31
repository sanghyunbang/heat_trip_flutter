/// detail_vm.dart
/// 화면 로딩/데이터/에러 상태를 관리하는 ChangeNotifier
import 'package:flutter/foundation.dart';
import 'package:heat_trip_flutter/features/explore/domain/entity_detail/place_detail.dart';
import '../../data_detail/place_detail_repository.dart';

class DetailVM extends ChangeNotifier {
  final PlaceDetailRepository repo;
  DetailVM(this.repo);

  bool loading = false;
  Object? error;
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
    } catch (e) {
      error = e;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
