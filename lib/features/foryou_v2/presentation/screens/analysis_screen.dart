import 'package:flutter/material.dart';
import '../../domain/models.dart';
import '../../state/foryou_vm.dart';
import '../widgets/common.dart';
import 'list_screen.dart';
import 'map_screen.dart';

class AnalysisScreen extends StatelessWidget {
  final ForYouVM vm;
  const AnalysisScreen({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final LlmMeta llm = vm.llm!;

    // LLM category_groups에서 카테고리 라벨만 모아서 칩으로 노출
    final chips = <String>{
      for (final g in llm.categoryGroups) ...g.categories,
    }.toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        EmotionInsightCard(
          summary: llm.emotionDiagnosis,
          tags: llm.keywords,
          moodKey: vm.request.moodKey,
          moodEmoji: vm.request.moodEmoji,
          onEdit: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(height: 8),

        Card(
          elevation: 0.6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: const Text('🌿', style: TextStyle(fontSize: 26)),
            title: Text(
              llm.themeName,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(llm.themeDescription),
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'list', label: Text('리스트')),
                ButtonSegment(value: 'map', label: Text('지도')),
              ],
              selected: {vm.ui.mode},
              onSelectionChanged: (s) => vm.setMode(s.first),
            ),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: vm.ui.sort,
              items: const [
                DropdownMenuItem(value: 'match', child: Text('매칭률 순')),
                DropdownMenuItem(value: 'distance', child: Text('가까운 순')),
              ],
              onChanged: (v) => v == null ? null : vm.setSort(v),
            ),
          ],
        ),
        const SizedBox(height: 12),

        const SectionHeader(title: '추천 카테고리'),
        const SizedBox(height: 8),
        chips.isEmpty
            ? const EmptyBox(text: '카테고리 결과가 없습니다.')
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chips
                    .map(
                      (c) => Chip(
                        label: Text(c),
                        backgroundColor: const Color(0xFFFFF3EE),
                        shape: StadiumBorder(
                          side: BorderSide(color: Colors.orange.shade200),
                        ),
                      ),
                    )
                    .toList(),
              ),
        const SizedBox(height: 16),

        if (vm.ui.mode == 'list')
          ListScreen(vm: vm)
        else
          SizedBox(height: 420, child: MapScreen(vm: vm)),
        const SizedBox(height: 72),
      ],
    );
  }
}
