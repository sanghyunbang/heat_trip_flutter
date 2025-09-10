import 'package:flutter/material.dart';
import '../../domain/entities.dart';

class ForYouCurationSheet extends StatefulWidget {
  const ForYouCurationSheet({super.key, required this.initial});
  final RankRequest initial;

  @override
  State<ForYouCurationSheet> createState() => _ForYouCurationSheetState();
}

class _ForYouCurationSheetState extends State<ForYouCurationSheet> {
  late int p, a, d;
  late int energy;
  late double socialNeed;
  late Set<String> goals;

  static const _goalDefs = <(String key, String label)>[
    ('quiet_reflection', '고요/성찰'),
    ('meaning_reflection', '의미/성찰'),
    ('nature_healing', '자연 힐링'),
    ('adventure', '모험/활동'),
    ('culture', '문화/예술'),
    ('social', '교류/연결'),
    ('spiritual', '영성/명상'),
  ];

  @override
  void initState() {
    super.initState();
    p = widget.initial.pad.pleasure;
    a = widget.initial.pad.arousal;
    d = widget.initial.pad.dominance;
    energy = widget.initial.energy;
    socialNeed = widget.initial.socialNeed;
    goals = widget.initial.goals.toSet();
  }

  void _toggleGoal(String k) =>
      setState(() => goals.contains(k) ? goals.remove(k) : goals.add(k));

  Widget _seg5(String title, int value, ValueChanged<int> onChanged) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: List.generate(5, (i) {
          final v = i - 2;
          return ChoiceChip(
            label: Text(v.toString()),
            selected: v == value,
            onSelected: (_) => onChanged(v),
          );
        }),
      ),
    ],
  );

  Widget _seg3(String title, int value, ValueChanged<int> onChanged) {
    const opts = [-1, 0, 1];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: opts
              .map(
                (v) => ChoiceChip(
                  label: Text(v.toString()),
                  selected: v == value,
                  onSelected: (_) => onChanged(v),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final padInset = MediaQuery.viewPaddingOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('감정 인사이트 설정'),
        actions: [
          TextButton(
            onPressed: () {
              final updated = widget.initial.copyWith(
                pad: widget.initial.pad.copyWith(
                  pleasure: p,
                  arousal: a,
                  dominance: d,
                ),
                energy: energy,
                socialNeed: double.parse(socialNeed.toStringAsFixed(1)),
                goals: goals.toList(),
              );
              Navigator.pop(context, updated);
            },
            child: const Text('저장'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + padInset.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _seg5('Pleasure (기분)', p, (v) => setState(() => p = v)),
              const SizedBox(height: 16),
              _seg5('Arousal (각성)', a, (v) => setState(() => a = v)),
              const SizedBox(height: 16),
              _seg5('Dominance (주도감)', d, (v) => setState(() => d = v)),
              const Divider(height: 32),
              _seg3('에너지', energy, (v) => setState(() => energy = v)),
              const SizedBox(height: 16),
              Text(
                '사회성 필요도',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Row(
                children: [
                  const Text('-1'),
                  Expanded(
                    child: Slider(
                      value: socialNeed,
                      min: -1,
                      max: 1,
                      divisions: 4,
                      label: socialNeed.toStringAsFixed(1),
                      onChanged: (v) => setState(
                        () => socialNeed = double.parse(v.toStringAsFixed(1)),
                      ),
                    ),
                  ),
                  const Text('1'),
                ],
              ),
              const Divider(height: 32),
              const Text(
                '여행 목표',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _goalDefs
                    .map(
                      (g) => FilterChip(
                        label: Text(g.$2),
                        selected: goals.contains(g.$1),
                        onSelected: (_) => _toggleGoal(g.$1),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
