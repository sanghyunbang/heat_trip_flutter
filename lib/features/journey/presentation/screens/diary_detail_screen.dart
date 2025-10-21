// lib/features/journey/presentation/screens/diary_detail_screen.dart
import 'package:flutter/material.dart';
import '../widgets/image_placeholders.dart';
import '../../domain/models.dart';

class DiaryDetailScreen extends StatelessWidget {
  final DiaryEntry? entry;
  const DiaryDetailScreen({super.key, this.entry});

  @override
  Widget build(BuildContext context) {
    if (entry == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('No Diary Entry', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0.5),
        backgroundColor: const Color(0xFFF8F8F8),
        body: const Center(child: Text('Diary entry not found.', style: TextStyle(fontSize: 16))),
      );
    }

    // ✅ 목록과 동일 seed
    final seed = deriveImageSeed(scheduleId: entry!.scheduleId, title: entry!.title);

    return Scaffold(
      appBar: AppBar(title: Text(entry!.title, style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0.5),
      backgroundColor: const Color(0xFFF8F8F8),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _InfoCard(children: [
            _InfoRow(icon: Icons.calendar_today, label: entry!.dateLabel),
            _InfoRow(icon: Icons.emoji_emotions_outlined, label: entry!.moodLabel),
            _InfoRow(icon: Icons.wb_sunny_outlined, label: entry!.weatherLabel),
          ]),
          const SizedBox(height: 16),

          if (entry!.location.trim().isNotEmpty)
            _InfoCard(children: [ _InfoRow(icon: Icons.place_outlined, label: entry!.location) ]),
          if (entry!.location.trim().isNotEmpty) const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE6E6E6))),
            child: Text(entry!.body, style: const TextStyle(fontSize: 16, height: 1.6)),
          ),
          const SizedBox(height: 24),

          if (entry!.photos.isNotEmpty) ...[
            const Text('📸 사진', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: entry!.photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final url = photoOrPlaceholder(entry!.photos[index], seed: seed, salt: index);
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(color: const Color(0xFFF3F3F3)),
                        Image.network(
                          url,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          loadingBuilder: (ctx, child, progress) => progress == null ? child : const _ThumbSkeleton(),
                          errorBuilder: (_, __, ___) => const _ThumbError(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// 아래 InfoCard/Row, _ThumbSkeleton/_ThumbError는 기존 그대로
class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE8E8E8))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 18, color: Colors.black87),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}

class _ThumbSkeleton extends StatelessWidget {
  const _ThumbSkeleton();
  @override
  Widget build(BuildContext context) {
    return Container(color: const Color(0xFFF3F3F3), alignment: Alignment.center, child: const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)));
  }
}

class _ThumbError extends StatelessWidget {
  const _ThumbError();
  @override
  Widget build(BuildContext context) {
    return Container(color: const Color(0xFFF3F3F3), alignment: Alignment.center, child: const Icon(Icons.broken_image_outlined, size: 24, color: Color(0xFF9E9E9E)));
  }
}
