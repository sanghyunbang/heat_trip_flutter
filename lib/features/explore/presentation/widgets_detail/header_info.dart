/// header_info.dart
/// - 상세 헤더: 타입 칩 + 타이틀 + 메타(평점/거리/시간)
import 'package:flutter/material.dart';
import '../../domain_detail/content_type.dart';
import '../../domain/entity_detail/place_detail.dart';

class HeaderInfo extends StatelessWidget {
  final PlaceDetail detail;
  const HeaderInfo({super.key, required this.detail});

  /// contentType → 한글 라벨 맵핑
  String _typeLabel(ContentType t) {
    switch (t) {
      case ContentType.attraction:
        return '관광지';
      case ContentType.culture:
        return '문화';
      case ContentType.festival:
        return '축제·공연';
      case ContentType.course:
        return '여행코스';
      case ContentType.leports:
        return '레포츠';
      case ContentType.lodging:
        return '숙박';
      case ContentType.shopping:
        return '쇼핑';
      case ContentType.food:
        return '음식점';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 라벨/텍스트가 비어있을 수 있으므로 if-guard로 방어
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 타입 칩 영역
        Row(
          children: [
            _RoundedChip(label: _typeLabel(detail.contentType)),
            if ((detail.priceTier ?? '').isNotEmpty) ...[
              const SizedBox(width: 8),
              _RoundedChip(label: detail.priceTier!),
            ],
          ],
        ),
        const SizedBox(height: 16),

        // 타이틀
        Text(
          detail.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),

        const SizedBox(height: 10),

        // 메타 정보 (평점/거리/예상시간)
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            if (detail.rating != null)
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 6),
                  Text('${detail.rating}'),
                ],
              ),
            if ((detail.distanceText ?? '').isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16),
                  const SizedBox(width: 6),
                  Text(detail.distanceText!),
                ],
              ),
            if ((detail.estimatedTimeText ?? '').isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16),
                  const SizedBox(width: 4),
                  Text(detail.estimatedTimeText!),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _RoundedChip extends StatelessWidget {
  const _RoundedChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        // 글씨색만 #353535 적용 (폰트 크기/두께/패딩은 Chip 기본값 유지)
        style: const TextStyle(color: Color(0xFF353535)),
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: const BorderSide(color: Color(0xFFE2E2E2)),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
