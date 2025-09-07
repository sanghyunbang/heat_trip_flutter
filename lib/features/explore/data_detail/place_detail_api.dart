/// place_detail_api.dart
/// 실제 HTTP 호출 담당. 각 프로젝트의 API 스펙에 맞게 Uri 생성만 교체하세요.
/// ─────────────────────────────────────────────────────────────────────────────
/// 이 클래스는 "이미 화면/라우터/VM에서 전달받은" contentId, contentTypeId를
/// 최종 URI에 쿼리로 붙여서 KTO API(detailCommon/detailIntro)를 호출합니다.
/// 여기서 contentId/contentTypeId를 '새로' 만드는 게 아니라,
/// 상위 계층(PlaceCard → Router → ExploreDetailScreen → DetailVM → Repository)에서
/// 흘러 내려온 값을 '그대로' 사용합니다.
/// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:http/http.dart' as http;

class PlaceDetailApi {
  /// http 클라이언트 (테스트 용이성을 위해 외부 주입)
  final http.Client client;

  /// 공통 상세(overview/mapx/mapy/주소 등)를 주는 베이스 URI
  /// 예) https://apis.data.go.kr/B551011/KorService2/detailCommon2?serviceKey=...&MobileOS=AND&MobileApp=HeatTrip&_type=json
  final Uri commonBaseUri;

  /// 타입별 상세(인트로: usetime/parking/infocenter 등)를 주는 베이스 URI
  /// 예) https://apis.data.go.kr/B551011/KorService2/detailIntro2?serviceKey=...&MobileOS=AND&MobileApp=HeatTrip&_type=json
  final Uri introBaseUri;

  PlaceDetailApi({
    required this.client,
    required this.commonBaseUri,
    required this.introBaseUri,
  });

  /// 내부 유틸: KTO 응답 공통 형태(response.body.items.item[0])에서 '첫 번째 아이템'만 꺼냅니다.
  /// - 이 API는 "리스트"를 감싸서 내려주므로 보통 1개만 필요하면 first 사용.
  /// - JSON이 아닌 XML이 오면 jsonDecode에서 터지므로, 상위 계층에서 `_type=json`
  ///   과 서비스키 인코딩(이중 인코딩 금지)을 꼭 확인하세요.
  Future<Map<String, dynamic>> _getFirstItem(Uri uri) async {
    //   - serviceKey(인코딩 여부), MobileOS, MobileApp, _type=json, contentId, contentTypeId
    print('[API] GET $uri');

    final res = await client.get(uri);
    print('[API] status=${res.statusCode}');
    print(
      '[API] body.head=${res.body.substring(0, res.body.length.clamp(0, 1000))}',
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final header = (decoded['response']?['header']) as Map<String, dynamic>?;
    final resultCode = header?['resultCode'];
    final resultMsg = header?['resultMsg'];
    print('[API] result=$resultCode $resultMsg');

    // final decoded = jsonDecode(res.body);
    // 꼭 타입 확인
    if (decoded is! Map)
      throw Exception('Unexpected JSON root: ${decoded.runtimeType}');

    final response = decoded['response'];
    final body = (response is Map) ? response['body'] : null;
    final items = (body is Map) ? body['items'] : null;
    final item = (items is Map) ? items['item'] : null;

    // ① item 이 List 인 경우
    if (item is List && item.isNotEmpty) {
      final first = item.first;
      if (first is Map<String, dynamic>) return first;
      if (first is Map) return Map<String, dynamic>.from(first);
      throw Exception('Unexpected item[0] type: ${first.runtimeType}');
    }

    // ② item 이 Map 인 경우(단일 반환 케이스)
    if (item is Map<String, dynamic>) return item;
    if (item is Map) return Map<String, dynamic>.from(item);

    throw Exception('Empty or unexpected `item` type: ${item.runtimeType}');
  }

  /// 공통 상세 호출
  ///  - 여기의 `contentId`는 "상위 레이어에서 넘겨준 값"입니다.
  ///  - 실제 URI는 `commonBaseUri`의 공통 쿼리에 contentId만 추가해서 생성합니다.
  Future<Map<String, dynamic>> fetchDetailCommonItem({
    required int
    contentId, // ← 어디서 오나? PlaceCard → Router → Screen → VM → Repository를 통해 전달됨.
  }) {
    // replace(queryParameters)로 per-call 파라미터(contentId)를 Merge
    final uri = commonBaseUri.replace(
      queryParameters: {
        ...commonBaseUri
            .queryParameters, // serviceKey/MobileOS/MobileApp/_type 등
        'contentId': contentId.toString(), // ← 최종적으로 여기에 붙습니다.
        // 필요 시 여기서 defaultYN/addrinfoYN/mapinfoYN/overviewYN도 켭니다(권장).
        // 'defaultYN': 'Y',
        // 'addrinfoYN': 'Y',
        // 'mapinfoYN': 'Y',
        // 'overviewYN': 'Y',
      },
    );
    return _getFirstItem(uri);
  }

  /// 타입별 상세 호출
  ///  - `contentTypeId`는 detailIntro에서 필수 파라미터입니다.
  ///  - 이 값 역시 상위에서 받은 것을 그대로 전달합니다.
  Future<Map<String, dynamic>> fetchDetailIntroItem({
    required int contentId, // ← 라우트 파라미터에서 내려온 동일한 ID
    required contentTypeId, // ← 라우트 파라미터에서 내려온 타입ID (12/14/15/25/28/32/38/39 등)
  }) {
    final uri = introBaseUri.replace(
      queryParameters: {
        ...introBaseUri
            .queryParameters, // serviceKey/MobileOS/MobileApp/_type 등
        'contentId': contentId.toString(),
        'contentTypeId': contentTypeId.toString(), // ← 여기 붙습니다.
      },
    );
    return _getFirstItem(uri);
  }
}
