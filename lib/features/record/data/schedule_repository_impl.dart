import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:heat_trip_flutter/features/record/data/dto/schedule_request.dart';
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';
import 'package:http/http.dart' as http;
import 'package:heat_trip_flutter/features/record/data/model/schedule_response.dart';

class ScheduleRepositoryImpl {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // ----------------글쓰기
  Future<String?> schedulepost(ScheduleRequest request) async {
    print('              [DEBUG] schedulepost 호출됨');
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

    print('📬 응답 Body: ${response.body}');
    print('🍪 응답 헤더 (Set-Cookie): ${response.headers['set-cookie']}');

    if (response.statusCode == 201) {
      return null;
    } else {
      // 실패한 경우 콘솔에 상태 코드 및 응답을 출력
      print('[X] 포스팅 실패: ${response.statusCode} / ${response.body}');
      return '저장 실패 (${response.statusCode})';
    }
  }

  // ----------------리스트 불러오기
  Future<List<ScheduleResponse>> fetchSchedules() async {
    print('          repository 리스트 불러오기 호출됨');
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('토큰이 없습니다.');
    }

    final url = Uri.parse('$baseUrl/public/schedules');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => ScheduleResponse.fromJson(item)).toList();
    } else {
      throw Exception('스케줄 가져오기 실패: ${response.statusCode}');
    }
  }
}
