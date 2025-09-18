import 'package:flutter/material.dart';

/// OutlinedCardShell
/// ---------------------------------------------------------------------------
/// • 역할: "얇은 외곽선" 중심의 카드 컨테이너 (그림자는 선택)
/// • 사용처 예: 리스트/그리드 섹션, 폼/필터 박스 등 구조적 구분이 필요할 때
/// • 파라미터:
///   - color:        배경색(기본 흰색)
///   - borderColor:  외곽선 색(연한 회색 권장)
///   - borderWidth:  외곽선 두께
///   - withShadow:   필요 시 아주 얕은 그림자
///   - radius/padding/margin: 공통 레이아웃 옵션
class OutlinedCardShell extends StatelessWidget {
  const OutlinedCardShell({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 12),
    this.borderColor = const Color(0xFFE5E7EB),
    this.borderWidth = 1.0,
    this.radius = 16.0,
    this.withShadow = false,
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color borderColor;
  final double borderWidth;
  final double radius;
  final bool withShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: withShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
