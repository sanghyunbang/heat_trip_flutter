import 'package:flutter/material.dart';
import '../../../domain/entities.dart';
import '../ui/badge.dart';

class PlaceTile extends StatelessWidget {
  const PlaceTile({super.key, required this.place});
  final RankedPlace place;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://picsum.photos/seed/${place.placeId}/160/120',
              width: 88,
              height: 66,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  place.cat3Code,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    BadgePill(text: '적합도 ${(place.traitMatch * 100).round()}%'),
                    const SizedBox(width: 6),
                    BadgePill(text: '인기도 ${(place.popularity * 100).round()}%'),
                  ],
                ),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
        ],
      ),
    );
  }
}
