/// hours_card.dart
/// - 요일 정렬(월→일) 후, 좌우 정렬로 깔끔하게 표기
import 'package:flutter/material.dart';

class HoursCard extends StatelessWidget {
  final Map<String, String> hours; // 예: {'월':'09:00-18:00', ...}
  const HoursCard({super.key, required this.hours});

  @override
  Widget build(BuildContext context) {
    if (hours.isEmpty) return const SizedBox.shrink();

    // 인간 친화 정렬: '월,화,수,목,금,토,일' 순
    const order = ['월', '화', '수', '목', '금', '토', '일'];
    final entries = hours.entries.toList()
      ..sort((a, b) => order.indexOf(a.key).compareTo(order.indexOf(b.key)));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('운영시간', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${e.key}요일',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    Text(e.value),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
