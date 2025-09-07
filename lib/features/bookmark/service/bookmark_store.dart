import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heat_trip_flutter/features/bookmark/domain/bookmark_repository.dart';
import 'package:heat_trip_flutter/features/bookmark/data/bookmark_repository_impl.dart';

/// 북마크 전역 상태
/// - _idsOrdered: 화면 표시용(최신순 유지)
/// - _idsSet: 포함여부 O(1) 체크용
class BookmarkStore extends ChangeNotifier {
  BookmarkStore._internal() : _repo = BookmarkRepositoryImpl();
  static final BookmarkStore instance = BookmarkStore._internal();

  final BookmarkRepository _repo;

  bool _initialized = false;
  final List<String> _idsOrdered = <String>[];
  final Set<String> _idsSet = <String>{};
  final Map<String, String> _imageById = <String, String>{};

  bool get isInitialized => _initialized;
  List<String> get idsOrdered => List.unmodifiable(_idsOrdered);
  bool isBookmarked(String id) => _idsSet.contains(id);
  String imageFor(String id) => _imageById[id] ?? '';

  static const _kIdsOrdered = 'bookmark.ids.ordered';
  static const _kImgs = 'bookmark.images';

  Future<void> _saveCache() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(_kIdsOrdered, _idsOrdered);
    await sp.setString(_kImgs, jsonEncode(_imageById));
  }

  Future<void> _loadCache() async {
    final sp = await SharedPreferences.getInstance();
    final ordered = sp.getStringList(_kIdsOrdered) ?? const <String>[];
    _idsOrdered
      ..clear()
      ..addAll(ordered);
    _idsSet
      ..clear()
      ..addAll(_idsOrdered);

    final raw = sp.getString(_kImgs);
    if (raw != null && raw.isNotEmpty) {
      final m = (jsonDecode(raw) as Map).map((k, v) => MapEntry(k.toString(), v.toString()));
      _imageById
        ..clear()
        ..addAll(m);
    }
  }

  /// 계정 전환/로그아웃 시 초기화
  Future<void> reset() async {
    _idsOrdered.clear();
    _idsSet.clear();
    _imageById.clear();
    _initialized = false;
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kIdsOrdered);
    await sp.remove(_kImgs);
    notifyListeners();
  }

  /// 캐시 → 즉시표시 → 서버 동기화(최신순 유지)
  Future<void> ensureInitialized() async {
    if (_initialized) return;
    await _loadCache();
    _initialized = true;
    notifyListeners();

    try {
      final serverOrdered = await _repo.fetchAllOrdered(); // ★ 최신순 보존
      _idsOrdered
        ..clear()
        ..addAll(serverOrdered);
      _idsSet
        ..clear()
        ..addAll(serverOrdered);

      await ensureImagesFor(_idsOrdered);
      await _saveCache();
      notifyListeners();
    } catch (_) {
      // 서버 실패 → 캐시 유지
    }
  }

  /// 주어진 id 중 이미지가 비어있는 것만 배치 조회
  Future<void> ensureImagesFor(Iterable<String> ids) async {
    final need = ids.where((id) => (_imageById[id] ?? '').isEmpty).toList();
    if (need.isEmpty) return;
    try {
      final map = await _repo.fetchImagesBatch(need);
      _imageById.addAll(map);
      await _saveCache();
      notifyListeners();
    } catch (_) {}
  }

  /// 토글(옵티미스틱) — 최신순을 위해 ON 시 리스트 맨 앞에 삽입
  Future<bool> toggle(String id, {String? collectionId}) async {
    await ensureInitialized();
    final willOn = !_idsSet.contains(id);

    if (willOn) {
      // 이미 어딘가에 있으면 제거 후 맨 앞에 삽입(중복 방지)
      _idsOrdered.remove(id);
      _idsOrdered.insert(0, id);
      _idsSet.add(id);
      notifyListeners();
      await _saveCache();

      try {
        await _repo.add(id, collectionId: collectionId);
        if ((_imageById[id] ?? '').isEmpty) {
          final url = await _repo.fetchImage(id);
          if (url != null && url.isNotEmpty) {
            _imageById[id] = url;
            await _saveCache();
            notifyListeners();
          }
        }
      } catch (_) {/* 실패해도 UI 유지 */}
    } else {
      _idsOrdered.remove(id);
      _idsSet.remove(id);
      notifyListeners();
      await _saveCache();

      try {
        await _repo.remove(id);
      } catch (_) {/* 실패해도 UI 유지 */}
    }
    return willOn;
  }
}
