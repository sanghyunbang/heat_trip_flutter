/// lib/features/explore/presentation/widgets/place_card/place_card.dart
///
/// 공개 진입점. 외부에서 사용하는 단 하나의 컴포넌트.
/// - 공통 Props 정의
/// - 레이아웃 분기 (vertical/horizontal)
/// - 상세 페이지 이동 로직(go_router) 보유
///
/// ✅ 변경: 카드의 썸네일 URL을 go_router `extra`로 함께 전달.
///         PlaceItem에 `firstImage`가 없으므로 `firstimage/firstimage2`만 사용.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heat_trip_flutter/features/explore/data/models/place_item_dto.dart';
import 'package:heat_trip_flutter/features/explore/data/models/extensions/place_item_ids.dart';

import 'place_card_vertical.dart';
import 'place_card_horizontal.dart';

enum PlaceCardLayout { horizontal, vertical }

class PlaceCard extends StatelessWidget {
  final PlaceItem data;
  final PlaceCardLayout layout;
  final double? imageHeight;
  final bool compact;

  final String? categoryLabel;
  final String? priceLabel;
  final bool showHeart;

  final double? rating;
  final String? distance;
  final String? duration;
  final List<String>? tags;

  final double thumbnailWidth;
  final double outerRadius;
  final double imageCornerRadius;
  final double imageElevation;
  final double barImageGap;
  final bool showTopBar;
  final EdgeInsets topBarPadding;

  const PlaceCard({
    super.key,
    required this.data,
    this.layout = PlaceCardLayout.vertical,
    this.imageHeight,
    this.compact = false,
    this.categoryLabel,
    this.priceLabel,
    this.rating,
    this.distance,
    this.duration,
    this.tags,
    this.showHeart = true,
    this.thumbnailWidth = 160,
    this.outerRadius = 12,
    this.imageCornerRadius = 1,
    this.imageElevation = 1,
    this.barImageGap = 4,
    this.showTopBar = true,
    this.topBarPadding = const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 6,
    ),
  });

  /// 상세 페이지로 이동
  /// - go_router를 통한 명명된 라우트 push
  /// - ✅ 카드의 썸네일 URL을 `extra`로 함께 전달
  void _goDetail(BuildContext context) {
    final cid = data.safeContentId;
    final ctid = data.safeContentTypeId;

    // ✅ PlaceItem에 존재하는 실제 이미지 필드 사용 (firstimage / firstimage2)
    String? seed = _pickSeedImage(data);
    if (seed != null && seed.trim().isEmpty) seed = null;

    context.pushNamed(
      'explore_detail',
      pathParameters: {'contentId': '$cid', 'contentTypeId': '$ctid'},
      extra: seed, // ✅ routes에서 state.extra as String? 으로 받음
    );
  }

  String? _pickSeedImage(PlaceItem d) {
    // 프로젝트의 DTO에 맞게 실제 필드만 남김
    final candidates = <String?>[d.firstimage, d.firstimage2];
    for (final s in candidates) {
      if (s != null && s.trim().isNotEmpty) return s;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    switch (layout) {
      case PlaceCardLayout.horizontal:
        return PlaceCardHorizontal(
          data: data,
          onTap: () => _goDetail(context),
          thumbnailWidth: thumbnailWidth,
          imageCornerRadius: imageCornerRadius,
        );
      case PlaceCardLayout.vertical:
      default:
        return PlaceCardVertical(
          data: data,
          onTap: () => _goDetail(context),
          imageHeight: imageHeight,
          compact: compact,
          categoryLabel: categoryLabel,
          priceLabel: priceLabel,
          rating: rating,
          distance: distance,
          duration: duration,
          tags: tags,
          showHeart: showHeart,
          outerRadius: outerRadius,
          imageCornerRadius: imageCornerRadius,
          imageElevation: imageElevation,
          barImageGap: barImageGap,
          showTopBar: showTopBar,
          topBarPadding: topBarPadding,
        );
    }
  }
}
