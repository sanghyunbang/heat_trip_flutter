import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models.dart';
import '../widgets/memories_count_text.dart'; // 상태 기반 카운트
import '../widgets/image_placeholders.dart'; // ✅ 통일된 플레이스홀더 유틸

/// 스케줄 목록 + 카드
class ScheduleList extends StatelessWidget {
  final List<Schedule> items;
  const ScheduleList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No schedules to show.'));
    }
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

    // ✅ 통일: 히어로 이미지도 유틸 사용
    final hero = photoOrPlaceholder(
      schedule.heroImageUrl,
      seed: schedule.id ?? schedule.title,
    );

    // ✅ 위치가 비어있으면 줄 자체를 숨김
    final hasLocation =
        (schedule.location != null && schedule.location!.trim().isNotEmpty);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        context.pushNamed(
          'journeyDetail',
          pathParameters: {'id': schedule.id.toString()},
          extra: schedule,
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0.8,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Hero (Image.network + errorBuilder/로딩 통일) ───
            SizedBox(
              height: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: const Color(0xFFF3F3F3)),
                  Image.network(
                    hero,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return const _HeroSkeleton();
                    },
                    errorBuilder: (_, __, ___) => const _HeroError(),
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

            // ─── 본문 ───
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // 📍 위치 (조건부)
                  if (hasLocation)
                    Row(
                      children: [
                        const Icon(Icons.place, size: 16),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            schedule.location!,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                  if (hasLocation) const SizedBox(height: 8),

                  // 📅 기간
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 16),
                      const SizedBox(width: 6),
                      Text(schedule.dateLabel),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 🖼️ Memories: 상태 기반 카운트(즉시 반영)
                  Row(
                    children: [
                      const Icon(Icons.photo_library_outlined, size: 16),
                      const SizedBox(width: 6),
                      MemoriesCountText(scheduleId: schedule.id!),
                    ],
                  ),

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
            backgroundColor: const Color(0xFFF1F1F1),
            side: BorderSide(color: outline),
          ),
        if (extra > 0)
          InputChip(
            label: Text('+$extra more'),
            onPressed: () {},
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: const Color(0xFFF1F1F1),
            side: BorderSide(color: outline),
          ),
      ],
    );
  }
}

/// 히어로 로딩 스켈레톤
class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F3F3),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

/// 히어로 에러 시 대체
class _HeroError extends StatelessWidget {
  const _HeroError();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F3F3),
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        size: 28,
        color: Color(0xFF9E9E9E),
      ),
    );
  }
}
