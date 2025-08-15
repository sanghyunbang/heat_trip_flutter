import 'package:flutter/material.dart';

/// WHAT: 저장/불러오기/오류 메시지를 잠깐 보여주는 알림 박스
class MessageBox extends StatelessWidget {
  final String title;
  final String text;
  final bool isError;
  const MessageBox({
    super.key,
    required this.title,
    required this.text,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isError ? Colors.red.shade50 : Colors.green.shade50;
    final border = isError ? Colors.red.shade300 : Colors.green.shade300;
    final fg = isError ? Colors.red.shade800 : Colors.green.shade800;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: fg,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: fg, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(text, style: TextStyle(color: fg)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
