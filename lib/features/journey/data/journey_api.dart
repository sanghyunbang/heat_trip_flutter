// lib/features/journey/data/journey_api.dart
//
// 변경 요약
// - RealJourneyApi가 ApiClient를 생성자 주입으로 받도록 수정
// - 내부에서 ScheduleRepositoryImpl, JourneyRepositoryImpl 에 같은 ApiClient 주입
// - ScheduleResponse -> Schedule 매핑 헬퍼 추가
//
// 주의
// - RealJourneyApi() 를 호출하던 곳은 이제 RealJourneyApi(context.read<ApiClient>()) 로 변경
//   (StatefulWidget에서는 initState에서 late 초기화 권장)

import 'dart:async';

import 'package:heat_trip_flutter/shared/network/api_client.dart';
import 'package:heat_trip_flutter/features/record/data/model/schedule_response.dart';
import 'package:heat_trip_flutter/features/record/data/schedule_repository_impl.dart';
import 'package:heat_trip_flutter/features/journey/data/journey_repository_impl.dart';

import '../domain/models.dart';

/// API 인터페이스(라이트 버전)
/// - 나중에 HttpJourneyApi로 교체만 하면 화면은 그대로 사용 가능
abstract class JourneyApi {
  Future<JourneyStats> fetchStats(); // 상단 통계 정보
  Future<List<Schedule>> fetchSchedules(); // 전체 스케줄 조회
  Future<Schedule?> fetchScheduleById(int id); // id로 단일 스케줄 조회
  Future<List<DiaryEntry>> fetchDiaries(); // 전체 일기 조회
  Future<List<DiaryEntry>> fetchDiariesBySchedule(int scheduleId); // 스케줄별 일기
  Future<List<Journey>> fetchJourneys(); // 저니(다이어리) 목록
  Future<void> deleteDiary(int id); // 다이어리 삭제
  Future<DiaryEntry> updateDiary(DiaryEntry entry); // 다이어리 수정
}

/// 실제 API(현재는 레포를 통해 서버와 통신)
class RealJourneyApi implements JourneyApi {
  /// 주입 받은 공용 ApiClient (Authorization/베이스URL 처리 담당)
  final ApiClient _api;

  /// 레포들도 같은 ApiClient를 주입 받아 사용
  late final ScheduleRepositoryImpl _scheduleRepo = ScheduleRepositoryImpl(_api);
  late final JourneyRepositoryImpl _journeyRepo = JourneyRepositoryImpl(_api);

  /// 생성자: 반드시 ApiClient를 주입해야 함.
  RealJourneyApi(this._api);

  // ──────────────────────────────────────────────────────────────────────────
  // Journeys
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Future<List<Journey>> fetchJourneys() => _journeyRepo.fetchJourneys();

  // ──────────────────────────────────────────────────────────────────────────
  // Stats
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Future<JourneyStats> fetchStats() async {
    // 간단 합성: 서버 통계를 별도 API로 쏘지 않고 현 데이터로 계산
    final diaries = await fetchDiaries();
    final schedules = await fetchSchedules();
    return JourneyStats(trips: schedules.length, diaryEntries: diaries.length);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Schedules
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Future<List<Schedule>> fetchSchedules() async {
    try {
      final response = await _scheduleRepo.fetchSchedules(); // 서버 호출 → ScheduleResponse[]
      return response.map(_mapToSchedule).toList();          // UI 도메인으로 변환
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Schedule?> fetchScheduleById(int id) async {
    final list = await fetchSchedules();
    // firstWhere의 orElse는 null을 반환할 수 없으므로 try/catch로 안전 처리
    try {
      return list.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Diaries
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Future<List<DiaryEntry>> fetchDiaries() async {
    try {
      return await _journeyRepo.fetchDiaries();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<DiaryEntry>> fetchDiariesBySchedule(int scheduleId) async {
    final all = await fetchDiaries();
    return all.where((e) => e.scheduleId == scheduleId).toList();
  }

  @override
  Future<void> deleteDiary(int id) => _journeyRepo.deleteDiary(id);

  @override
  Future<DiaryEntry> updateDiary(DiaryEntry entry) =>
      _journeyRepo.updateDiary(entry);
}

// ──────────────────────────────────────────────────────────────────────────
// Mapping helper
// ──────────────────────────────────────────────────────────────────────────

/// ScheduleResponse → 화면 도메인 Schedule 매핑 헬퍼
Schedule _mapToSchedule(ScheduleResponse res) {
  return Schedule(
    id: res.scheduleId,
    title: res.title,
    content: res.content,
    dateFrom: res.dateFrom,
    dateTo: res.dateTo,
    createdAt: res.createdAt,
    updatedAt: res.updatedAt,
    userId: res.user?.userId ?? 0,
    location: null,      // 서버에 location 없으면 null 처리
    tags: const [],      // 서버에 태그 없으면 빈 리스트
    memoriesCount: 0,    // 기본값 0
    heroImageUrl: null,  // null 처리
  );
}
