import 'package:flutter/material.dart';

/// 지역 단일 선택 바텀시트
/// - 지역 목록을 보여주고 사용자가 하나를 선택하면 바로 닫히면서 값 반환
class RegionSelectSheet extends StatefulWidget {
  final String title; // 바텀시트 상단에 표시될 제목
  final List<String> options; // 선택 가능한 지역 목록
  final String initial; // 처음 선택되어 있는 지역

  const RegionSelectSheet({
    super.key,
    required this.title,
    required this.options,
    required this.initial,
  });

  @override
  State<RegionSelectSheet> createState() => _RegionSelectSheetState();
}

class _RegionSelectSheetState extends State<RegionSelectSheet> {
  late String _selected; // 현재 선택된 지역 값

  @override
  void initState() {
    super.initState();
    _selected = widget.initial; // 초기값을 위젯에서 전달받은 값으로 설정
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only( // 바텀시트 내부 여백 지정
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom, // 하단 패딩은 키보드 높이(viewInsets.bottom)까지 반영
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 높이를 내용물에 맞게(min) 조정
        children: [
          // 제목 텍스트
          Text(widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          // 지역 선택 칩들을 가로/세로로 나열
          Wrap(
            spacing: 8, // 칩 간 가로 간격
            runSpacing: 8, // 칩 간 세로 간격
            children: widget.options.map((opt) {
              final sel = _selected == opt; // 현재 선택된 칩인지 여부
              return ChoiceChip(
                label: Text(opt), // 칩에 표시될 텍스트
                selected: sel, // 현재 선택 여부
                onSelected: (_) {
                  setState(() => _selected = opt); // 선택 값 변경
                  Navigator.pop(context, opt); // 선택 즉시 바텀시트 닫으면서 선택한 값을 반환
                },
                // 선택 상태일 때 배경색
                selectedColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.18),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
