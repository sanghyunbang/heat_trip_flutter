/// lib/features/explore/presentation/widgets/place_card/badges.dart
///
/// 상단바에서 사용하는 작은 뱃지들.

import 'package:flutter/material.dart';

class BadgeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool small;
  final bool muted;

  const BadgeChip({
    super.key,
    required this.icon,
    required this.label,
    this.small = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final double padH = small ? 7 : 8;
    final double padV = small ? 3 : 4;
    final double iconSize = small ? 12 : 14;
    final double fontSize = small ? 10 : 11;
    final Color fg = Colors.black.withOpacity(muted ? 0.58 : 0.87);
    final Color bg = Colors.white.withOpacity(muted ? 0.70 : 0.92);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        boxShadow: muted ? const [] : const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: fg),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: fg, height: 1.05)),
        ],
      ),
    );
  }
}

class BadgePill extends StatelessWidget {
  final String text;
  const BadgePill({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
