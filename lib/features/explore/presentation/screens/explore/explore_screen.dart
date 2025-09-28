import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// ── 커서 모드(기존 무한 스크롤)
import 'package:heat_trip_flutter/features/explore/data/remote/place_api.dart';
import 'package:heat_trip_flutter/features/explore/data/remote/place_api_http.dart';
import 'package:heat_trip_flutter/features/explore/presentation/state/explore_scroll_vm.dart';

// UI
import 'package:heat_trip_flutter/features/explore/presentation/widgets/region_select_sheet.dart';
import 'package:heat_trip_flutter/features/explore/presentation/widgets/region_filter_chip.dart';
import 'package:heat_trip_flutter/features/explore/presentation/widgets/place_card/place_card.dart';
import 'widgets/explore_masonry_grid.dart';

// ── 검색 모드(/api/explore/places/search)
import 'package:heat_trip_flutter/features/explore/data_search/explore_search_api.dart';
import 'package:heat_trip_flutter/features/explore/data_search/explore_search_repository.dart';
import 'package:heat_trip_flutter/features/explore/presentation/state/explore_list_vm.dart';

// 모델 변환(검색 PlaceSummary → 카드 PlaceItem)
import 'package:heat_trip_flutter/features/explore/data/models/place_item_dto.dart';
import 'package:heat_trip_flutter/features/explore/data_search/search_models.dart' show PlaceSummary;

