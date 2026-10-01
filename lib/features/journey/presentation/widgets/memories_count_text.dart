import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/journey_state.dart';

/// 스케줄별 다이어리 개수를 상태에서 즉시 계산해 보여주는 텍스트 위젯.
/// 사용 예: Text 대신 MemoriesCountText(scheduleId: s.id)
class MemoriesCountText extends StatelessWidget {
  final int scheduleId;
  final TextStyle? style;
  final String suffix; // 기본: ' memories captured'

  const MemoriesCountText({
    super.key,
    required this.scheduleId,
    this.style,
    this.suffix = '개의 추억이 담겨있어요',
  });

  @override
  Widget build(BuildContext context) {
    final count =
        context.watch<JourneyState>().diariesBySchedule(scheduleId).length;
    return Text('$count$suffix', style: style);
  }
}
