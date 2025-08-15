import 'package:heat_trip_flutter/features/curation/domain/repositories.dart';

import '../domain/entities.dart';

/// WHAT: 하드코딩된 하위 감정 테이블. 실서비스에서는 서버/원격 구성을 고려.
class BuiltInSubEmotionSource implements SubEmotionSource {
  const BuiltInSubEmotionSource();

  @override
  List<SubEmotion> all() => const [
    SubEmotion(name: '쾌활함', english: 'Cheerfulness', P: 0.8, A: 0.6, D: 0.6),
    SubEmotion(name: '기쁨', english: 'Delight', P: 0.9, A: 0.7, D: 0.6),
    SubEmotion(name: '큰 기쁨', english: 'Elation', P: 1.0, A: 0.8, D: 0.7),
    SubEmotion(name: '재미', english: 'Amusement', P: 0.7, A: 0.5, D: 0.5),
    SubEmotion(name: '장난기', english: 'Playfulness', P: 0.8, A: 0.8, D: 0.6),
    SubEmotion(name: '감사', english: 'Gratitude', P: 0.8, A: 0.5, D: 0.6),
    SubEmotion(name: '자부심', english: 'Pride', P: 0.9, A: 0.7, D: 0.9),
    SubEmotion(name: '승리감', english: 'Triumph', P: 0.9, A: 0.9, D: 0.9),
    SubEmotion(name: '자신감', english: 'Confidence', P: 0.7, A: 0.6, D: 0.8),
    SubEmotion(
      name: '다정한 기쁨',
      english: 'Affectionate Joy',
      P: 0.8,
      A: 0.5,
      D: 0.6,
    ),
    SubEmotion(name: '신남', english: 'Glee', P: 0.9, A: 0.8, D: 0.6),
    SubEmotion(name: '따뜻함', english: 'Warmth', P: 0.7, A: 0.4, D: 0.5),
  ];
}
