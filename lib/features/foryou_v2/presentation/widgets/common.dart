import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class EmptyBox extends StatelessWidget {
  final String text;
  const EmptyBox({super.key, required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.black12),
    ),
    child: Center(
      child: Text(text, style: const TextStyle(color: Colors.black54)),
    ),
  );
}

class ErrorBox extends StatelessWidget {
  final String text;
  final VoidCallback onRetry;
  const ErrorBox({super.key, required this.text, required this.onRetry});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      EmptyBox(text: text),
      const SizedBox(height: 8),
      OutlinedButton(onPressed: onRetry, child: const Text('다시 시도')),
    ],
  );
}

/// 변경: EmotionAnalysis 대신 summary/tags만 받도록 단순화
class EmotionInsightCard extends StatelessWidget {
  final String summary;
  final List<String> tags;
  final String? moodKey;
  final String? moodEmoji;
  final VoidCallback? onEdit;
  const EmotionInsightCard({
    super.key,
    required this.summary,
    required this.tags,
    this.moodKey,
    this.moodEmoji,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF7B42), Color(0xFFFF5670)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    moodEmoji ?? '💡',
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    moodKey ?? '감정 분석',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
              ],
            ),
            const SizedBox(height: 10),
            Text(summary, style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags
                  .map(
                    (t) => Chip(
                      label: Text(t),
                      backgroundColor: const Color(0xFFFFF3EE),
                      shape: StadiumBorder(
                        side: BorderSide(color: Colors.orange.shade200),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
