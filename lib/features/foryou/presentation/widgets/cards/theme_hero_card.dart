import 'package:flutter/material.dart';

class ThemeHeroCard extends StatelessWidget {
  const ThemeHeroCard({super.key});
  @override
  Widget build(BuildContext context) {
    const img =
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1600&q=80';
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              img,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF222),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.white54,
                  size: 48,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.05), Colors.black54],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          const Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '마음의 치유',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '고요함을 찾는 여행',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const Positioned(
            right: 16,
            bottom: 16,
            child: FilledButton(onPressed: null, child: Text('테마 여행지 보기')),
          ),
        ],
      ),
    );
  }
}
