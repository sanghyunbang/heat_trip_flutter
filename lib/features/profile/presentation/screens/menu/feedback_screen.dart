import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/profile/data/feedback_repository_impl.dart';
import 'package:heat_trip_flutter/features/profile/domain/repository/feedback_repository.dart';

/// 의견 보내기 화면
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _controller = TextEditingController();
  final FeedbackRepository _repo = FeedbackRepositoryImpl();

  // 브랜드 컬러
  static const kPrimary = Color(0xFFEB9C64);

  // 드롭다운 카테고리
  final List<String> _categories = const ['버그', '제안', '칭찬', '기타'];
  String? _category;

  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력해 주세요.')),
      );
      return;
    }

    setState(() => _sending = true);

    final ok = await _repo.sendFeedback(
      content: content,
      category: _category,
      appVersion: null,
      deviceInfo: null,
    );

    if (!mounted) return;
    setState(() => _sending = false);

    if (ok) {
      _controller.clear();
      setState(() => _category = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('의견이 제출되었어요. 감사합니다!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제출에 실패했어요. 잠시 후 다시 시도해 주세요.')),
      );
    }
  }

  // 카테고리 → 아이콘 매핑
  IconData _categoryIcon(String c) {
    switch (c) {
      case '버그':
        return Icons.bug_report_outlined;
      case '제안':
        return Icons.lightbulb_outline;
      case '칭찬':
        return Icons.thumb_up_alt_outlined;
      default:
        return Icons.chat_bubble_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _controller.text.trim().isNotEmpty && !_sending;

    return Scaffold(
      appBar: AppBar(title: const Text('의견보내기')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── 카테고리 드롭다운 (커스텀 디자인) ──
            Align(
              alignment: Alignment.centerLeft,
              child: DropdownButtonFormField<String>(
                value: _category,
                isExpanded: true,
                itemHeight: 52,                // 펼쳐진 메뉴에서 각 항목 높이
                menuMaxHeight: 280,            // 메뉴 최대 높이
                dropdownColor: Colors.white,   // 펼쳐진 메뉴 배경
                borderRadius: BorderRadius.circular(14), // 메뉴 모서리
                icon: const Icon(              // 오른쪽 화살표 아이콘
                  Icons.keyboard_arrow_down_rounded,
                  color: kPrimary,
                ),
                style: const TextStyle(        // 선택된 값 텍스트 스타일
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                items: _categories
                    .map(
                      (c) => DropdownMenuItem<String>(
                    value: c,
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: kPrimary.withOpacity(.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _categoryIcon(c),
                            size: 18,
                            color: kPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          c,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: (_category == c)
                                ? kPrimary
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .toList(),
                onChanged: (v) => setState(() => _category = v),
                decoration: InputDecoration(
                  labelText: '카테고리',
                  floatingLabelStyle: const TextStyle(
                    color: kPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFFAF4EE), // 살짝 톤 있는 배경
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    BorderSide(color: kPrimary.withOpacity(.35), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kPrimary, width: 1.6),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── 내용 입력 ──
            TextField(
              controller: _controller,
              onChanged: (_) => setState(() {}),
              maxLines: 8,
              decoration: InputDecoration(
                hintText: '앱 사용 중 불편 사항이나 제안을 알려주세요.',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 12),

            // ── 전송 버튼 ──
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: canSend ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: kPrimary.withOpacity(.4),
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                child: _sending
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                  CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text('보내기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
