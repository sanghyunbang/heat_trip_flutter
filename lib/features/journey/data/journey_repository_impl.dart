// lib/features/journey/data/journey_repository_impl.dart
//
// 목적
// - JourneyRepositoryImpl 을 ApiClient 주입형으로 일원화
// - 서버 통신은 가능한 ApiClient를 경유(공통 baseUrl/토큰 헤더 처리)
// - 멀티파트 업로드 등 ApiClient에 없는 특수 케이스만 TokenStorage+http 직접 사용
//
// 중요
// - 생성자 시그니처: JourneyRepositoryImpl(this._api);  ← 반드시 ApiClient 1개를 받는다
// - RealJourneyApi 등에서 JourneyRepositoryImpl(_api) 로 호출해야 한다
//
// 주의
// - 기존에 동일 클래스명이 다른 경로에 중복되어 있으면 제거하세요(분석기 혼동 원인)
// - 변경 후 IDE에서 "Dart Analysis: Restart" / `flutter clean` 해주면 캐시 혼동을 줄일 수 있음

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import 'package:heat_trip_flutter/shared/network/api_client.dart';
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';
import 'package:heat_trip_flutter/core/config/env.dart';

import '../domain/schedule.dart';
import '../domain/diary_entry.dart';
import '../domain/journeyStats.dart';
import '../domain/journey.dart';

class JourneyRepositoryImpl {
  final ApiClient _api;               // ★ 주입된 공용 클라이언트(베이스URL/토큰 처리)
  JourneyRepositoryImpl(this._api);   // ★ 생성자: 반드시 1개 인자 필요

  String get _baseUrl => Env.apiBase ?? '';

  // ------------------- 통계 조회 (가능하면 ApiClient 경유)
  Future<JourneyStats> fetchStats() async {
    final res = await _api.get('/journeys/stats');
    if (res.statusCode == 200) {
      return JourneyStats.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to fetch stats: ${res.statusCode}');
  }

  // ------------------- 스케줄 전체 조회 (도메인 Schedule 사용)
  // ※ 보통 스케줄은 ScheduleRepositoryImpl에서 처리하지만, 필요하면 유지
  Future<List<Schedule>> fetchSchedules() async {
    final res = await _api.get('/public/schedules');
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((e) => Schedule.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch schedules: ${res.statusCode}');
  }

  // ------------------- 다이어리 전체 조회
  Future<List<DiaryEntry>> fetchDiaries() async {
    final res = await _api.get('/journeys/v2/entries');
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((e) => DiaryEntry.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch diaries: ${res.statusCode}');
  }

  // ------------------- 다이어리 등록
  Future<String?> postDiary(DiaryEntry entry) async {
    final res = await _api.postJson(
      '/journeys/v2/entries',
      entry.toJson(includeId: false),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return null;
    }
    // 디버깅 로그
    // print('Failed to post diary: ${res.statusCode} ${res.body}');
    return '등록 실패 (${res.statusCode})';
  }

  // ------------------- 이미지 업로드(멀티파트)
  // ApiClient에 멀티파트 헬퍼가 없다면 TokenStorage+http로 처리
  Future<List<String>?> uploadImages(List<File> images) async {
    final token = await TokenStorage.getToken();
    if (token == null) return null;

    final url = Uri.parse('$_baseUrl/journeys/entries/images');
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token';

    for (final file in images) {
      final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
      final mediaType = MediaType.parse(mimeType);
      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          file.path,
          contentType: mediaType,
        ),
      );
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return List<String>.from(data);
    }
    // print('Image upload failed: ${res.statusCode} ${res.body}');
    return null;
  }

  // ------------------- 저니(다이어리) 목록 조회 (도메인 Journey 사용)
  Future<List<Journey>> fetchJourneys() async {
    final res = await _api.get('/journeys/v2/entries');
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((e) => Journey.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch journeys: ${res.statusCode}');
  }

  // ------------------- 다이어리 삭제
  Future<void> deleteDiary(int diaryId) async {
    final res = await _api.delete('/journeys/v2/entries/$diaryId');
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to delete diary: ${res.statusCode}');
    }
  }

  // ------------------- 다이어리 수정
  Future<DiaryEntry> updateDiary(DiaryEntry entry) async {
    if (entry.id == null) {
      throw Exception('Diary ID is required for update');
    }
    final res = await _api.putJson(
      '/journeys/v2/entries/${entry.id}',
      entry.toJson(includeId: false),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return DiaryEntry.fromJson(jsonDecode(res.body));
    }
    // print('Failed to update diary: ${res.statusCode} ${res.body}');
    throw Exception('Failed to update diary');
  }
}
