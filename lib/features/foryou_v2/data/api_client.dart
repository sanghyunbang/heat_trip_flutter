import 'dart:convert';
import 'package:http/http.dart' as http;

/// 간단 HTTP 클라이언트 (JSON POST만)
class ApiClient {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  const ApiClient({
    required this.baseUrl,
    this.defaultHeaders = const {'Content-Type': 'application/json'},
  });

  Future<Map<String, dynamic>> postJson(
    String path, {
    Object? body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final merged = {...defaultHeaders, if (headers != null) ...headers};
    final jsonBody = body is String ? body : jsonEncode(body);
    final res = await http
        .post(uri, headers: merged, body: jsonBody)
        .timeout(timeout);
    if (res.statusCode ~/ 100 != 2) {
      throw Exception('HTTP ${res.statusCode} ${res.body}');
    }
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }
}
