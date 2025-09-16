import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// ── 커서 모드(기존 무한 스크롤)
import 'package:heat_trip_flutter/features/explore/data/remote/place_api.dart';
import 'package:heat_trip_flutter/features/explore/data/remote/place_api_http.dart';
import 'package:heat_trip_flutter/features/explore/presentation/state/explore_scroll_vm.dart';

// UI
import 'package:heat_trip_flutter/features/explore/presentation/widgets/region_select_sheet.dart';
import 'package:heat_trip_flutter/features/explore/presentation/widgets/region_filter_chip.dart';
import 'widgets/explore_masonry_grid.dart';
import 'widgets/search_delegate.dart';

// ── 검색 모드(/api/explore/places/search)
import 'package:heat_trip_flutter/features/explore/data_search/explore_search_api.dart';
import 'package:heat_trip_flutter/features/explore/data_search/explore_search_repository.dart';
import 'package:heat_trip_flutter/features/explore/presentation/state/explore_list_vm.dart';

import 'package:cached_network_image/cached_network_image.dart';

class ExploreScreen extends StatefulWidget {
  final ExploreFilters? initialFilters;
  const ExploreScreen({super.key, this.initialFilters});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // ─────────────────────────────────────────────
  // 모드
  // ─────────────────────────────────────────────
  bool _searchMode = false;             // true면 /places/search 사용
  Map<String, String> _searchQuery = {}; // 검색 모드에서 사용할 쿼리(q, page, size, sort …)

  // ─────────────────────────────────────────────
  // 커서 스크롤(추천/탐색)
  // ─────────────────────────────────────────────
  ExploreScrollVM? _vm;
  final ScrollController _scroll = ScrollController();
  late final PlaceApi _api;

  // 홈에서 준 cat3를 지역 전환 시에도 계속 유지
  List<String>? _initialCat3List;

  // 지역
  String _selectedRegion = '전체';
  final List<String> _regions = const ['전체', '서울', '경기', '인천', '부산', '제주'];

  @override
  void initState() {
    super.initState();

    _api = PlaceApiHttp(client: http.Client());

    _scroll.addListener(() {
      if (_searchMode) return; // 검색 모드에선 무한 스크롤 주체가 다름(ExploreListVM)
      final vm = _vm;
      if (vm == null) return;
      if (_scroll.position.extentAfter < 600) vm.fetchNext();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // 라우터가 준 쿼리(Provider<Map<String,String>>.value)
      final qp = context.read<Map<String, String>?>() ?? {};

      // 규칙:
      // - cat3 가 있으면 → 커서 모드(추천/탐색) 유지
      // - cat3 가 없고 q/emotionCategoryId 가 있으면 → 검색 모드
      final hasCat3 = (qp['cat3']?.trim().isNotEmpty ?? false);
      final hasSearchKey =
          (qp['q']?.trim().isNotEmpty ?? false) ||
          (qp['emotionCategoryId']?.trim().isNotEmpty ?? false);

      if (!hasCat3 && hasSearchKey) {
        _searchMode = true;
        _searchQuery = {
          if (qp['q'] != null) 'q': qp['q']!.trim(),
          if (qp['contentTypeId'] != null) 'contentTypeId': qp['contentTypeId']!,
          if (qp['emotionCategoryId'] != null) 'emotionCategoryId': qp['emotionCategoryId']!,
          'page': qp['page'] ?? '0',
          'size': qp['size'] ?? '20',
          if (qp['sort'] != null) 'sort': qp['sort']!,
        };
        setState(() {});
        return;
      }

      // 커서 모드 초기화
      final filters = _composeInitialFilters();
      _vm = _buildVm(filters: filters);
      _vm!.refresh();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _vm?.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // 커서 모드: 초기 필터
  // ─────────────────────────────────────────────
  ExploreFilters _composeInitialFilters() {
    if (widget.initialFilters != null) return widget.initialFilters!;

    final qp = context.read<Map<String, String>?>();

    // cat3 CSV → List<String>
    final cat3Csv = qp?['cat3'];
    final cat3ListHint = (cat3Csv == null || cat3Csv.isEmpty)
        ? null
        : cat3Csv
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

    _initialCat3List ??= cat3ListHint;

    return _composeFilters(cat3ListHint: _initialCat3List);
  }

  ExploreFilters _composeFilters({List<String>? cat3ListHint}) {
    final areaCode = _mapAreaCode(_selectedRegion);
    return ExploreFilters(
      areacode: areaCode,
      sigungucode: null,
      cat1: null,
      cat2: null,
      cat3: null,
      cat3List: cat3ListHint,
    );
  }

  ExploreScrollVM _buildVm({required ExploreFilters filters}) {
    return ExploreScrollVM(api: _api, filters: filters, pageSize: 20);
  }

  void _rebuildVmAndRefresh() {
    final newFilters = _composeFilters(cat3ListHint: _initialCat3List);
    _vm?.dispose();
    _vm = _buildVm(filters: newFilters);
    _vm!.refresh();
    _scroll.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    setState(() {});
  }

  // 지역 선택
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
      if (!_searchMode) _rebuildVmAndRefresh();
    }
  }

  // 돋보기 검색 → 검색 모드로 전환
  Future<void> _openSearch() async {
    final q = await showSearch<String>(
      context: context,
      delegate: SearchDelegateWithReturn(initialQuery: ''),
    );
    if (q == null || q.trim().isEmpty) return;
    setState(() {
      _searchMode = true;
      _searchQuery = {'q': q.trim(), 'page': '0', 'size': '20'};
    });
  }

  @override
  Widget build(BuildContext context) {
    // ── ❶ 검색 모드
    if (_searchMode) {
      return MultiProvider(
        providers: [
          Provider(create: (_) => ExploreSearchApi()),
          ProxyProvider<ExploreSearchApi, ExploreSearchRepository>(
            update: (_, api, __) => ExploreSearchRepository(api),
          ),
          ChangeNotifierProvider(
            create: (ctx) => ExploreListVM(
              ctx.read<ExploreSearchRepository>(),
              initialQuery: _searchQuery,
            )..loadInitial(),
          ),
        ],
        child: const _SearchListScaffold(),
      );
    }

    // ── ❷ 커서 모드
    final vm = _vm;
    if (vm == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Explore'),
          actions: [IconButton(icon: const Icon(Icons.search), onPressed: _openSearch)],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return AnimatedBuilder(
      animation: vm,
      builder: (_, __) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Explore'),
            actions: [IconButton(icon: const Icon(Icons.search), onPressed: _openSearch)],
          ),
          body: SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      RegionFilterChip(
                        label: _selectedRegion,
                        selected: _selectedRegion != '전체',
                        onTap: _openRegionSelect,
                      ),
                      const Spacer(),
                      if (_selectedRegion != '전체')
                        TextButton(
                          onPressed: () {
                            setState(() => _selectedRegion = '전체');
                            _rebuildVmAndRefresh();
                          },
                          child: const Text('초기화'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(child: ExploreMasonryGrid(vm: vm, scrollController: _scroll)),
              ],
            ),
          ),
        );
      },
    );
  }

  int? _mapAreaCode(String region) {
    switch (region) {
      case '전체': return null;
      case '서울': return 1;
      case '인천': return 2;
      case '부산': return 6;
      case '경기': return 31;
      case '제주': return 39;
      default: return null;
    }
  }
}

