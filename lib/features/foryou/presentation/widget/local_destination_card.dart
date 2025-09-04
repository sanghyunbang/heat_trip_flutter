import 'package:flutter/material.dart';
import '../../domain/entities/local_destination.dart';

/// 리스트 아이템 카드(작은 썸네일 + 정보 + 난이도 배지)
class LocalDestinationCard extends StatelessWidget {
  final LocalDestination d;
  const LocalDestinationCard({super.key, required this.d});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                d.imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 14),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          d.location,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 16,
                          ),
                          Text(
                            d.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      _diffBadge(d.difficulty),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
          ],
        ),
      ),
    );
  }

  Widget _diffBadge(String diff) {
    final (bg, fg, label) = switch (diff) {
      'easy' => (Colors.green, Colors.white, '쉬움'),
      'medium' => (Colors.orange, Colors.white, '보통'),
      'hard' => (Colors.red, Colors.white, '어려움'),
      _ => (Colors.grey, Colors.white, '보통'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg.withOpacity(.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: fg, fontSize: 11)),
    );
  }
}
