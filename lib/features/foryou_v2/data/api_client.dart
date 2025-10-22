import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// 공통 타임아웃 정책 (연결+수신 통합 타임아웃 예산)
const Duration kDefaultHttpTimeout = Duration(seconds: 25);

/// 짧은 백오프 후 1회 재시도하는 헬퍼
Future<T> _withTimeoutRetryOnce<T>(
  Future<T> Function() task, {
  Duration timeout = kDefaultHttpTimeout,
  Duration backoff = const Duration(seconds: 1),
}) async {
  try {
    // 1차 시도
    return await task().timeout(timeout);
  } on TimeoutException {
    // 1회 재시도 (일시적 지연/콜드스타트 흡수)
    await Future.delayed(backoff);
    return await task().timeout(timeout);
  }
}

/// 간단 HTTP 클라이언트 (JSON POST만)
class ApiClient {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  const ApiClient({
    required this.baseUrl,
    this.defaultHeaders = const {'Content-Type': 'application/json'},
  });

  /// JSON POST
  /// - timeout: 기본 25s (내부에서 1회 재시도)
  /// - 2xx 외에는 Exception으로 던짐
  /// - res.bodyBytes → utf8.decode → jsonDecode 로 안전 디코딩
  Future<Map<String, dynamic>> postJson(
    String path, {
    Object? body,
    Map<String, String>? headers,
    Duration timeout = kDefaultHttpTimeout,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final merged = {...defaultHeaders, if (headers != null) ...headers};
    final jsonBody = body is String ? body : jsonEncode(body);

    // ✅ 일시적 지연을 흡수하기 위해 1회 재시도 래퍼 사용
    final res = await _withTimeoutRetryOnce(
      () => http.post(uri, headers: merged, body: jsonBody),
      timeout: timeout,
    );

    // ✅ 2xx 아닌 경우, 본문을 그대로 실어 로그/디버깅에 도움
    if (res.statusCode ~/ 100 != 2) {
      final text = utf8.decode(res.bodyBytes);
      throw HttpExceptionDetailed(
        statusCode: res.statusCode,
        body: text,
        url: uri.toString(),
      );
    }

    // ✅ UTF-8로 안전 디코딩 후 JSON 파싱
    final text = utf8.decode(res.bodyBytes);
    final decoded = jsonDecode(text);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    } else {
      throw FormatException('Unexpected JSON type (expected object): $decoded');
    }
  }
}

/// HTTP 상세 예외: 상위 레이어에서 status/body 로깅에 유용
class HttpExceptionDetailed implements Exception {
  final int statusCode;
  final String body;
  final String url;
  HttpExceptionDetailed({required this.statusCode, required this.body, required this.url});

  @override
  String toString() => 'HTTP $statusCode @ $url\n$body';
}
