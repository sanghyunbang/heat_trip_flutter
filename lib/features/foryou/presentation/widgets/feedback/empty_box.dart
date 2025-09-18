// features/foryou/presentation/widgets/feedback/empty_box.dart
import 'package:flutter/material.dart';

class EmptyBox extends StatelessWidget {
  const EmptyBox({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black54, fontSize: 13),
      ),
    );
  }
}
