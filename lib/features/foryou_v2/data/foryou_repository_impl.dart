import '../domain/models.dart';
import '../domain/repositories.dart';
import 'api_client.dart';

class ForYouRepositoryImpl implements ForYouRepository {
  final ApiClient api;
  ForYouRepositoryImpl(this.api);

  @override
  Future<ForYouRecommendationResponse> recommend(
    RankRequest request, {
    double? userLat,
    double? userLng,
  }) async {
    final payload = {
      ...request.toJson(),
      if (userLat != null && userLng != null)
        'userLocation': {'lat': userLat, 'lng': userLng},
    };
    final json = await api.postJson('/api/curation/recommend', body: payload);
    return ForYouRecommendationResponse.fromJson(json);
  }
}
