// lib/features/record/data/schedule_repository_impl.dart

import 'dart:convert';
import 'package:heat_trip_flutter/core/errors/app_exception.dart';
import 'package:heat_trip_flutter/features/record/data/dto/schedule_request.dart';
import 'package:heat_trip_flutter/features/record/data/model/schedule_response.dart';
import 'package:heat_trip_flutter/shared/network/api_client.dart';

class ScheduleRepositoryImpl {
  final ApiClient _api;
  ScheduleRepositoryImpl(this._api); // [F] 주입형

  Future<String?> schedulePost(ScheduleRequest request) async {
    final res = await _api.postJson('/public/schedules', request.toJson());
    if (res.statusCode == 201 || res.statusCode == 200) return null;
    return '저장 실패 (${res.statusCode})';
  }

  Future<List<ScheduleResponse>> fetchSchedules() async {
    final res = await _api.get('/public/schedules');
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((e) => ScheduleResponse.fromJson(e)).toList();
    }
    if (res.statusCode == 204) return <ScheduleResponse>[];
    throw const AuthRequiredException();
  }

  Future<String?> deleteSchedule(int scheduleId) async {
    final res = await _api.delete('/public/schedules/$scheduleId');
    if (res.statusCode == 200 || res.statusCode == 204) return null;
    return '삭제 실패 (${res.statusCode})';
  }

  // ----- 이하 유틸/필터는 동일 -----
  String getDDayText(DateTime from, DateTime to) {
    final now = DateTime.now();
    if (now.isAfter(to)) return '종료됨';
    return 'D-${from.difference(now).inDays + 1}';
  }

  List<ScheduleResponse> getOngoingSchedules(List<ScheduleResponse> all) {
    final now = DateTime.now();
    return all.where((s) {
      return now.isAfter(s.dateFrom.subtract(const Duration(days: 1))) &&
          now.isBefore(s.dateTo.add(const Duration(days: 1)));
    }).toList();
  }

  List<ScheduleResponse> filterSchedules({
    required List<ScheduleResponse> all,
    String title = '',
    DateTime? date,
    String filterType = '전체',
  }) {
    final now = DateTime.now();
    return all.where((s) {
      final titleMatch = s.title.toLowerCase().contains(title.toLowerCase());
      final dateMatch = date == null ||
          (date.isAfter(s.dateFrom.subtract(const Duration(days: 1))) &&
              date.isBefore(s.dateTo.add(const Duration(days: 1))));
      final isPast = s.dateTo.isBefore(now);
      final isFuture = s.dateFrom.isAfter(now);
      final filterMatch = filterType == '전체' ||
          (filterType == '지나간' && isPast) ||
          (filterType == '앞으로' && isFuture);
      return titleMatch && dateMatch && filterMatch;
    }).toList();
  }
}
