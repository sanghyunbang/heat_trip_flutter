import 'package:flutter/material.dart';
import '../../domain/models.dart';

/// 상단 통계 카드 (2 × 1 : Trips · Diary Entries)
class StatsCard extends StatelessWidget {
  final JourneyStats stats;
  const StatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0.5,
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          // 카드 내부 여백
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              // 왼쪽 칸 : Trips
              Expanded(
                child: _StatItem(
                  icon: Icons.travel_explore,
                  iconColor: Colors.indigo,
                  value: '${stats.trips}',
                  label: 'Trips',
                ),
              ),
              // 오른쪽 칸 : Diary Entries
              Expanded(
                child: _StatItem(
                  icon: Icons.menu_book_outlined,
                  iconColor: Colors.purple,
                  value: '${stats.diaryEntries}',
                  label: 'Diary Entries',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 통계 항목(아이콘 + 값 + 라벨)
class _StatItem extends StatelessWidget {
  final IconData icon;       // 아이콘
  final Color iconColor;     // 아이콘 색상
  final String value;        // 숫자
  final String label;        // 라벨

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }
}
