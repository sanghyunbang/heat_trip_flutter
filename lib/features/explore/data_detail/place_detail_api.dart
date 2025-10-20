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
import 'dart:async' as dart_async; // [①] TimeoutException 이름 충돌 방지 별칭
import 'dart:io' show SocketException, HandshakeException;

import 'package:http/http.dart' as http;
import 'package:heat_trip_flutter/core/errors/app_exception.dart';

class PlaceDetailApi {
  /// http 클라이언트 (테스트 용이성을 위해 외부 주입)
  final http.Client client;

  /// 공통 상세(overview/mapx/mapy/주소 등)를 주는 베이스 URI
  /// 예) https://apis.data.go.kr/B551011/KorService2/detailCommon2?serviceKey=...&_type=json
  final Uri commonBaseUri;

  /// 타입별 상세(인트로: usetime/parking/infocenter 등)를 주는 베이스 URI
  /// 예) https://apis.data.go.kr/B551011/KorService2/detailIntro2?serviceKey=...&_type=json
  final Uri introBaseUri;

  PlaceDetailApi({
    required this.client,
    required this.commonBaseUri,
    required this.introBaseUri,
  });

  // ────────────────────────────────────────────────────────────────────────────
  // 공통 URI 빌더
  // [②] baseParams(queryParameters) + extraParams를 머지하여 최종 Uri 생성.
  //      _type=json은 baseUri 쪽에서 이미 넣는 걸 권장하므로 여기서 강제하지 않습니다.
  // ────────────────────────────────────────────────────────────────────────────
  Uri _buildUri({
    required String epPath, // 예: "/B551011/KorService2/detailCommon2"
    required Map<String, String> baseParams,
    Map<String, String>? extraParams,
  }) {
    final merged = <String, String>{
      ...baseParams,
      if (extraParams != null) ...extraParams,
    };
    return Uri.https('apis.data.go.kr', epPath, merged);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // KTO 응답에서 '첫 번째 아이템'을 꺼내는 공통 유틸
  // [③] ep 라벨로 COMMON/INTRO 호출을 로그에서 명확히 구분.
  // [④] 원문 본문(rawBody) 스니펫을 항상 출력(디버깅 가시성 확보).
  // [⑤] 방어적 파싱 강화를 통해 예기치 않은 구조 → AppFormatException으로 통일.
  // ────────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> _getFirstItem(
    Uri uri, {
    required String ep,
  }) async {
    print('[PlaceDetailApi][$ep] GET $uri');

    // [⑥] 보안/호스트 가드
    if (uri.scheme != 'https') {
      throw const AppMessageException('보안 연결(HTTPS)만 허용됩니다.');
    }
    const allowedHosts = {'apis.data.go.kr'};
    if (!allowedHosts.contains(uri.host)) {
      throw AppMessageException('잘못된 호스트로 요청되었습니다: ${uri.host}');
    }

    try {
      final res = await client.get(uri).timeout(const Duration(seconds: 12));

      print(
        '[PlaceDetailApi][$ep] status=${res.statusCode} len=${res.body.length}',
      );
      print(
        '[PlaceDetailApi][$ep] content-type=${res.headers['content-type']}',
      );

      // [④] 원문 바디 스니펫
      final rawBody = res.body;
      final rawSnippet = rawBody.length > 800
          ? '${rawBody.substring(0, 800)}…'
          : rawBody;
      print('[PlaceDetailApi][$ep] body: ${rawSnippet.replaceAll('\n', ' ')}');

      // HTTP 코드 체크
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw HttpFailureException(res.statusCode, '공공데이터 포털 응답 오류');
      }

      // [⑤] 방어적 파싱(노드별 타입 확인)
      final decoded = jsonDecode(rawBody);
      if (decoded is! Map) throw const AppFormatException();

      final response = decoded['response'];
      if (response is! Map) throw const AppFormatException();

      final header = response['header'];
      if (header is! Map) throw const AppFormatException();

      final resultCode = header['resultCode'];
      final resultMsg = header['resultMsg'];
      print(
        '[PlaceDetailApi][$ep] resultCode=$resultCode resultMsg=$resultMsg',
      );

      // 공공데이터포털 에러코드(문자열/숫자 혼재 가능성 고려)
      if (resultCode != null && resultCode.toString() != '0000') {
        // [⑦] 서버 메시지를 그대로 사용자 친화 에러로 포장
        throw AppMessageException('API 응답 오류: $resultMsg($resultCode)');
      }

      final bodyNode = response['body'];
      if (bodyNode is! Map) throw const AppFormatException();

      final itemsNode = bodyNode['items'];
      if (itemsNode is! Map) throw const AppFormatException();

      final itemNode = itemsNode['item'];

      if (itemNode is List && itemNode.isNotEmpty) {
        final first = itemNode.first;
        if (first is Map) return Map<String, dynamic>.from(first);
        throw const AppFormatException();
      }
      if (itemNode is Map) {
        return Map<String, dynamic>.from(itemNode);
      }

      // [⑤] item이 없거나 타입이 다르면 포맷 에러
      throw const AppFormatException();
    }
    // 네트워크 계층 → AppException 계열로 변환
    on SocketException {
      throw const NetworkException('네트워크 연결을 확인해 주세요.');
    } on HandshakeException {
      throw const ServerException('보안 연결에 실패했습니다(인증서/호스트 불일치).');
    } on dart_async.TimeoutException {
      throw const AppTimeoutException();
    } on FormatException {
      throw const AppFormatException();
    } on AppException {
      // [⑧] 이미 AppException이면 그대로 상위로
      rethrow;
    } catch (_) {
      // [⑨] 알 수 없는 예외 → UnknownException 통일
      throw const UnknownException();
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // detailCommon2 호출
  // [중요] 문서에 있는 파라미터만 사용:
  //   필수: MobileOS, MobileApp, serviceKey, contentId
  //   옵션: numOfRows, pageNo, _type
  // ────────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchDetailCommonItem({required int contentId}) {
    final uri = _buildUri(
      epPath: '/B551011/KorService2/detailCommon2',
      baseParams: commonBaseUri
          .queryParameters, // MobileOS, MobileApp, serviceKey, (_type)
      extraParams: {
        'contentId': contentId.toString(), // 문서상 이 엔드포인트에서 우리가 추가해야 할 유일한 값
        // ⚠ 문서에 없는 파라미터는 절대 추가하지 않음(예: addrinfoYN, mapinfoYN, defaultYN, firstImageYN, overviewYN 등)
      },
    );
    return _getFirstItem(uri, ep: 'COMMON'); // [③] ep 라벨은 로그 구분 전용
  }

  // ────────────────────────────────────────────────────────────────────────────
  // detailIntro2 호출
  //   필수: MobileOS, MobileApp, serviceKey, contentId, contentTypeId
  //   옵션: numOfRows, pageNo, _type
  // ────────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> fetchDetailIntroItem({
    required int contentId,
    required int contentTypeId,
  }) {
    final uri = _buildUri(
      epPath: '/B551011/KorService2/detailIntro2',
      baseParams: introBaseUri.queryParameters,
      extraParams: {
        'contentId': contentId.toString(),
        'contentTypeId': contentTypeId.toString(),
      },
    );
    return _getFirstItem(uri, ep: 'INTRO');
  }
}
