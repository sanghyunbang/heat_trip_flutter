// lib/features/journey/presentation/widgets/diary_tab.dart
//
// 목적
// - Diary Archive 탭 컨테이너(UI): 상단 버튼(opt) + 리스트
// - ⛔ 부모가 넘겨준 리스트 스냅샷을 쓰지 않고, JourneyState를 직접 watch
//   → 삭제/수정/추가가 즉시 반영(낙관적 갱신과 궁합)
//
// 핵심 포인트
// [D1] entries 인자 제거 → 내부에서 context.watch<JourneyState>().diaries 읽기
// [D2] onEdit/onDelete 콜백은 부모에서 주입(동일)
// [D3] 라우팅 시 entryId 파라미터 버그 수정: pathParameters의 entryId는 "다이어리 ID"로 전달
// [D4] showNewButton: Archive에선 숨기고, 필요 화면에서만 노출 가능

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:heat_trip_flutter/features/journey/state/journey_state.dart';
import '../../domain/models.dart';

// ⬇️ 핵심: DiaryList 위젯 임포트 (같은 widgets 폴더)
import 'diary_list.dart';

/// Diary 탭 컨테이너: 상단 버튼 + 리스트
class DiaryTab extends StatelessWidget {
  final void Function(DiaryEntry entry)? onEdit;
  final void Function(DiaryEntry entry)? onDelete;

  /// 상단 "New Diary Entry" 버튼 노출 여부 (Archive에서는 숨기기 위해)
  final bool showNewButton;

  const DiaryTab({
    super.key,
    this.onEdit,
    this.onDelete,
    this.showNewButton = false, // 기본은 숨김(Archive에서 AppBar 버튼 사용)
  });

  @override
  Widget build(BuildContext context) {
    // [D1] 단일 소스: 상태를 직접 구독 → 낙관적 갱신 즉시 반영
    final entries = context.watch<JourneyState>().diaries;

    return Column(
      children: [
        const SizedBox(height: 8),
        if (showNewButton)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _NewDiaryButton(),
          ),
        if (showNewButton) const SizedBox(height: 12),

        // ✅ DiaryList는 widgets/diary_list.dart의 위젯입니다.
        Expanded(
          child: entries.isEmpty
              ? const Center(child: Text('No diaries yet'))
              : DiaryList(
                  entries: entries,
                  onEdit: onEdit,
                  onDelete: onDelete,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  onTap: (entry) {
                    // [D3] 라우트 파라미터 정정:
                    //  - id: scheduleId(없으면 0)
                    //  - entryId: "다이어리 ID"
                    final sid = entry.scheduleId ?? 0;
                    final eid = entry.id ?? 0;
                    context.pushNamed(
                      'diaryDetail',
                      pathParameters: {
                        'id': '$sid',
                        'entryId': '$eid',
                      },
                      extra: entry, // 초기 렌더 최적화
                    );
                  },
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
        onPressed: () => context.pushNamed('newDiary'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Diary Entry'),
      ),
    );
  }
}
