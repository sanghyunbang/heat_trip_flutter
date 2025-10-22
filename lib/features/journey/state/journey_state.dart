// lib/features/journey/state/journey_state.dart
//
// 목적
// - Journey 화면군의 단일 소스 상태(스케줄/다이어리) 보유
// - 최초 부트스트랩 로드 + 필터링 + CRUD(다이어리) 낙관적 갱신
// - 화면은 이 상태만 watch/read하여 렌더 (API/Repo 직접 new 금지)
//
// 변경 사항
// - refreshAll(): 스케줄과 다이어리를 병렬로 재조회하여 즉시 정합성 확보.
// - [변경] schedules getter: 필터 적용 후 dateFrom 오름차순(동률 시 dateTo, 그다음 id) 정렬 보장.

import 'package:flutter/foundation.dart';
import '../domain/models.dart';
import '../data/journey_api.dart';
import '../data/journey_repository_impl.dart'; // for postDiary
import 'package:heat_trip_flutter/shared/network/api_client.dart';

enum TripFilter { all, active, planned, completed }

class JourneyState extends ChangeNotifier {
  final JourneyApi api;                // 읽기/수정/삭제 등 일반 API
  final JourneyRepositoryImpl repo;    // 다이어리 생성(post) 전용 Repo

  JourneyState({required this.api, required ApiClient apiClient})
      : repo = JourneyRepositoryImpl(apiClient);

  bool loading = false;

  // 원본 보관소(필터/정렬은 getter에서)
  List<Schedule> _schedules = [];
  List<DiaryEntry> _diaries = [];

  TripFilter filter = TripFilter.all;

  // [신규] null-safe DateTime 비교 유틸
  int _cmpDate(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;  // a가 null이면 뒤로
    if (b == null) return -1; // b가 null이면 a가 먼저
    return a.compareTo(b);    // 오름차순
  }

// ───────────────── Schedules ─────────────────
// [변경] 미래/진행중 먼저(가까운 미래 우선) → 과거(가까운 과거 우선) 순으로 정렬
List<Schedule> get schedules {
  // 1) 필터링
  List<Schedule> list;
  switch (filter) {
    case TripFilter.active:
      list = _schedules
          .where((s) => s.status == ScheduleStatus.inProgress)
          .toList();
      break;
    case TripFilter.planned:
      list = _schedules
          .where((s) => s.status == ScheduleStatus.planned)
          .toList();
      break;
    case TripFilter.completed:
      list = _schedules
          .where((s) => s.status == ScheduleStatus.completed)
          .toList();
      break;
    case TripFilter.all:
    default:
      list = List<Schedule>.from(_schedules);
      break;
  }

  // 2) 오늘 00:00 기준으로 과거/미래를 나눕니다.
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  bool isPast(Schedule s) {
    final end = s.dateTo ?? s.dateFrom;      // 종료일 없으면 시작일 사용
    if (end == null) return false;           // 날짜 정보 없으면 과거로 보지 않음
    return end.isBefore(today);              // 어제까지 끝난 건 과거
  }

  bool isFutureOrOngoing(Schedule s) {
    final start = s.dateFrom;
    final end = s.dateTo ?? s.dateFrom ?? today;
    if (start == null) return false;
    // 시작이 오늘 이후이거나, 오늘 기준 아직 종료 전이면 미래/진행중
    return start.isAfter(today) || !end.isBefore(today);
  }

  // 3) 그룹 분리
  final upcoming = <Schedule>[];
  final past = <Schedule>[];

  for (final s in list) {
    if (isFutureOrOngoing(s)) {
      upcoming.add(s);
    } else if (isPast(s)) {
      past.add(s);
    } else {
      // 애매한 경우(날짜 없음 등)는 일단 아래로 보냄
      past.add(s);
    }
  }

  // 4) 그룹 내 정렬
  //    - 미래/진행중: dateFrom 오름차순(가까운 일정이 위)
  //    - 과거: dateFrom 내림차순(가까운 과거가 위)
  int cmpDateAsc(DateTime? a, DateTime? b) => _cmpDate(a, b);
  int cmpDateDesc(DateTime? a, DateTime? b) => _cmpDate(b, a);

  upcoming.sort((a, b) {
    final c1 = cmpDateAsc(a.dateFrom, b.dateFrom);
    if (c1 != 0) return c1;
    final c2 = cmpDateAsc(a.dateTo, b.dateTo);
    if (c2 != 0) return c2;
    return (a.id ?? 0).compareTo(b.id ?? 0);
  });

  past.sort((a, b) {
    final c1 = cmpDateDesc(a.dateFrom, b.dateFrom);
    if (c1 != 0) return c1;
    final c2 = cmpDateDesc(a.dateTo, b.dateTo);
    if (c2 != 0) return c2;
    return (a.id ?? 0).compareTo(b.id ?? 0);
  });

  // 5) 미래/진행중 → 과거 순으로 합치기
  return [...upcoming, ...past];
}

