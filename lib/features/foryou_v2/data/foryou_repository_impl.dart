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
    final src = request.toJson();

    final payload = <String, dynamic>{
      'pad': src['pad'],
      'energy': src['energy'],
      'socialNeed': src['socialNeed'],
      'goals': src['goals'],
      'purposeKeywords': src['purposeKeywords'],
      // 서버 스키마에 맞춰 키 치환
      'topK': src['topK'],
      if (src['moodKey'] != null) 'moodKey': src['moodKey'],
      if (src['notes'] != null) 'notes': src['notes'],
      if (userLat != null && userLng != null) ...{
        'userLat': userLat,
        'userLng': userLng,
      },
      // 필요 시 반경/가중치도 추가로 넣을 수 있음:
      // 'maxDistanceKm': ...,
      // 'distanceWeight': ...,
    };

    final json = await api.postJson('/api/curation/recommend', body: payload);
    return ForYouRecommendationResponse.fromJson(json);
  }
}
