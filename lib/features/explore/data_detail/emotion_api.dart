/// 감정/특성 관련 백엔드 REST 호출 전용.
/// - http.Client를 주입받아 테스트/교체 용이.
/// - .env에는 "API_BASE_URL=http://host:port"만 넣습니다. (※ 슬래시 없이)
/// - 본 클래스의 baseUrl은 내부에서 "/api/explore/places"를 붙여 만듭니다.
///   예: http://222.111.78.27:8080 + /api/explore/places
///
/// 엔드포인트 매핑
///   GET  {baseUrl}/{contentId}/features[?includeConf=false]
///   GET  {baseUrl}/{contentId}/emotional-reviews
///   POST {baseUrl}/{contentId}/feedback
///
/// 각주
/// ① utf8.decode(bodyBytes): 한글/멀티바이트 안전 파싱
/// ② _join(): baseUrl/tail 안전 결합(중복 슬래시 제거)
/// ③ includeConf=false면 conf_*, n_reviews 등 메타 제외

import 'dart:convert';
import 'package:http/http.dart' as http;

class EmotionApi {
  final http.Client _client;
  final String baseUrl; // 최종: http://host:port/api/explore/places

  EmotionApi(
    this._client, {
    required String apiBaseFromEnv, // 예: http://222.111.78.27:8080
  }) : baseUrl = _normalizeBase(apiBaseFromEnv);

  /// ENV의 API_BASE_URL에 "/api/explore/places"를 붙이고
  /// 말단 슬래시를 정규화합니다.
  static String _normalizeBase(String root) {
    // 끝 슬래시 제거
    final trimmed = root.replaceFirst(RegExp(r'/*$'), '');
    return '$trimmed/api/explore/places';
  }

  /// baseUrl과 tail을 안전하게 합칩니다. (②)
  String _join(String tail) {
    final root = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final path = tail.startsWith('/') ? tail : '/$tail';
    return '$root$path';
  }

  /// 공간 특성 조회 (③)
  Future<Map<String, dynamic>> getFeatures(
    int contentId, {
    bool includeConf = true,
  }) async {
    final q = includeConf ? '' : '?includeConf=false';
    final url = _join('$contentId/features$q');
    final r = await _client.get(Uri.parse(url));
    if (r.statusCode != 200) {
      throw Exception('features load failed ${r.statusCode}');
    }
    return json.decode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>; // ①
  }

  /// 감정 리뷰 목록
  Future<List<dynamic>> getReviews(int contentId) async {
    final url = _join('$contentId/emotional-reviews');
    final r = await _client.get(Uri.parse(url));
    if (r.statusCode != 200) {
      throw Exception('reviews load failed ${r.statusCode}');
    }
    return json.decode(utf8.decode(r.bodyBytes)) as List<dynamic>; // ①
  }

  /// 나의 경험(피드백) 제출
  /// body: { beforeEmotion, afterEmotion, featureRatings:{...}, content?, timestamp }
  Future<void> submitFeedback(int contentId, Map<String, dynamic> payload) async {
    final url = _join('$contentId/feedback');
    final r = await _client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('feedback submit failed ${r.statusCode}');
    }
  }
}
