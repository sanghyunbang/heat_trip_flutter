/// Repository: API 호출 결과를 도메인 모델로 변환하여 상위에 제공.
/// - 화면/VM이 API 형식에 의존하지 않도록 중간 계층 역할.

import '../domain_detail/emotion_models.dart';
import 'emotion_api.dart';

class EmotionRepository {
  final EmotionApi api;
  EmotionRepository(this.api);

  /// DB/백엔드에서 공간 특성 로드
  Future<PlaceFeatures> fetchFeatures(int contentId) async {
    final j = await api.getFeatures(contentId);
    return PlaceFeatures.fromJson(j);
  }

  /// 감정 리뷰 로드
  Future<List<EmotionalReview>> fetchReviews(int contentId) async {
    final list = await api.getReviews(contentId);
    return list
        .map((e) => EmotionalReview.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 사용자 피드백 제출
  Future<void> sendFeedback({
    required int contentId,
    required String beforeEmotionId,
    required String afterEmotionId,
    required Map<String, double> featureRatings, // 각 0~1
    String? text,
  }) async {
    await api.submitFeedback(contentId, {
      'beforeEmotion': beforeEmotionId,
      'afterEmotion': afterEmotionId,
      'featureRatings': featureRatings.map((k, v) => MapEntry(k, v)),
      if (text != null && text.isNotEmpty) 'content': text,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
