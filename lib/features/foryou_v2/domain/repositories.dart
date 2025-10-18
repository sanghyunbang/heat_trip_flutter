import 'models.dart';

/// 단일 엔드포인트 호출용
abstract class ForYouRepository {
  Future<ForYouRecommendationResponse> recommend(
    RankRequest request, {
    double? userLat,
    double? userLng,
  });
}
