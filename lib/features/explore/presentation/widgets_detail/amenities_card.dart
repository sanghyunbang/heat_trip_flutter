/// amenities_card.dart
/// ▷ '편의시설' 항목을 카드 형태로 출력하는 위젯
/// ▷ amenity_utils.dart 파일에 정의된 amenity 아이콘 및 라벨 매핑 함수를 활용
/// ▷ 각 편의시설을 2열(Grid)로 간결하게 나열 (아이콘 + 텍스트)
/// ▷ 예시 입력: ['wifi', 'parking', 'card']

import 'package:flutter/material.dart';
import '../../data_detail/amenity_utils.dart'; // amenityIcon, amenityLabel 함수 import

// StatelessWidget: amenities가 변하지 않는 고정형 UI
class AmenitiesCard extends StatelessWidget {
  final List<String> amenities; // 편의시설 리스트 (예: ['wifi', 'parking', 'card'])

  const AmenitiesCard({
    super.key,
    required this.amenities, // 필수 파라미터로 선언
  });

  @override
  Widget build(BuildContext context) {
    // (1) 편의시설이 아예 없으면 빈 박스 반환 (카드 자체를 숨김 효과)
    if (amenities.isEmpty) return const SizedBox.shrink();

    // (2) 실제 카드 UI 반환
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14), // 카드 안쪽 여백
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 텍스트/그리드를 좌측 정렬
          children: [
            const Text(
              '편의시설',
              style: TextStyle(fontWeight: FontWeight.w700), // 굵은 제목
            ),
            const SizedBox(height: 8), // 제목과 내용 사이 여백
            // (3) amenities 리스트를 2열 그리드로 렌더링
            GridView.builder(
              shrinkWrap: true, // 부모 Column 내에서만 높이 차지 (스크롤 없음)
              physics: const NeverScrollableScrollPhysics(), // 자체 스크롤 비활성화
              itemCount: amenities.length, // 아이템 개수만큼 반복

              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2열 그리드
                mainAxisExtent: 36, // 각 아이템 행 높이 고정 (아이콘 + 텍스트 높이)
                crossAxisSpacing: 8, // 열 간 간격
                mainAxisSpacing: 8, // 행 간 간격
              ),

              itemBuilder: (_, i) {
                final a = amenities[i]; // 현재 amenity 키 (예: 'wifi')

                // amenity 아이콘 + 텍스트 나열 (Row)
                return Row(
                  children: [
                    Icon(
                      amenityIcon(a), // 아이콘 매핑 함수 사용
                      size: 18,
                    ),
                    const SizedBox(width: 8), // 아이콘과 텍스트 간 여백
                    Expanded(
                      child: Text(
                        amenityLabel(a), // 라벨 매핑 함수 사용 (예: 'Wi-Fi')
                        overflow: TextOverflow.ellipsis, // 너무 길면 생략
                      ),
                    ),
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
