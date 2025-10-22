// lib/features/journey/presentation/screens/journey_detail_screen.dart
//
// 목적
// - 스케줄 상세 + 해당 스케줄의 다이어리 리스트 화면
// - 화면에서 API/Repo 직접 생성 제거 → JourneyState만 의존
//
// 핵심 변경점
// [J1] 상태에서 스케줄/다이어리를 읽고 구독(watch) → 실시간 반영
// [J2] Photos 카운트 = 상태 기반 합계(context.watch 후 fold)로 계산
// [J3] 편집/삭제는 JourneyState 메서드로 일원화
// [J4] initial 스케줄이 없을 경우 1회 보충 fetch
// [FIX] DiaryEditScreen 제거 → NewDiaryScreen(initial: entry)로 수정

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/models.dart';
import '../../state/journey_state.dart';
import 'diary_detail_screen.dart';
// import 'diary_edit_screen.dart'; // ❌ 제거
import '../screens/new_diary_screen.dart'; // ✅ 수정: 공용 신규/수정 화면 사용
import '../widgets/diary_list.dart';

import 'package:flutter/foundation.dart';
import 'package:heat_trip_flutter/features/journey/presentation/widgets/image_placeholders.dart';

class JourneyDetailScreen extends StatefulWidget {
  const JourneyDetailScreen({super.key, required this.id, this.initial});

  final int id;
  final Schedule? initial;

  @override
  State<JourneyDetailScreen> createState() => _JourneyDetailScreenState();
}

class _JourneyDetailScreenState extends State<JourneyDetailScreen> {
  Schedule? _schedule; // 상세 헤더용
  bool _fetchingSchedule = false;

  @override
  void initState() {
    super.initState();
    _schedule = widget.initial;
    _ensureScheduleLoaded();
  }

  /// 상태에 없으면 1회만 API로 스케줄 보충 로드
  Future<void> _ensureScheduleLoaded() async {
    final state = context.read<JourneyState>();

    // [SAFE] 상태에서 먼저 찾아보기 (firstOrNull 사용하지 않음)
    if (_schedule == null) {
      for (final s in state.schedules) {
        if (s.id == widget.id) {
          _schedule = s;
          break;
        }
      }
    }

    // 그래도 없으면 API 조회
    if (_schedule == null) {
      setState(() => _fetchingSchedule = true);
      try {
        final fresh = await state.api.fetchScheduleById(widget.id);
        if (mounted) setState(() => _schedule = fresh);
      } finally {
        if (mounted) setState(() => _fetchingSchedule = false);
      }
    }
  }

  // ✅ 수정은 NewDiaryScreen을 '수정 모드'로 사용
  Future<void> _handleEdit(DiaryEntry entry) async {
    final updated = await Navigator.push<DiaryEntry?>(
      context,
      MaterialPageRoute(builder: (_) => NewDiaryScreen(initial: entry)),
    );
    if (updated != null) {
      await context.read<JourneyState>().updateDiary(updated); // [J3]
    }
  }

