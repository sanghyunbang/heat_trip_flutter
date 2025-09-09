/// "나의 경험" 탭
/// - 방문 전/후 감정 선택(ChoiceChip)
/// - 공간 특성 슬라이더(0~1, 10단계)
/// - 텍스트 입력 + 제출 버튼

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/detail_emotion_vm.dart';
import 'emotion_tab.dart' show EMOTIONS; // 감정 라벨/이모지 재사용

class FeedbackTab extends StatelessWidget {
  const FeedbackTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetailEmotionVM>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('방문 전 감정 상태'),
        // 방문 전 감정 선택
        Wrap(
          spacing: 8, runSpacing: 8,
          children: EMOTIONS.map((e){
            final on = vm.beforeEmotionId == e.id;
            return ChoiceChip(
              label: Text('${e.emoji} ${e.name}'),
              selected: on,
              onSelected: (_) => vm.setBefore(e.id),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        _sectionTitle('방문 후 어떤 기분이 되고 싶나요?'),
        // 방문 후 감정 선택
        Wrap(
          spacing: 8, runSpacing: 8,
          children: EMOTIONS.map((e){
            final on = vm.afterEmotionId == e.id;
            return ChoiceChip(
              label: Text('${e.emoji} ${e.name}'),
              selected: on,
              onSelected: (_) => vm.setAfter(e.id),
            );
          }).toList(),
        ),

        const Divider(height: 32),

        _sectionTitle('이 공간의 특성을 평가해주세요'),
        // 각 특성 슬라이더 (0~1)
        ...vm.userFeatureRatings.entries.map((e)=>Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SizedBox(width: 100, child: Text(_k2label(e.key))),
              Expanded(
                child: Slider(
                  value: e.value,
                  onChanged: (v) => vm.setFeature(e.key, v),
                  min: 0, max: 1, divisions: 10,
                ),
              ),
              SizedBox(width: 40, child: Text('${(e.value*100).round()}%')),
            ],
          ),
        )),

        const Divider(height: 32),

        _sectionTitle('상세 경험 (선택)'),
        // 자유 텍스트
        TextField(
          minLines: 3, maxLines: 6,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '감정적 경험을 자유롭게 적어주세요',
          ),
          onChanged: vm.setText,
        ),
        const SizedBox(height: 12),

        // 제출 버튼: 방문 전/후 감정이 모두 선택되어야 활성화
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: (vm.beforeEmotionId==null || vm.afterEmotionId==null)
                ? null
                : () async {
                    await vm.submit();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('경험을 공유했어요. 고마워요!')),
                      );
                    }
                  },
            icon: const Icon(Icons.send),
            label: const Text('경험 공유하기'),
          ),
        ),
      ],
    );
  }

  /// 섹션 타이틀 공통 위젯
  Widget _sectionTitle(String s) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(s, style: const TextStyle(fontWeight: FontWeight.w600)),
  );

  /// 내부 키 → 한글 라벨
  String _k2label(String k){
    switch(k){
      case 'sociality': return '사교성';
      case 'spirituality': return '영적 체험';
      case 'adventure': return '모험성';
      case 'culture': return '문화성';
      case 'nature_healing': return '자연치유';
      case 'quiet': return '고요함';
      default: return k;
    }
  }
}
