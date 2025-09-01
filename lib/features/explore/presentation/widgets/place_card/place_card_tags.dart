/// lib/features/explore/presentation/widgets/place_card/place_card_tags.dart
///
/// 태그 리스트를 Wrap으로 표현.
/// - 최대 4개 노출(과하면 2줄로 감기며 UI 눌림)

import 'package:flutter/material.dart';

class TagList extends StatelessWidget {
  final List<String> tags;
  final bool compact;
  const TagList({super.key, required this.tags, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: compact ? 4 : 6,
      runSpacing: compact ? 4 : 6,
      children: tags.take(4).map((t) => TagChip(text: t, small: compact)).toList(),
    );
  }
}

class TagChip extends StatelessWidget {
  final String text;
  final bool small;
  const TagChip({super.key, required this.text, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 6 : 8, vertical: small ? 2 : 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(999),
        color: Colors.white,
      ),
      child: Text(text, style: TextStyle(fontSize: small ? 10 : 11, color: Colors.black87)),
    );
  }
}
