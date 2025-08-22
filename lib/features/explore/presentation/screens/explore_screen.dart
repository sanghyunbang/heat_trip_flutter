import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/explore/data/models/place_item_dto.dart';
import 'package:heat_trip_flutter/features/explore/data/remote/place_api.dart';
import 'package:heat_trip_flutter/features/explore/data/remote/place_api_http.dart';

import 'package:heat_trip_flutter/features/explore/presentation/state/explore_scroll_vm.dart';
import 'package:heat_trip_flutter/features/explore/presentation/widgets/place_card.dart';
import 'package:heat_trip_flutter/features/explore/presentation/widgets/region_filter_chip.dart';
import 'package:heat_trip_flutter/features/explore/presentation/widgets/region_select_sheet.dart';
import 'package:http/http.dart' as http;

/// ExploreScreen
/// - 관광지/축제 리스트를 "무한 스크롤"로 보여주는 화면
/// - 기존 UI(탭, 지역 필터, 카드 그리드)를 유지하면서
///   실제 HTTP 통신 + 커서 기반 페이지네이션을 동작시키기 위한 예제
///
/// 구조 개요
/// 1) View(UI): 본 파일의 StatefulWidget + AnimatedBuilder
/// 2) ViewModel: ExploreScrollVM(ChangeNotifier)
///    - 현재 아이템 목록, 로딩 상태, nextCursor, hasNext 등을 관리
///    - refresh(...) / loadMore(...)로 페이지네이션 수행
/// 3) Repository/API: PlaceRepositoryImpl → HttpPlaceApi
///    - 실제 HTTP로 서버 `/api/explore/places/scroll` 호출(예시)
///
/// 핵심 포인트
/// - ScrollController.position.extentAfter(아래 남은 스크롤 거리)를 이용해
///   특정 임계값(< 600) 이하로 내려가면 vm.loadMore() 호출
/// - 그리드의 "마지막 칸"을 sentinel로 사용하여
///   로딩 중이면 로더 셀, 더 이상 없으면 No more 셀을 표기
///

/// ExploreScreen – 관광지 / 축제 목록을 보여주는 화면
class ExploreScreen extends StatefulWidget {
  /// 초기 필터
  final ExploreFilters? initialFilters;

  const ExploreScreen({super.key, this.initialFilters});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

/// SingleTickerProviderStateMixin
/// - TabController(애니메이션 프레임 동기화)를 위해 vsync 제공

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  // 상태 컨트롤러
  late final ExploreScrollVM _vm;
  late TabController _tab;
  final ScrollController _scroll = ScrollController();

  // late final GetPlaceItems _getPlaceItems; // 유스케이스 (데이터 불러오기)

  // 지역 필터
  String _selectedRegion = '전체';
  final List<String> regions = ['전체', '서울', '경기', '인천', '부산', '제주'];

  // API
  late final PlaceApi _api;
  // late Future<List<PlaceItem>> _future; // 비동기 데이터 (관광지/축제 목록)

  @override
  void initState() {
    super.initState();

    // API 준비 (explore는 로그인 없이 구현)
    _api = PlaceApiHttp(client: http.Client());

    // 탭(0=관광지, 1=축제)
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() {
      if (_tab.indexIsChanging) return; // 애니메이션 중복 방지
      _rebuildVmAndRefresh();
    });

    // 스크롤 하단 근접시 다음 페이지
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 600) {
        _vm.fetchNext(); // 다음 페이지 로드
      }
    });

    // 최초 VM 생성 + 로드
    _vm = _buildVm(filters: _composeFilters());
    _vm.refresh(); // 초기 데이터 로드
  }

  @override
  void dispose() {
    _tab.dispose();
    _scroll.dispose();
    _vm.dispose();
    super.dispose();
  }

  // 현재 탭/지역 → ExploreFilters 변환
  ExploreFilters _composeFilters() {
    final areaCode = _mapAreaCode(_selectedRegion);

    String? cat1;
    String? cat2;
    String? cat3;

    if (_tab.index == 0) {
      // 관광지 (백엔드 코드 체계에 맞게 필요 시 설정)
      // cat1 = 'A01';
    } else {
      // 축제
      // cat1 = 'A02';
      // cat2 = 'A0207';
    }

    return ExploreFilters(
      areacode: areaCode,
      sigungucode: null,
      cat1: cat1,
      cat2: cat2,
      cat3: cat3,
    );
  }

  // VM 재생성 + 첫 페이지 로드
  void _rebuildVmAndRefresh() {
    final newFilters = _composeFilters();
    _vm.dispose();
    _vm = _buildVm(filters: newFilters);
    _vm.refresh();

    // UX: 최상단으로
    _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );

    setState(() {}); // AnimatedBuilder 갱신
  }

  // VM 팩토리
  ExploreScrollVM _buildVm({required ExploreFilters filters}) {
    return ExploreScrollVM(api: _api, filters: filters, pageSize: 20);
  }

  // 지역 선택 바텀시트
  Future<void> _openRegionSelect() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFFF5ECD7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => RegionSelectSheet(
        title: '지역 선택',
        options: regions,
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
                    // 검색을 서버에 전달하려면 ExploreFilters/Api에 q 필드 추가
                    _rebuildVmAndRefresh();
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              const SizedBox(height: 8),
              // 지역 필터 칩
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

              // 목록 + sentinel
              Expanded(child: _buildGridWithPaging(context)),
            ],
          ),
        );
      },
    );
  }

  // 상태에 따른 그리드 렌더링
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

    final itemCount = _vm.items.length + 1; // + sentinel

    return GridView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: itemCount,
      itemBuilder: (_, i) {
        if (i < _vm.items.length) {
          final PlaceItem item = _vm.items[i];
          return PlaceCard(data: item);
        }
        if (_vm.loading) return const _GridLoaderCell();
        if (!_vm.hasNext) return const _GridNoMoreCell();
        return const SizedBox.shrink();
      },
    );
  }

  // 지역명 → areacode 매핑(예시 값)
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

// sentinel: 로더 셀
class _GridLoaderCell extends StatelessWidget {
  const _GridLoaderCell();
  @override
  Widget build(BuildContext context) =>
      const Card(child: Center(child: CircularProgressIndicator()));
}

// sentinel: No more 셀
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

/// 간단 검색 Delegate (선택 문자열 반환)
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
    if (suggestions.isEmpty) return Center(child: Text('검색어: $query'));
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (_, i) => ListTile(
        title: Text(suggestions[i]),
        onTap: () => Navigator.of(context).pop(suggestions[i]),
      ),
    );
  }
}
