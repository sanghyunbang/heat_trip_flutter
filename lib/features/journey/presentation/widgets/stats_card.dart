import 'package:flutter/material.dart';
import '../../domain/models.dart';

/// 상단 통계 카드 (나의 총 여행 수 · 나의 총 일기 수)
class StatsCard extends StatelessWidget {
  final JourneyStats stats;
  const StatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0.5,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.flight_takeoff,
                  iconColor: Colors.indigo,
                  iconSize: 28,                // ⬅ 아이콘 크게
                  value: '${stats.trips}',
                  label: '나의 총 여행 수',
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.menu_book_rounded,
                  iconColor: Colors.purple,
                  iconSize: 28,                // ⬅ 아이콘 크게
                  value: '${stats.diaryEntries}',
                  label: '나의 총 일기 수',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final double iconSize;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: iconColor),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,                 // ⬅ 숫자 조금 키움
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,                    // ⬅ 라벨도 살짝 키움
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
