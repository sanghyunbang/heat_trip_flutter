/// lib/features/explore/presentation/widgets/place_card/place_card.dart
///
/// 공개 진입점. 외부에서 사용하는 단 하나의 컴포넌트.
/// - 공통 Props 정의
/// - 레이아웃 분기 (vertical/horizontal)
/// - 상세 페이지 이동 로직(go_router) 보유
///
/// 나머지 UI는 세부 컴포넌트로 분리해 가독성/재사용성 개선.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heat_trip_flutter/features/explore/data/models/place_item_dto.dart';
import 'package:heat_trip_flutter/features/explore/data/models/extensions/place_item_ids.dart';

import 'place_card_vertical.dart';
import 'place_card_horizontal.dart';

enum PlaceCardLayout { horizontal, vertical }

class PlaceCard extends StatelessWidget {
  /// 서버에서 내려온 원본 데이터
  final PlaceItem data;

  /// 레이아웃 타입: 가로/세로
  final PlaceCardLayout layout;

  /// 이미지 높이(세로형 전용). null이면 16:9 비율 유지
  final double? imageHeight;

  /// compact 모드: 타이포/패딩 축소
  final bool compact;

  /// 상단 바 옵션들
  final String? categoryLabel; // 왼쪽 카테고리 배지
  final String? priceLabel;    // 오른쪽 가격 배지
  final bool showHeart;        // 하트 버튼 노출 여부

  /// 메타/리뷰/태그
  final double? rating;
  final String? distance;      // 예: "1.2km"
  final String? duration;      // 예: "20m"
  final List<String>? tags;

  /// 가로형에서만 사용하는 썸네일 폭
  final double thumbnailWidth;

  /// 카드/이미지 모서리/외곽 옵션
  final double outerRadius;
  final double imageCornerRadius;
  final double imageElevation;
  final double barImageGap;

  /// 상단바 표시/패딩
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
    this.topBarPadding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  });

  /// 상세 페이지로 이동
  /// - go_router를 통한 명명된 라우트 push
  void _goDetail(BuildContext context) {
    final cid = data.safeContentId;
    final ctid = data.safeContentTypeId;

    context.pushNamed(
      'explore_detail',
      pathParameters: {'contentId': '$cid', 'contentTypeId': '$ctid'},
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (layout) {
      case PlaceCardLayout.horizontal:
        return PlaceCardHorizontal(
          data: data,
          onTap: () => _goDetail(context),
          // 재사용 가능한 옵션 전달
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
