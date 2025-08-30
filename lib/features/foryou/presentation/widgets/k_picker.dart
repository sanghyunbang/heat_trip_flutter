// lib/features/foryou/presentation/widgets/k_picker.dart
import 'package:flutter/material.dart';

class KPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final bool framed; // ← 추가: 외곽 캡슐 on/off
  const KPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.framed = true,
  });

  @override
  Widget build(BuildContext context) {
    const options = [4, 8, 12];

    // 외곽 캡슐 있는 버전
    if (framed) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE6E1D6), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map(
                (k) => _Pill(
                  label: 'Top $k',
                  selected: value == k,
                  onTap: () => onChanged(k),
                ),
              )
              .toList(),
        ),
      );
    }

    // 외곽 캡슐 없는 인라인 버전
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: options
          .map(
            (k) => _Pill(
              label: 'Top $k',
              selected: value == k,
              onTap: () => onChanged(k),
            ),
          )
          .toList(),
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
    final fg = selected ? Colors.white : const Color(0xFF374151);
    final bg = selected ? const Color(0xFF0B1220) : Colors.white;
    final bd = selected ? Colors.transparent : const Color(0xFFE6E1D6);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 4), // 알약간 간격
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: bd, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          splashColor: Colors.black12,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: fg,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
