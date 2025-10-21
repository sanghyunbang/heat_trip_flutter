// Diary Archive 탭
// - 상태(JourneyState)에서 diaries를 watch
// - 공용 카드 위젯 DiaryList 재사용(상태 기반 최신순)
// - [★POINT] 보관함에서는 외곽선만 살짝 진하게, 그림자 제거

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:heat_trip_flutter/features/journey/state/journey_state.dart';
import 'package:heat_trip_flutter/features/journey/domain/models.dart';
import '../screens/diary_detail_screen.dart';
import 'diary_list.dart';

class DiaryTab extends StatelessWidget {
  const DiaryTab({
    super.key,
    this.showNewButton = true,
    required this.onEdit,
    required this.onDelete,
  });

  final bool showNewButton;
  final ValueChanged<DiaryEntry> onEdit;
  final ValueChanged<DiaryEntry> onDelete;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<JourneyState>();
    final entries = state.diaries; // JourneyState가 최신순 사본으로 반환

    if (state.loading && entries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (entries.isEmpty) {
      return _EmptyArchive(showNewButton: showNewButton);
    }

    // ✅ 핵심: DiaryList를 그대로 쓰되 카드 테두리/그림자만 보관함 룩으로 오버라이드
    return DiaryList(
      entries: entries,
      embedded: false,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      // ───── 카드 스타일 오버라이드(보관함 전용) ─────
      cardBorderColor: const Color(0xFFDADADA), // 기존 #E8E8E8 보다 약간 진하게
      cardBorderWidth: 1.2,
      cardShadow: const [],                      // 그림자 제거
      // cardRadius: 16,                          // 라운드는 기본 유지

      onTap: (entry) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DiaryDetailScreen(entry: entry)),
        );
      },
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}

class _EmptyArchive extends StatelessWidget {
  const _EmptyArchive({required this.showNewButton});
  final bool showNewButton;

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.draw_outlined, size: 46, color: subtle),
            const SizedBox(height: 12),
            const Text('No diaries yet', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Start documenting your journeys', style: TextStyle(color: subtle)),
          ],
        ),
      ),
    );
  }
}
