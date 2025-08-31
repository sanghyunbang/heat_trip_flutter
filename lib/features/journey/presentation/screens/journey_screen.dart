import 'package:flutter/material.dart';
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
  // 간단 주입: 데모에서는 더미 API. (TODO: 실서버 시 교체)
  final JourneyApi _api = MockJourneyApi();

  late final Future<JourneyStats> _statsF = _api.fetchStats();
  late final Future<List<Schedule>> _schedulesF = _api.fetchSchedules();
  late Future<List<DiaryEntry>> _diariesF = _api.fetchDiaries();

  // TabController를 State에 보관해서 리빌드/색상 변경에도 선택 상태 유지
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
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
                    child: NewDiaryScreen(), // scheduleId 넘기고 싶으면 여기에 전달
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
                backgroundColor: const Color.fromARGB(
                  255,
                  25,
                  28,
                  33,
                ), // ↓ 블랙보다 부드러운 다크그레이
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
                overlayColor: Colors.white.withOpacity(.06), // 눌림 효과도 은은하게
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
                    return DiaryTab(entries: snap.data!);
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
    const selectedBg = Color(0xFFEBE2CD); // 선택 배경
    const selectedFg = Color(0xFF353535); // 선택 텍스트

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
      // (선택) 리플 없애고 싶다면 주석 해제
      // splashFactory: NoSplash.splashFactory,

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
