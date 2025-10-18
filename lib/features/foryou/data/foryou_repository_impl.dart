import '../domain/entities.dart';
import '../domain/repositories.dart';
import 'api_client.dart';

class ForYouRepositoryImpl implements ForYouRepository {
  final ApiClient _api;
  ForYouRepositoryImpl(this._api);

  @override
  Future<List<RankedPlace>> fetchRanked({
    required RankRequest request,
    double? userLat,
    double? userLng,
  }) async {
    final body = {...request.toJson()};
    if (userLat != null) body['userLat'] = userLat;
    if (userLng != null) body['userLng'] = userLng;

    final res = await _api.post('/api/curation/rank', body: body);
    if (res.statusCode != 200) {
      throw Exception('Rank API failed: ${res.statusCode}');
    }
    final list = _api.decodeBodyBytes(res) as List;
    return list.map((e) => RankedPlace.fromJson(e)).toList();
  }

  @override
  Future<List<CategoryScore>> fetchCategories({
    required RankRequest request,
    int topN = 6,
  }) async {
    final body = {...request.toJson(), 'topN': topN};
    final res = await _api.post('/api/curation/categories', body: body);
    // 백엔드가 아직 없으면 404가 올 수 있어서 빈 리스트로 안전 처리
    if (res.statusCode == 404) return const <CategoryScore>[];
    if (res.statusCode != 200) {
      throw Exception('Categories API failed: ${res.statusCode}');
    }
    final list = _api.decodeBodyBytes(res) as List;
    return list.map((e) => CategoryScore.fromJson(e)).toList();
  }
}
