// lib/features/explore/presentation/screens/home/home_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 목록으로 이동할 경로 (프로젝트 라우터와 맞춰 사용)
const String kExploreListPath = '/explore/list';

// ────────────────────────────────────────────────────────────────
// 데이터 모델
class BoardCardData {
  final String id;
  final String title; // 예: 전통 사찰
  final String desc; // 예: 천년고도로 치유 — 길게도 가능, 카드 안 2줄로 제한
  final List<String> preview; // 대표 이미지는 preview.first 사용
  final String themeId; // (현재 스타일엔 사용 X, 추후 확장용)
  final int? contentTypeId;
  final String? query;
  final List<String> cat3List; // 관련 cat3 리스트로 추가하기
  const BoardCardData({
    required this.id,
    required this.title,
    required this.desc,
    required this.preview,
    required this.themeId,
    this.contentTypeId,
    this.query,
    this.cat3List = const [],
  });
}

class BoardSection {
  final String title; // 예: 마음의 치유
  final String subtitle; // 예: 자연과 함께하는 힐링 여행
  final List<BoardCardData> boards;
  const BoardSection({
    required this.title,
    required this.subtitle,
    required this.boards,
  });
}

// 샘플 데이터 (이미지/문구 자유 교체)
const List<BoardSection> kSections = [
  BoardSection(
    title: '마음의 치유',
    subtitle: '자연과 함께하는 힐링 여행',
    boards: [
      BoardCardData(
        id: 'healing-1',
        title: '전통 사찰',
        cat3List: ['A02010800'],
        desc: '천년고도로 치유 — 고즈넉한 숲길과 종소리, 사찰 차 한 잔의 여유를 느껴보세요.',
        preview: [
          'https://images.unsplash.com/photo-1644647926885-fe106de1c4d0?w=1600',
        ],
        themeId: 'healing',
        contentTypeId: 12,
        query: '사찰 명상',
      ),
      BoardCardData(
        id: 'healing-2',
        title: '스파 리조트',
        cat3List: ['A02020300'],
        desc: '따뜻한 온기와 휴식 — 노천탕, 테라피, 조용한 라운지까지 한 번에.',
        preview: [
          'https://images.unsplash.com/photo-1722177189511-aae39a9f5162?w=1600',
        ],
        themeId: 'healing',
        contentTypeId: 12,
        query: '스파',
      ),
      BoardCardData(
        id: 'healing-3',
        title: '산림욕장',
        cat3List: ['A01010400', 'A01010500', 'A01010600'],
        desc: '피톤치드 가득한 숲길에서 호흡을 가다듬고 몸과 마음을 재충전하세요.',
        preview: [
          'https://images.unsplash.com/photo-1723382596965-7d51dc7a348c?w=1600',
        ],
        themeId: 'healing',
        contentTypeId: 12,
        query: '산림욕',
      ),
    ],
  ),
  BoardSection(
    title: '문화 탐방',
    subtitle: '전통과 현대가 만나는 특별한 경험',
    boards: [
      BoardCardData(
        id: 'culture-1',
        title: '미술관',
        cat3List: ['A02060500'],
        desc: '새로운 시선의 전시 — 설치, 사진, 미디어아트를 한 공간에서.',
        preview: [
          'https://images.unsplash.com/photo-1608434904164-c8447262aa0d?w=1600',
        ],
        themeId: 'culture',
        contentTypeId: 12,
        query: '미술관',
      ),
      // BoardCardData(
      //   id: 'culture-2',
      //   title: '한복 체험',
      //   desc: '도심 속 전통 — 골목 산책, 사진 촬영, 찻집까지 연결되는 하루.',
      //   preview: [
      //     'https://images.unsplash.com/photo-1711887540798-9d7d720e5319?w=1600',
      //   ],
      //   themeId: 'culture',
      //   contentTypeId: 12,
      //   query: '한복',
      // ),
      BoardCardData(
        id: 'culture-3',
        title: '고궁 탐방',
        cat3List: ['A02010200', 'A02010300'],
        desc: '시간을 거스르는 산책 — 고즈넉한 전각과 계절별 정원의 풍경.',
        preview: [
          'https://images.unsplash.com/photo-1686232342940-b8c4148c69e4?w=1600',
        ],
        themeId: 'culture',
        contentTypeId: 12,
        query: '고궁',
      ),
    ],
  ),
  BoardSection(
    title: '아늑한 공간',
    subtitle: '따뜻하고 편안한 나만의 시간',
    boards: [
      BoardCardData(
        id: 'cozy-1',
        title: '감성 카페',
        cat3List: ['A05020900'],
        desc: '햇살, LP음악, 수제 디저트 — 머무르는 자체가 여행이 되는 곳.',
        preview: [
          'https://images.unsplash.com/photo-1726763580111-8bb05287de6b?w=1600',
        ],
        themeId: 'cozy',
        contentTypeId: 12,
        query: '카페',
      ),
      BoardCardData(
        id: 'cozy-2',
        title: '서점',
        cat3List: ['A02061000'],
        desc: '취향을 발견하는 서가 — 작은 프로그램과 북토크도 함께.',
        preview: [
          'https://images.unsplash.com/photo-1649520189000-be2b9d14914e?w=1600',
        ],
        themeId: 'cozy',
        contentTypeId: 12,
        query: '서점',
      ),
      BoardCardData(
        id: 'cozy-3',
        title: '가든 테라스',
        cat3List: ['C01130001'],
        desc: '초록과 햇살 — 바람 좋은 오후, 아웃도어 테이블에서 여유를.',
        preview: [
          'https://images.unsplash.com/photo-1727303559695-32ed61cb2fe1?w=1600',
        ],
        themeId: 'cozy',
        contentTypeId: 12,
        query: '테라스',
      ),
    ],
  ),
];

