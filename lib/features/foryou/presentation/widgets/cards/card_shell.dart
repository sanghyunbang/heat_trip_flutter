import 'package:flutter/material.dart';

/// ElevatedCardShell
/// ---------------------------------------------------------------------------
/// • 역할: "부드러운 그림자" 중심의 카드 컨테이너 (외곽선 기본 X)
/// • 사용처 예: 히어로/인사이트/프로모션 카드 등 입체감이 필요한 섹션
/// • 파라미터:
///   - color:      배경색(기본 흰색). 파스텔 tint도 가능
///   - padding:    카드 안쪽 여백
///   - margin:     카드 바깥 여백(섹션 간 간격)
///   - radius:     모서리 둥글기
///   - shadow*     그림자 색/강도/오프셋 커스터마이즈
class ElevatedCardShell extends StatelessWidget {
  const ElevatedCardShell({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 12),
    this.radius = 16.0,
    this.shadowColor,
    this.shadowBlur = 18.0,
    this.shadowOffset = const Offset(0, 10),
    this.shadowAlpha = 0.05,
    // 🆕 선택적 외곽선(없으면 null)
    this.borderColor,
    this.borderWidth = 1.0,
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double radius;

  // shadow
  final Color? shadowColor;
  final double shadowBlur;
  final Offset shadowOffset;
  final double shadowAlpha;

  // 🆕 border
  final Color? borderColor; // null이면 외곽선 없음
  final double borderWidth; // 외곽선 두께

  @override
  Widget build(BuildContext context) {
    final sc = (shadowColor ?? Colors.black).withValues(alpha: shadowAlpha);

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        // 🆕 borderColor가 넘어오면 외곽선을 그림
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
        boxShadow: [
          BoxShadow(color: sc, blurRadius: shadowBlur, offset: shadowOffset),
        ],
      ),
      child: child,
    );
  }
}