  // ───────────────── Diaries ─────────────────
  List<DiaryEntry> get diaries {
    final copy = List<DiaryEntry>.from(_diaries);
    copy.sort((a, b) => b.date.compareTo(a.date));
    return copy;
  }

  List<DiaryEntry> diariesBySchedule(int scheduleId) {
    final xs = _diaries.where((e) => e.scheduleId == scheduleId).toList();
    xs.sort((a, b) => b.date.compareTo(a.date));
    return xs;
  }

  int photosCountForSchedule(int scheduleId) {
    return _diaries
        .where((e) => e.scheduleId == scheduleId)
        .fold<int>(0, (sum, e) => sum + e.photos.length);
  }

  // ───────────────── Lifecycle ─────────────────
  Future<void> bootstrap() async {
    loading = true;
    notifyListeners();
    try {
      final result = await Future.wait([
        api.fetchSchedules(),
        api.fetchDiaries(),
      ]);
      _schedules = result[0] as List<Schedule>;
      _diaries = result[1] as List<DiaryEntry>;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// ✅ 스케줄과 다이어리를 한 번에 재조회(정합성 즉시 맞춤)
  Future<void> refreshAll() async {
    final result = await Future.wait([
      api.fetchSchedules(),
      api.fetchDiaries(),
    ]);
    _schedules = result[0] as List<Schedule>;
    _diaries = result[1] as List<DiaryEntry>;
    notifyListeners();
  }

  Future<void> refreshSchedules() async {
    _schedules = await api.fetchSchedules();
    notifyListeners();
  }

  Future<void> refreshDiaries() async {
    _diaries = await api.fetchDiaries();
    notifyListeners();
  }

  void setFilter(TripFilter f) {
    filter = f;
    notifyListeners();
  }

  // ───────────────── CRUD: Diary ─────────────────
  Future<String?> createDiary(DiaryEntry draft) async {
    final temp = draft.copyWith(id: DateTime.now().millisecondsSinceEpoch * -1);
    _diaries = [temp, ..._diaries];
    notifyListeners();

    final error = await repo.postDiary(draft);
    if (error != null) {
      _diaries.removeWhere((e) => e.id == temp.id);
      notifyListeners();
      return error;
    }
    await refreshDiaries();
    return null;
  }

  Future<void> deleteDiary(int id) async {
    final backup = List<DiaryEntry>.from(_diaries);
    _diaries.removeWhere((e) => e.id == id);
    notifyListeners();
    try {
      await api.deleteDiary(id);
    } catch (_) {
      _diaries = backup;
      notifyListeners();
      rethrow;
    }
  }

  /// ✅ UI에서 `String? error = await state.updateDiary(entry);` 형태로 사용 가능
  Future<String?> updateDiary(DiaryEntry entry) async {
    try {
      final updated = await api.updateDiary(entry);
      final idx = _diaries.indexWhere((e) => e.id == updated.id);
      if (idx != -1) {
        _diaries[idx] = updated;
      } else {
        _diaries.insert(0, updated);
      }
      notifyListeners();
      return null; // 성공
    } catch (e) {
      return e.toString(); // 실패 메시지
    }
  }

  // ───────────────── CRUD: Schedule ─────────────────
  Future<void> deleteSchedule(
    int scheduleId, {
    Future<void> Function(int id)? performServerDelete,
  }) async {
    final prevSchedules = List<Schedule>.from(_schedules);
    final prevDiaries = List<DiaryEntry>.from(_diaries);

    _schedules.removeWhere((s) => s.id == scheduleId);
    _diaries.removeWhere((d) => d.scheduleId == scheduleId);
    notifyListeners();

    try {
      if (performServerDelete != null) {
        await performServerDelete(scheduleId);
      }
      refreshDiaries();
    } catch (e) {
      _schedules = prevSchedules;
      _diaries = prevDiaries;
      notifyListeners();
      rethrow;
    }
  }
}

/* ───────────── 각주 ─────────────
- refreshAll(): 서버의 최종 상태로 즉시 동기화(스케줄·다이어리 동시 로드)
- [변경] schedules getter에서 dateFrom 오름차순 정렬 보장(동률 시 dateTo, 그다음 id)
──────────────────────── */
