import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/foryou/presentation/widgets/foryou_curation_sheet.dart';
import 'package:provider/provider.dart';

import '../../domain/entities.dart';
import '../../state/foryou_vm.dart';
import '../widgets/widgets.dart'; // ← 배럴만 임포트

class ForYouScreen extends StatelessWidget {
  const ForYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ForYouVM>();
    final req = (vm.requestListenable as ValueNotifier<RankRequest>).value;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('For You', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 2),
            Text(
              '당신만을 위한 여행 추천',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: RefreshIndicator(
        onRefresh: vm.load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            EmotionInsightCard(
              req: req,
              onRecord: () async {
                final updated = await Navigator.of(context).push<RankRequest>(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => ForYouCurationSheet(initial: req),
                  ),
                );
                if (updated != null) vm.applyRequest(updated);
              },
            ),
            const SizedBox(height: 12),
            PersonalizedCard(
              onTune: () async {
                final updated = await Navigator.of(context).push<RankRequest>(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => ForYouCurationSheet(initial: req),
                  ),
                );
                if (updated != null) vm.applyRequest(updated);
              },
            ),
            const SizedBox(height: 12),
            const ThemeHeroCard(),
            const SizedBox(height: 16),

            const SectionHeader(title: '여행 카테고리'),
            const SizedBox(height: 8),
            if (vm.loading && vm.categories.isEmpty)
              const SkeletonCard(height: 120)
            else if (vm.categories.isEmpty)
              const EmptyBox(text: '카테고리 결과가 없습니다.')
            else
              CategoryGrid(items: vm.categories),

            const SizedBox(height: 16),
            SectionHeader(
              title: '추천 여행지',
              trailing: CountPill(count: vm.places.length), // 선택사항
            ),
            const SizedBox(height: 8),

            if (vm.loading && vm.places.isEmpty)
              const SkeletonList()
            else if (vm.error != null)
              ErrorBox(text: vm.error!, onRetry: vm.load)
            else if (vm.places.isEmpty)
              const EmptyBox(text: '추천 결과가 없습니다.')
            else
              Column(
                children: vm.places.map((p) => PlaceTile(place: p)).toList(),
              ),

            const SizedBox(height: 72),
          ],
        ),
      ),
    );
  }
}

// (선택) 작은 트레일링 뱃지
class CountPill extends StatelessWidget {
  const CountPill({super.key, required this.count});
  final int count;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.05),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text('$count곳', style: const TextStyle(fontSize: 12)),
  );
}
