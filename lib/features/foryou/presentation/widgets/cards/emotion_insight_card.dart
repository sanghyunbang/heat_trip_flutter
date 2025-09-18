import 'package:flutter/material.dart';
import '../../../domain/entities.dart';
import '../ui/card_shell.dart';
import '../ui/chip.dart';

class EmotionInsightCard extends StatelessWidget {
  const EmotionInsightCard({
    super.key,
    required this.req,
    required this.onRecord,
  });
  final RankRequest req;
  final VoidCallback onRecord;

  String _goalLabel(List<String> goals) {
    if (goals.isEmpty) return '—';
    return goals
        .map((g) {
          switch (g) {
            case 'relaxation':
              return '진정';
            case 'mood-enhancement':
              return '기분상향';
            case 'immersion':
              return '몰입';
            case 'social-connection':
              return '연결';
            case 'perspective-shift':
              return '관점전환';
            case 'meaning_reflection':
            case 'meaning-reflection':
              return '의미/성찰';
            case 'quiet_reflection':
            case 'quiet-reflection':
              return '고요/성찰';
            default:
              return g;
          }
        })
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return CardShell(
      color: const Color(0xFFEDEAFF),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(Icons.psychology_alt_rounded, color: Color(0xFF6B5BFF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '감정 인사이트',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    TinyChip('P ${req.pad.pleasure}'),
                    TinyChip('A ${req.pad.arousal}'),
                    TinyChip('D ${req.pad.dominance}'),
                    TinyChip('에너지 ${req.energy}'),
                    TinyChip('사회성 ${req.socialNeed}'),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '목표: ${_goalLabel(req.goals)}',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: onRecord,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6B5BFF),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('수정'),
          ),
        ],
      ),
    );
  }
}
