class FeedbackRequest {
  final String content;
  final String? category;
  final String? appVersion;
  final String? deviceInfo;

  FeedbackRequest({
    required this.content,
    this.category,
    this.appVersion,
    this.deviceInfo,
  });

  Map<String, dynamic> toJson() => {
    'content': content,
    if (category != null && category!.trim().isNotEmpty) 'category': category,
    if (appVersion != null && appVersion!.trim().isNotEmpty) 'appVersion': appVersion,
    if (deviceInfo != null && deviceInfo!.trim().isNotEmpty) 'deviceInfo': deviceInfo,
  };
}
