// =============================
// explore_screen.dart — Masonry(핀터레스트형) 카드 그리드
// =============================
//
// 변경 핵심 요약
// - GridView.builder → MasonryGridView.count 로 교체
// - 카드별 가변 높이 전달을 위해 PlaceCard(imageHeight: ...) 사용
// - 무한 스크롤/에러/로딩/빈 상태 로직은 그대로 유지
//
// 라우팅
// - go_router 설정: '/explore' → const ExploreScreen()
// - 별도 수정 없이 현재 라우트 설정으로 동작
//
// 의존
// - flutter_staggered_grid_view: ^0.7.0

import 'package:flutter/material.dart';

// 데이터 모델들 - 장소 정보를 담는 DTO 클래스들
import 'package:heat_trip_flutter/features/explore/data/models/place_item_dto.dart';

// API 인터페이스와 구현체 - 의존성 주입을 위한 추상화와 실제 구현
import 'package:heat_trip_flutter/features/explore/data/remote/place_api.dart'; // 추상 인터페이스
import 'package:heat_trip_flutter/features/explore/data/remote/place_api_http.dart'; // HTTP 구현체

// 상태 관리 - 커서 기반 페이지네이션을 처리하는 ViewModel
import 'package:heat_trip_flutter/features/explore/presentation/state/explore_scroll_vm.dart';

// UI 컴포넌트들 - 재사용 가능한 위젯들
import 'package:heat_trip_flutter/features/explore/presentation/widgets/place_card.dart';
import 'package:heat_trip_flutter/features/explore/presentation/widgets/region_filter_chip.dart';
import 'package:heat_trip_flutter/features/explore/presentation/widgets/region_select_sheet.dart';

// HTTP 클라이언트 - 실제 네트워크 요청을 위한 라이브러리
import 'package:http/http.dart' as http;

// Masonry 그리드
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/// 탐색 화면 - 장소들을 Masonry 그리드로 표시하는 메인 화면
///
/// 기능:
/// - 탭을 통한 카테고리 분류 (관광지/축제)
//  - 지역 필터링 (서울, 부산, 제주 등)
//  - 무한 스크롤을 통한 데이터 로딩
//  - 검색 기능
//  - Pull-to-refresh 새로고침
class ExploreScreen extends StatefulWidget {
  // 외부에서 전달받을 수 있는 초기 필터 설정
  final ExploreFilters? initialFilters;

  const ExploreScreen({super.key, this.initialFilters});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================================
  // 핵심 상태 변수들
  // ============================================================================

  late ExploreScrollVM _vm; // 페이지네이션/데이터 로딩 VM
  late TabController _tab; // '관광지' / '축제' 탭
  final ScrollController _scroll = ScrollController(); // 무한 스크롤 감지

  late final PlaceApi _api; // API 인터페이스 (DI)

  // ============================================================================
  // 필터 관련 상태
  // ============================================================================

  String _selectedRegion = '전체';
  final List<String> _regions = ['전체', '서울', '경기', '인천', '부산', '제주'];

  @override
  void initState() {
    super.initState();

    // 1) API 구현체 주입
    _api = PlaceApiHttp(client: http.Client());

    // 2) 탭 컨트롤러
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() {
      if (_tab.indexIsChanging) return;
      _rebuildVmAndRefresh(); // 탭 변경 시 필터 갱신
    });

