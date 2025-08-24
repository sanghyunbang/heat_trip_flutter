import 'package:flutter/material.dart';
import '../../data/journey_api.dart';
import '../../domain/models.dart';
import '../widgets/stats_card.dart';
import '../widgets/schedule_list.dart';
import '../widgets/diary_tab.dart';

/// Journey 메인 화면 (go_router용 const 생성자)
class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  // 간단 주입: 데모에서는 더미 API. (TODO: 실서버 시 교체)
  final JourneyApi _api = MockJourneyApi();

  late final Future<JourneyStats> _statsF = _api.fetchStats();
  late final Future<List<Schedule>> _schedulesF = _api.fetchSchedules();
  late final Future<List<DiaryEntry>> _diariesF = _api.fetchDiaries();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Journey'),
          actions: [
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add Trip'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _JourneyTabs(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                children: [
                  // Timeline
                  FutureBuilder<List<Schedule>>(
                    future: _schedulesF,
                    builder: _scheduleBuilder(),
                  ),
                  // Active
                  FutureBuilder<List<Schedule>>(
                    future: _schedulesF,
                    builder: (context, snap) =>
                        _scheduleBuilder(filter: (s) => s.status == ScheduleStatus.inProgress)(context, snap),
                  ),
                  // Planned
                  FutureBuilder<List<Schedule>>(
                    future: _schedulesF,
                    builder: (context, snap) =>
                        _scheduleBuilder(filter: (s) => s.status == ScheduleStatus.planned)(context, snap),
                  ),
                  // Diary
                  FutureBuilder<List<DiaryEntry>>(
                    future: _diariesF,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError || !snap.hasData) {
                        return const Center(child: Text('Failed to load diaries.'));
                      }
                      return DiaryTab(entries: snap.data!);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
      final items = filter == null ? snap.data! : snap.data!.where(filter).toList();
      return ScheduleList(items: items);
    };
  }
}

/// 탭 헤더
class _JourneyTabs extends StatelessWidget {
  const _JourneyTabs();

  @override
  Widget build(BuildContext context) {
    return TabBar(
      isScrollable: false,
      tabAlignment: TabAlignment.fill,
      labelPadding: const EdgeInsets.symmetric(vertical: 8),
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      labelColor: Theme.of(context).colorScheme.primary,
      unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
      tabs: const [
        Tab(text: 'Timeline'),
        Tab(text: 'Active'),
        Tab(text: 'Planned'),
        Tab(text: 'Diary'),
      ],
    );
  }
}
