import 'package:flutter/material.dart';

/// 상단 필터 트리거 칩 (공용 스타일)
class RegionFilterChip extends StatelessWidget {
  final String label;        // 칩에 표시할 텍스트
  final bool selected;       // 현재 선택 상태 여부 (true면 강조 스타일)
  final bool outlined;       // 외곽선만 표시하는 스타일 여부
  final VoidCallback onTap;  // 클릭 시 호출되는 콜백 함수

  const RegionFilterChip({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.outlined = false,
  });

  static const Color _primary = Color(0xFFEB9C64); // 테마 포인트 컬러

  @override
  Widget build(BuildContext context) {
    const Color onSurface = Colors.black87;

    // ✅ 화이트 배경 고정, 상태에 따라 보더/텍스트만 강조
    final bool isOutlineStyle = outlined || !selected;
    final Color borderColor = selected ? _primary : const Color(0xFFE0E0E0);
    final Color bgColor = Colors.white; // 항상 화이트
    final Color labelColor = selected ? _primary : onSurface;

    return Material(
      color: bgColor,
      elevation: selected ? 1.5 : 0, // 선택 시 살짝 띄워 줌
      shadowColor: Colors.black.withOpacity(0.12),
      shape: StadiumBorder(
        side: BorderSide(color: borderColor, width: isOutlineStyle ? 1 : 1),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.place_outlined,
                size: 18,
                color: labelColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                Icon(Icons.close, size: 18, color: labelColor.withOpacity(0.9)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
