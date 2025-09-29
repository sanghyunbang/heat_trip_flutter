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
import 'dart:async' as dart_async; // ✅ 내장 TimeoutException 별칭(우리 커스텀과 충돌 방지)
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
  // 내부 유틸: KTO 응답 공통 형태(response.body.items.item[0])에서 '첫 번째 아이템'만 꺼냅니다.
  // **예외 처리 포인트 A**
  //  - 네트워크: SocketException / HandshakeException / Timeout → App*Exception으로 변환
  //  - 포맷: dart:convert FormatException → AppFormatException
  //  - HTTP 코드: 200이 아니면 HttpFailureException
  //  - JSON 구조 이상: AppFormatException
  // ────────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> _getFirstItem(Uri uri) async {
    // 안전장치: HTTPS와 올바른 호스트만 허용(Hostname mismatch 방지)
    if (uri.scheme != 'https') {
      throw const AppMessageException('보안 연결(HTTPS)만 허용됩니다.');
    }
    const allowedHosts = {'apis.data.go.kr'};
    if (!allowedHosts.contains(uri.host)) {
      throw AppMessageException('잘못된 호스트로 요청되었습니다: ${uri.host}');
    }

    try {
      final res = await client.get(uri).timeout(const Duration(seconds: 12));

      if (res.statusCode != 200) {
        throw HttpFailureException(res.statusCode, '공공데이터 포털 응답 오류');
      }

      final decoded = jsonDecode(res.body); // 포맷 오류는 아래 on FormatException
      if (decoded is! Map) throw const AppFormatException();

      final response = decoded['response'];
      final header = (response is Map) ? response['header'] : null;
      final resultCode = (header is Map) ? header['resultCode'] : null;
      final resultMsg = (header is Map) ? header['resultMsg'] : null;

      // 공공데이터포털 특유의 오류코드 (필요 시 케이스 추가)
      if (resultCode != null && resultCode != '0000') {
        throw AppMessageException('API 응답 오류: $resultMsg($resultCode)');
      }

      final body = (response is Map) ? response['body'] : null;
      final items = (body is Map) ? body['items'] : null;
      final item = (items is Map) ? items['item'] : null;

      if (item is List && item.isNotEmpty) {
        final first = item.first;
        if (first is Map) return Map<String, dynamic>.from(first);
        throw AppFormatException();
      }
      if (item is Map) return Map<String, dynamic>.from(item);

      // 데이터 없음/형식 오류 → 상위에서 빈 DTO로 대체 가능
      throw const AppFormatException();
    }
    // 네트워크 계층 → 사용자 친화 메시지 변환
    on SocketException {
      throw const NetworkException('네트워크 연결을 확인해 주세요.');
    } on HandshakeException {
      throw const ServerException('보안 연결에 실패했습니다(인증서/호스트 불일치).');
    } on dart_async.TimeoutException {
      throw const AppTimeoutException();
    }
    // 포맷/디코드 오류 → 일관 메시지
    on FormatException {
      throw const AppFormatException();
    }
    // 이미 AppException 변환된 건 그대로 올림
    on AppException {
      rethrow;
    }
    // 그 외 알 수 없는 오류
    catch (_) {
      throw const UnknownException();
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 공통 상세 호출
  //  - 주어진 contentId만 쿼리에 합쳐 Uri를 생성합니다.
  //  - **예외 처리 포인트 A**에서 모든 예외 변환
  // ────────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchDetailCommonItem({required int contentId}) {
    // Host/Scheme 실수를 원천 차단하기 위해 Uri.https 사용
    final uri = Uri.https(
      'apis.data.go.kr',
      '/B551011/KorService2/detailCommon2',
      {
        ...commonBaseUri.queryParameters, // serviceKey, MobileOS, MobileApp 등
        'contentId': contentId.toString(),
        // 권장 옵션
        'defaultYN': 'Y',
        'addrinfoYN': 'Y',
        'mapinfoYN': 'Y',
        'overviewYN': 'Y',
        '_type': 'json',
      },
    );
    return _getFirstItem(uri);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 타입별 상세 호출(detailIntro)
  //  - contentTypeId는 필수
  //  - **예외 처리 포인트 A**에서 모든 예외 변환
  // ────────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchDetailIntroItem({
    required int contentId,
    required int contentTypeId,
  }) {
    final uri = Uri.https(
      'apis.data.go.kr',
      '/B551011/KorService2/detailIntro2',
      {
        ...introBaseUri.queryParameters, // serviceKey, MobileOS, MobileApp 등
        'contentId': contentId.toString(),
        'contentTypeId': contentTypeId.toString(),
        '_type': 'json',
      },
    );
    return _getFirstItem(uri);
  }
}
