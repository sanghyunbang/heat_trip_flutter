// lib/features/journey/presentation/screens/journey_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:heat_trip_flutter/shared/network/api_client.dart';
import 'package:heat_trip_flutter/features/auth/state/auth_state.dart';

import 'package:heat_trip_flutter/features/journey/presentation/screens/diary_edit_screen.dart';
import 'package:heat_trip_flutter/features/record/data/model/schedule_response.dart';
import 'package:heat_trip_flutter/features/record/data/schedule_repository_impl.dart';
import '../../data/journey_api.dart';
import '../../domain/models.dart';
import '../widgets/stats_card.dart';
import '../widgets/schedule_list.dart';
import '../widgets/diary_tab.dart';
import '../screens/new_diary_screen.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen>
    with SingleTickerProviderStateMixin {
  // ── 주입 의존성 (didChangeDependencies에서 생성) ──
  JourneyApi? _api;
  ScheduleRepositoryImpl? _scheduleRepo;

  // ── 데이터 Future (로그인 상태 변화 시 재생성) ──
  Future<JourneyStats>? _statsF;
  Future<List<Schedule>>? _schedulesF;
  Future<List<DiaryEntry>>? _diariesF;

  bool? _lastLoggedIn;
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final loggedIn = context.watch<AuthState>().loggedIn;

    if (_lastLoggedIn != loggedIn || _api == null || _scheduleRepo == null) {
      _lastLoggedIn = loggedIn;

      final apiClient = context.read<ApiClient>();
      _api ??= RealJourneyApi(apiClient);                // 이전 디자인에서 쓰던 RealJourneyApi 유지
      _scheduleRepo ??= ScheduleRepositoryImpl(apiClient);

      setState(() {
        _statsF     = _api!.fetchStats();
        _schedulesF = _fetchSchedulesFromApi();
        _diariesF   = _api!.fetchDiaries();
      });
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<List<Schedule>> _fetchSchedulesFromApi() async {
    try {
      final responses = await _scheduleRepo!.fetchSchedules();
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
      MaterialPageRoute(builder: (_) => DiaryEditScreen(entry: entry)),
    );
    if (updatedEntry != null) {
      setState(() {
        _diariesF = _api!.fetchDiaries();
      });
    }
  }

  Future<void> _handleDelete(DiaryEntry entry) async {
    try {
      await _api!.deleteDiary(entry.id!);
      setState(() {
        _diariesF = _api!.fetchDiaries();
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
    // ✅ 핵심: 항상 같은 Scaffold/디자인을 유지하고, 본문만 상태에 따라 바뀌게
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
                  isScrollControlled: true,
                  useSafeArea: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: const NewDiaryScreen(),
                  ),
                );
                if (entry != null && context.mounted) {
                  setState(() {
                    _diariesF = _api!.fetchDiaries();
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

          // ── 상단 통계 카드 (부트스트랩 이전엔 로딩 스켈레톤) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _statsF == null
                ? const LinearProgressIndicator(minHeight: 4)
                : FutureBuilder<JourneyStats>(
                    future: _statsF,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const LinearProgressIndicator(minHeight: 4);
                      }
                      if (snap.hasError || !snap.hasData) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Failed to load stats'),
                        );
                      }
                      return StatsCard(stats: snap.data!);
                    },
                  ),
          ),

          const SizedBox(height: 12),

          // ── 탭 헤더 (디자인 유지) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _JourneyTabs(controller: _tab),
          ),

          const SizedBox(height: 8),

          // ── 탭 컨텐츠 (부트스트랩 동안에도 구조 유지) ──
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                // Timeline
                _schedulesF == null
                    ? const _LoadingPane()
                    : FutureBuilder<List<Schedule>>(
                        future: _schedulesF,
                        builder: _scheduleBuilder(),
                      ),

                // Active
                _schedulesF == null
                    ? const _LoadingPane()
                    : FutureBuilder<List<Schedule>>(
                        future: _schedulesF,
                        builder: (context, snap) => _scheduleBuilder(
                          filter: (s) => s.status == ScheduleStatus.inProgress,
                        )(context, snap),
                      ),

                // Planned
                _schedulesF == null
                    ? const _LoadingPane()
                    : FutureBuilder<List<Schedule>>(
                        future: _schedulesF,
                        builder: (context, snap) => _scheduleBuilder(
                          filter: (s) => s.status == ScheduleStatus.planned,
                        )(context, snap),
                      ),

                // Diary
                _diariesF == null
                    ? const _LoadingPane()
                    : FutureBuilder<List<DiaryEntry>>(
                        future: _diariesF,
                        builder: (context, snap) {
                          if (snap.connectionState != ConnectionState.done) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snap.hasError || !snap.hasData) {
                            return const Center(child: Text('Failed to load diaries.'));
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

  // 공통 스케줄 빌더
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
      final items = filter == null ? snap.data! : snap.data!.where(filter).toList();
      return ScheduleList(items: items);
    };
  }
}

// 탭 헤더 (디자인 유지)
class _JourneyTabs extends StatelessWidget {
  const _JourneyTabs({super.key, required this.controller});
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    const selectedBg = Color(0xFFEBEBEB);
    const selectedFg = Color(0xFFEB9C64);

    return TabBar(
      controller: controller,
      isScrollable: false,
      tabAlignment: TabAlignment.fill,
      labelPadding: const EdgeInsets.symmetric(vertical: 8),
      indicatorSize: TabBarIndicatorSize.tab,
      overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
        if (states.contains(MaterialState.pressed)) {
          return selectedBg.withOpacity(0.25);
        }
        if (states.contains(MaterialState.hovered) || states.contains(MaterialState.focused)) {
          return selectedBg.withOpacity(0.18);
        }
        return Colors.transparent;
      }),
      indicator: BoxDecoration(
        color: selectedBg.withOpacity(0.25),
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

// 로딩 시에도 레이아웃을 유지하기 위한 플레이스홀더
class _LoadingPane extends StatelessWidget {
  const _LoadingPane();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
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
    location: null,
    tags: const [],
    memoriesCount: 0,
    heroImageUrl: null,
  );
}
