// lib/features/foryou/presentation/widgets/circle_icon_button.dart

/// CircleIconButton  [Widget]
/// 역할: 둥근 반투명 배경의 라이트 액션 버튼(공유/북마크 등).
/// 입력: [icon] 아이콘, [onTap] 탭 콜백
/// 사용처: DetailPage 상단 우측 액션 영역.
/// 주의: 내부 아이콘은 외부에서 주입된 [icon]을 그대로 사용.

import 'package:flutter/material.dart';

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const CircleIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.28),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
