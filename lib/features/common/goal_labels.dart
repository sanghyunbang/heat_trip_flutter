import 'package:flutter/foundation.dart';

/// 표준 목표 라벨(SSOT: Single Source of Truth)
/// - 시트에서 쓰는 키 + 과거 카드 키 모두 포함
const Map<String, String> kGoalLabels = {
  // 현재 시트 키
  'quiet_reflection': '고요/성찰',
  'meaning_reflection': '의미/성찰',
  'nature_healing': '자연 힐링',
  'adventure': '모험/활동',
  'culture': '문화/예술',
  'social': '교류/연결',
  'spiritual': '영성/명상',

  // 과거(카드) 키도 지원
  'relaxation': '진정',
  'mood_enhancement': '기분상향',
  'immersion': '몰입',
  'social_connection': '연결',
  'perspective_shift': '관점전환',
};

/// 과거/혼합 키를 표준 키로 정규화하기 위한 별칭(aliase)
const Map<String, String> kGoalAliases = {
  // kebab → snake
  'quiet-reflection': 'quiet_reflection',
  'meaning-reflection': 'meaning_reflection',
  'social-connection': 'social_connection',
  'mood-enhancement': 'mood_enhancement',
  'perspective-shift': 'perspective_shift',

  // 공백 → snake
  'quiet reflection': 'quiet_reflection',
  'meaning reflection': 'meaning_reflection',
  'social connection': 'social_connection',
  'mood enhancement': 'mood_enhancement',
  'perspective shift': 'perspective_shift',
};

/// 키 정규화: trim → lower → space/kebab → snake → alias 적용
@visibleForTesting
String normalizeGoalKey(String raw) {
  final s = raw.trim().toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
  return kGoalAliases[s] ?? s;
}

/// 여러 키를 한국어 라벨 문자열로 변환
String goalLabelFromKeys(Iterable<String> keys) {
  final labels = <String>[];
  for (final k in keys) {
    final nk = normalizeGoalKey(k);
    labels.add(kGoalLabels[nk] ?? k); // 미정의면 원키 노출(디버깅 시 유용)
  }
  return labels.join(', ');
}

/// 시트 기본 목표 세트(칩 렌더링용)
const List<String> kDefaultGoalKeys = [
  'quiet_reflection',
  'meaning_reflection',
  'nature_healing',
  'adventure',
  'culture',
  'social',
  'spiritual',
];
