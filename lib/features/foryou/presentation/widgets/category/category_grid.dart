import 'package:flutter/material.dart';
import '../../../domain/entities.dart';
import '../ui/card_shell.dart' show OutlinedCardShell; // ⬅️ 명시적 import
import 'category_tile.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key, required this.items});
  final List<CategoryScore> items;

  @override
  Widget build(BuildContext context) {
    return OutlinedCardShell(
      // 필요 시 withShadow: true 로 아주 얕은 입체감 추가 가능
      // withShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items.map((c) => CategoryTile(c)).toList(),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () {}, child: const Text('전체 보기')),
        ],
      ),
    );
  }
}
