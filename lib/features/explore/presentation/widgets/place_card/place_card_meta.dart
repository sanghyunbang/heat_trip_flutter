/// lib/features/explore/presentation/widgets/place_card/place_card_meta.dart
///
/// 주소(광역+기초), 거리, 소요시간을 한 줄에 표현.
/// - compact에 따라 아이콘/폰트 크기 조정.

import 'package:flutter/material.dart';

class MetaRow extends StatelessWidget {
  final String? addr1;
  final String? distance;
  final String? duration;
  final bool compact;

  const MetaRow({
    super.key,
    required this.addr1,
    this.distance,
    this.duration,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final double iconSize = compact ? 12 : 14;
    final double fontSize = compact ? 11 : 12;

    String _shortAddr(String? addr) {
      if (addr == null) return '';
      final t = addr.trim();
      if (t.isEmpty) return '';
      final parts = t.split(RegExp(r'\s+'));
      return parts.length >= 2 ? '${parts[0]} ${parts[1]}' : t;
    }

    final pieces = <Widget>[
      Icon(Icons.map_outlined, size: iconSize, color: Colors.black54),
      const SizedBox(width: 4),
      Flexible(
        child: Text(
          _shortAddr(addr1),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.black54, fontSize: fontSize),
        ),
      ),
    ];

    // • 구분점과 함께 거리/시간을 뒤에 덧붙임
    void addDot() {
      pieces.addAll(const [
        SizedBox(width: 6),
        Text('•', style: TextStyle(color: Colors.black26)),
        SizedBox(width: 6),
      ]);
    }

    if ((distance ?? '').trim().isNotEmpty) {
      addDot();
      pieces.add(Text(distance!.trim(), style: TextStyle(color: Colors.black54, fontSize: fontSize)));
    }

    if ((duration ?? '').trim().isNotEmpty) {
      addDot();
      pieces.add(Row(
        children: [
          Icon(Icons.schedule, size: iconSize, color: Colors.black54),
          const SizedBox(width: 2),
          Text(duration!.trim(), style: TextStyle(color: Colors.black54, fontSize: fontSize)),
        ],
      ));
    }

    return Row(children: pieces);
  }
}

/// 오른쪽 끝의 별점 뱃지(숫자만 간단 표기)
class RatingBadge extends StatelessWidget {
  final double rating;
  const RatingBadge({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    final iconSize = 16.0;
    return Row(
      children: [
        Icon(Icons.star, size: iconSize, color: const Color(0xFFFFC107)),
        const SizedBox(width: 4),
        Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
