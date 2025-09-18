import 'package:flutter/material.dart';
import '../../../domain/entities.dart';
import '../ui/card_shell.dart';
import 'category_tile.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key, required this.items});
  final List<CategoryScore> items;

  @override
  Widget build(BuildContext context) {
    return CardShell(
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
