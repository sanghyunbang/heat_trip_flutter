// features/foryou/presentation/widgets/feedback/error_box.dart
import 'package:flutter/material.dart';

class ErrorBox extends StatelessWidget {
  const ErrorBox({super.key, required this.text, required this.onRetry});
  final String text;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final color = Colors.red.shade700;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: color, height: 1.2)),
          ),
          TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}
