// lib/features/journey/presentation/screens/journey_screen.dart
//
// 변경 요약
// - ScheduleRepositoryImpl 이 ApiClient 의존성 주입을 요구 → 화면에서 Provider로 받아 생성 [A][B]
// - JourneyApi(RealJourneyApi)도 ApiClient 주입으로 변경
// - context를 쓰는 의존성 초기화는 initState에서 수행, 그 후 Future 필드 초기화 [C]

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';                                   // [A] Provider로 ApiClient 읽기
import 'package:heat_trip_flutter/shared/network/api_client.dart';          // [A] 주입 대상

import 'package:heat_trip_flutter/features/journey/presentation/screens/diary_edit_screen.dart';
import 'package:heat_trip_flutter/features/record/data/model/schedule_response.dart';
import 'package:heat_trip_flutter/features/record/data/schedule_repository_impl.dart';
import '../../data/journey_api.dart';
import '../../domain/models.dart';
import '../widgets/stats_card.dart';
import '../widgets/schedule_list.dart';
import '../widgets/diary_tab.dart';
import '../screens/new_diary_screen.dart';

/// Journey 메인 화면 (go_router용 const 생성자)
class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen>
    with SingleTickerProviderStateMixin {
  // ── 주입 의존성 ──
  late final JourneyApi _api;                                             // [B] initState에서 생성
  late final ScheduleRepositoryImpl _scheduleRepo;                        // [B] initState에서 생성

  // ── 데이터 Future ──
  late final Future<JourneyStats> _statsF;                                // [C] initState에서 초기화
  late final Future<List<Schedule>> _schedulesF;                          // [C] initState에서 초기화
  late Future<List<DiaryEntry>> _diariesF;                                // [C] initState에서 초기화

  // TabController를 State에 보관해서 리빌드/색상 변경에도 선택 상태 유지
  late final TabController _tab;

  @override
  void initState() {
    super.initState();

    // [B] Provider에서 ApiClient 읽어 주입형 생성
    final apiClient = context.read<ApiClient>();
    _api = RealJourneyApi(apiClient);
    _scheduleRepo = ScheduleRepositoryImpl(apiClient);

    // [C] 의존성 준비 이후 Future들 초기화
    _statsF = _api.fetchStats();
    _schedulesF = _fetchSchedulesFromApi();
    _diariesF = _api.fetchDiaries();

    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<List<Schedule>> _fetchSchedulesFromApi() async {
    try {
      final responses = await _scheduleRepo.fetchSchedules();
      return responses.map(mapToSchedule).toList();
    } catch (e) {
      // ignore: avoid_print
      print('[JourneyScreen] 스케줄 불러오기 실패: $e');
      return [];
    }
  }

  Future<void> _handleEdit(DiaryEntry entry) async {
    final updatedEntry = await Navigator.push<DiaryEntry>(
      context,
      MaterialPageRoute(
        builder: (_) => DiaryEditScreen(entry: entry),
      ),
    );

    if (updatedEntry != null) {
      setState(() {
        _diariesF = _api.fetchDiaries(); // 리스트 다시 로딩
      });
    }
  }

  Future<void> _handleDelete(DiaryEntry entry) async {
    try {
      await _api.deleteDiary(entry.id!); // <- 실제 API 호출
      setState(() {
        _diariesF = _api.fetchDiaries(); // 목록 새로고침
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('다이어리를 삭제했어요.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              onPressed: () async {
                final entry = await showModalBottomSheet<DiaryEntry>(
                  context: context,
                  isScrollControlled: true, // <- 화면 대부분 차지하게
                  useSafeArea: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: const NewDiaryScreen(), // scheduleId 넘기고 싶으면 여기에 전달
                  ),
                );

                if (entry != null && context.mounted) {
                  setState(() {
                    _diariesF = _api.fetchDiaries(); // 작성 후 목록 새로고침
                  });
                }
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Diary'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 25, 28, 33),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
                overlayColor: Colors.white.withOpacity(.06),
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(8),
          child: SizedBox(height: 8),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // 상단 통계
          FutureBuilder<JourneyStats>(
            future: _statsF,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: LinearProgressIndicator(minHeight: 4),
                );
              }
              if (snap.hasError || !snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Failed to load stats'),
                );
              }
              return StatsCard(stats: snap.data!);
            },
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _JourneyTabs(controller: _tab), // 컨트롤러 전달
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tab, // 동일 컨트롤러 사용
              children: [
                // Timeline
                FutureBuilder<List<Schedule>>(
                  future: _schedulesF,
                  builder: _scheduleBuilder(),
                ),
                // Active
                FutureBuilder<List<Schedule>>(
                  future: _schedulesF,
                  builder: (context, snap) => _scheduleBuilder(
                    filter: (s) => s.status == ScheduleStatus.inProgress,
                  )(context, snap),
                ),
                // Planned
                FutureBuilder<List<Schedule>>(
                  future: _schedulesF,
                  builder: (context, snap) => _scheduleBuilder(
                    filter: (s) => s.status == ScheduleStatus.planned,
                  )(context, snap),
                ),
                // Diary
                FutureBuilder<List<DiaryEntry>>(
                  future: _diariesF,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError || !snap.hasData) {
                      return const Center(
                        child: Text('Failed to load diaries.'),
                      );
                    }
                    return DiaryTab(
                      entries: snap.data!,
                      onEdit: _handleEdit,
                      onDelete: _handleDelete,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 스케줄 탭 공통 빌더 (필터링 콜백 주입)
  AsyncWidgetBuilder<List<Schedule>> _scheduleBuilder({
    bool Function(Schedule s)? filter,
  }) {
    return (context, snap) {
      if (snap.connectionState != ConnectionState.done) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snap.hasError || !snap.hasData) {
        return const Center(child: Text('Failed to load schedules.'));
      }
      final items = filter == null
          ? snap.data!
          : snap.data!.where(filter).toList();
      return ScheduleList(items: items);
    };
  }
}

/// 탭 헤더
class _JourneyTabs extends StatelessWidget {
  const _JourneyTabs({super.key, required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    const selectedBg = Color(0xFFEBEBEB); // 선택 배경
    const selectedFg = Color(0xFFEB9C64); // 선택 텍스트

    return TabBar(
      controller: controller,
      isScrollable: false,
      tabAlignment: TabAlignment.fill,
      labelPadding: const EdgeInsets.symmetric(vertical: 8),
      indicatorSize: TabBarIndicatorSize.tab,

      // 눌렀을 때/호버/포커스 overlay 색 커스텀
      overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
        if (states.contains(MaterialState.pressed)) {
          return selectedBg.withOpacity(0.25); // 눌렀을 때도 지정 색
        }
        if (states.contains(MaterialState.hovered) ||
            states.contains(MaterialState.focused)) {
          return selectedBg.withOpacity(0.18);
        }
        return Colors.transparent;
      }),

      // 선택된 탭 배경/글자
      indicator: BoxDecoration(
        color: selectedBg.withOpacity(0.25), // indicator와 overlay 톤을 맞추면 깜빡임 없음
        borderRadius: BorderRadius.circular(12),
      ),
      labelColor: selectedFg,
      unselectedLabelColor: const Color(0xFF9E9E9E),

      tabs: const [
        Tab(text: 'Timeline'),
        Tab(text: 'Active'),
        Tab(text: 'Planned'),
        Tab(text: 'Diary'),
      ],
    );
  }
}

Schedule mapToSchedule(ScheduleResponse res) {
  return Schedule(
    id: res.scheduleId,
    title: res.title,
    content: res.content,
    dateFrom: res.dateFrom,
    dateTo: res.dateTo,
    createdAt: res.createdAt,
    updatedAt: res.updatedAt,
    userId: res.user?.userId ?? 0,
    location: null, // 서버에 location 없으면 null 처리
    tags: [], // 서버에 태그 없으면 빈 리스트
    memoriesCount: 0, // 기본값 0
    heroImageUrl: null, // null 처리
  );
}

/* ─────────────────────────── 각주 ───────────────────────────
[A] 에러 원인:
    ScheduleRepositoryImpl 생성자가 ApiClient 1개(위치 인자)를 요구하게 바뀌었는데
    화면에서 ScheduleRepositoryImpl()로 호출 → “1 positional argument expected …” 발생.

[B] 해결:
    Provider로 올려둔 ApiClient를 context.read<ApiClient>()로 읽어
    _scheduleRepo = ScheduleRepositoryImpl(context.read<ApiClient>()) 형태로 주입.

[C] 주의:
    context를 사용하는 의존성 초기화는 필드 초기화 구역에서 하면 안 됨.
    initState에서 의존성 주입을 마치고, 그 다음에 Future 필드(_statsF, _schedulesF, _diariesF)를 초기화해야
    _fetchSchedulesFromApi()에서 _scheduleRepo를 안전하게 사용할 수 있음.
────────────────────────────────────────────────────────── */
