/// lib/features/explore/presentation/widgets/place_card/place_card_image.dart
///
/// 이미지 영역을 담당.
/// - Hero 연결 태그는 'place:<contentId>'
/// - 높이 지정 없으면 16:9 비율 유지
/// - errorBuilder로 fallback 이미지 제공
/// - PhysicalModel로 얇은 elevation 연출

import 'package:flutter/material.dart';

class PlaceImageBox extends StatelessWidget {
  final int contentId;
  final String imageUrl;
  final double? imageHeight;
  final double cornerRadius;
  final double elevation;

  const PlaceImageBox({
    super.key,
    required this.contentId,
    required this.imageUrl,
    this.imageHeight,
    this.cornerRadius = 1,
    this.elevation = 1,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(cornerRadius);

    Widget _image() => Hero(
          tag: 'place:$contentId',
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Image.network(
              'https://cdn.pixabay.com/photo/2019/07/08/04/23/traveling-4323759_1280.png',
              fit: BoxFit.cover,
            ),
          ),
        );

    final child = PhysicalModel(
      color: Colors.white,
      elevation: elevation,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: _image(),
    );

    if (imageHeight != null) return SizedBox(height: imageHeight, child: child);
    return AspectRatio(aspectRatio: 16 / 9, child: child);
  }
}
