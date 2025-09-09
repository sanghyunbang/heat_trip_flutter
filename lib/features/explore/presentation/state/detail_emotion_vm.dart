/// 감정 탭 묶음의 상태를 관리하는 ChangeNotifier.
/// - active 탭, 로딩/에러, 로드된 데이터, 제출폼 상태 등.
/// - 탐색 상세 화면과 별도의 VM로 분리하여 관심사를 분리.

import 'package:flutter/foundation.dart';
import '../../data_detail/emotion_repository.dart';
import '../../domain_detail/emotion_models.dart';

/// 탭 식별용 enum
// AFTER: "overview" 추가 + 기본 탭을 overview로 시작하고 싶으면 active 초기값도 변경
enum EmotionTab { overview, emotion, features, feedback }

// 기본 탭을 개요로 시작 (원하면 emotion으로도 가능)
EmotionTab active = EmotionTab.overview;

class DetailEmotionVM extends ChangeNotifier {
  final EmotionRepository repo;
  final int contentId; // 현재 상세 페이지의 contentId

  DetailEmotionVM({required this.repo, required this.contentId});

  /// 현재 활성 탭
  EmotionTab active = EmotionTab.emotion;

  /// 백엔드에서 로드한 데이터
  PlaceFeatures? features;
  List<EmotionalReview> reviews = [];

  /// 로딩/에러 상태
  bool loadingFeatures = false;
  bool loadingReviews = false;
  String? error;

  /// 제출폼(나의 경험) 입력값(초기값 0.5)
  String? beforeEmotionId;
  String? afterEmotionId;
  final Map<String, double> userFeatureRatings = {
    'sociality': .5,
    'spirituality': .5,
    'adventure': .5,
    'culture': .5,
    'nature_healing': .5,
    'quiet': .5,
  };
  String feedbackText = '';

  /// 최초 로딩(특성+리뷰 병렬 호출)
  Future<void> init() async {
    await Future.wait([loadFeatures(), loadReviews()]);
  }

  /// 공간 특성 로드
  Future<void> loadFeatures() async {
    loadingFeatures = true; error = null; notifyListeners();
    try {
      features = await repo.fetchFeatures(contentId);
    } catch (e) {
      error = '$e';
    }
    loadingFeatures = false; notifyListeners();
  }

  /// 감정 리뷰 로드
  Future<void> loadReviews() async {
    loadingReviews = true; error = null; notifyListeners();
    try {
      reviews = await repo.fetchReviews(contentId);
    } catch (e) {
      error = '$e';
    }
    loadingReviews = false; notifyListeners();
  }

  /// 탭 전환
  void setTab(EmotionTab t) { active = t; notifyListeners(); }

  /// 제출폼 바인딩용 setter들
  void setBefore(String id) { beforeEmotionId = id; notifyListeners(); }
  void setAfter(String id) { afterEmotionId = id; notifyListeners(); }
  void setFeature(String key, double v){ userFeatureRatings[key] = v; notifyListeners(); }
  void setText(String t){ feedbackText = t; notifyListeners(); }

  /// 제출
  Future<void> submit() async {
    if (beforeEmotionId == null || afterEmotionId == null) return;
    await repo.sendFeedback(
      contentId: contentId,
      beforeEmotionId: beforeEmotionId!,
      afterEmotionId: afterEmotionId!,
      featureRatings: userFeatureRatings,
      text: feedbackText.trim().isEmpty ? null : feedbackText.trim(),
    );
    // 전송 후 텍스트만 초기화(필요시 더 초기화 가능)
    feedbackText = '';
    notifyListeners();
  }
}
