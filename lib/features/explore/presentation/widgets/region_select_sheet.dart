import 'package:flutter/material.dart';

/// 지역 단일 선택 바텀시트
/// - 지역 목록을 보여주고 사용자가 하나를 선택하면 바로 닫히면서 값 반환
class RegionSelectSheet extends StatefulWidget {
  final String title;         // 바텀시트 상단에 표시될 제목
  final List<String> options; // 선택 가능한 지역 목록
  final String initial;       // 처음 선택되어 있는 지역

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

  static const Color _primary = Color(0xFFEB9C64); // 테마 포인트 컬러

  @override
  void initState() {
    super.initState();
    _selected = widget.initial; // 초기값을 위젯에서 전달받은 값으로 설정
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = Colors.black87;

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white, // ✅ 배경 화이트 고정
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000), // 10% 블랙 그림자
              blurRadius: 16,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            // 하단 패딩은 키보드 높이(viewInsets.bottom)까지 반영
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── 그랩 핸들
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),

              // ── 타이틀 행 + 닫기
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: '닫기',
                    icon: const Icon(Icons.close),
                    color: onSurface.withOpacity(0.8),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: Color(0xFFEDEDED)),

              const SizedBox(height: 12),

              // ── 지역 선택 칩 (스크롤 가능)
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,     // 칩 간 가로 간격
                    runSpacing: 10,  // 칩 간 세로 간격
                    children: widget.options.map((opt) {
                      final sel = _selected == opt;

                      // ✅ 화이트 배경 유지 + 선택 시 얕은 틴트
                      final Color bg = sel ? _primary.withOpacity(0.08) : Colors.white;
                      final Color border = sel ? _primary : const Color(0xFFE0E0E0);
                      final Color textColor = sel ? _primary : onSurface;

                      return ChoiceChip(
                        label: Text(
                          opt,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        avatar: sel
                            ? const Icon(Icons.check, size: 18, color: _primary)
                            : Icon(Icons.place_outlined, size: 18, color: onSurface.withOpacity(0.75)),
                        selected: sel,
                        onSelected: (_) {
                          setState(() => _selected = opt);
                          // 선택 즉시 바텀시트 닫으면서 선택한 값을 반환
                          Navigator.pop(context, opt);
                        },
                        backgroundColor: bg,
                        selectedColor: _primary.withOpacity(0.10),
                        side: BorderSide(color: border, width: 1),
                        shape: StadiumBorder(
                          side: BorderSide(color: border, width: 1),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
