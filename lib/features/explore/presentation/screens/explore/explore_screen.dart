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
                  leading: (image == null)
                      ? const Icon(Icons.image_not_supported)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(image, width: 56, height: 56, fit: BoxFit.cover),
                        ),
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



// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';

// import 'package:heat_trip_flutter/features/explore/data/remote/place_api.dart';
// import 'package:heat_trip_flutter/features/explore/data/remote/place_api_http.dart';
// import 'package:heat_trip_flutter/features/explore/presentation/state/explore_scroll_vm.dart';

// // 기존 필터 UI
// import 'package:heat_trip_flutter/features/explore/presentation/widgets/region_select_sheet.dart';
// import 'package:heat_trip_flutter/features/explore/presentation/widgets/region_filter_chip.dart';

// // 새로 분리된 컴포넌트
// import 'widgets/explore_app_bar.dart';
// import 'widgets/explore_filters_bar.dart';
// import 'widgets/explore_masonry_grid.dart';
// import 'widgets/search_delegate.dart';

// class ExploreScreen extends StatefulWidget {
//   final ExploreFilters? initialFilters;
//   const ExploreScreen({super.key, this.initialFilters});

//   @override
//   State<ExploreScreen> createState() => _ExploreScreenState();
// }

// class _ExploreScreenState extends State<ExploreScreen>
//     with SingleTickerProviderStateMixin {
//   // ────────────────────────────────────────────────────────────────
//   // 핵심 상태/의존
//   // ────────────────────────────────────────────────────────────────
//   ExploreScrollVM? _vm; // nullable로 두고 준비되면 설정
//   late TabController _tab; // '관광지' / '축제'
//   final ScrollController _scroll = ScrollController();
//   late final PlaceApi _api; // API 인터페이스

//   List<String>? _initialCat3List; // 지역탭 바꿔도 cat3 필터가 유지될 수 있게

//   // ────────────────────────────────────────────────────────────────
//   // 필터 상태
//   // ────────────────────────────────────────────────────────────────
//   String _selectedRegion = '전체';
//   final List<String> _regions = const ['전체', '서울', '경기', '인천', '부산', '제주'];

//   // ────────────────────────────────────────────────────────────────
//   // 라이프사이클
//   // ────────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();

//     _api = PlaceApiHttp(client: http.Client());
//     _tab = TabController(length: 2, vsync: this); // 상단 관광지, 축제 관련 탭

//     _tab.addListener(() {
//       if (_tab.indexIsChanging) return;
//       _rebuildVmAndRefresh(); // [D]
//     });

//     _scroll.addListener(() {
//       final vm = _vm;
//       if (vm == null) return;
//       if (_scroll.position.extentAfter < 600) {
//         vm.fetchNext();
//       }
//     });

//     // [A] 초기 VM 생성/로드는 프레임 이후에 수행(빌드 중 notify 방지).
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//       final filters = _composeInitialFilters(); // [B][C]
//       _vm = _buildVm(filters: filters);
//       _vm!.refresh();
//       setState(() {}); // AnimatedBuilder 없이 첫 그림을 띄우기 위함
//     });
//   }

//   @override
//   void dispose() {
//     _tab.dispose();
//     _scroll.dispose();
//     _vm?.dispose();
//     super.dispose();
//   }

//   // ────────────────────────────────────────────────────────────────
//   // 초기 필터 구성: initialFilters > Provider(queryParameters)
//   // ────────────────────────────────────────────────────────────────
//   ExploreFilters _composeInitialFilters() {
//     // [C] 위젯 인자로 명시적 필터가 있으면 그것을 우선.
//     if (widget.initialFilters != null) {
//       return widget.initialFilters!;
//     }

//     // [B] routes에서 Provider<Map<String,String>>로 감싼 쿼리 파라미터 읽기.
//     final Map<String, String>? qp = context.read<Map<String, String>?>();
//     final themeId = qp?['themeId'];
//     final q = qp?['q'];
//     final ctid = int.tryParse(qp?['contentTypeId'] ?? '');

//     // CSV -> List<String> 파싱
//     final cat3Csv = qp?['cat3'];
//     final List<String>? cat3ListHint = (cat3Csv == null || cat3Csv.isEmpty)
//         ? null
//         : cat3Csv
//         .split(',')
//         .map((s) => s.trim())
//         .where((s) => s.isNotEmpty)
//         .toList();

//     // 원하면 “초기값으로” 보관 (탭/지역 바뀌어도 유지하려면 사용)
//     _initialCat3List ??= cat3ListHint;

//     // 여기서는 탭/지역도 반영해서 일관된 ExploreFilters로 만든다.
//     return _composeFilters(
//       themeIdHint: themeId,
//       keywordHint: q,
//       contentTypeIdHint: ctid,
//       cat3ListHint: _initialCat3List,
//     );
//   }

