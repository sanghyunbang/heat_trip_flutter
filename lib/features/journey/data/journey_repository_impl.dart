import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../domain/schedule.dart';
import '../domain/diary_entry.dart';
import '../domain/journeyStats.dart';
import '../domain/journey.dart';

import '../../auth/service/token_storage.dart';
import 'package:heat_trip_flutter/core/config/env.dart';

class JourneyRepositoryImpl {
  final String baseUrl = Env.apiBase ?? '';

  // ------------------- 통계 조회
  Future<JourneyStats> fetchStats() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('No auth token');

    final url = Uri.parse('$baseUrl/journeys/stats');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return JourneyStats.fromJson(data);
    } else {
      throw Exception('Failed to fetch stats: ${response.statusCode}');
    }
  }

  // ------------------- 스케줄 전체 조회
  Future<List<Schedule>> fetchSchedules() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('No auth token');

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
      return data.map((e) => Schedule.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch schedules: ${response.statusCode}');
    }
  }

  // ------------------- 다이어리 전체 조회
  Future<List<DiaryEntry>> fetchDiaries() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('No auth token');

    final url = Uri.parse('$baseUrl/journeys/v2/entries');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('  ㅡㅡㅡㅡㅡㅡㅡjourney impl - 📦[fetchDiaries] body: ${response.body[0]}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => DiaryEntry.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch diaries: ${response.statusCode}');
    }
  }

  // ------------------- 스케줄 추가 (이미지 포함)
  Future<String?> postTrip({
    required String title,
    required String content,
    required DateTime dateFrom,
    required DateTime dateTo,
    required List<File> images,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) return 'Authentication required';

    final url = Uri.parse('$baseUrl/journeys/schedules');
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token';

    request.fields.addAll({
      'title': title,
      'content': content,
      'dateFrom': dateFrom.toIso8601String(),
      'dateTo': dateTo.toIso8601String(),
    });

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

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return null;
    } else {
      print(
        '[JourneyRepositoryImpl] postTrip failed: ${response.statusCode} / ${response.body}',
      );
      return '등록 실패 (${response.statusCode})';
    }
  }

  Future<String?> postDiary(DiaryEntry entry) async {
    final token = await TokenStorage.getToken();
    if (token == null) return 'Authentication required';

    final url = Uri.parse('$baseUrl/journeys/v2/entries');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(entry.toJson(includeId: false)),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return null;
    } else {
      print('Failed to post diary: ${response.statusCode} ${response.body}');
      return '등록 실패 (${response.statusCode})';
    }
  }

  Future<List<String>?> uploadImages(List<File> images) async {
    final token = await TokenStorage.getToken();
    if (token == null) return null;

    final url = Uri.parse('$baseUrl/media');
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['category'] = 'journeys';
    request.fields['refType'] = 'journey';

    for (final file in images) {
      final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
      final mediaType = MediaType.parse(mimeType);

      request.files.add(
        await http.MultipartFile.fromPath(
          'files',
          file.path,
          contentType: mediaType,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((item) => item['url'].toString())
          .toList(); // 🔁 서버 응답 형식에 맞게
    } else {
      print(
        '[uploadImages] ❌ Upload failed: ${response.statusCode} / ${response.body}',
      );
      return null;
    }
  }

  Future<List<Journey>> fetchJourneys() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('No auth token');

    final url = Uri.parse('$baseUrl/journeys/v2/entries');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Journey.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch journeys: ${response.statusCode}');
    }
  }

  Future<void> deleteDiary(int diaryId) async {
    print("   journey impl - deleteDiary 진입, 들어온 diaryId : $diaryId");
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Authentication required');

    final url = Uri.parse('$baseUrl/journeys/v2/entries/$diaryId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete diary: ${response.statusCode}');
    }
  }

  Future<DiaryEntry> updateDiary(DiaryEntry entry) async {
    print(
      "   ㅡㅡㅡㅡㅡㅡㅡjourney impl - updateDiary 진입, 진입한 값 : ${entry} \n entry id = ${entry.id}",
    );
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Authentication required');
    if (entry.id == null) throw Exception('Diary ID is required for update');

    final Did = entry.id;
    final url = Uri.parse('$baseUrl/journeys/v2/entries/$Did');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(entry.toJson(includeId: false)),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return DiaryEntry.fromJson(data);
    } else {
      print('Failed to update diary: ${response.statusCode} ${response.body}');
      throw Exception('Failed to update diary');
    }
  }
}
