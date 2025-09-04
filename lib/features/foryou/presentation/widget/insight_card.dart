import 'package:flutter/material.dart';

/// 상단 "감정 인사이트" 카드(현재 감정 요약 / 기록 버튼)
class InsightCard extends StatelessWidget {
  final VoidCallback onRecord; // "감정 기록하기" 버튼
  final String? moodEmoji; // 선택된 감정 이모지
  final int? energy; // 0~10
  final int? social; // 0~10
  const InsightCard({
    super.key,
    required this.onRecord,
    this.moodEmoji,
    this.energy,
    this.social,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = moodEmoji != null && energy != null && social != null;
    return Card(
      color: const Color(0xFFEFF1FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: hasData ? _withData(context) : _empty(context),
      ),
    );
  }

  Widget _empty(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: const [
          Icon(Icons.auto_awesome, color: Colors.indigo),
          SizedBox(width: 8),
          Text('감정 인사이트', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        '감정을 기록하면 더 정확한 추천을 받을 수 있어요',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const SizedBox(height: 12),
      OutlinedButton(onPressed: onRecord, child: const Text('감정 기록하기')),
    ],
  );

  Widget _withData(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.indigo),
          const SizedBox(width: 8),
          const Text('감정 인사이트', style: TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(moodEmoji!, style: const TextStyle(fontSize: 22)),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(child: _stat('에너지', '$energy/10', _energyLabel(energy!))),
          const SizedBox(width: 8),
          Expanded(child: _stat('소셜니즈', '$social/10', _socialLabel(social!))),
        ],
      ),
    ],
  );

  Widget _stat(String title, String value, String level) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        Text(level, style: const TextStyle(fontSize: 12)),
      ],
    ),
  );

  String _energyLabel(int v) => v <= 3 ? '낮음' : (v <= 7 ? '보통' : '높음');
  String _socialLabel(int v) => v <= 3 ? '혼자' : (v <= 7 ? '보통' : '함께');
}
