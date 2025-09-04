// 감정 기록(8개 + energy/social). 모달이 아닌 "풀스크린" 페이지.
import 'package:flutter/material.dart';
import '../../domain/entities/diagnosis.dart';

class EmotionPage extends StatefulWidget {
  const EmotionPage({super.key});
  @override
  State<EmotionPage> createState() => _EmotionPageState();
}

class _EmotionPageState extends State<EmotionPage> {
  String? mood; // 'HAPPY' 등
  double energy = 5; // 0~10
  double social = 5; // 0~10

  @override
  Widget build(BuildContext context) {
    final moods = [
      ('HAPPY', '😊', '기쁨'),
      ('CALM', '😌', '평온'),
      ('CURIOUS', '🤔', '호기심'),
      ('PROUD', '🕶️', '뿌듯'),
      ('ANXIOUS', '😰', '불안'),
      ('ANGRY', '😠', '화남'),
      ('SAD', '😢', '슬픔'),
      ('TIRED', '🥱', '피곤'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('감정 기록하기')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('지금 기분은 어떤가요?', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),

          // TSX와 유사한 2열 넓은 그리드(버튼 느낌)
          GridView.builder(
            itemCount: moods.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3.3,
            ),
            itemBuilder: (_, i) {
              final (id, emoji, label) = moods[i];
              final sel = mood == id;
              return GestureDetector(
                onTap: () => setState(() => mood = id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sel
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                    ),
                    color: sel
                        ? Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withOpacity(.35)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(label, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),
          _slider(
            '에너지 레벨',
            '낮음',
            '높음',
            (v) => setState(() => energy = v),
            energy,
          ),
          const SizedBox(height: 12),
          _slider(
            '소셜 니즈',
            '혼자',
            '함께',
            (v) => setState(() => social = v),
            social,
          ),
          const SizedBox(height: 24),

          FilledButton(
            onPressed: mood == null
                ? null
                : () {
                    final result = Diagnosis(
                      mood: mood!,
                      energy: energy.round(),
                      social: social.round(),
                    );
                    Navigator.of(context).pop(result);
                  },
            child: const Text('저장하기'),
          ),
        ],
      ),
    );
  }

  Widget _slider(
    String title,
    String left,
    String right,
    ValueChanged<double> onChanged,
    double value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title),
            const Spacer(),
            Text(
              '${value.round()}/10',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        Row(
          children: [
            Text(left, style: Theme.of(context).textTheme.bodySmall),
            Expanded(
              child: Slider(
                value: value,
                min: 0,
                max: 10,
                divisions: 10,
                onChanged: onChanged,
              ),
            ),
            Text(right, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}
