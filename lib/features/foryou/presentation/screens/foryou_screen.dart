import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities.dart';
import '../../state/foryou_vm.dart';
import '../widgets/foryou_curation_sheet.dart';

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
            // 인사이트 카드
            _EmotionInsightCard(
              req: req,
              onRecord: () async {
                final updated = await Navigator.of(context).push<RankRequest>(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => ForYouCurationSheet(initial: req),
                  ),
                );
                if (updated != null) {
                  vm.applyRequest(updated); // 서버 재호출
                }
              },
            ),
            const SizedBox(height: 12),
            _PersonalizedCard(
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
            const _ThemeHeroCard(),
            const SizedBox(height: 16),

            const _SectionHeader(title: '여행 카테고리'),
            const SizedBox(height: 8),
            if (vm.loading && vm.categories.isEmpty)
              const _SkeletonCard(height: 120)
            else if (vm.categories.isEmpty)
              const _EmptyBox(text: '카테고리 결과가 없습니다.')
            else
              _CategoryGrid(items: vm.categories),

            const SizedBox(height: 16),
            _SectionHeader(
              title: '추천 여행지',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${vm.places.length}곳',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),

            if (vm.loading && vm.places.isEmpty)
              const _SkeletonList()
            else if (vm.error != null)
              _ErrorBox(text: vm.error!, onRetry: vm.load)
            else if (vm.places.isEmpty)
              const _EmptyBox(text: '추천 결과가 없습니다.')
            else
              Column(
                children: vm.places.map((p) => _PlaceTile(place: p)).toList(),
              ),

            const SizedBox(height: 72),
          ],
        ),
      ),
    );
  }
}

// ===== 아래는 화면 내부 위젯(기존 스타일 유지) =====

class _EmotionInsightCard extends StatelessWidget {
  const _EmotionInsightCard({required this.req, required this.onRecord});
  final RankRequest req;
  final VoidCallback onRecord;

  String _goalLabel(List<String> goals) {
    if (goals.isEmpty) return '—';
    return goals
        .map((g) {
          switch (g) {
            case 'relaxation':
              return '진정';
            case 'mood-enhancement':
              return '기분상향';
            case 'immersion':
              return '몰입';
            case 'social-connection':
              return '연결';
            case 'perspective-shift':
              return '관점전환';
            case 'meaning_reflection':
            case 'meaning-reflection':
              return '의미/성찰';
            case 'quiet_reflection':
            case 'quiet-reflection':
              return '고요/성찰';
            default:
              return g;
          }
        })
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      color: const Color(0xFFEDEAFF),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(Icons.psychology_alt_rounded, color: Color(0xFF6B5BFF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '감정 인사이트',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Chip('P ${req.pad.pleasure}'),
                    _Chip('A ${req.pad.arousal}'),
                    _Chip('D ${req.pad.dominance}'),
                    _Chip('에너지 ${req.energy}'),
                    _Chip('사회성 ${req.socialNeed}'),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '목표: ${_goalLabel(req.goals)}',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: onRecord,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6B5BFF),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('수정'),
          ),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.items});
  final List<CategoryScore> items;
  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items.map((c) => _CategoryTile(c)).toList(),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () {}, child: const Text('전체 보기')),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile(this.c);
  final CategoryScore c;
  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2 - 6;
    return InkWell(
      onTap: () {
        /* TODO: 상세 */
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6FA),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(
              c.emoji.isNotEmpty ? c.emoji : '🧭',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                c.categoryName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              '${(c.score * 100).round()}%',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonalizedCard extends StatelessWidget {
  const _PersonalizedCard({required this.onTune});
  final VoidCallback onTune;
  @override
  Widget build(BuildContext context) {
    return _CardShell(
      color: const Color(0xFFE8FFF1),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(Icons.auto_awesome, color: Color(0xFF00B86B)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '감정 기반 추천',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  '분석 결과에 따른 맞춤 여행지',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
                SizedBox(height: 8),
                Text(
                  '감정 분석을 통해 개인화된 여행지를 추천해드립니다.',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.tonalIcon(
            onPressed: onTune,
            icon: const Icon(Icons.tune),
            label: const Text('맞춤'),
          ),
        ],
      ),
    );
  }
}

class _ThemeHeroCard extends StatelessWidget {
  const _ThemeHeroCard();
  @override
  Widget build(BuildContext context) {
    const img =
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1600&q=80';
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              img,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF222),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.white54,
                  size: 48,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.05), Colors.black54],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          const Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '마음의 치유',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '고요함을 찾는 여행',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const Positioned(
            right: 16,
            bottom: 16,
            child: FilledButton(onPressed: null, child: Text('테마 여행지 보기')),
          ),
        ],
      ),
    );
  }
}

class _PlaceTile extends StatelessWidget {
  const _PlaceTile({required this.place});
  final RankedPlace place;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://picsum.photos/seed/${place.placeId}/160/120',
              width: 88,
              height: 66,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  place.cat3Code,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _Badge(text: '적합도 ${(place.traitMatch * 100).round()}%'),
                    const SizedBox(width: 6),
                    _Badge(text: '인기도 ${(place.popularity * 100).round()}%'),
                  ],
                ),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
        ],
      ),
    );
  }
}

// small bits
class _Chip extends StatelessWidget {
  const _Chip(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.06),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(text, style: const TextStyle(fontSize: 11)),
  );
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.06),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(text, style: const TextStyle(fontSize: 11)),
  );
}

class _CardShell extends StatelessWidget {
  const _CardShell({super.key, this.color, required this.child});
  final Color? color;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: child,
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});
  final String title;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
      const Spacer(),
      if (trailing != null) trailing!,
    ],
  );
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();
  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(
      6,
      (_) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({this.height = 120});
  final double height;
  @override
  Widget build(BuildContext context) => Container(
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
  );
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.text, required this.onRetry});
  final String text;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.red.shade200),
    ),
    child: Row(
      children: [
        Icon(Icons.error_outline, color: Colors.red.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(color: Colors.red.shade800)),
        ),
        TextButton(onPressed: onRetry, child: const Text('다시 시도')),
      ],
    ),
  );
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    height: 64,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.black54, fontSize: 13),
    ),
  );
}
