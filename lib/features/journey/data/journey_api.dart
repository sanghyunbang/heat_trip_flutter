import 'dart:async';
import '../domain/models.dart';

/// API 인터페이스(라이트 버전)
/// - 나중에 HttpJourneyApi로 교체만 하면 화면은 그대로 사용 가능
abstract class JourneyApi {
  Future<JourneyStats> fetchStats(); // 상단 통계 정보
  Future<List<Schedule>> fetchSchedules(); // 전체 스케줄 조회
  Future<Schedule?> fetchScheduleById(int id); // id로 단일 스케줄 조회
  Future<List<DiaryEntry>> fetchDiaries(); // 전체 일기 조회
  Future<List<DiaryEntry>> fetchDiariesBySchedule(int scheduleId); // 스케줄별 일기
}

/// 데모용 더미 API → 실제 서버 구현 시 수정
class MockJourneyApi implements JourneyApi {
  // 상단 통계 정보
  @override
  Future<JourneyStats> fetchStats() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final diaries = await fetchDiaries();
    final schedules = await fetchSchedules();
    return JourneyStats(
      trips: schedules.length,
      diaryEntries: diaries.length,
    );
  }

  // 전체 스케줄 조회
  @override
  Future<List<Schedule>> fetchSchedules() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final now = DateTime.now();

    // 날짜 배치를 조정해 planned/inProgress/completed 모두 보이도록 함
    final plannedStart = now.add(const Duration(days: 200));
    final plannedEnd = plannedStart.add(const Duration(days: 7));

    final inProgressStart = now.subtract(const Duration(days: 2));
    final inProgressEnd = now.add(const Duration(days: 5));

    final completedStart = now.subtract(const Duration(days: 140));
    final completedEnd = completedStart.add(const Duration(days: 7));

    final completed2Start = now.subtract(const Duration(days: 300));
    final completed2End = completed2Start.add(const Duration(days: 5));

    return [
      Schedule(
        id: 1,
        title: 'Iceland',
        content: 'Aurora hunt & Blue Lagoon',
        dateFrom: plannedStart,
        dateTo: plannedEnd,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
        userId: 1,
        location: 'Iceland',
        tags: const ['Northern Lights', 'Blue Lagoon', 'Golden Circle'],
        memoriesCount: 0,
        heroImageUrl:
        'https://images.unsplash.com/photo-1519681393784-d120267933ba?q=80&w=1600&auto=format&fit=crop',
      ),
      Schedule(
        id: 2,
        title: 'San Diego',
        content: 'Beach & Downtown',
        dateFrom: inProgressStart,
        dateTo: inProgressEnd,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now,
        userId: 1,
        location: 'USA',
        tags: const ['Beach', 'Gaslamp Quarter'],
        memoriesCount: 12,
        heroImageUrl:
        'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?q=80&w=1600&auto=format&fit=crop',
      ),
      Schedule(
        id: 3,
        title: 'Kyoto',
        content: 'Cherry blossoms and temples',
        dateFrom: completedStart,
        dateTo: completedEnd,
        createdAt: now.subtract(const Duration(days: 150)),
        updatedAt: completedEnd,
        userId: 1,
        location: 'Japan',
        tags: const ['Fushimi Inari', 'Gion', 'Arashiyama'],
        memoriesCount: 8,
        heroImageUrl:
        'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?q=80&w=1600&auto=format&fit=crop',
      ),
      Schedule(
        id: 4,
        title: 'Paris',
        content: 'Museums and Seine',
        dateFrom: completed2Start,
        dateTo: completed2End,
        createdAt: now.subtract(const Duration(days: 320)),
        updatedAt: completed2End,
        userId: 1,
        location: 'France',
        tags: const ['Louvre', 'Seine'],
        memoriesCount: 5,
        heroImageUrl:
        'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?q=80&w=1600&auto=format&fit=crop',
      ),
    ];
  }

  // 단일 스케줄 상세정보 조회
  @override
  Future<Schedule?> fetchScheduleById(int id) async {
    final list = await fetchSchedules();
    for (final s in list) {
      if (s.id == id) return s;   // int 비교
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
        scheduleId: null,                          // ✅ 전역
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
        body: 'Woke up at 5 AM to visit the famous Tsukiji Fish Market. The tuna auction was incredible to witness — the speed and precision of the auctioneers is mesmerizing. Had the most amazing sushi breakfast afterwards. This is what traveling is all about — experiencing authentic local culture.',
      ),

      // 특정 스케줄(예: id=3 Kyoto)에 묶인 일기
      DiaryEntry(
        scheduleId: 3,                              // ✅ 스케줄 연동
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
