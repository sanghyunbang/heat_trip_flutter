import 'dart:async';
import '../domain/models.dart';
import '../domain/repositories.dart';
import 'api_client.dart';

// (선택) 문자열 Sanitizer: NUL 등 제어문자 방어
String _sanitize(String? s) {
  if (s == null) return '';
  final filtered = s.runes.map((cp) => cp == 0x0000 ? 0xFFFD : cp);
  return String.fromCharCodes(filtered);
}

class ForYouRepositoryImpl implements ForYouRepository {
  final ApiClient api;
  ForYouRepositoryImpl(this.api);

  @override
  Future<ForYouRecommendationResponse> recommend(
    RankRequest request, {
    double? userLat,
    double? userLng,
  }) async {
    // 원본 JSON
    final src = request.toJson();

    // ✅ 전송 직전: 필요한 필드만 추려서 서버 스키마에 맞게 구성
    //    (문자열 필드에는 sanitize 권장)
    final payload = <String, dynamic>{
      'pad': src['pad'],
      'energy': src['energy'],
      'socialNeed': src['socialNeed'],
      'goals': src['goals'],
      'purposeKeywords': (src['purposeKeywords'] as List<dynamic>?)
              ?.map((e) => _sanitize(e?.toString()))
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
      'topK': src['topK'],
      if (src['moodKey'] != null) 'moodKey': _sanitize(src['moodKey']?.toString()),
      if (src['notes'] != null)
        'notes': (() {
          final s = _sanitize(src['notes']?.toString());
          return s.isEmpty ? null : s;
        })(),
      if (userLat != null && userLng != null) ...{
        'userLat': userLat,
        'userLng': userLng,
      },
      // 필요 시 반경/가중치 추가
      // 'maxDistanceKm': ...,
      // 'distanceWeight': ...,
    };

    try {
      // ✅ 명시적으로 타임아웃 전달 (ApiClient 내부에서 1회 재시도 포함)
      final json = await api.postJson(
        '/api/curation/recommend',
        body: payload,
        timeout: kDefaultHttpTimeout, // 25s (필요 시 변경/주입 가능)
      );

      return ForYouRecommendationResponse.fromJson(json);
    } on TimeoutException {
      // 상위(VM)에서 사용자 메시지를 구분 처리할 수 있도록 예외 그대로 전달 권장
      rethrow;
    } on HttpExceptionDetailed {
      rethrow; // 상위에서 상태코드에 따라 분기 처리 가능
    } catch (e) {
      // 기타 예외는 한 단계 감싸서 전달해도 되고, 그냥 rethrow 해도 됨
      rethrow;
    }
  }
}
