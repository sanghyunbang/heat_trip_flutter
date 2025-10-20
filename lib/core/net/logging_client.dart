// lib/core/net/logging_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoggingClient extends http.BaseClient {
  final http.Client _inner;
  LoggingClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final startedAt = DateTime.now();
    print('┌─ HTTP ${request.method} ${request.url}');
    request.headers.forEach((k, v) => print('│ H: $k: $v'));

    final response = await _inner.send(request);
    final elapsed = DateTime.now().difference(startedAt);
    print('│ ← status: ${response.statusCode} (${elapsed.inMilliseconds} ms)');

    final bytes = await http.Response.fromStream(response);
    final body = bytes.body;
    final snippet = body.length > 800 ? '${body.substring(0, 800)}…' : body;
    print('│ B: ${snippet.replaceAll('\n', ' ')}');
    print('└─');

    // 다시 StreamedResponse로 감싸 반환
    return http.StreamedResponse(
      Stream.value(utf8.encode(body)),
      bytes.statusCode,
      request: request,
      headers: bytes.headers,
      reasonPhrase: bytes.reasonPhrase,
    );
  }
}