// ────────────────────────────────────────────────────────────────
// 화면
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();

  void _goExplore({Map<String, String>? qp}) {
    context.go(
      Uri(path: kExploreListPath, queryParameters: qp ?? {}).toString(),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              // ── HERO + 검색바 (가독성 유지)
              SliverToBoxAdapter(
                child: _HeroWithSearchBar(
                  imageUrl:
                      'https://images.unsplash.com/photo-1636545550720-ee79a51a958d?w=1600',
                  title: '감정 기반 여행지 추천',
                  subtitle: '당신의 마음에 딱 맞는 특별한 장소를 찾아보세요',
                  searchCtrl: _searchCtrl,
                  searchFocus: _searchFocus,
                  onSubmitted: (q) => _goExplore(qp: {'q': q}),
                  onTapHero: () => _goExplore(qp: {'q': '추천'}),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ── 섹션 (제목/부제 + 가로 카드)
              SliverList.separated(
                itemCount: kSections.length,
                separatorBuilder: (_, __) => const SizedBox(height: 38),
                itemBuilder: (context, idx) {
                  final s = kSections[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _BoardSectionView(
                      section: s,
                      onTapCard: (b) => _goExplore(
                        qp: {
                          'themeId': b.themeId,
                          if (b.contentTypeId != null)
                            'contentTypeId': '${b.contentTypeId}',
                          if (b.query != null) 'q': b.query!,
                          if (b.cat3List.isNotEmpty)
                            'cat3': b.cat3List.join(','), // CSV
                        },
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// HERO + 얇은 검색바
class _HeroWithSearchBar extends StatelessWidget {
  final String imageUrl, title, subtitle;
  final TextEditingController searchCtrl;
  final FocusNode searchFocus;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onTapHero;
  const _HeroWithSearchBar({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.searchCtrl,
    required this.searchFocus,
    required this.onSubmitted,
    required this.onTapHero,
  });

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        InkWell(
          onTap: onTapHero,
          child: Ink(
            height: 260,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        // 하단 가독성 그라디언트
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0, .6),
                end: Alignment(0, -1),
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          ),
        ),
        // 타이틀
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _GlassChip(text: '추천', icon: Icons.auto_awesome),
              SizedBox(height: 8),
              Text(
                '감정 기반 여행지 추천',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6),
              Text(
                '당신의 마음에 딱 맞는 특별한 장소를 찾아보세요',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        // 검색바
        Positioned(
          left: 16,
          right: 16,
          top: paddingTop + 8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.35),
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: searchCtrl,
                  focusNode: searchFocus,
                  textInputAction: TextInputAction.search,
                  onSubmitted: onSubmitted,
                  cursorColor: Colors.white,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: '아이디어 검색',
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    suffixIcon: Icon(Icons.tune, color: Colors.white),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassChip extends StatelessWidget {
  final String text;
  final IconData icon;
  const _GlassChip({required this.text, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// 섹션(제목/부제 + 가로 카드)
//  - 프레임 제거, 이미지 더 크게(폭 280, 비율 3:2)
//  - 텍스트는 이미지 "내부" 하단에 화이트로 오버레이
class _BoardSectionView extends StatelessWidget {
  final BoardSection section;
  final void Function(BoardCardData) onTapCard;
  const _BoardSectionView({required this.section, required this.onTapCard});

  @override
  Widget build(BuildContext context) {
    // 카드 폭/라운드/간격
    const double cardWidth = 300;
    const double radius = 18;
    const double gapX = 12;

    // 대표 이미지 높이(3:2 = 0.666...)
    final double coverH = cardWidth * (2 / 3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 17, // 또는 16
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          section.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.black54),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: coverH, // 카드 총 높이 = 이미지 높이 (텍스트가 내부 오버레이이므로 별도 높이 불필요)
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: section.boards.length,
            separatorBuilder: (_, __) => const SizedBox(width: gapX),
            itemBuilder: (_, i) => _BoardCard(
              data: section.boards[i],
              width: cardWidth,
              radius: radius,
              coverH: coverH,
              onTap: () => onTapCard(section.boards[i]),
            ),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────
// 보드 카드: 대표 이미지 + 하단 텍스트 오버레이(화이트)
//  - 어두운 그라디언트로 가독성 확보
class _BoardCard extends StatelessWidget {
  final BoardCardData data;
  final double width, radius, coverH;
  final VoidCallback onTap;

  const _BoardCard({
    required this.data,
    required this.width,
    required this.radius,
    required this.coverH,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String cover = (data.preview.isNotEmpty)
        ? data.preview.first
        : 'https://picsum.photos/seed/heattrip/1200/800'; // 안전 기본값

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            // 이미지
            SizedBox(
              width: width,
              height: coverH,
              child: Image.network(
                cover,
                fit: BoxFit.cover,
                frameBuilder: (c, child, frame, _) => AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 250),
                  child: child,
                ),
                errorBuilder: (_, __, ___) => Container(color: Colors.black12),
              ),
            ),
            // 어둡게(아래쪽이 더 진하게) — 텍스트 가독성
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0x99000000), // 중간
                      Color(0xCC000000), // 하단 진하게
                    ],
                    stops: [0.45, 0.75, 1.0],
                  ),
                ),
              ),
            ),
            // 텍스트(화이트)
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