// Masonry
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ExploreScreen extends StatefulWidget {
  final ExploreFilters? initialFilters;
  const ExploreScreen({super.key, this.initialFilters});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _searchMode = false;               // true면 /places/search 사용
  Map<String, String> _searchQuery = {};  // 검색 모드에서 사용할 쿼리

  ExploreScrollVM? _vm;
  final ScrollController _scroll = ScrollController();
  late final PlaceApi _api;

  List<String>? _initialCat3List;

  String _selectedRegion = '전체';
  final List<String> _regions = const ['전체', '서울', '경기', '인천', '부산', '제주'];

  // ── AppBar 인라인 검색 상태 (추가)
  bool _typingSearch = false; // true면 타이틀 대신 TextField 표시
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _api = PlaceApiHttp(client: http.Client());

    _scroll.addListener(() {
      if (_searchMode) return; // 검색 모드에선 ExploreListVM이 페이징
      final vm = _vm;
      if (vm == null) return;
      if (_scroll.position.extentAfter < 600) vm.fetchNext();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final qp = context.read<Map<String, String>?>() ?? {};
      final hasCat3 = (qp['cat3']?.trim().isNotEmpty ?? false);
      final hasSearchKey = (qp['q']?.trim().isNotEmpty ?? false) ||
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
    _searchController.dispose(); // 추가
    _searchFocus.dispose();      // 추가
    super.dispose();
  }

  ExploreFilters _composeInitialFilters() {
    if (widget.initialFilters != null) return widget.initialFilters!;
    final qp = context.read<Map<String, String>?>();

    final cat3Csv = qp?['cat3'];
    final cat3ListHint = (cat3Csv == null || cat3Csv.isEmpty)
        ? null
        : cat3Csv.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

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

  // 검색 모드 종료(X)
  void _exitSearch() {
    setState(() {
      _searchMode = false;
      _searchQuery = {};
    });
    if (_vm == null) {
      final filters = _composeInitialFilters();
      _vm = _buildVm(filters: filters);
      _vm!.refresh();
      setState(() {});
    }
    _scroll.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
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

  // ── AppBar 인라인 검색 (추가)
  void _startInlineSearch() {
    setState(() => _typingSearch = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  void _cancelInlineSearch() {
    setState(() {
      _typingSearch = false;
      _searchController.clear();
    });
    _searchFocus.unfocus();
  }

  void _submitInlineSearch(String q) {
    final query = q.trim();
    if (query.isEmpty) return;
    _searchFocus.unfocus();
    setState(() {
      _typingSearch = false;                 // 입력창 닫기
      _searchMode = true;                    // 검색 모드 On
      _searchQuery = {'q': query, 'page': '0', 'size': '20'};
    });
  }

  PreferredSizeWidget _buildAppBar() {
    if (_typingSearch) {
      // 검색 입력 중: 타이틀 대신 TextField
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _cancelInlineSearch,
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: _submitInlineSearch,
          decoration: const InputDecoration(
            hintText: '어디로 떠나세요?',
            border: InputBorder.none,
          ),
          onChanged: (_) => setState(() {}), // Clear 버튼 표시 갱신
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
                setState(() {});
                _searchFocus.requestFocus();
              },
            ),
        ],
      );
    }

    // 평상시 AppBar
    return AppBar(
      title: const Text('Explore'),
      actions: [
        IconButton(icon: const Icon(Icons.search), onPressed: _startInlineSearch),
      ],
    );
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
        child: _SearchListScaffold(onClose: _exitSearch),
      );
    }

    // ── ❷ 커서 모드
    final vm = _vm;
    if (vm == null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return AnimatedBuilder(
      animation: vm,
      builder: (_, __) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(),
          body: SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 8),
                // 지역 칩은 커서 모드에서만 노출
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      RegionFilterChip(
                        label: _selectedRegion,
                        selected: _selectedRegion != '전체',
                        onTap: () { _openRegionSelect(); }, // ← 래핑(반환형 void)
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
// 검색 모드 전용 목록 UI (탐색 탭 UI와 동일하게 Masonry + PlaceCard 사용)
// ─────────────────────────────────────────────
class _SearchListScaffold extends StatefulWidget {
  const _SearchListScaffold({required this.onClose});
  final VoidCallback onClose;

  @override
  State<_SearchListScaffold> createState() => _SearchListScaffoldState();
}

class _SearchListScaffoldState extends State<_SearchListScaffold> {
  final ScrollController _controller = ScrollController();
  _SearchVmAdapter? _gridVm;

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

  @override
  void dispose() {
    _controller.dispose();
    _gridVm?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _gridVm ??= _SearchVmAdapter(context.read<ExploreListVM>());
    final vm = context.watch<ExploreListVM>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('탐색 결과'),
        actions: [
          IconButton(icon: const Icon(Icons.close), onPressed: widget.onClose),
        ],
      ),
      body: Builder(
        builder: (_) {
          if (vm.loading && vm.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.error != null && vm.items.isEmpty) {
            return Center(child: Text('오류: ${vm.error}'));
          }
          if (vm.items.isEmpty) {
            return const Center(child: Text('결과가 없습니다'));
          }

          final adapter = _gridVm!;
          return RefreshIndicator(
            onRefresh: () => context.read<ExploreListVM>().loadInitial(),
            child: _SearchMasonryGrid(
              vmAdapter: adapter,
              scrollController: _controller,
            ),
          );
        },
      ),
    );
  }
}

class _SearchVmAdapter extends ChangeNotifier {
  final ExploreListVM _vm;
  _SearchVmAdapter(this._vm) {
    _vm.addListener(_relay);
  }
  List<dynamic> get items => _vm.items;
  bool get loading => _vm.loading;
  bool get hasNext => _vm.hasNext;
  Future<void> fetchNext() async => _vm.loadMore();
  Future<void> refresh() async => _vm.loadInitial();
  void _relay() => notifyListeners();
  @override
  void dispose() {
    _vm.removeListener(_relay);
    super.dispose();
  }
}

class _SearchMasonryGrid extends StatelessWidget {
  final _SearchVmAdapter vmAdapter;
  final ScrollController scrollController;
  const _SearchMasonryGrid({
    required this.vmAdapter,
    required this.scrollController,
  });

  double _imageHeightFor(PlaceItem p, int index) {
    final seed = (p.contentid * 31 + index * 17) % 6;
    switch (seed) {
      case 0: return 180;
      case 1: return 200;
      case 2: return 220;
      case 3: return 190;
      case 4: return 240;
      default: return 210;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: vmAdapter,
      builder: (_, __) {
        final items = vmAdapter.items;
        return MasonryGridView.count(
          controller: scrollController,
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          itemCount: items.length + (vmAdapter.hasNext ? 2 : 0),
          itemBuilder: (context, index) {
            if (index >= items.length) {
              vmAdapter.fetchNext();
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final item = items[index];
            late final PlaceItem place;
            if (item is PlaceItem) {
              place = item;
            } else if (item is PlaceSummary) {
              place = PlaceItemDto.fromSummary(item);
            } else {
              throw StateError('Unknown item type: ${item.runtimeType}');
            }

            return PlaceCard(
              data: place,
              layout: PlaceCardLayout.vertical,
              showHeart: true,
              categoryLabel: place.cat3Name,
              imageHeight: _imageHeightFor(place, index),
            );
          },
        );
      },
    );
  }
}
