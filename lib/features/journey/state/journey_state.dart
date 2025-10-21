// lib/features/journey/state/journey_state.dart
//
// 목적
// - Journey 화면군의 단일 소스 상태(스케줄/다이어리) 보유
// - 최초 부트스트랩 로드 + 필터링 + CRUD(다이어리) 낙관적 갱신
// - 화면은 이 상태만 watch/read하여 렌더 (API/Repo 직접 new 금지)
//
// 핵심 포인트
// [S1] Constructor에서 ApiClient를 받아 JourneyRepositoryImpl 주입 (postDiary용)
// [S2] bootstrap(): 스케줄/다이어리 병렬 로드
// [S3] createDiary(): 임시ID로 낙관적 추가 → 서버 실패 시 롤백 → 성공 시 재동기화
// [S4] diariesBySchedule(): 스케줄별 정렬된 다이어리 리스트
// [S5] photosCountForSchedule(): 특정 스케줄의 사진 총합(= entries.photos 총합)
//     → 화면에서 schedule.memoriesCount 대신 이 합계를 쓰면 작성 직후에도 반영됨
// [S6] deleteSchedule(): 스케줄 낙관적 삭제 + 해당 스케줄의 일기들도 즉시 제거 → 그 후 서버/재동기화

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
      : repo = JourneyRepositoryImpl(apiClient); // [S1]

  bool loading = false;

  // 원본 보관소(필터/정렬은 getter에서)
  List<Schedule> _schedules = [];
  List<DiaryEntry> _diaries = [];

  TripFilter filter = TripFilter.all;

  // ───────────────── Schedules ─────────────────
  List<Schedule> get schedules {
    switch (filter) {
      case TripFilter.active:
        return _schedules
            .where((s) => s.status == ScheduleStatus.inProgress)
            .toList();
      case TripFilter.planned:
        return _schedules
            .where((s) => s.status == ScheduleStatus.planned)
            .toList();
      case TripFilter.completed:
        return _schedules
            .where((s) => s.status == ScheduleStatus.completed)
            .toList();
      case TripFilter.all:
      default:
        return _schedules;
    }
  }

  // ───────────────── Diaries ─────────────────
  /// 최신순으로 정렬된 사본을 반환 (원본(_diaries)은 보존)
  List<DiaryEntry> get diaries {
    final copy = List<DiaryEntry>.from(_diaries);
    copy.sort((a, b) => b.date.compareTo(a.date));
    return copy;
  }

  /// 특정 스케줄의 일기(최신순)
  List<DiaryEntry> diariesBySchedule(int scheduleId) {
    final xs = _diaries.where((e) => e.scheduleId == scheduleId).toList();
    xs.sort((a, b) => b.date.compareTo(a.date));
    return xs;
  }

  /// [보조] 특정 스케줄의 사진 총합 (UI의 Photos 카운트용)
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
      // [S2] 초기 데이터 병렬 로드
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
  /// 다이어리 생성: 낙관적 갱신 후 서버 저장, 실패 시 롤백
  Future<String?> createDiary(DiaryEntry draft) async {
    // [S3] 1) 임시 ID(음수)로 즉시 추가 → UI 즉시 반영
    final temp = draft.copyWith(id: DateTime.now().millisecondsSinceEpoch * -1);
    _diaries = [temp, ..._diaries];
    notifyListeners();

    // 2) 서버 저장
    final error = await repo.postDiary(draft);
    if (error != null) {
      // 3) 실패 → 롤백
      _diaries.removeWhere((e) => e.id == temp.id);
      notifyListeners();
      return error;
    }
    // 4) 성공 → 서버의 실제 ID 반영을 위해 재동기화
    await refreshDiaries();
    return null;
  }

  Future<void> deleteDiary(int id) async {
    final backup = List<DiaryEntry>.from(_diaries);
    _diaries.removeWhere((e) => e.id == id); // 낙관적 제거
    notifyListeners();
    try {
      await api.deleteDiary(id);
    } catch (_) {
      _diaries = backup; // 실패 → 복구
      notifyListeners();
      rethrow;
    }
  }

  Future<DiaryEntry?> updateDiary(DiaryEntry entry) async {
    final updated = await api.updateDiary(entry);
    final idx = _diaries.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      _diaries[idx] = updated;
      notifyListeners();
    }
    return updated;
  }

  // ───────────────── CRUD: Schedule ─────────────────
  /// [S6] 스케줄 삭제: 스케줄 + 해당 스케줄의 다이어리들을 낙관적으로 즉시 제거
  ///  - performServerDelete: 실제 서버 삭제 함수를 주입(UI/Repo 레이어에서 호출)
  ///  - 서버 호출 실패 시 롤백
  Future<void> deleteSchedule(
    int scheduleId, {
    Future<void> Function(int id)? performServerDelete,
  }) async {
    final prevSchedules = List<Schedule>.from(_schedules);
    final prevDiaries = List<DiaryEntry>.from(_diaries);

    // 1) 낙관적 제거(즉시 UI 반영)
    _schedules.removeWhere((s) => s.id == scheduleId);
    _diaries.removeWhere((d) => d.scheduleId == scheduleId);
    notifyListeners();

    try {
      // 2) 실제 서버 삭제 실행(주입)
      if (performServerDelete != null) {
        await performServerDelete(scheduleId);
      }
      // 3) 서버/정합성 재확인
      refreshDiaries(); // await 없이 호출 → 화면은 이미 최신 상태
    } catch (e) {
      // 4) 실패 롤백
      _schedules = prevSchedules;
      _diaries = prevDiaries;
      notifyListeners();
      rethrow;
    }
  }
}

/* ───────────── 각주 ─────────────
[S1] DI: 화면은 Api/Repo를 직접 new 하지 않고, 상위(main.dart)에서 ApiClient를 주입해 조립합니다.
[S2] bootstrap(): 앱 시작 시 스케줄/다이어리 병렬 로드로 초기 렌더 빠르게.
[S3] 낙관적 생성: temp ID로 즉시 리스트에 추가 → 실패 시 롤백 → 성공 시 재조회로 정합성 확보.
[S4] diariesBySchedule(): 스케줄 상세/목록에서 공통 사용. 정렬도 여기서 책임.
[S5] photosCountForSchedule(): 서버 필드(memoriesCount) 대신 현재 상태 기반 합계 산출.
[S6] deleteSchedule(): 스케줄 삭제 시 Diary 탭에 남아있는 문제를 클라이언트에서 먼저 해결.
──────────────────────── */
