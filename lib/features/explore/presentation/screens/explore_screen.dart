// =============================
// explore_screen.dart — render vertical cards like the 2nd screenshot
// =============================
import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/explore/data/models/place_item_dto.dart';
import 'package:heat_trip_flutter/features/explore/data/remote/place_api.dart';
import 'package:heat_trip_flutter/features/explore/data/remote/place_api_http.dart';
import 'package:heat_trip_flutter/features/explore/presentation/state/explore_scroll_vm.dart';
import 'package:heat_trip_flutter/features/explore/presentation/widgets/place_card.dart';
import 'package:heat_trip_flutter/features/explore/presentation/widgets/region_filter_chip.dart';
import 'package:heat_trip_flutter/features/explore/presentation/widgets/region_select_sheet.dart';
import 'package:http/http.dart' as http;

class ExploreScreen extends StatefulWidget {
  final ExploreFilters? initialFilters;
  const ExploreScreen({super.key, this.initialFilters});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late ExploreScrollVM _vm;
  late TabController _tab;
  final ScrollController _scroll = ScrollController();
  late final PlaceApi _api;

  String _selectedRegion = '전체';
  final List<String> _regions = ['전체', '서울', '경기', '인천', '부산', '제주'];

  @override
  void initState() {
    super.initState();
    _api = PlaceApiHttp(client: http.Client());

    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() {
      if (_tab.indexIsChanging) return; // 중복 호출 방지
      _rebuildVmAndRefresh();
    });

    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 600) {
        _vm.fetchNext();
      }
    });

    _vm = _buildVm(filters: _composeFilters());
    _vm.refresh();
  }

  @override
  void dispose() {
    _tab.dispose();
    _scroll.dispose();
    _vm.dispose();
    super.dispose();
  }

  ExploreFilters _composeFilters() {
    final areaCode = _mapAreaCode(_selectedRegion);
    String? cat1;
    String? cat2;
    String? cat3;
    if (_tab.index == 0) {
      // 관광지
    } else {
      // 축제
    }
    return ExploreFilters(
      areacode: areaCode,
      sigungucode: null,
      cat1: cat1,
      cat2: cat2,
      cat3: cat3,
    );
  }

  void _rebuildVmAndRefresh() {
    final newFilters = _composeFilters();
    _vm.dispose();
    _vm = _buildVm(filters: newFilters);
    _vm.refresh();
    _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    setState(() {});
  }

  ExploreScrollVM _buildVm({required ExploreFilters filters}) {
    return ExploreScrollVM(api: _api, filters: filters, pageSize: 20);
  }

  Future<void> _openRegionSelect() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFFF5ECD7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => RegionSelectSheet(
        title: '지역 선택',
        options: _regions,
        initial: _selectedRegion,
      ),
    );

    if (result != null) {
      setState(() => _selectedRegion = result);
      _rebuildVmAndRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _vm,
      builder: (_, __) {
        return Scaffold(
          backgroundColor: const Color(0xFFF6F6F6),
          appBar: AppBar(
            title: const Text('Explore'),
            bottom: TabBar(
              controller: _tab,
              labelColor: const Color(0xFF346145),
              unselectedLabelColor: Colors.black45,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: const Color(0xFF346145),
              tabs: const [
                Tab(text: '관광지'),
                Tab(text: '축제'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () async {
                  final result = await showSearch<String>(
                    context: context,
                    delegate: _SearchDelegateWithReturn(initialQuery: ''),
                  );
                  if (result != null) {
                    _rebuildVmAndRefresh();
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      RegionFilterChip(
                        label: _selectedRegion,
                        selected: _selectedRegion != '전체',
                        onTap: _openRegionSelect,
                      ),
                      if (_selectedRegion != '전체')
                        RegionFilterChip(
                          label: '초기화',
                          outlined: true,
                          onTap: () {
                            setState(() => _selectedRegion = '전체');
                            _rebuildVmAndRefresh();
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildGridWithPaging(context)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridWithPaging(BuildContext context) {
    if (_vm.error != null && _vm.items.isEmpty) {
      return Center(child: Text('에러: ${_vm.error}'));
    }
    if (_vm.loading && _vm.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_vm.items.isEmpty) {
      return const Center(child: Text('검색 결과가 없습니다.'));
    }

    // 두 번째 스샷의 비율을 위해 세로형 카드 기준으로 조정
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1000 ? 2 : 1; // 태블릿 이상 2열, 모바일 1열
    // ---- 여기부터 동적 카드 비율 계산 ----
    const hPad = 12.0; // Grid padding (좌우)
    const spacing = 12.0; // 카드 간격
    final tileWidth =
        (width - hPad * 2 - spacing * (crossAxisCount - 1)) / crossAxisCount;

    const imageAspect = 16 / 9; // PlaceCard(vertical)의 이미지 비율과 반드시 동일
    const infoHeight = 96.0; // 제목/메타/태그 예상 높이(필요 시 80~120에서 조절)
    final tileHeight = tileWidth / imageAspect + infoHeight;
    final childAspectRatio = tileWidth / tileHeight;
    // ---- 동적 계산 끝 ----
    final itemCount = _vm.items.length + 1; // + sentinel

    return GridView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: childAspectRatio, // ⬅ 여기!
      ),
      itemCount: itemCount,
      itemBuilder: (_, i) {
        if (i < _vm.items.length) {
          final PlaceItem item = _vm.items[i];
          // ▼ 배지/가격/평점/거리/시간은 API가 없으면 생략됩니다(옵션 파라미터)
          return PlaceCard(
            data: item,
            layout: PlaceCardLayout.vertical,
            // categoryLabel: '카페',
            // priceLabel: '\$\$',
            // rating: 4.8,
            // distance: '0.5km',
            // duration: '1-2시간',
            // tags: const ['전통','차분함','문화'],
          );
        }
        if (_vm.loading) return const _GridLoaderCell();
        if (!_vm.hasNext) return const _GridNoMoreCell();
        return const SizedBox.shrink();
      },
    );
  }

  int? _mapAreaCode(String region) {
    switch (region) {
      case '전체':
        return null;
      case '서울':
        return 1;
      case '인천':
        return 2;
      case '부산':
        return 6;
      case '경기':
        return 31;
      case '제주':
        return 39;
      default:
        return null;
    }
  }
}

class _GridLoaderCell extends StatelessWidget {
  const _GridLoaderCell();
  @override
  Widget build(BuildContext context) =>
      const Card(child: Center(child: CircularProgressIndicator()));
}

class _GridNoMoreCell extends StatelessWidget {
  const _GridNoMoreCell();
  @override
  Widget build(BuildContext context) => const Card(
    child: Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('No more results'),
      ),
    ),
  );
}

class _SearchDelegateWithReturn extends SearchDelegate<String> {
  _SearchDelegateWithReturn({String? initialQuery}) {
    query = initialQuery ?? '';
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
    TextButton(onPressed: () => query = '', child: const Text('모두 지우기')),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, query),
  );

  @override
  Widget buildResults(BuildContext context) => _ResultList(query: query);
  @override
  Widget buildSuggestions(BuildContext context) => _ResultList(query: query);
}

class _ResultList extends StatelessWidget {
  final String query;
  const _ResultList({required this.query});

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      '서울',
      '부산',
      '제주',
      '강릉',
    ].where((s) => s.contains(query)).toList();

    if (suggestions.isEmpty) {
      return Center(child: Text('검색어: $query'));
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (_, i) => ListTile(
        title: Text(suggestions[i]),
        onTap: () => Navigator.of(context).pop(suggestions[i]),
      ),
    );
  }
}
