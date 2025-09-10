import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  const ApiClient({
    required this.baseUrl,
    this.defaultHeaders = const {'Content-Type': 'application/json'},
  });

  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final merged = {...defaultHeaders, if (headers != null) ...headers};
    final jsonBody = body is String ? body : jsonEncode(body);
    final res = await http
        .post(uri, headers: merged, body: jsonBody)
        .timeout(timeout);
    return res;
  }

  dynamic decodeBodyBytes(http.Response res) =>
      jsonDecode(utf8.decode(res.bodyBytes));
}
