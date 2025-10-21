// lib/features/journey/presentation/screens/journey_screen.dart
//
// 변경점
// - AppBar 제목: "Diary" (영문)
// - 필터 바: 외곽 박스 제거, Wrap으로 자동 줄바꿈(가로 넘침 없음)
// - 라벨: 전체 / 진행 중 / 예정 / 완료 (한국어)
// - TabBar 라벨: 여정 / 다이어리 보관함

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:heat_trip_flutter/features/journey/state/journey_state.dart';
import 'package:heat_trip_flutter/features/journey/domain/models.dart';
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
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this); // 여정 / 다이어리 보관함
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
        title: const Text('Diary'), // ← 영문 고정
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: '여정'),
            Tab(text: '다이어리 보관함'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              height: 36,
              child: FilledButton.icon(
                onPressed: () async {
                  await context.push('/journey/diary/new');
                  if (!mounted) return;
                  await context.read<JourneyState>().refreshDiaries();
                },
                icon: const Icon(Icons.edit_note, size: 18, color: Colors.white),
                label: const Text(
                  '다이어리 쓰기',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0B0B14),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          // ───────────── 여정(Trips) 탭 ─────────────
          Column(
            children: [
              const SizedBox(height: 10), // TabBar와 필터 사이 간격
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

          // ─────────── 다이어리 보관함(Diary Archive) 탭 ───────────
          DiaryTab(
            showNewButton: false,
            onEdit: (DiaryEntry entry) async {
              final updated = await Navigator.push<DiaryEntry?>(
                context,
                MaterialPageRoute(builder: (_) => NewDiaryScreen(initial: entry)),
              );
              if (!mounted) return;
              if (updated != null) {
                await context.read<JourneyState>().refreshDiaries();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('다이어리를 수정했어요.')),
                );
              }
            },
            onDelete: (DiaryEntry entry) async {
              try {
                await context.read<JourneyState>().deleteDiary(entry.id!);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('다이어리를 삭제했어요.')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('삭제 실패: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────
// 아주 작고 가벼운 필터 바 (한 줄 유지용)
// - 글자 굵기 보통, 크기 12
// - 아이콘 14
// - 내부 패딩/탭 타깃 최소화 (두 줄로 안 떨어지게)
// - 칩 간 여백 축소
// ───────────────────────────────────────────
class _TripFilterBar extends StatelessWidget {
  const _TripFilterBar({required this.current, required this.onChanged});
  final TripFilter current;
  final ValueChanged<TripFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    Color selectedBg(TripFilter f) {
      switch (f) {
        case TripFilter.active:     return const Color(0xFFEFF5FF);
        case TripFilter.planned:    return const Color(0xFFFFF7EC);
        case TripFilter.completed:  return const Color(0xFFEFF8F1);
        case TripFilter.all:
        default:                    return const Color(0xFFF6F6F8);
      }
    }

    Color selectedFg(TripFilter f) {
      switch (f) {
        case TripFilter.active:     return const Color(0xFF2563EB);
        case TripFilter.planned:    return const Color(0xFFB45309);
        case TripFilter.completed:  return const Color(0xFF15803D);
        case TripFilter.all:
        default:                    return const Color(0xFF4B5563);
      }
    }

    Widget pill({
      required TripFilter value,
      required String label,
      required IconData icon,
    }) {
      final isSelected = current == value;
      final fg = isSelected ? selectedFg(value) : const Color(0xFF6B7280);

      return ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
            // 글씨 작고 굵지 않게
            Text(
              label,
              overflow: TextOverflow.clip,
              softWrap: false,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onChanged(value),
        // 최대한 낮은 높이
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        labelPadding: EdgeInsets.zero,
        shape: const StadiumBorder(),
        backgroundColor: const Color(0xFFF7F7FA),
        selectedColor: selectedBg(value),
        side: BorderSide(
          color: isSelected ? fg.withOpacity(.3) : const Color(0xFFE5E7EB),
          width: 1,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 6,    // 칩 사이 가로 간격 더 줄임
        runSpacing: 6, // 줄바꿈 시 세로 간격
        children: [
          pill(value: TripFilter.all,       label: '전체',   icon: Icons.all_inclusive),
          pill(value: TripFilter.active,    label: '진행 중', icon: Icons.play_circle_outline),
          pill(value: TripFilter.planned,   label: '예정',   icon: Icons.schedule_outlined),
          pill(value: TripFilter.completed, label: '완료',   icon: Icons.check_circle_outline),
        ],
      ),
    );
  }
}
