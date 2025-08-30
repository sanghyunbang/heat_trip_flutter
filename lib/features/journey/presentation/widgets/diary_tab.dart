import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models.dart';
import 'diary_list.dart';

/// Diary 탭 컨테이너: 상단 버튼 + 리스트
class DiaryTab extends StatelessWidget {
  final List<DiaryEntry> entries;
  const DiaryTab({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _NewDiaryButton(),
        ),
        const SizedBox(height: 12),
        // DiaryList 위젯 호출
        Expanded(
          child: DiaryList(
            entries: entries,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          ),
        ),
      ],
    );
  }
}

/// "+ New Diary Entry" 버튼(검정색, 전체폭)
class _NewDiaryButton extends StatelessWidget {
  const _NewDiaryButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          context.pushNamed('newDiary'); // ✅ scheduleId 없음
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Diary Entry'),
      ),
    );
  }
}
