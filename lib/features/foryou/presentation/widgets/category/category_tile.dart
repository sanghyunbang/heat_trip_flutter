import 'package:flutter/material.dart';
import '../../../domain/entities.dart';

class CategoryTile extends StatelessWidget {
  const CategoryTile(this.c, {super.key});
  final CategoryScore c;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2 - 6;
    return InkWell(
      onTap: () {
        /* TODO: 상세 */
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6FA),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(
              c.emoji.isNotEmpty ? c.emoji : '🧭',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                c.categoryName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              '${(c.score * 100).round()}%',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
