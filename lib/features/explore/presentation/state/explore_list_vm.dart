import 'package:flutter/foundation.dart';
import '../../data_search/explore_search_repository.dart';
import '../../data_search/search_models.dart';

/// Explore 목록 VM
/// - 초기 쿼리를 받아 첫 페이지 로딩
/// - 무한 스크롤(loadMore) 지원
class ExploreListVM extends ChangeNotifier {
  ExploreListVM(this._repo, {required Map<String, String> initialQuery})
      : _query = Map.of(initialQuery);

  final ExploreSearchRepository _repo;
  final Map<String, String> _query;

  final List<PlaceSummary> _items = [];
  List<PlaceSummary> get items => List.unmodifiable(_items);

  bool _loading = false;
  bool get loading => _loading;

  bool _hasNext = true;
  bool get hasNext => _hasNext;

  int _page = 0;
  int _size = 20;

  String? _error;
  String? get error => _error;

  Future<void> loadInitial() async {
    if (_loading) return;
    _items.clear();
    _page = int.tryParse(_query['page'] ?? '') ?? 0;
    _size = int.tryParse(_query['size'] ?? '') ?? 20;
    _hasNext = true;
    _error = null;

    _loading = true; notifyListeners();
    try {
      final resp = await _repo.searchFromQuery({..._query, 'page': '$_page', 'size': '$_size'});
      _items.addAll(resp.items);
      // 다음 페이지 여부 계산(총합 방식/last 플래그 둘 다 대응)
      _hasNext = resp.last ?? (((_page + 1) * _size) < resp.total);
    } catch (e) {
      _error = '$e';
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_loading || !_hasNext) return;
    _loading = true; notifyListeners();
    try {
      _page += 1;
      final resp = await _repo.searchFromQuery({..._query, 'page': '$_page', 'size': '$_size'});
      _items.addAll(resp.items);
      _hasNext = resp.last ?? (((_page + 1) * _size) < resp.total);
    } catch (e) {
      _error = '$e';
    } finally {
      _loading = false; notifyListeners();
    }
  }

  void updateQuery(Map<String, String> next) {
    _query
      ..clear()
      ..addAll(next);
  }
}
