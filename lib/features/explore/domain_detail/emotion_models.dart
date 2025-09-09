// lib/features/explore/domain_detail/emotion_models.dart
/// 감정/특성/감정리뷰 도메인 모델 정의.
/// - 프레젠테이션(위젯)과 데이터 계층 사이의 중간 형태.
/// - API 스키마가 바뀌더라도 fromJson만 고치면 상위 코드 영향 최소화.

class EmotionScore {
  /// 감정의 ID (예: 'JOY', 'CALM')
  final String id;

  /// 한글명 (예: '기쁨', '평온')
  final String name;

  /// UI에 표시할 이모지
  final String emoji;

  /// V(Valence, 유쾌-불쾌)
  final double valence;

  /// A(Arousal, 각성도)
  final double arousal;

  /// D(Dominance, 통제감)
  final double dominance;

  const EmotionScore({
    required this.id,
    required this.name,
    required this.emoji,
    required this.valence,
    required this.arousal,
    required this.dominance,
  });
}

class PlaceFeatures {
  /// 사람들과 어울림 (0~1)
  final double sociality;

  /// 내면/영성 체험 (0~1)
  final double spirituality;

  /// 모험/자극 (0~1)
  final double adventure;

  /// 문화/학습성 (0~1)
  final double culture;

  /// 자연 치유감 (0~1) — 백엔드는 snake_case(nature_healing)일 수도 있음
  final double natureHealing;

  /// 정숙/고요 (0~1)
  final double quiet;

  const PlaceFeatures({
    required this.sociality,
    required this.spirituality,
    required this.adventure,
    required this.culture,
    required this.natureHealing,
    required this.quiet,
  });

  /// 백엔드 JSON을 안전하게 읽어오는 팩토리.
  /// - 키가 없거나 null이면 0.0으로 처리.
  /// - 'nature_healing' 혹은 'natureHealing' 둘 다 지원.
  factory PlaceFeatures.fromJson(Map<String, dynamic> j) => PlaceFeatures(
    sociality: (j['sociality'] ?? 0.0).toDouble(),
    spirituality: (j['spirituality'] ?? 0.0).toDouble(),
    adventure: (j['adventure'] ?? 0.0).toDouble(),
    culture: (j['culture'] ?? 0.0).toDouble(),
    natureHealing: (j['nature_healing'] ?? j['natureHealing'] ?? 0.0).toDouble(),
    quiet: (j['quiet'] ?? 0.0).toDouble(),
  );
}

class EmotionalReview {
  /// 리뷰 PK(문자열화)
  final String id;

  /// 작성자 표시명
  final String author;

  /// 작성일 (DateTime으로 변환)
  final DateTime date;

  /// 방문 전 감정 ID
  final String beforeEmotionId;

  /// 방문 후 감정 ID
  final String afterEmotionId;

  /// 감정 변화량(ΔV/ΔA/ΔD)
  final double dV, dA, dD;

  /// 리뷰 본문
  final String content;

  /// 도움돼요 카운트
  final int helpfulCount;

  /// 첨부 이미지(썸네일용)
  final List<String> images;

  EmotionalReview({
    required this.id,
    required this.author,
    required this.date,
    required this.beforeEmotionId,
    required this.afterEmotionId,
    required this.dV,
    required this.dA,
    required this.dD,
    required this.content,
    required this.helpfulCount,
    required this.images,
  });

  /// API 응답(JSON) → 모델 변환
  factory EmotionalReview.fromJson(Map<String, dynamic> j) => EmotionalReview(
    id: j['id'].toString(),
    author: j['author'] ?? '익명',
    date: DateTime.tryParse(j['date'] ?? '') ?? DateTime.now(),
    beforeEmotionId: j['beforeEmotion'] ?? 'CALM',
    afterEmotionId: j['afterEmotion'] ?? 'JOY',
    dV: (j['emotionalChange']?['valence'] ?? 0.0).toDouble(),
    dA: (j['emotionalChange']?['arousal'] ?? 0.0).toDouble(),
    dD: (j['emotionalChange']?['dominance'] ?? 0.0).toDouble(),
    content: j['content'] ?? '',
    helpfulCount: (j['helpfulCount'] ?? 0) as int,
    images: (j['images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
  );
}