//   // 현재 선택된 탭/지역 + (선택적으로) 홈에서 온 hint를 조합해 서버 필터를 만든다.
//   ExploreFilters _composeFilters({
//     String? themeIdHint,
//     String? keywordHint,
//     int? contentTypeIdHint,
//     List<String>? cat3ListHint,
//   }) {
//     final areaCode = _mapAreaCode(_selectedRegion);

//     String? cat1; // 대분류
//     String? cat2; // 중분류
//     String? cat3; // 소분류

//     // 외부에서 온 cat3List가 있다면 그것을 우선 적용
//     final List<String>? cat3List = cat3ListHint;

//     if (_tab.index == 0) {
//       // 관광지
//       // TODO: 카테고리 코드 매핑 (예: cat1 = 'A01')
//     } else {
//       // 축제
//       // TODO: 카테고리 코드 매핑 (예: cat1 = 'A02')
//     }

//     // ExploreFilters는 기존 프로젝트의 타입을 그대로 사용.
//     // 필요시 생성자에 themeId/keyword/contentTypeId 같은 필드를 추가하세요.
//     return ExploreFilters(
//       areacode: areaCode,
//       sigungucode: null,
//       cat1: cat1,
//       cat2: cat2,
//       cat3: cat3,
//       cat3List: cat3List,
//       // ↓ 아래 3개는 프로젝트 정의에 맞게 반영(예시는 주석)
//       // themeId: themeIdHint,
//       // keyword: keywordHint,
//       // contentTypeId: contentTypeIdHint,
//     );
//   }

//   // VM 팩토리
//   ExploreScrollVM _buildVm({required ExploreFilters filters}) {
//     return ExploreScrollVM(api: _api, filters: filters, pageSize: 20);
//   }

//   // VM 재생성 + 새로고침 (탭/지역/검색 등 필터 바뀔 때 공통 루틴)
//   void _rebuildVmAndRefresh() {
//     final newFilters = _composeFilters(
//       cat3ListHint: _initialCat3List, // 유지 => 탭 지역 바뀌어도 계속 동일 cat3
//     );
//     _vm?.dispose();
//     _vm = _buildVm(filters: newFilters);
//     _vm!.refresh();

//     _scroll.animateTo(
//       0,
//       duration: const Duration(milliseconds: 250),
//       curve: Curves.easeOut,
//     );

//     setState(() {}); // 상단 탭 텍스트/필터 표시 갱신
//   }

//   // 지역 선택 바텀시트
//   Future<void> _openRegionSelect() async {
//     final result = await showModalBottomSheet<String>(
//       context: context,
//       backgroundColor: const Color(0xFFF5ECD7),
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
//       ),
//       builder: (_) => RegionSelectSheet(
//         title: '지역 선택',
//         options: _regions,
//         initial: _selectedRegion,
//       ),
//     );

//     if (result != null) {
//       setState(() => _selectedRegion = result);
//       _rebuildVmAndRefresh();
//     }
//   }

//   // SearchDelegate 호출
//   Future<void> _openSearch() async {
//     final result = await showSearch<String>(
//       context: context,
//       delegate: SearchDelegateWithReturn(initialQuery: ''),
//     );
//     if (result != null) {
//       // TODO: 검색어를 ExploreFilters에 반영 (프로젝트 필드에 맞춰 적용)
//       _rebuildVmAndRefresh();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final vm = _vm;

//     // [A-보강] 아직 VM 준비 전이면 간단한 프레임홀더 표시
//     if (vm == null) {
//       return Scaffold(
//         appBar: ExploreAppBar(tabController: _tab, onPressSearch: _openSearch),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     // VM이 준비된 이후에는 AnimatedBuilder로 감싼다.
//     return AnimatedBuilder(
//       animation: vm, // ChangeNotifier를 관찰 → 상태 변화 시 리빌드
//       builder: (_, __) {
//         return Scaffold(
//           backgroundColor: Colors.white,
//           body: SafeArea( // [E] 상단 status bar 영역만큼 확보
//             top: true,
//             bottom: false,
//             child: Column(
//               children: [
//                 const SizedBox(height: 8),
//                 ExploreFiltersBar(
//                   selectedRegion: _selectedRegion,
//                   showReset: _selectedRegion != '전체',
//                   onTapRegion: _openRegionSelect,
//                   onReset: () {
//                     setState(() => _selectedRegion = '전체');
//                     _rebuildVmAndRefresh();
//                   },
//                 ),
//                 const SizedBox(height: 8),
//                 // 메인 콘텐츠
//                 Expanded(
//                   child: ExploreMasonryGrid(vm: vm, scrollController: _scroll),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // 지역명 → API 지역코드 매핑
//   int? _mapAreaCode(String region) {
//     switch (region) {
//       case '전체':
//         return null;
//       case '서울':
//         return 1;
//       case '인천':
//         return 2;
//       case '부산':
//         return 6;
//       case '경기':
//         return 31;
//       case '제주':
//         return 39;
//       default:
//         return null;
//     }
//   }
// }
