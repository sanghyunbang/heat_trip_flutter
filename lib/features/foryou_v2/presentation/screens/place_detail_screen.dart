import 'package:flutter/material.dart';
import '../../domain/models.dart';

/// 장소 상세: 라이트 버전(확장 여지)
class PlaceDetailScreen extends StatelessWidget {
  final Place place;
  const PlaceDetailScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(place.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0.6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.place_outlined),
              title: Text(
                place.name,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text('카테고리: ${place.cat3Code}'),
              trailing: Chip(
                label: Text('${(place.finalScore * 100).toStringAsFixed(0)}%'),
              ),
            ),
          ),
          if (place.distanceKm != null)
            ListTile(
              leading: const Icon(Icons.map),
              title: Text('${place.distanceKm!.toStringAsFixed(1)} km 떨어져 있어요'),
            ),
          const SizedBox(height: 8),
          const Text('추천 이유, 리뷰, CTA 섹션은 추후 확장합니다.'),
        ],
      ),
    );
  }
}
