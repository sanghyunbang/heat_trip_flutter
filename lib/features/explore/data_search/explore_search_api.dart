import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'search_models.dart';

/// Explore 검색 API 래퍼
/// - GET /api/explore/search
/// - 쿼리: q, contentTypeId, cat3(CSV), emotionCategoryId, page, size, sort
class ExploreSearchApi {
  ExploreSearchApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _buildUri(Map<String, String?> qp) {
    final base = dotenv.maybeGet('API_BASE_URL') ?? 'http://10.0.2.2:8080';
    return Uri.parse('$base/api/explore/places/search').replace(
      queryParameters: Map.fromEntries(
        qp.entries.where((e) => e.value != null && e.value!.isNotEmpty),
      ),
    );
  }

  Future<PageResponsePS> search({
    String? q,
    int? contentTypeId,
    List<String>? cat3List,
    int? emotionCategoryId,
    int page = 0,
    int size = 20,
    String? sort,
  }) async {
    // cat3은 CSV로 전송
    final qp = <String, String?>{
      'q': q,
      'contentTypeId': contentTypeId?.toString(),
      'cat3': (cat3List == null || cat3List.isEmpty) ? null : cat3List.join(','),
      'emotionCategoryId': emotionCategoryId?.toString(),
      'page': '$page',
      'size': '$size',
      'sort': sort,
    };

    final uri = _buildUri(qp);
    final res = await _client.get(uri);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final map = json.decode(res.body) as Map<String, dynamic>;
      return PageResponsePS.fromJson(map);
    }
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }

  void dispose() => _client.close();
}
