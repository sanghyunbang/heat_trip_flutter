abstract class FeedbackRepository {
  /// 피드백 전송
  /// - [content]는 필수, 나머지는 선택
  Future<bool> sendFeedback({
    required String content,
    String? category,
    String? appVersion,
    String? deviceInfo,
  });
}
