import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/foryou/presentation/widget/category_grid.dart';
import 'package:heat_trip_flutter/features/foryou/presentation/widget/emotion_page.dart';
import 'package:heat_trip_flutter/features/foryou/presentation/widget/insight_card.dart';
import 'package:heat_trip_flutter/features/foryou/presentation/widget/local_destination_card.dart';
import 'package:heat_trip_flutter/features/foryou/presentation/widget/mood_recommend_card.dart';
import 'package:heat_trip_flutter/features/foryou/presentation/widget/popular_content_list.dart';
import 'package:heat_trip_flutter/features/foryou/presentation/widget/recent_interest_carousel.dart';
import 'package:heat_trip_flutter/features/foryou/presentation/widget/theme_card.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/context.dart' as dom;
import '../states/foryou_vm.dart';
import 'detail_page.dart';

class ForYouScreen extends StatefulWidget {
  final dom.Context contextModel;
  final int k;
  const ForYouScreen({super.key, required this.contextModel, this.k = 8});

  @override
  State<ForYouScreen> createState() => _ForYouScreenState();
}

class _ForYouScreenState extends State<ForYouScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ForYouVM>().load(widget.contextModel, widget.k);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ForYouVM>();
    final list = vm.items;

    final moodEmoji = switch (vm.diagnosis?.mood) {
      'CURIOUS' => '🤔',
      'CALM' => '😌',
      'HAPPY' => '😊',
      'PROUD' => '🕶️',
      'TIRED' => '🥱',
      'ANXIOUS' => '😰',
      'ANGRY' => '😠',
      'SAD' => '😢',
      _ => null,
    };

    // ── 카테고리 2열 카드 데이터(샘플 숫자는 TSX처럼 감성만 맞춤)
    final cats = [
      CategoryTileData(
        id: 'nature',
        labelKo: '자연',
        count: 45,
        icon: Icons.terrain,
        color: Colors.green,
      ),
      CategoryTileData(
        id: 'city',
        labelKo: '도시',
        count: 32,
        icon: Icons.location_city,
        color: Colors.blue,
      ),
      CategoryTileData(
        id: 'coastal',
        labelKo: '해안',
        count: 28,
        icon: Icons.waves,
        color: Colors.cyan,
      ),
      CategoryTileData(
        id: 'cultural',
        labelKo: '문화',
        count: 38,
        icon: Icons.camera_alt_outlined,
        color: Colors.deepPurple,
      ),
      CategoryTileData(
        id: 'cafe',
        labelKo: '카페',
        count: 52,
        icon: Icons.local_cafe_outlined,
        color: Colors.orange,
      ),
      CategoryTileData(
        id: 'healing',
        labelKo: '힐링',
        count: 29,
        icon: Icons.favorite_outline,
        color: Colors.pink,
      ),
    ];

    // 인기 콘텐츠(샘플)
    final popular = const [
      PopularContent('제주도 숨은 카페 10곳', 1278),
      PopularContent('부산 핫플레이스 완전정복', 1321),
      PopularContent('서울 감성 여행 코스', 548),
    ];

    // 최근 관심(간단히 추천 상위 4개 사용)
    final recent = list.take(4).toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverList.list(
                children: [
                  Text(
                    'For You',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '당신만을 위한 여행 추천',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // 인사이트 카드
                  InsightCard(
                    onRecord: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const EmotionPage()),
                      );
                      if (result != null && mounted) {
                        vm.setDiagnosis(result);
                        final ctx = dom.Context(
                          energy: result.energy,
                          social: result.social,
                          location: widget.contextModel.location,
                        );
                        vm.load(ctx, widget.k);
                      }
                    },
                    moodEmoji: moodEmoji,
                    energy: vm.diagnosis?.energy,
                    social: vm.diagnosis?.social,
                  ),
                  const SizedBox(height: 12),

                  const MoodRecommendCard(),
                  const SizedBox(height: 12),

                  // ▼ 배너(이미지 안전 처리됨)
                  ThemeCard(
                    title: '마음의 치유',
                    subtitle: '고요함을 찾는 힐링 여행',
                    // 의도한 1차 URL (깨지면 자동으로 폴백)
                    primaryImageUrl:
                        'https://images.unsplash.com/photo-1536589961740-7f8f4f4f7f52?auto=format&fit=crop&w=1600&q=80',
                    onTap: () {},
                  ),

                  const SizedBox(height: 16),

                  // ▼ 여행 카테고리(2열 그리드)
                  CategoryGrid(
                    items: cats,
                    onSeeAll: () {}, // TODO: 전체 보기로 이동
                    onTap: (id) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CategoryDetailPage(
                            category: id,
                            contextModel: widget.contextModel,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ▼ 추천 여행지 섹션
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text(
                      '추천 여행지',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Text(
                      '${list.length}곳',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              sliver: vm.loading
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  : SliverList.separated(
                      itemCount: list.length,
                      itemBuilder: (_, i) => LocalDestinationCard(d: list[i]),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                    ),
            ),

            // ▼ 인기 여행 콘텐츠
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: SliverToBoxAdapter(
                child: PopularContentList(items: popular),
              ),
            ),

            // ▼ 최근 관심 여행지
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              sliver: SliverToBoxAdapter(
                child: RecentInterestCarousel(
                  items: recent,
                  onSeeAll: () {}, // TODO: 전체보기
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
