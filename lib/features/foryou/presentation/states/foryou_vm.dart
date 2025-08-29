// lib/features/foryou/presentation/states/foryou_vm.dart
import 'package:flutter/foundation.dart';

import 'package:heat_trip_flutter/features/foryou/domain/entities/entities.dart'
    as dom;
import 'package:heat_trip_flutter/features/foryou/domain/foryou_repository.dart';
import 'package:heat_trip_flutter/features/foryou/domain/reward.dart';

class ForYouVM extends ChangeNotifier {
  final ForYouRepository repo;
  ForYouVM({required this.repo});

  final List<dom.RankItem> _items = [];
  List<dom.RankItem> get items => List.unmodifiable(_items);

  bool _loading = false;
  bool get loading => _loading;

  Object? _error;
  Object? get error => _error;

  int _k = 8;
  int get k => _k;

  // ---- 노출/클릭/바운스 상태 ----
  final Map<String, Stopwatch> _impressions = {};
  final Map<String, bool> _clicked = {};
  final Map<String, bool> _bounced = {};

  // ---- 지연 피드백용 버퍼 ----
  final Map<String, double> _pendingDwell = {}; // 클릭 후 상세에서 끝날 때까지 보관
  final Set<String> _inDetail = {}; // 상세 화면에 들어간 카테고리

  Future<void> load(dom.Context ctx, {int? k}) async {
    if (k != null) _k = k;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await repo.getTopK(ctx, k: _k);
      _items
        ..clear()
        ..addAll(result);
    } catch (e) {
      _error = e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void onCardVisible(String id) {
    _impressions[id]?.stop();
    _impressions[id] = Stopwatch()..start();
    _clicked[id] = false;
    _bounced[id] = false;
  }

  /// 리스트에서 보이지 않게 될 때 호출됨.
  /// - 스크롤로 사라진 경우: 즉시 피드백 전송
  /// - "탭해서 상세로 진입한" 경우: dwell만 저장하고 상세 종료 시 전송
  Future<void> onCardInvisible(String id, dom.Context ctx) async {
    final sw = _impressions.remove(id);
    if (sw == null) return;
    sw.stop();
    final dwell = sw.elapsedMilliseconds / 1000.0;
    final clicked = _clicked[id] == true;

    if (clicked) {
      // 상세에서 마무리할 것이므로 지연
      _pendingDwell[id] = dwell;
      _inDetail.add(id);
      return;
    }

    // 클릭 없이 스크롤로 사라졌다면 즉시 피드백
    final r = computeReward(
      clicked: false,
      dwellS: dwell,
      bounced: _bounced[id] == true,
    );

    try {
      await repo.sendFeedback(
        dom.FeedbackEvent(context: ctx, targetCategory: id, reward: r),
      );
    } catch (e, st) {
      debugPrint('sendFeedback (invisible) failed: $e\n$st');
      // 실패는 기록만 하고, UI는 계속 진행
    }
  }

  void onTap(String id) {
    _clicked[id] = true;
  }

  void markBounced(String id) {
    _bounced[id] = true;
  }

  /// 상세 페이지에서 pop될 때 한 번 호출
  Future<void> finishDetail(String id, dom.Context ctx) async {
    if (!_inDetail.remove(id)) return; // 상세 진입 케이스가 아니면 무시
    final dwell = _pendingDwell.remove(id) ?? 0.0;
    final r = computeReward(
      clicked: true,
      dwellS: dwell,
      bounced: _bounced[id] == true,
    );

    try {
      await repo.sendFeedback(
        dom.FeedbackEvent(context: ctx, targetCategory: id, reward: r),
      );
    } catch (e, st) {
      debugPrint('sendFeedback (finishDetail) failed: $e\n$st');
    }
  }
}
