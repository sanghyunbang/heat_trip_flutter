import 'package:flutter/material.dart';
import 'badges.dart';
import 'circle_icon_button.dart';
import 'package:heat_trip_flutter/features/bookmark/presentation/widgets/bookmark_heart.dart';

class PlaceTopBar extends StatelessWidget {
  final String? categoryLabel;
  final String? priceLabel;
  final bool showHeart;
  final EdgeInsets padding;

  /// ✅ 추가: 관광지 식별 ID
  final String? contentId;

  const PlaceTopBar({
    super.key,
    this.categoryLabel,
    this.priceLabel,
    this.showHeart = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    this.contentId,
  });

  @override
  Widget build(BuildContext context) {
    final String _cat = (categoryLabel ?? '').trim();
    final String? _price = (() {
      final s = (priceLabel ?? '').trim();
      return s.isEmpty ? null : s;
    })();

    return Container(
      padding: padding,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_cat.isNotEmpty) BadgeChip(icon: Icons.local_cafe_outlined, label: _cat, small: true)
          else const SizedBox.shrink(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_price != null) ...[
                const SizedBox(width: 4),
                BadgePill(text: _price),
                const SizedBox(width: 8),
              ],
              if (showHeart)
                (contentId != null && contentId!.isNotEmpty)
                    ? BookmarkHeart(contentId: contentId!, iconSize: 22)
                    : CircleIconButton(
                  icon: Icons.favorite_border,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('콘텐츠 ID가 없어 북마크할 수 없어요')),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
