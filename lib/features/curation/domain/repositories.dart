import 'dart:math' as math; // WHY: 거리 계산에 표준 sqrt 사용
import 'entities.dart';

/// 저장/불러오기/초기화 추상화(의존성 역전). Data 계층이 구현합니다.
abstract class CurationRepository {
  Future<void> save(UserSelection selection);
  Future<UserSelection?> load();
  Future<void> reset();
}

/// 하위 감정 데이터 소스 추상화(현재는 로컬 상수, 나중에 원격으로 교체 가능)
abstract class SubEmotionSource {
  List<SubEmotion> all();
}

/// PAD 공간에서 유클리드 거리 기반 Top-N 매칭
class SubEmotionMatcher {
  List<SubEmotion> topMatches({
    required PadNormalized target,
    required List<SubEmotion> pool,
    int topN = 8,
  }) {
    // WHAT: (p,a,d) 좌표 간 거리 계산 → 가까운 순 정렬
    final scored = pool.map((e) {
      final dx = target.p - e.P;
      final dy = target.a - e.A;
      final dz = target.d - e.D;
      final dist = math.sqrt(dx * dx + dy * dy + dz * dz);
      return (e, dist);
    }).toList();
    scored.sort((a, b) => a.$2.compareTo(b.$2));
    return scored.take(topN).map((t) => t.$1).toList(growable: false);
  }
}