    // 3) 무한 스크롤 감지
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 600) {
        _vm.fetchNext();
      }
    });

    // 4) VM 초기화 + 첫 로드
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

  /// 현재 상태(선택된 지역 + 탭)를 기반으로 서버 필터 객체 생성
  ExploreFilters _composeFilters() {
    final areaCode = _mapAreaCode(_selectedRegion);

    String? cat1; // 대분류
    String? cat2; // 중분류
    String? cat3; // 소분류

    if (_tab.index == 0) {
      // 관광지 탭
      // TODO: 관광지 카테고리 코드 매핑
      // cat1 = 'A01';
    } else {
      // 축제 탭
      // TODO: 축제 카테고리 코드 매핑
      // cat1 = 'A02';
    }

    return ExploreFilters(
      areacode: areaCode,
      sigungucode: null,
      cat1: cat1,
      cat2: cat2,
      cat3: cat3,
    );
  }

  /// VM 재생성 + 새로고침 (탭/지역/검색 등 필터 바뀔 때 공통 루틴)
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

  /// VM 팩토리
  ExploreScrollVM _buildVm({required ExploreFilters filters}) {
    return ExploreScrollVM(api: _api, filters: filters, pageSize: 20);
  }

  /// 지역 선택 바텀시트
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
    // ViewModel이 ChangeNotifier 이므로 상태 변경 시 자동 재빌드
    return AnimatedBuilder(
      animation: _vm,
      builder: (_, __) {
        return Scaffold(
          backgroundColor: Colors.white,
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
                    // TODO: 검색어를 필터에 반영
                    _rebuildVmAndRefresh();
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              const SizedBox(height: 8),
              // 필터 칩 영역
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

              // 메인 콘텐츠 영역
              Expanded(child: _buildMasonryWithPaging(context)),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // Masonry + 페이지네이션
  // ===========================================================================
  Widget _buildMasonryWithPaging(BuildContext context) {
    // 상태 분기
    if (_vm.error != null && _vm.items.isEmpty) {
      return Center(child: Text('에러: ${_vm.error}'));
    }
    if (_vm.loading && _vm.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_vm.items.isEmpty) {
      return const Center(child: Text('검색 결과가 없습니다.'));
    }

    // 반응형 열 수
    final width = MediaQuery.of(context).size.width;
    // 폰 2열, 태블릿 3열, 큰 화면 4열
    final crossAxisCount = width >= 1200 ? 4 : (width >= 900 ? 3 : 2);

    // 패딩/간격
    const hPad = 0.0;
    const spacing = 5.0;

    // 칼럼 하나의 가로폭 (이미지 높이 추정에 사용)
    final tileWidth =
        (width - hPad * 2 - spacing * (crossAxisCount - 1)) / crossAxisCount;

    // +1: 마지막에 로딩/완료 센티넬
    final itemCount = _vm.items.length + 1;

    return MasonryGridView.count(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      cacheExtent: 800, // 프리페치로 스크롤 부드럽게
      itemCount: itemCount,
      itemBuilder: (_, i) {
        // 실제 데이터 아이템
        if (i < _vm.items.length) {
          final PlaceItem item = _vm.items[i];

          // Masonry 핵심: 카드별 이미지 높이를 다양하게 줘서 자연스러움 확보
          // - 서버에서 원본 가로/세로 비율이 오면 그걸 쓰는 게 베스트
          // - 여기선 contentid 해시 기반으로 3가지 비율로 섞어 줌
          final imgH = _estimateImageHeight(tileWidth, item);

          return PlaceCard(
            data: item,
            layout: PlaceCardLayout.vertical,
            imageHeight: imgH, // ← Masonry 가변 높이 전달
            compact: true,
            categoryLabel: (item.cat3Name ?? '').isNotEmpty
                ? item.cat3Name
                : null,
            tags: (item.simpleTags.isNotEmpty)
                ? item.simpleTags
                : item.hashtags,
          );
        }

        // 센티넬: 로딩/끝
        if (_vm.loading) {
          return const SizedBox(height: 80, child: _GridLoaderCell());
        }
        if (!_vm.hasNext) {
          return const SizedBox(height: 56, child: _GridNoMoreCell());
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// 간단한 이미지 높이 추정 로직
  /// - 실제로는 (원본세로/원본가로)*tileWidth 가 가장 자연스럽습니다.
  /// - 현재는 해시 기반으로 3개 버킷(0.75, 1.0, 1.35배)에서 선택.
  double _estimateImageHeight(double tileWidth, PlaceItem item) {
    final bucket = (item.contentid.hashCode.abs() % 3);
    const ratios = [0.75, 1.0, 1.35]; // height = width * ratio
    return tileWidth * ratios[bucket];
  }

  /// 지역명을 서버 API가 인식할 수 있는 지역 코드로 매핑
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

// ==============================================================================
// 보조 위젯들 - 그리드의 특별한 셀들을 위한 위젯
// ==============================================================================

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

// ==============================================================================
// 검색 기능 - Flutter의 SearchDelegate 활용 (기존 유지)
// ==============================================================================

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
