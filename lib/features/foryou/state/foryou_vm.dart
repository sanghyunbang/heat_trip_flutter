import 'package:flutter/foundation.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';

class ForYouVM extends ChangeNotifier {
  final ForYouRepository repo;

  ForYouVM({required this.repo, required RankRequest initial})
    : _request = ValueNotifier<RankRequest>(initial);

  // request (외부에서 listen 가능)
  final ValueNotifier<RankRequest> _request;
  ValueListenable<RankRequest> get requestListenable => _request;
  RankRequest get request => _request.value;

  // data
  List<RankedPlace> places = const [];
  List<CategoryScore> categories = const [];
  bool loading = false;
  String? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final r = _request.value;
      final results = await Future.wait([
        repo.fetchRanked(request: r),
        repo.fetchCategories(request: r, topN: 6),
      ]);
      places = results[0] as List<RankedPlace>;
      categories = results[1] as List<CategoryScore>;
    } catch (e) {
      error = '$e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // 저장/수정된 요청 반영
  void applyRequest(RankRequest updated) {
    _request.value = updated;
    load();
  }
}
