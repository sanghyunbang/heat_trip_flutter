/// lib/features/explore/presentation/widgets/place_card/place_card_horizontal.dart
///
/// 가로형 카드 구현.
/// - 왼쪽 썸네일, 오른쪽 텍스트 블럭.

import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/explore/data/models/place_item_dto.dart';
import 'package:heat_trip_flutter/features/explore/data/models/extensions/place_item_ids.dart';

class PlaceCardHorizontal extends StatelessWidget {
  final PlaceItem data;
  final VoidCallback onTap;

  final double thumbnailWidth;
  final double imageCornerRadius;

  const PlaceCardHorizontal({
    super.key,
    required this.data,
    required this.onTap,
    this.thumbnailWidth = 160,
    this.imageCornerRadius = 1,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(imageCornerRadius);

    String _shortAddr(String? addr) {
      if (addr == null) return '';
      final t = addr.trim();
      if (t.isEmpty) return '';
      final parts = t.split(RegExp(r'\s+'));
      return parts.length >= 2 ? '${parts[0]} ${parts[1]}' : t;
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 좌측 이미지
            SizedBox(
              width: thumbnailWidth,
              child: ClipRRect(
                borderRadius: BorderRadius.horizontal(left: Radius.circular(imageCornerRadius)),
                child: Hero(
                  tag: 'place:${data.safeContentId}',
                  child: Image.network(
                    data.firstimage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.network(
                      'https://cdn.pixabay.com/photo/2019/07/08/04/23/traveling-4323759_1280.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            // 우측 텍스트
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.map_outlined, size: 14, color: Colors.black54),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _shortAddr(data.addr1),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
