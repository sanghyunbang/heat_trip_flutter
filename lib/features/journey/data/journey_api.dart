import 'dart:async';
import '../domain/models.dart';
import 'package:heat_trip_flutter/features/record/data/model/schedule_response.dart';
import 'package:heat_trip_flutter/features/record/data/schedule_repository_impl.dart';
import 'package:heat_trip_flutter/features/journey/data/journey_repository_impl.dart';

/// API 인터페이스(라이트 버전)
/// - 나중에 HttpJourneyApi로 교체만 하면 화면은 그대로 사용 가능
abstract class JourneyApi {
  Future<JourneyStats> fetchStats(); // 상단 통계 정보
  Future<List<Schedule>> fetchSchedules(); // 전체 스케줄 조회
  Future<Schedule?> fetchScheduleById(int id); // id로 단일 스케줄 조회
  Future<List<DiaryEntry>> fetchDiaries(); // 전체 일기 조회
  Future<List<DiaryEntry>> fetchDiariesBySchedule(int scheduleId); // 스케줄별 일기
  Future<List<Journey>> fetchJourneys();
}

/// 데모용 더미 API → 실제 서버 구현 시 수정 (수정됨)
class RealJourneyApi implements JourneyApi {
  final ScheduleRepositoryImpl _repo = ScheduleRepositoryImpl();
  final JourneyRepositoryImpl _jrepo = JourneyRepositoryImpl();

  @override
  Future<List<Journey>> fetchJourneys() async {
    return await _jrepo.fetchJourneys();
  }

  // 상단 통계 정보
  @override
  Future<JourneyStats> fetchStats() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final diaries = await fetchDiaries();
    final schedules = await fetchSchedules();
    return JourneyStats(trips: schedules.length, diaryEntries: diaries.length);
  }

  // 전체 스케줄 조회
  @override
  Future<List<Schedule>> fetchSchedules() async {
    try {
      final response = await _repo.fetchSchedules(); // 실제 API 호출
      final schedules = response.map((e) => e.toSchedule()).toList();
      return schedules;
    } catch (e, stackTrace) {
      print('❌ fetchSchedules 에러: $e');
      return [];
    }
  }

  // 단일 스케줄 상세정보 조회
  @override
  Future<Schedule?> fetchScheduleById(int id) async {
    final list = await fetchSchedules();
    for (final s in list) {
      if (s.id == id) return s; // int 비교
    }
    return null;
  }

  // 일기 조회
  @override
  Future<List<DiaryEntry>> fetchDiaries() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return [
      // 전역 일기 (스케줄 미연동)
      DiaryEntry(
        scheduleId: null, // ✅ 전역
        authorInitials: 'JD',
        title: 'Magical Morning at Tsukiji',
        date: DateTime(DateTime.now().year, 1, 21),
        location: 'Tsukiji, Tokyo',
        moodLabel: 'Amazed',
        weatherLabel: 'Partly cloudy, 12°C',
        photos: const [
          'https://cdn.pixabay.com/photo/2025/08/15/07/25/ai-generated-9776380_1280.jpg',
          'https://cdn.pixabay.com/photo/2022/12/21/21/59/ai-generated-7671021_1280.jpg',
        ],
        body:
            'Woke up at 5 AM to visit the famous Tsukiji Fish Market. The tuna auction was incredible to witness — the speed and precision of the auctioneers is mesmerizing. Had the most amazing sushi breakfast afterwards. This is what traveling is all about — experiencing authentic local culture.',
      ),

      // 특정 스케줄(예: id=3 Kyoto)에 묶인 일기
      DiaryEntry(
        scheduleId: 3, // ✅ 스케줄 연동
        authorInitials: 'MK',
        title: 'Evening in Gion',
        date: DateTime(DateTime.now().year, 3, 28),
        location: 'Gion, Kyoto',
        moodLabel: 'Calm',
        weatherLabel: 'Clear, 9°C',
        photos: const [],
        body: 'Strolled through Gion at dusk...',
      ),
    ];
  }

  @override
  Future<List<DiaryEntry>> fetchDiariesBySchedule(int scheduleId) async {
    final all = await fetchDiaries();
    return all.where((e) => e.scheduleId == scheduleId).toList(); // ✅ null 제외
  }
}
