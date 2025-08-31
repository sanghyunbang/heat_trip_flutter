/// amenities_card.dart
/// - amenity_utils의 아이콘/라벨 맵핑을 사용
/// - 2열 그리드로 간결하게 나열
import 'package:flutter/material.dart';
import '../../data_detail/amenity_utils.dart';

class AmenitiesCard extends StatelessWidget {
  final List<String> amenities; // 예: ['wifi','parking','card',...]
  const AmenitiesCard({super.key, required this.amenities});

  @override
  Widget build(BuildContext context) {
    if (amenities.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('편의시설', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true, // 카드 내 스크롤 금지
              physics: const NeverScrollableScrollPhysics(),
              itemCount: amenities.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2열
                mainAxisExtent: 36, // 아이템 높이
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (_, i) {
                final a = amenities[i];
                return Row(
                  children: [
                    Icon(amenityIcon(a), size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(amenityLabel(a))),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