  Future<void> _handleDelete(DiaryEntry entry) async {
    try {
      await context.read<JourneyState>().deleteDiary(entry.id!); // [J3]
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('다이어리를 삭제했어요.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
  }

  Future<void> _refresh() async {
    await context.read<JourneyState>().refreshDiaries();
    await context.read<JourneyState>().refreshSchedules();
  }

  @override
  Widget build(BuildContext context) {
    final schedule = _schedule;
    if (schedule == null) {
      // 아직 로딩 중이거나 찾지 못한 경우
      return Scaffold(
        appBar: AppBar(leading: const BackButton(), title: const Text('Journey')),
        body: Center(
          child: _fetchingSchedule
              ? const CircularProgressIndicator()
              : const Text('Schedule not found.'),
        ),
      );
    }

    // 이 스케줄에 귀속된 다이어리 목록 (상태 구독)
    final entries = context.watch<JourneyState>().diariesBySchedule(widget.id);

    // [J2] Photos 카운트: 현재 상태의 다이어리들에서 사진 합계 계산
    final photosCount = entries.fold<int>(0, (sum, e) => sum + e.photos.length);

    final journeyCount = entries.length;
    final int? tripDays = (schedule.dateFrom != null && schedule.dateTo != null)
        ? schedule.dateTo!.difference(schedule.dateFrom!).inDays + 1
        : null;

    final hero = photoOrPlaceholder(
      schedule.heroImageUrl,
      seed: schedule.id ?? schedule.title,
    );

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              schedule.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              'Journey details & memories',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ───────── Hero ─────────
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 8.4,
                  child: Image.network(
                    hero,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFF3F3F3),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        size: 28,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ───────── Info Card ─────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      // const SizedBox(height: 8),
                      // Row(
                      //   children: [
                      //     const Icon(Icons.place_outlined, size: 18),
                      //     const SizedBox(width: 6),
                      //     Text(
                      //       schedule.location ?? '—',
                      //       style: TextStyle(
                      //         color: Theme.of(context)
                      //             .colorScheme
                      //             .onSurfaceVariant,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            _formatRange(schedule.dateFrom, schedule.dateTo),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      // const SizedBox(height: 16),
                      // const Text(
                      //   'Tags',
                      //   style: TextStyle(
                      //     fontWeight: FontWeight.w700,
                      //     fontSize: 16,
                      //   ),
                      // ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 4,
                        runSpacing: 8,
                        children: [
                          for (final t in schedule.tags.take(3)) _TagPill(text: t),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _StatMini(
                              icon: Icons.photo_camera_outlined,
                              iconColor: const Color(0xFF4E7CFF),
                              value: '$photosCount',      // [J2]
                              label: 'Photos',
                            ),
                          ),
                          Expanded(
                            child: _StatMini(
                              icon: Icons.menu_book_outlined,
                              iconColor: const Color(0xFF8B5CF6),
                              value: '$journeyCount',
                              label: 'Diary Entries',
                            ),
                          ),
                          Expanded(
                            child: _StatMini(
                              icon: Icons.place_outlined,
                              iconColor: const Color(0xFF2ECC71),
                              value: tripDays?.toString() ?? '—',
                              label: 'Days',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ───────── New Diary Button ─────────
              SizedBox(
                height: 48,
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    context.pushNamed(
                      'newDiaryForSchedule',
                      pathParameters: {'id': widget.id.toString()},
                    ).then((_) {
                      // 돌아오면 새로고침 (서버/상태 재동기화 보장)
                      context.read<JourneyState>().refreshDiaries();
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('다이어리 쓰기'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF191C21),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    overlayColor: Colors.white24,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ───────── Diary Entries ─────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Diary Entries',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F2F5),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${entries.length} entries',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (entries.isEmpty)
                    _EmptyDiaryCard(title: schedule.title)
                  else
                    DiaryList(
                      entries: entries,
                      embedded: true,
                      padding: EdgeInsets.zero,
                      onTap: (entry) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DiaryDetailScreen(entry: entry),
                          ),
                        );
                      },
                      onEdit: _handleEdit,   // ✅ 수정 경로 고정
                      onDelete: _handleDelete,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRange(DateTime? from, DateTime? to) {
    String f(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    if (from == null && to == null) return 'Dates TBA';
    if (from != null && to == null) return f(from);
    if (from == null && to != null) return f(to);
    return '${f(from!)} ~ ${f(to!)}';
  }
}

// ───────── 작은 위젯들 ─────────
class _TagPill extends StatelessWidget {
  const _TagPill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4B5563),
        ),
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  const _StatMini({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: subtle)),
      ],
    );
  }
}

class _EmptyDiaryCard extends StatelessWidget {
  const _EmptyDiaryCard({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        children: [
          Icon(Icons.draw_outlined, size: 46, color: subtle),
          const SizedBox(height: 14),
          const Text(
            '아직 일기가 없어요',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '당신의 $title 추억을 기록해 보세요!',
            style: TextStyle(fontSize: 13, color: subtle),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            '"다이어리 쓰기" 버튼을 눌러 첫 번째 추억을 남겨보세요.',
            style: TextStyle(fontSize: 12, color: subtle),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/* ───────────── 각주 ─────────────
[FIX] DiaryEditScreen → NewDiaryScreen(initial: entry)로 교체하여
     undefined_method 에러 및 편집 경로 불일치 문제 해결.
[J1] 화면은 JourneyState만 의존: API/Repo new 제거 → 테스트/DI 단순화.
[J2] Photos 카운트는 entries.photos 합계 산출로 변경 → 작성/삭제 즉시 반영.
[J3] 편집/삭제는 JourneyState 메서드로 일원화(낙관적/롤백 전략과 일관성 유지).
[J4] initial이 없을 때 1회 fetch 보충. 라우팅 시 extra 미전달 케이스 커버.
──────────────────────── */
