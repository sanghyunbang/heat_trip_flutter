import 'package:flutter/foundation.dart';

/// ✅ 5종 플레이스홀더(Unsplash 예시)
const _placeholders = <String>[
  'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&auto=format&fit=crop&w=1600', // 바다
  'https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&auto=format&fit=crop&w=1600', // 산
  'https://images.unsplash.com/photo-1508057198894-247b23fe5ade?q=80&auto=format&fit=crop&w=1600', // 도시
  'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?q=80&auto=format&fit=crop&w=1600', // 숲
];

/// ✅ seed가 null이어도 안전하게 만들어주는 헬퍼
Object _ensureSeed(Object? scheduleId, String? title) {
  return scheduleId ?? (title != null && title.isNotEmpty ? title : 'default');
}

/// (선택) 외부에서 명시적으로 seed를 만들고 싶을 때 사용
Object deriveImageSeed({Object? scheduleId, String? title}) {
  return _ensureSeed(scheduleId, title);
}

/// ✅ 시드 기반 플레이스홀더 선택 (salt로 같은 시드 내 변형)
String pickPlaceholder({Object? seed, String? title, int salt = 0}) {
  final s = _ensureSeed(seed, title);
  final h = (s.hashCode + salt).abs();
  return _placeholders[h % _placeholders.length];
}

/// ✅ url이 비어있으면 플레이스홀더 반환 (seed가 null이어도 OK)
String photoOrPlaceholder(
  String? url, {
  Object? seed,
  String? title,
  int salt = 0,
}) {
  final has = (url != null && url.trim().isNotEmpty);
  if (has) return url!;
  return pickPlaceholder(seed: seed, title: title, salt: salt);
}