// ─────────────────────────────────────────────
// 검색 모드 전용 목록 UI
// ─────────────────────────────────────────────
class _SearchListScaffold extends StatefulWidget {
  const _SearchListScaffold();

  @override
  State<_SearchListScaffold> createState() => _SearchListScaffoldState();
}

class _SearchListScaffoldState extends State<_SearchListScaffold> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final vm = context.read<ExploreListVM>();
      if (!vm.loading &&
          vm.hasNext &&
          _controller.position.pixels >= _controller.position.maxScrollExtent - 300) {
        vm.loadMore();
      }
    });
  }
  // ✅ 플레이스홀더 (그대로 사용)
  Widget _placeholderThumb({double w = 56, double h = 56}) => Container(
    width: w, height: h,
    color: const Color(0xFFE5E7EB),
    alignment: Alignment.center,
    child: const Icon(Icons.photo, size: 20, color: Color(0xFF9CA3AF)),
  );

  // ✅ URL 정규화: 앞뒤 공백, 프로토콜 누락(//...), 잘못된 한 슬래시(http:/) 보정
  String _normalizeUrl(String raw) {
    var s = raw.trim();
    if (s.startsWith('//')) s = 'https:$s';
    if (s.startsWith('http:/') && !s.startsWith('http://')) {
      s = s.replaceFirst('http:/', 'http://');
    }
    if (s.startsWith('https:/') && !s.startsWith('https://')) {
      s = s.replaceFirst('https:/', 'https://');
    }
    return s;
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExploreListVM>();
    final items = vm.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('탐색 결과'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
      body: Builder(
        builder: (_) {
          if (vm.loading && items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.error != null && items.isEmpty) {
            return Center(child: Text('오류: ${vm.error}'));
          }
          if (items.isEmpty) {
            return const Center(child: Text('결과가 없습니다'));
          }
          return RefreshIndicator(
            onRefresh: () => context.read<ExploreListVM>().loadInitial(),
            child: ListView.builder(
              controller: _controller,
              itemCount: items.length + (vm.hasNext ? 1 : 0),
              itemBuilder: (_, i) {
                if (i >= items.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final p = items[i];
                final image = p.firstimage ?? p.firstimage2;
                return ListTile(
                  leading: (image != null &&
            (image.startsWith('http://') || image.startsWith('https://')))
                      ?  ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(image, width: 56, height: 56, fit: BoxFit.cover),
                        ) : const Icon(Icons.image_not_supported),
                  title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    [
                      if (p.cat3Name != null) p.cat3Name,
                      if (p.addr1 != null) p.addr1,
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    context.push('/explore/${p.contentid}/${p.contentTypeId ?? 12}');
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
