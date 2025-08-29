/// KPicker  [Widget]
/// 역할: 추천 개수 K(Top-K)를 세그먼트 버튼으로 선택.
/// 입력: [value] 현재 K, [onChanged] 변경 콜백
/// 사용처: ForYouScreen AppBar 액션 영역.
/// 비고: UI 전용. 비즈니스 로직 없음.

// lib/features/foryou/presentation/widgets/k_picker.dart
import 'package:flutter/material.dart';

class KPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const KPicker({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = const [4, 8, 12];
    return SegmentedButton<int>(
      segments: options
          .map((e) => ButtonSegment(value: e, label: Text('K=$e')))
          .toList(),
      selected: {value},
      showSelectedIcon: false,
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
