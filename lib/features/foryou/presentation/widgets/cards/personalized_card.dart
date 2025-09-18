import 'package:flutter/material.dart';
import '../../../domain/entities.dart';
import '../cards/card_shell.dart' show ElevatedCardShell;

class PersonalizedCard extends StatelessWidget {
  const PersonalizedCard({super.key, required this.req});
  final RankRequest req;

  @override
  Widget build(BuildContext context) {
    const mint = Color(0xFF00A67E);
    final mood = req.moodKey ?? _moodByPleasure(req.pad.pleasure);
    final energy = _energyLabel(req.energy);

    return ElevatedCardShell(
      color: const Color(0xFFE8FFF3),
      radius: 18,
      padding: const EdgeInsets.all(16),
      borderColor: mint.withValues(alpha: 0.25),
      borderWidth: 1.2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.recommend, color: mint),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '감정 기반 추천',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '분석 결과에 따른 맞춤 여행지',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              _chip('맞춤', mint),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '현재 당신의 $mood 감정과 $energy 에너지 상태를 고려하여 아래 장소들을 추천드립니다.',
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  static Widget _chip(String text, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: c.withValues(alpha: 0.55)),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: c.withValues(alpha: 0.95),
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
    ),
  );

  static String _moodByPleasure(double p) {
    if (p >= 1.5) return 'JOY';
    if (p >= 0.5) return 'CONTENT';
    if (p <= -1.5) return 'SAD';
    if (p <= -0.5) return 'LETHARGIC';
    return 'BALANCED';
  }

  static String _energyLabel(int e) => switch (e) {
    -1 => '낮음',
    0 => '보통',
    1 => '높음',
    _ => '보통',
  };
}
