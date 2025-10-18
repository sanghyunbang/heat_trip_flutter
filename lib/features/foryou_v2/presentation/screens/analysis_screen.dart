import 'package:flutter/material.dart';
import '../../domain/models.dart';
import '../../state/foryou_vm.dart';
import '../widgets/common.dart';
import 'list_screen.dart';
import 'map_screen.dart';

/// 분석 결과/테마/카테고리 + 보기/정렬 전환
class AnalysisScreen extends StatelessWidget {
  final ForYouVM vm;
  const AnalysisScreen({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final EmotionAnalysis analysis = vm.analysis!;
    final TravelTheme theme = vm.theme!;
    final cats = vm.categories;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        EmotionInsightCard(
          analysis: analysis,
          moodKey: vm.request.moodKey,
          moodEmoji: vm.request.moodEmoji,
          onEdit: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(height: 8),
        // 추천 테마 카드
        Card(
          elevation: 0.6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: const Text('🌿', style: TextStyle(fontSize: 26)),
            title: Text(
              theme.title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(theme.description),
          ),
        ),
        const SizedBox(height: 12),
        // 보기/정렬
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
        cats.isEmpty
            ? const EmptyBox(text: '카테고리 결과가 없습니다.')
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cats
                    .map(
                      (c) => Chip(
                        label: Text(c.categoryName),
                        backgroundColor: const Color(0xFFFFF3EE),
                        shape: StadiumBorder(
                          side: BorderSide(color: Colors.orange.shade200),
                        ),
                      ),
                    )
                    .toList(),
              ),
        const SizedBox(height: 16),

        // 리스트/지도 패널 스위치
        if (vm.ui.mode == 'list') ...[
          ListScreen(vm: vm),
        ] else ...[
          SizedBox(height: 420, child: MapScreen(vm: vm)), // 추후 SDK로 교체
        ],
        const SizedBox(height: 72),
      ],
    );
  }
}
