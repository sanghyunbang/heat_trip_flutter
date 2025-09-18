import 'package:flutter/material.dart';
import '../ui/card_shell.dart';

class PersonalizedCard extends StatelessWidget {
  const PersonalizedCard({super.key, required this.onTune});
  final VoidCallback onTune;

  @override
  Widget build(BuildContext context) {
    return CardShell(
      color: const Color(0xFFE8FFF1),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(Icons.auto_awesome, color: Color(0xFF00B86B)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '감정 기반 추천',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  '분석 결과에 따른 맞춤 여행지',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
                SizedBox(height: 8),
                Text(
                  '감정 분석을 통해 개인화된 여행지를 추천해드립니다.',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.tonalIcon(
            onPressed: onTune,
            icon: const Icon(Icons.tune),
            label: const Text('맞춤'),
          ),
        ],
      ),
    );
  }
}
