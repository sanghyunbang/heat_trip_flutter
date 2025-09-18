import 'package:flutter/material.dart';

class BadgePill extends StatelessWidget {
  const BadgePill({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.06),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(text, style: const TextStyle(fontSize: 11)),
  );
}
