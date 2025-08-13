import 'package:flutter/material.dart';

/// 상단 필터 트리거 칩 (공용 스타일)
class RegionFilterChip extends StatelessWidget {
  final String label; // 칩에 표시할 텍스트
  final bool selected; // 현재 선택 상태 여부 (true면 강조 스타일)
  final bool outlined; // 외곽선만 표시하는 스타일 여부
  final VoidCallback onTap; // 클릭 시 호출되는 콜백 함수

  const RegionFilterChip({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // 현재 앱의 색상 테마 가져오기
    final border = selected || outlined ? cs.primary : Colors.grey.shade300; // 테두리 색상: 선택 상태이거나 outlined 모드면 primary 색상, 아니면 회색
    final bg = selected ? cs.primary.withOpacity(0.06) : Colors.white; // 배경색: 선택 상태면 primary의 옅은 색, 아니면 흰색

    return RawChip(
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)), // 칩에 표시될 텍스트 (굵게 표시)
      onPressed: onTap, // 칩 클릭 시 실행할 함수
      showCheckmark: false, // 체크마크 아이콘 숨김 (선택 표시 없이 스타일만 변경)
      side: BorderSide(color: border), // 외곽선 스타일
      backgroundColor: bg, // 배경색 적용
      shape: StadiumBorder(side: BorderSide(color: border)), // 칩 모양을 둥글게 (StadiumBorder = 양끝이 둥근 캡슐 형태)
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 칩 클릭 범위를 텍스트/패딩에 맞춤 (불필요한 여백 제거)
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // 칩 내부 패딩 (좌우 12, 상하 8)
    );
  }
}
