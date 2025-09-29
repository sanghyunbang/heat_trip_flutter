// 서버 MediaController 엔드포인트들과 1:1로 대응하는 낮은 수준의 HTTP 클라이언트
// - 순수 HTTP 호출/직렬화만 담당 (비즈니스 규칙은 Repository에서)
// - 토큰 주입/기본 URL 구성/에러 텍스트 보존 등을 책임

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../models/media_models.dart';

/// 외부에서 액세스 토큰을 얻어오는 함수 시그니처
typedef TokenProvider = Future<String?> Function();

class MediaApiClient {
  /// 예: 'http://10.0.2.2:8080' 또는 배포용 베이스 URL
  final String baseUrl;

  /// 필요 시 Authorization 헤더에 주입
  final TokenProvider? tokenProvider;

  MediaApiClient({required this.baseUrl, this.tokenProvider});

  /// 토큰이 있으면 Authorization 헤더 추가
  Map<String, String> _authHeaders(String? token) =>
      token == null ? {} : {'Authorization': 'Bearer $token'};

  /// POST /media
  /// - 필드명은 서버와 반드시 동일: files, category, (refType|refId)
  /// - 업로드 성공 시 UploadedMedia 리스트 반환
  Future<List<UploadedMedia>> uploadMany({
    required List<File> files,
    required UploadCategory category,
    String? refType,
    String? refId,
  }) async {
    final uri = Uri.parse('$baseUrl/media');
    final req = http.MultipartRequest('POST', uri);

    // 파일 파트 추가
    for (final f in files) {
      final mime = lookupMimeType(f.path) ?? 'application/octet-stream';
      req.files.add(
        await http.MultipartFile.fromPath(
          'files', // 서버 파라미터명
          f.path,
          contentType: MediaType.parse(mime),
        ),
      );
    }

    // 일반 필드
    req.fields['category'] = category.name;
    if (refType != null) req.fields['refType'] = refType;
    if (refId != null) req.fields['refId'] = refId;

    // 인증 헤더
    final token = tokenProvider == null ? null : await tokenProvider!();
    req.headers.addAll(_authHeaders(token));

    // 전송 → 표준 Response로 변환
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    // 2xx면 성공으로 간주
    if (res.statusCode ~/ 100 == 2) {
      final List raw = jsonDecode(res.body) as List;
      return raw
          .map((e) => UploadedMedia.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    // 에러 텍스트를 그대로 보존하여 디버깅에 도움
    throw Exception('uploadMany failed: ${res.statusCode} ${res.body}');
  }

  /// PUT /media/{mediaId}
  /// - 기존 미디어 교체(프로필 사진 변경 등)
  /// - 서버 응답은 {id, key, url} 단일 오브젝트
  Future<UploadedMedia> replaceFile({
    required int mediaId,
    required File file,
  }) async {
    final uri = Uri.parse('$baseUrl/media/$mediaId');
    final req = http.MultipartRequest('PUT', uri);

    final mime = lookupMimeType(file.path) ?? 'application/octet-stream';
    req.files.add(
      await http.MultipartFile.fromPath(
        'file', // 서버 파라미터명
        file.path,
        contentType: MediaType.parse(mime),
      ),
    );

    final token = tokenProvider == null ? null : await tokenProvider!();
    req.headers.addAll(_authHeaders(token));

    final res = await http.Response.fromStream(await req.send());
    if (res.statusCode ~/ 100 == 2) {
      final Map<String, dynamic> j = jsonDecode(res.body);
      // 서버는 category를 반환하지 않으므로 임시값을 넣거나
      // 필요 시 별도 조회로 보강 (여기선 임시로 PROFILE로 세팅)
      return UploadedMedia(
        id: (j['id'] as num).toInt(),
        key: j['key'] as String,
        url: j['url'] as String,
        category: UploadCategory.PROFILE_IMAGE,
      );
    }
    throw Exception('replaceFile failed: ${res.statusCode} ${res.body}');
  }

  /// DELETE /media/{mediaId}
  Future<void> deleteById(int mediaId) async {
    final token = tokenProvider == null ? null : await tokenProvider!();
    final res = await http.delete(
      Uri.parse('$baseUrl/media/$mediaId'),
      headers: _authHeaders(token),
    );
    if (res.statusCode != 204) {
      throw Exception('delete failed: ${res.statusCode} ${res.body}');
    }
  }

  /// DELETE /media?refType=...&refId=...
  /// - 특정 리소스에 연결된 모든 미디어 삭제
  Future<void> deleteByRef({
    required String refType,
    required String refId,
  }) async {
    final token = tokenProvider == null ? null : await tokenProvider!();
    final uri = Uri.parse('$baseUrl/media?refType=$refType&refId=$refId');
    final res = await http.delete(uri, headers: _authHeaders(token));
    if (res.statusCode != 204) {
      throw Exception('deleteByRef failed: ${res.statusCode} ${res.body}');
    }
  }

  /// GET /media/url?key=...
  /// - 공개 URL을 서버에서 조립(CloudFront 도메인 변경에도 클라 변경 불필요)
  Future<String> getPublicUrl(String key) async {
    final res = await http.get(Uri.parse('$baseUrl/media/url?key=$key'));
    if (res.statusCode ~/ 100 == 2) {
      return (jsonDecode(res.body) as Map<String, dynamic>)['url'] as String;
    }
    throw Exception('getPublicUrl failed: ${res.statusCode} ${res.body}');
  }

  /// GET /media/presigned?key=...&minutes=...
  /// - 비공개 객체 접근 시, 일시적 URL 발급
  Future<String> getPresigned(String key, {int minutes = 10}) async {
    final res = await http.get(
      Uri.parse('$baseUrl/media/presigned?key=$key&minutes=$minutes'),
    );
    if (res.statusCode ~/ 100 == 2) {
      return (jsonDecode(res.body) as Map<String, dynamic>)['url'] as String;
    }
    throw Exception('getPresigned failed: ${res.statusCode} ${res.body}');
  }
}
