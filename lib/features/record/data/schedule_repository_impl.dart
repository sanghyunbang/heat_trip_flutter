import 'dart:convert';
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';
import 'package:heat_trip_flutter/features/record/data/dto/schedule_request.dart';
import 'package:heat_trip_flutter/features/record/data/model/schedule_response.dart';
import 'package:http/http.dart' as http;
import 'package:heat_trip_flutter/core/config/env.dart';
import 'package:heat_trip_flutter/core/errors/app_exception.dart';

class ScheduleRepositoryImpl {
  final String baseUrl = Env.apiBase ?? '';

  // ------------------- 스케쥴 생성
  Future<String?> schedulePost(ScheduleRequest request) async {
    final token = await TokenStorage.getToken();
    if (token == null) return '[schedulePost] 인증 정보가 없습니다.';

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
      print('[X] 포스팅 실패: ${response.statusCode} / ${response.body}');
      return '저장 실패 (${response.statusCode})';
    }
  }

  // ------------------- 스케쥴 전체 조회
  Future<List<ScheduleResponse>> fetchSchedules() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw const AppException('로그인이 필요합니다.'); // 👈 깔끔한 메시지만
    }

    final url = Uri.parse('$baseUrl/public/schedules');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => ScheduleResponse.fromJson(item)).toList();
    }
    // 스케줄이 전혀 없을 때 204를 빈 리스트로 간주
    if (response.statusCode == 204) {
      return <ScheduleResponse>[];
    }
    throw AppException('스케줄 가져오기 실패 (${response.statusCode})');
  }

  // ------------------- 스케쥴 삭제
  Future<String?> deleteSchedule(int scheduleId) async {
    final token = await TokenStorage.getToken();
    if (token == null) return '[deleteSchedule] 인증 정보가 없습니다.';

    final url = Uri.parse('$baseUrl/public/schedules/$scheduleId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return null;
    } else {
      print('[X] 삭제 실패: ${response.statusCode} / ${response.body}');
      return '삭제 실패 (${response.statusCode})';
    }
  }

  // ------------------- D-Day 계산
  String getDDayText(DateTime from, DateTime to) {
    final now = DateTime.now();
    if (now.isAfter(to)) {
      return '종료됨';
    } else {
      final daysLeft = from.difference(now).inDays;
      return 'D-${daysLeft + 1}';
    }
  }

  // ------------------- 현재 진행 중인 스케쥴 필터링
  List<ScheduleResponse> getOngoingSchedules(List<ScheduleResponse> all) {
    final now = DateTime.now();
    return all.where((schedule) {
      return now.isAfter(schedule.dateFrom.subtract(const Duration(days: 1))) &&
          now.isBefore(schedule.dateTo.add(const Duration(days: 1)));
    }).toList();
  }

  // ------------------- 조건에 따른 필터링
  List<ScheduleResponse> filterSchedules({
    required List<ScheduleResponse> all,
    String title = '',
    DateTime? date,
    String filterType = '전체', // '전체', '지나간', '앞으로'
  }) {
    final now = DateTime.now();

    return all.where((schedule) {
      final titleMatch = schedule.title.toLowerCase().contains(
        title.toLowerCase(),
      );

      final dateMatch =
          date == null ||
          (date.isAfter(schedule.dateFrom.subtract(const Duration(days: 1))) &&
              date.isBefore(schedule.dateTo.add(const Duration(days: 1))));

      final isPast = schedule.dateTo.isBefore(now);
      final isFuture = schedule.dateFrom.isAfter(now);

      final filterMatch =
          filterType == '전체' ||
          (filterType == '지나간' && isPast) ||
          (filterType == '앞으로' && isFuture);

      return titleMatch && dateMatch && filterMatch;
    }).toList();
  }
}
