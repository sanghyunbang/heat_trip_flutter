// lib/features/journey/presentation/screens/journey_screen.dart
//
// 변경 핵심
// [J1] AppBar 오른쪽 "다이어리 쓰기" 버튼은 항상 표시(모든 탭 공통)
// [J2] DiaryTab에는 entries 스냅샷을 넘기지 않음 → 내부에서 JourneyState.watch()
// [J3] 삭제/수정 콜백만 전달 (낙관적 갱신 + 즉시 반영)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:heat_trip_flutter/features/journey/state/journey_state.dart';
import '../../domain/models.dart';
import '../widgets/schedule_list.dart';
import '../widgets/diary_tab.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});
  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this); // Trips, Diary Archive
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<JourneyState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Trips'),
            Tab(text: 'Diary Archive'),
          ],
        ),
        // ✅ 모든 탭에서 항상 보이는 "다이어리 쓰기" 버튼
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              height: 36,
              child: FilledButton.icon(
                onPressed: () async {
                  await context.push('/journey/diary/new'); // or: context.pushNamed('newDiary')
                  if (context.mounted) {
                    context.read<JourneyState>().refreshDiaries();
                  }
                },
                icon: const Icon(Icons.edit_note, size: 18, color: Colors.white),
                label: const Text(
                  '다이어리 쓰기',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0B0B14), // 검정
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                // ─────────────── Trips ───────────────
                Column(
                  children: [
                    _TripFilterBar(
                      current: state.filter,
                      onChanged: (f) => context.read<JourneyState>().setFilter(f),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: state.loading
                          ? const Center(child: CircularProgressIndicator())
                          : ScheduleList(items: state.schedules),
                    ),
                  ],
                ),
                // ───────────── Diary Archive ──────────
                // Archive 화면에서는 내부 상단 버튼 숨김 (AppBar 버튼만 사용)
                DiaryTab(
                  showNewButton: false, // ← AppBar 버튼만 노출
                  onEdit: (e) => context.read<JourneyState>().updateDiary(e),
                  onDelete: (e) async {
                    try {
                      await context.read<JourneyState>().deleteDiary(e.id!);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('다이어리를 삭제했어요.')),
                        );
                      }
                    } catch (err) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('삭제 실패: $err')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      // ⛔ 떠있는 FAB는 사용하지 않음
      // floatingActionButton: ...
    );
  }
}

class _TripFilterBar extends StatelessWidget {
  const _TripFilterBar({required this.current, required this.onChanged});
  final TripFilter current;
  final ValueChanged<TripFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    Chip _chip(String label, TripFilter v) => Chip(
          label: Text(label),
          backgroundColor:
              current == v ? const Color(0xFFEBEBEB) : const Color(0xFFF6F6F6),
          side: const BorderSide(color: Color(0xFFE6E6E6)),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onChanged(TripFilter.all),
            child: _chip('All', TripFilter.all),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onChanged(TripFilter.active),
            child: _chip('Active', TripFilter.active),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onChanged(TripFilter.planned),
            child: _chip('Planned', TripFilter.planned),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onChanged(TripFilter.completed),
            child: _chip('Completed', TripFilter.completed),
          ),
        ],
      ),
    );
  }
}
