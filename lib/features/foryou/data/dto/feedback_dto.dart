// lib/features/foryou/data/dto/feedback_dto.dart

import 'context_dto.dart';

/// 사용자의 실제 행동(선택/클릭/이탈 등)에 따라 학습 피드백을 전송하는 모델
/// → 서버의 /feedback 엔드포인트에 POST 전송
class FeedbackDto {
  final ContextDto context; // 추천 당시의 입력 컨텍스트
  final String targetCategory; // 사용자가 실제 클릭/선택한 카테고리
  final double reward; // 행동 기반 보상값 (0.0 ~ 1.0)

  FeedbackDto({
    required this.context,
    required this.targetCategory,
    required this.reward,
  });

  /// 서버로 전송할 JSON 형태로 변환
  Map<String, dynamic> toJson() => {
    "context": context.toJson(),
    "target_category": targetCategory,
    "reward": reward,
  };
}
