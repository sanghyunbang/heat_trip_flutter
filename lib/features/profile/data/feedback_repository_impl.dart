import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';
import 'package:heat_trip_flutter/features/profile/domain/repository/feedback_repository.dart';
import 'package:heat_trip_flutter/features/profile/data/dto/feedback_request.dart';
import 'package:http/http.dart' as http;
import 'package:heat_trip_flutter/core/config/env.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final String baseUrl = Env.apiBase ?? '';

  @override
  Future<bool> sendFeedback({
    required String content,
    String? category,
    String? appVersion,
    String? deviceInfo,
  }) async {
    final uri = Uri.parse('$baseUrl/feedback');
    final token = await TokenStorage.getToken(); // 로그인 연동(선택)
    final req = FeedbackRequest(
      content: content,
      category: category,
      appVersion: appVersion,
      deviceInfo: deviceInfo,
    );

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      if (kDebugMode) {
        print('[POST /feedback] body: ${jsonEncode(req.toJson())}');
      }
      final res = await http.post(uri, headers: headers, body: jsonEncode(req.toJson()));

      if (res.statusCode == 200) return true;

      if (kDebugMode) {
        print('[X] sendFeedback 실패: ${res.statusCode} / ${res.body}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('[X] sendFeedback 예외: $e');
      }
      return false;
    }
  }
}
