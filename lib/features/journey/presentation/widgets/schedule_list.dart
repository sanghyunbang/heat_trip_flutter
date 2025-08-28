import 'package:flutter/material.dart';
import '../../domain/models.dart';

/// 스케줄 목록 + 카드
class ScheduleList extends StatelessWidget {
  final List<Schedule> items;
  const ScheduleList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Center(child: Text('No schedules to show.'));
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) => ScheduleCard(schedule: items[i]),
    );
  }
}

/// 단일 스케줄 카드
class ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  const ScheduleCard({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    final statusLabel = switch (schedule.status) {
      ScheduleStatus.planned => 'Planned',
      ScheduleStatus.inProgress => 'In Progress',
      ScheduleStatus.completed => 'Completed',
    };
    final dotColor = switch (schedule.status) {
      ScheduleStatus.planned => Colors.orange,
      ScheduleStatus.inProgress => Colors.green,
      ScheduleStatus.completed => Colors.blueGrey,
    };

    final hero = schedule.heroImageUrl ??
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1600&auto=format&fit=crop';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {}, // TODO: 상세 이동
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0.8,
        color: Colors.white, // ✅ 카드 배경: 흰색
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 헤더
            SizedBox(
              height: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Ink.image(
                    image: NetworkImage(hero),
                    fit: BoxFit.cover,
                    child: const SizedBox.shrink(),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusLabel,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.black.withOpacity(0.5),
                      child: const Icon(Icons.chevron_right, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            // 본문
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(schedule.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.place, size: 16),
                    const SizedBox(width: 6),
                    Text(schedule.location ?? '—'),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.calendar_month, size: 16),
                    const SizedBox(width: 6),
                    Text(schedule.dateLabel),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.photo_library_outlined, size: 16),
                    const SizedBox(width: 6),
                    Text('${schedule.memoriesCount} memories captured'),
                  ]),
                  const SizedBox(height: 10),
                  _ScheduleTags(tags: schedule.tags),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 태그 칩(2개만 노출, 나머지는 +N more)
class _ScheduleTags extends StatelessWidget {
  final List<String> tags;
  const _ScheduleTags({required this.tags});

  @override
  Widget build(BuildContext context) {
    final visible = tags.take(2).toList();
    final extra = tags.length - visible.length;
    final outline = Theme.of(context).colorScheme.outlineVariant;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final t in visible)
          Chip(
            label: Text(t),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: const Color(0xFFF1F1F1), // ✅ 칩 배경: 연한 회색
            side: BorderSide(color: outline),
          ),
        if (extra > 0)
          InputChip(
            label: Text('+$extra more'),
            onPressed: () {}, // TODO: 바텀시트 등으로 전체 표시
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: const Color(0xFFF1F1F1), // ✅ 칩 배경: 연한 회색
            side: BorderSide(color: outline),
          ),
      ],
    );
  }
}
