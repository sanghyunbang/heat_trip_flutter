import 'package:flutter/material.dart';

class CardShell extends StatelessWidget {
  const CardShell({super.key, this.color, required this.child});
  final Color? color;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: child,
  );
}
