// lib/features/explore/presentation/screens/explore/explore_screen.dart
//
// ExploreScreen — Masonry(핀터레스트형) 카드 그리드 (오케스트레이션 전용)
//
// 역할 요약
// - 상태/DI/라우팅 제어: TabController, ScrollController, ExploreScrollVM, PlaceApi 주입
// - 필터 조합 및 VM 재빌드
// - 하위 UI는 모두 분리된 컴포넌트에 위임 (AppBar, FiltersBar, MasonryGrid)
// - 기존 주석/각주 스타일 유지 + 보강
//
// 변경점
// - place_card 경로 변경: widgets/place_card/index.dart 배럴 사용
// - UI 세부 구현을 위젯들로 분리해 파일 길이/복잡도 낮춤
//
// 의존
// - flutter_staggered_grid_view: ^0.7.0

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:heat_trip_flutter/features/explore/data/models/place_item_dto.dart';
import 'package:heat_trip_flutter/features/explore/data/remote/place_api.dart';
import 'package:heat_trip_flutter/features/explore/data/remote/place_api_http.dart';
import 'package:heat_trip_flutter/features/explore/presentation/state/explore_scroll_vm.dart';

// 기존 필터 UI
import 'package:heat_trip_flutter/features/explore/presentation/widgets/region_select_sheet.dart';
import 'package:heat_trip_flutter/features/explore/presentation/widgets/region_filter_chip.dart';

// 새로 분리된 컴포넌트
import 'widgets/explore_app_bar.dart';
import 'widgets/explore_filters_bar.dart';
import 'widgets/explore_masonry_grid.dart';
import 'widgets/search_delegate.dart';

class ExploreScreen extends StatefulWidget {
  final ExploreFilters? initialFilters;
  const ExploreScreen({super.key, this.initialFilters});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  // ────────────────────────────────────────────────────────────────────────────
  // 핵심 상태/의존
  // ────────────────────────────────────────────────────────────────────────────
  late ExploreScrollVM _vm;                   // 커서 기반 페이지네이션 VM
  late TabController _tab;                    // '관광지' / '축제'
  final ScrollController _scroll = ScrollController(); // 무한 스크롤 감지
  late final PlaceApi _api;                   // API 인터페이스 (DI)

  // ────────────────────────────────────────────────────────────────────────────
  // 필터 상태
  // ────────────────────────────────────────────────────────────────────────────
  String _selectedRegion = '전체';
  final List<String> _regions = const ['전체', '서울', '경기', '인천', '부산', '제주'];

  @override
  void initState() {
    super.initState();

    // 1) API 구현체 주입
    _api = PlaceApiHttp(client: http.Client());

    // 2) 탭 컨트롤러
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() {
      if (_tab.indexIsChanging) return; // 애니메이션 중 중복호출 방지
      _rebuildVmAndRefresh();            // 탭 변경 시 필터 갱신
    });

    // 3) 무한 스크롤 트리거
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

  // ────────────────────────────────────────────────────────────────────────────
  // 필터 조합/VM 재생성
  // ────────────────────────────────────────────────────────────────────────────

  /// 현재 선택된 탭/지역을 바탕으로 서버 필터 조합
  ExploreFilters _composeFilters() {
    final areaCode = _mapAreaCode(_selectedRegion);

    String? cat1; // 대분류
    String? cat2; // 중분류
    String? cat3; // 소분류

    if (_tab.index == 0) {
      // 관광지
      // TODO: 카테고리 코드 매핑
      // cat1 = 'A01';
    } else {
      // 축제
      // TODO: 카테고리 코드 매핑
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

    _scroll.animateTo(0,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);

    setState(() {}); // AnimatedBuilder에 감싸져 있어도 상단 탭 텍스트 등 갱신 위해 호출
  }

  /// VM 팩토리
  ExploreScrollVM _buildVm({required ExploreFilters filters}) {
    return ExploreScrollVM(api: _api, filters: filters, pageSize: 20);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 지역 선택 바텀시트
  // ────────────────────────────────────────────────────────────────────────────

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

  // ────────────────────────────────────────────────────────────────────────────
  // SearchDelegate 호출
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> _openSearch() async {
    final result = await showSearch<String>(
      context: context,
      delegate: SearchDelegateWithReturn(initialQuery: ''),
    );
    if (result != null) {
      // TODO: 검색어를 ExploreFilters에 반영
      _rebuildVmAndRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _vm, // ChangeNotifier를 관찰 → 상태 변화 시 리빌드
      builder: (_, __) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: ExploreAppBar(
            tabController: _tab,
            onPressSearch: _openSearch,
          ),
          body: Column(
            children: [
              const SizedBox(height: 8),
              ExploreFiltersBar(
                selectedRegion: _selectedRegion,
                showReset: _selectedRegion != '전체',
                onTapRegion: _openRegionSelect,
                onReset: () {
                  setState(() => _selectedRegion = '전체');
                  _rebuildVmAndRefresh();
                },
              ),
              const SizedBox(height: 8),
              // 메인 콘텐츠
              Expanded(
                child: ExploreMasonryGrid(
                  vm: _vm,
                  scrollController: _scroll,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 지역명 → API 지역코드 매핑
  // ────────────────────────────────────────────────────────────────────────────
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
