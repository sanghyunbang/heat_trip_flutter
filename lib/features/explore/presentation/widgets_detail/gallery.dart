/// gallery.dart
/// - 상세 상단 배경 갤러리(페이지뷰 + 점 인디케이터)
import 'package:flutter/material.dart';

class Gallery extends StatelessWidget {
  final List<String> images; // 이미지 URL 리스트
  final int index; // 현재 페이지 인덱스 (부모에서 관리)
  final ValueChanged<int> onChanged; // 페이지 변경 콜백

  const Gallery({
    super.key,
    required this.images,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      // 빈 갤러리: 회색 배경으로 안전 처리
      return Container(color: Colors.grey.shade200);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1) 메인 이미지 슬라이더
        PageView.builder(
          onPageChanged: onChanged,
          itemCount: images.length,
          itemBuilder: (_, i) => Image.network(images[i], fit: BoxFit.cover),
        ),

        // 2) 하단 점 인디케이터 (2장 이상일 때만 노출)
        if (images.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                final active = i == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? Colors.white : Colors.white70,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
