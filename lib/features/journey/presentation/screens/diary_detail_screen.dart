import 'package:flutter/material.dart';
import '../../domain/models.dart';

class DiaryDetailScreen extends StatelessWidget {
  final DiaryEntry entry;

  const DiaryDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(entry.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// 📅 날짜, 😄 기분, 🌤 날씨
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.dateLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('🌤 ${entry.weatherLabel}'),
              Text('😄 ${entry.moodLabel}'),
            ],
          ),
          const SizedBox(height: 12),

          /// 📍 장소
          if (entry.location.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(entry.location),
              ],
            ),
          const SizedBox(height: 12),

          /// 📝 본문
          Text(entry.body, style: const TextStyle(fontSize: 16)),

          const SizedBox(height: 20),

          /// 🖼 사진 목록
          if (entry.photos.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('사진', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: entry.photos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final photoUrl = entry.photos[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(photoUrl),
                      );
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
