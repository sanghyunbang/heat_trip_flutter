import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heat_trip_flutter/features/journey/presentation/widgets/diary_list.dart';

import '../../domain/models.dart';
import '../../data/journey_api.dart';

class JourneyDetailScreen extends StatefulWidget {
  const JourneyDetailScreen({
    super.key,
    required this.id,
    this.initial,
  });

  final int id;                 // ✅ URL에서 파싱된 int
  final Schedule? initial;      // 선택: 초기 렌더 최적화용

  @override
  State<JourneyDetailScreen> createState() => _JourneyDetailScreenState();
}

class _JourneyDetailScreenState extends State<JourneyDetailScreen> {
  final JourneyApi _api = MockJourneyApi();
  Schedule? _data;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _data = widget.initial;   // 초기 즉시 렌더
    _fetch();                 // 최신 데이터로 갱신
  }

  Future<void> _fetch() async {
    setState(() => _loading = _data == null);
    try {
      final fresh = await _api.fetchScheduleById(widget.id);
      if (!mounted) return;
      setState(() => _data = fresh ?? _data);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedule = _data;
    if (schedule == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 간단 통계
    final hero = schedule.heroImageUrl ??
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1600&auto=format&fit=crop';
    final photosCount = schedule.memoriesCount;
    // Days 계산 (null 처리 포함)
    final int? tripDays = (schedule.dateFrom != null && schedule.dateTo != null)
        ? schedule.dateTo!.difference(schedule.dateFrom!).inDays + 1
        : null;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(schedule.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text('Journey details & memories',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetch,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === 상단 히어로 이미지 + 상태 배지 ===
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 8.4,
                      child: Image.network(
                        hero,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image_outlined,
                              size: 28, color: Colors.black26),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // === 정보 카드 (위치/기간/태그/미니 통계) ===
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
                      Text(schedule.title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            schedule.location ?? '—',
                            style: TextStyle(
                              color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
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
                      const SizedBox(height: 16),

                      const Text('Tags',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
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

                      // 미니 통계 (Photos / Diary Entries / Days)
                      Row(
                        children: [
                          Expanded(
                            child: _StatMini(
                              icon: Icons.photo_camera_outlined,
                              iconColor: const Color(0xFF4E7CFF),
                              value: '$photosCount',
                              label: 'Photos',
                            ),
                          ),
                          // Diary Entries 수는 실제 조회해서 반영
                          Expanded(
                            child: FutureBuilder<List<DiaryEntry>>(
                              future:
                              _api.fetchDiariesBySchedule(widget.id),
                              builder: (context, snap) {
                                final subtle = Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant;
                                if (snap.connectionState !=
                                    ConnectionState.done) {
                                  return Column(
                                    children: [
                                      const SizedBox(height: 2),
                                      const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                      const SizedBox(height: 6),
                                      Text('Diary Entries',
                                          style: TextStyle(
                                              fontSize: 12, color: subtle)),
                                    ],
                                  );
                                }
                                final count =
                                (snap.hasData ? snap.data!.length : 0);
                                return _StatMini(
                                  icon: Icons.menu_book_outlined,
                                  iconColor: const Color(0xFF8B5CF6),
                                  value: '$count',
                                  label: 'Diary Entries',
                                );
                              },
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

              // === 새 일기 버튼 ===
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // 새 일기 작성화면으로 이동 (스케줄 id가 있는 상태)
                    context.pushNamed(
                      'newDiaryForSchedule',
                      pathParameters: {'id': widget.id.toString()},
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('New Diary Entry',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B0B14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),

              // === Diary Entries 섹션 ===
              const SizedBox(height: 22),
              FutureBuilder<List<DiaryEntry>>(
                future: _api.fetchDiariesBySchedule(widget.id),
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }
                  if (snap.hasError || !snap.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Failed to load diaries.'),
                    );
                  }
                  final entries = snap.data!;
                  final diaryCount = entries.length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text('Diary Entries',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F2F5),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text('$diaryCount entries',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (diaryCount == 0)
                        _EmptyDiaryCard(title: schedule.title)
                      else
                        // DiaryList(entries: entries),
                        DiaryList(
                          entries: entries,
                          embedded: true,                   // 부모 스크롤 사용
                          padding: EdgeInsets.zero,
                        ),
                    ],
                  );
                },
              ),

              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(minHeight: 3),
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

    final f0 = from!;
    final t0 = to!;
    return '${f(f0)} ~ ${f(t0)}';
  }
}

/// 태그 (화이트 + 옅은 테두리 필)
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

/// 미니 통계 블록 (아이콘 + 수치 + 라벨)
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
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black)),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: subtle)),
      ],
    );
  }
}

/// 일기 빈 상태 카드
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
          const Text('No diary entries yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Start documenting your $title memories!',
              style: TextStyle(fontSize: 13, color: subtle),
              textAlign: TextAlign.center),
          const SizedBox(height: 14),
          Text('Tap the "New Diary Entry" button above to get started',
              style: TextStyle(fontSize: 12, color: subtle),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
