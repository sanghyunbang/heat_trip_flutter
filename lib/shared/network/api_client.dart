// lib/shared/network/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  final Future<String?> Function() tokenProvider;

  ApiClient({required this.baseUrl, required this.tokenProvider});

  Future<http.Response> get(String path) async {
    final token = await tokenProvider();
    return http.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers(token),
    );
  }

  Future<http.Response> postJson(String path, Map<String, dynamic> body) async {
    final token = await tokenProvider();
    return http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String path) async {
    final token = await tokenProvider();
    return http.delete(
      Uri.parse('$baseUrl$path'),
      headers: _headers(token),
    );
  }

  // ✅ 추가: raw PUT (body 직전달)
  Future<http.Response> put(String path, {required String body}) async {
    final token = await tokenProvider();
    return http.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers(token),
      body: body,
    );
  }

  // ✅ 추가: JSON PUT
  Future<http.Response> putJson(String path, Map<String, dynamic> body) async {
    final token = await tokenProvider();
    return http.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
  }

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
}
