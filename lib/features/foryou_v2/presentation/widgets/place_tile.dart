import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/foryou_v2/domain/models.dart';

/// 리스트 타일
/// - 그림자 없음
/// - 흰색 배경 + 진한 외곽선
/// - 카테고리/거리 분리
/// - 매칭 배지: **단일 색(파스텔 레드) 외곽선만**, 배경 흰색, 텍스트 짙은 회색
class PlaceTile extends StatelessWidget {
  final Place place;
  final VoidCallback? onTap;
  const PlaceTile({super.key, required this.place, this.onTap});

  static const _cardBorder = Color(0xFFCACAD3); // 리스트/그리드 톤 통일
  static const _muted = Color(0xFF555661); // 텍스트 짙은 회색

  // 파스텔 레드(형광X)
  static const _pillBorder = Color(0xFFE07A7A); // 외곽만 컬러
  static const _pillText = Color(0xFF2B2B34); // 배지 텍스트(짙은 회색)

  static const _PLACEHOLDER =
      'https://placehold.co/400x400/F5F6F8/9AA0A6?text=%EC%9D%B4%EB%AF%B8%EC%A7%80%0A%EC%97%86%EC%9D%8C&font=inter';

  @override
  Widget build(BuildContext context) {
    final cat = (place.cat3Name ?? place.cat3Code);
    final dist = place.distanceKm != null
        ? '${place.distanceKm!.toStringAsFixed(1)}km'
        : null;

    // 표시는 반올림 정수로 통일
    final int pct = ((place.finalScore * 100)).round().clamp(0, 100);

    final String url = (place.firstImageUrl ?? '').isNotEmpty
        ? place.firstImageUrl!
        : _PLACEHOLDER;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _cardBorder, width: 1.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 썸네일
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 56,
                height: 56,
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.network(
                    _PLACEHOLDER,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFF3F3F6),
                      child: const Icon(
                        Icons.image_outlined,
                        color: Color(0xFFB8B8C3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // 텍스트 블록
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 타이틀 (더 작게)
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5, // grid와 동일 축소 사이즈
                      height: 1.18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // 카테고리
                  Text(
                    cat,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 12.5,
                      height: 1.2,
                    ),
                  ),
                  // 거리(있을 때만)
                  if (dist != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: _muted,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            dist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 12.5,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // 매칭률 배지 (외곽 컬러만, 배경 흰색)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _pillBorder, width: 1.2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$pct%',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: _pillText, // 짙은 회색
                  height: 1.0,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
