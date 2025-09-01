/// lib/features/explore/presentation/widgets/place_card/place_card_vertical.dart
///
/// 세로형 카드 구현.
/// - 상단 바(카테고리/가격/하트) + 이미지 + 본문(제목/메타/태그)로 구성.
/// - 스타일 관련 수치(compact, 패딩 등)를 이 파일에서 계산/적용.

import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/explore/data/models/place_item_dto.dart';
import 'package:heat_trip_flutter/features/explore/data/models/extensions/place_item_ids.dart';

import 'place_card_topbar.dart';
import 'place_card_image.dart';
import 'place_card_meta.dart';
import 'place_card_tags.dart';

class PlaceCardVertical extends StatelessWidget {
  final PlaceItem data;
  final VoidCallback onTap;

  final double? imageHeight;
  final bool compact;

  final String? categoryLabel;
  final String? priceLabel;
  final double? rating;
  final String? distance;
  final String? duration;
  final List<String>? tags;
  final bool showHeart;

  final double outerRadius;
  final double imageCornerRadius;
  final double imageElevation;
  final double barImageGap;
  final bool showTopBar;
  final EdgeInsets topBarPadding;

  const PlaceCardVertical({
    super.key,
    required this.data,
    required this.onTap,
    this.imageHeight,
    this.compact = false,
    this.categoryLabel,
    this.priceLabel,
    this.rating,
    this.distance,
    this.duration,
    this.tags,
    this.showHeart = true,
    this.outerRadius = 12,
    this.imageCornerRadius = 1,
    this.imageElevation = 1,
    this.barImageGap = 4,
    this.showTopBar = true,
    this.topBarPadding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    // compact 여부에 따라 타이포/패딩 등 크기 조정
    final double pad = compact ? 8 : 12;
    final double titleSize = compact ? 13 : 16;
    final double titleHeight = compact ? 1.1 : 1.2;

    final outline = Theme.of(context).colorScheme.outlineVariant;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(outerRadius),
        side: BorderSide.none,
      ),
      clipBehavior: Clip.none,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: outline, width: 1),
            borderRadius: BorderRadius.circular(outerRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showTopBar)
                PlaceTopBar(
                  categoryLabel: categoryLabel,
                  priceLabel: priceLabel,
                  showHeart: showHeart,
                  padding: topBarPadding,
                ),
              if (barImageGap > 0) SizedBox(height: barImageGap),
              PlaceImageBox(
                contentId: data.safeContentId,
                imageUrl: data.firstimage,
                imageHeight: imageHeight,
                cornerRadius: imageCornerRadius,
                elevation: imageElevation,
              ),
              Padding(
                padding: EdgeInsets.all(pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목 + (옵션) 평점
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            data.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w700,
                              height: titleHeight,
                            ),
                          ),
                        ),
                        if (rating != null)
                          RatingBadge(rating: rating!),
                      ],
                    ),
                    const SizedBox(height: 6),
                    MetaRow(
                      addr1: data.addr1,
                      distance: distance,
                      duration: duration,
                      compact: compact,
                    ),
                    if ((tags ?? const []).isNotEmpty) ...[
                      SizedBox(height: compact ? 6 : 10),
                      TagList(tags: tags!, compact: compact),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
