// lib/features/foryou/domain/entities/feedback_event.dart
import 'context.dart';

class FeedbackEvent {
  final Context context; // 추천 당시 컨텍스트
  final String targetCategory; // 사용자가 선택/노출된 카테고리
  final double reward; // 0.0 ~ 1.0
  const FeedbackEvent({
    required this.context,
    required this.targetCategory,
    required this.reward,
  });
}
