/// KPicker  [Widget]
/// 역할: 추천 개수 K(Top-K)를 세그먼트 버튼으로 선택.
/// 입력: [value] 현재 K, [onChanged] 변경 콜백
/// 사용처: ForYouScreen AppBar 액션 영역.
/// 비고: UI 전용. 비즈니스 로직 없음.

// lib/features/foryou/presentation/widgets/k_picker.dart
import 'package:flutter/material.dart';

class _Pal {
  static const primary100 = Color(0xFFEB9C64); // orange
  static const primary200 = Color(0xFFFF8789); // pink
  static const bg200 = Color(0xFFEBE2CD);
  static const bg300 = Color(0xFFC2BAA6);
  static const text100 = Color(0xFF353535);
}

class KPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const KPicker({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = [4, 8, 12];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.65),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _Pal.bg200.withOpacity(.9), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options
            .map(
              (k) => _Pill(
                label: 'Top $k', // ← ‘K=’ 대신 텍스트로 자연스럽게
                selected: value == k,
                onTap: () => onChanged(k),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: selected ? _Pal.primary100 : Colors.transparent,
        // 선택 안 됐을 때는 외곽선만, 선택 시 외곽선 없애서 더 깔끔하게
        border: selected
            ? null
            : Border.all(color: _Pal.bg300.withOpacity(.9), width: 0.8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          splashColor: Colors.black12,
          child: Padding(
            // AppBar에 맞게 컴팩트
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : _Pal.text100,
                height: 1.0,
                letterSpacing: .2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
