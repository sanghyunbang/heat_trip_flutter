import 'package:flutter/material.dart';

// ✅ Bookmark 탭: 아직 북마크 데이터가 없거나 로딩 중일 때 자리만 잡아주는 스켈레톤
/// 로딩 상태용 스켈레톤 박스
class SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;

  const SkeletonBox({super.key, required this.height, this.width});

  @override
  Widget build(BuildContext context) {
    final w = width ?? double.infinity;
    return Container(
      width: w,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black12.withOpacity(.06),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
