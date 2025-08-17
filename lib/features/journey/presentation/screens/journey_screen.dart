import 'package:flutter/material.dart';

/// Journey 피드 화면 (샘플 데이터 버전)
/// - 상단 하이라이트 카드 + 페이지 인디케이터
/// - 아래 리스트형 카드들
/// - 나중에 API 연동 시 [_loadJourney]만 교체하면 됩니다.
class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  // 페이지 인디케이터용 컨트롤러
  final _pageController = PageController(viewportFraction: 1.0);

  // 샘플 데이터 (나중에 API 데이터로 대체)
  late Future<_JourneyFeed> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadJourney(); // ← 최초 로드
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 샘플 데이터를 비동기로 반환
  /// TODO(api): 이 부분만 실제 API 호출로 교체하세요.
  Future<_JourneyFeed> _loadJourney() async {
    await Future<void>.delayed(const Duration(milliseconds: 300)); // 로딩 느낌
    return _JourneyFeed(
      highlights: List.generate(
        3,
            (i) => _JourneyHighlight(
          id: i,
          title: 'Header',
          body:
          "He'll want to use your yacht, and I don't want this thing smelling like fish.",
          timeAgo: '8m ago',
          // imageUrl: 'https://picsum.photos/seed/high$i/1200/800', // 실제 이미지가 있을 때
        ),
      ),
      items: List.generate(
        8,
            (i) => _JourneyItem(
          id: i,
          title: 'Header',
          body:
          "He'll want to use your yacht, and I don't want this thing smelling like fish.",
          timeAgo: '8m ago',
          // thumbUrl: 'https://picsum.photos/seed/item$i/120/120',
        ),
      ),
    );
  }

  // 인디케이터 점 위젯
  Widget _dot(bool active, Color activeColor) {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: active ? activeColor : Colors.black12,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leadingWidth: 56,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFEDEBFE), // 연보라 느낌의 플레이스홀더
            child: Icon(Icons.shield, color: Color(0xFF8B5CF6)),
          ),
        ),
        title: const Text('My Journey', style: TextStyle(color: Colors.black)),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          ),
        ],
      ),
      body: FutureBuilder<_JourneyFeed>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(child: Text('피드를 불러올 수 없어요.'));
          }
          final feed = snap.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- 상단 하이라이트 카드 ----------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _HighlightCard(
                    controller: _pageController,
                    highlights: feed.highlights,
                    indicatorBuilder: (activeIndex, total) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: List.generate(
                          total,
                              (i) => _dot(i == activeIndex, const Color(0xFF4CAF50)), // 초록색 활성 점
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // ---------- 리스트 ----------
                ListView.separated(
                  itemCount: feed.items.length,
                  separatorBuilder: (_, __) => const Padding(
                    padding: EdgeInsets.only(left: 88, right: 16),
                    child: Divider(height: 24),
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i) {
                    final it = feed.items[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 썸네일(라운드 사각)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 56,
                              height: 56,
                              child: it.thumbUrl == null
                                  ? Container(color: const Color(0xFFF1F2F4))
                                  : Image.network(it.thumbUrl!, fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // 텍스트 영역
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 타이틀 + 시간
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Header',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      it.timeAgo,
                                      style: TextStyle(color: Colors.black.withOpacity(0.5)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  it.body,
                                  style: TextStyle(color: Colors.black.withOpacity(0.7)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 상단 하이라이트 카드 (PageView + 인디케이터)
class _HighlightCard extends StatefulWidget {
  final PageController controller;
  final List<_JourneyHighlight> highlights;
  final Widget Function(int activeIndex, int total) indicatorBuilder;

  const _HighlightCard({
    required this.controller,
    required this.highlights,
    required this.indicatorBuilder,
  });

  @override
  State<_HighlightCard> createState() => _HighlightCardState();
}

class _HighlightCardState extends State<_HighlightCard> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      final i = widget.controller.page?.round() ?? 0;
      if (i != _index) setState(() => _index = i);
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.highlights[_index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 이미지(플레이스홀더) 영역
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: PageView.builder(
              controller: widget.controller,
              itemCount: widget.highlights.length,
              itemBuilder: (_, i) {
                final item = widget.highlights[i];
                return item.imageUrl == null
                    ? Container(color: const Color(0xFFF1F2F4))
                    : Image.network(item.imageUrl!, fit: BoxFit.cover);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 텍스트/시간/인디케이터
        Text(
          h.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          h.body,
          style: TextStyle(color: Colors.black.withOpacity(0.7)),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              h.timeAgo,
              style: TextStyle(color: Colors.black.withOpacity(0.5)),
            ),
            const Spacer(),
            widget.indicatorBuilder(_index, widget.highlights.length),
          ],
        ),
      ],
    );
  }
}

/* --------------------------- 샘플 데이터 모델 --------------------------- */

class _JourneyFeed {
  final List<_JourneyHighlight> highlights;
  final List<_JourneyItem> items;
  _JourneyFeed({required this.highlights, required this.items});
}

class _JourneyHighlight {
  final int id;
  final String title;
  final String body;
  final String timeAgo;
  final String? imageUrl; // null이면 플레이스홀더
  _JourneyHighlight({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.imageUrl,
  });
}

class _JourneyItem {
  final int id;
  final String title;
  final String body;
  final String timeAgo;
  final String? thumbUrl; // null이면 플레이스홀더
  _JourneyItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.thumbUrl,
  });
}
