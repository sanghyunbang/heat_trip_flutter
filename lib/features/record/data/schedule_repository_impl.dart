import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:heat_trip_flutter/features/record/data/dto/schedule_request.dart';
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';
import 'package:http/http.dart' as http;

class ScheduleRepositoryImpl {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<String?> schedulepost(ScheduleRequest request) async {
    final token = await TokenStorage.getToken();
    if (token == null) return '[schedulepost] 인증 정보가 없습니다.';

    final url = Uri.parse('$baseUrl/public/schedules');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return null;
    } else {
      // 실패한 경우 콘솔에 상태 코드 및 응답을 출력
      print('[X] 포스팅 실패: ${response.statusCode} / ${response.body}');
      return '저장 실패 (${response.statusCode})';
    }
  }
}
