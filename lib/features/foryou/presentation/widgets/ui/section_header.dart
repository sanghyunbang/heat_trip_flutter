import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
      const Spacer(),
      if (trailing != null) trailing!,
    ],
  );
}
