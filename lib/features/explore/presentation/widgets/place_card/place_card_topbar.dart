/// lib/features/explore/presentation/widgets/place_card/place_card_topbar.dart
///
/// 카드 상단의 얇은 바(라운드, 흰 배경).
/// - 좌측: 카테고리 배지 (있을 때만)
/// - 우측: 가격 Pill (선택) + 하트 버튼(선택)

import 'package:flutter/material.dart';
import 'badges.dart';
import 'circle_icon_button.dart';

class PlaceTopBar extends StatelessWidget {
  final String? categoryLabel;
  final String? priceLabel;
  final bool showHeart;
  final EdgeInsets padding;

  const PlaceTopBar({
    super.key,
    this.categoryLabel,
    this.priceLabel,
    this.showHeart = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
          if (_cat.isNotEmpty)
            BadgeChip(icon: Icons.local_cafe_outlined, label: _cat, small: true)
          else
            const SizedBox.shrink(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_price != null) ...[
                const SizedBox(width: 4),
                BadgePill(text: _price),
                const SizedBox(width: 8),
              ],
              if (showHeart)
                CircleIconButton(
                  icon: Icons.favorite_border,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('북마크에 저장 완료! (mock)'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
