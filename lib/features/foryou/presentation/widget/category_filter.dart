import 'package:flutter/material.dart';

/// 상단 카테고리 칩(전체/자연/도시/해안/문화/카페/힐링)
class CategoryFilter extends StatelessWidget {
  final String selected; // 'all' | 'nature' | ...
  final ValueChanged<String> onChanged;
  const CategoryFilter({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const cats = [
      ('all', '전체', Icons.all_inclusive),
      ('nature', '자연', Icons.terrain),
      ('city', '도시', Icons.location_city),
      ('coastal', '해안', Icons.waves),
      ('cultural', '문화', Icons.camera_alt_outlined),
      ('cafe', '카페', Icons.local_cafe_outlined),
      ('healing', '힐링', Icons.favorite_outline),
    ];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (id, label, icon) = cats[i];
          return ChoiceChip(
            avatar: Icon(icon, size: 16),
            label: Text(label),
            selected: selected == id,
            onSelected: (_) => onChanged(id),
          );
        },
      ),
    );
  }
}
