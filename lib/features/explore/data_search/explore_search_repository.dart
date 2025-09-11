import 'explore_search_api.dart';
import 'search_models.dart';

/// Repository는 화면/VM에서 쓸만한 인터페이스만 노출.
/// ※R-1: API 교체(REST → gRPC/GraphQL) 시 여기만 바꿔 끼움.
class ExploreSearchRepository {
  ExploreSearchRepository(this._api);
  final ExploreSearchApi _api;

  Future<PageResponsePS> searchFromQuery(Map<String, String> qp) {
    int? _toInt(String? s) => (s == null || s.isEmpty) ? null : int.tryParse(s);
    List<String>? _csv(String? s) =>
        (s == null || s.trim().isEmpty) ? null : s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return _api.search(
      q: qp['q'],
      contentTypeId: _toInt(qp['contentTypeId']),
      cat3List: _csv(qp['cat3']),
      emotionCategoryId: _toInt(qp['emotionCategoryId']),
      page: _toInt(qp['page']) ?? 0,
      size: _toInt(qp['size']) ?? 20,
      sort: qp['sort'],
    );
  }
}
