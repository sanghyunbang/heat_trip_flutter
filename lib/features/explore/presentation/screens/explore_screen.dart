// =============================
// explore_screen.dart — 세로형 카드를 렌더링하는 탐색 화면
// =============================

// Flutter 기본 위젯들
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

/// 탐색 화면 - 장소들을 세로형 카드로 표시하는 메인 화면
///
/// 기능:
/// - 탭을 통한 카테고리 분류 (관광지/축제)
/// - 지역 필터링 (서울, 부산, 제주 등)
/// - 무한 스크롤을 통한 데이터 로딩
/// - 검색 기능
/// - Pull-to-refresh 새로고침
class ExploreScreen extends StatefulWidget {
  // 외부에서 전달받을 수 있는 초기 필터 설정
  final ExploreFilters? initialFilters;

  const ExploreScreen({super.key, this.initialFilters});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  // TabController를 위한 Mixin

  // ============================================================================
  // 핵심 상태 변수들
  // ============================================================================

  /// 페이지네이션과 데이터 로딩을 관리하는 ViewModel
  /// - 스크롤 위치에 따라 자동으로 다음 페이지 로드
  /// - 필터 변경 시 데이터 새로고침
  late ExploreScrollVM _vm;

  /// 탭 컨트롤러 - '관광지'와 '축제' 탭을 관리
  /// - 탭 변경 시 필터가 달라지므로 데이터 새로고침 필요
  late TabController _tab;

  /// 스크롤 컨트롤러 - 무한 스크롤 구현을 위한 스크롤 위치 감지
  /// - 스크롤이 하단 600px 이내에 도달하면 다음 페이지 로드
  final ScrollController _scroll = ScrollController();

  /// API 인터페이스 - 의존성 주입을 통해 실제 구현체가 할당됨
  /// - 테스트 시에는 MockPlaceApi로 교체 가능
  /// - 운영 환경에서는 PlaceApiHttp로 실제 서버 통신
  late final PlaceApi _api;

  // ============================================================================
  // 필터 관련 상태
  // ============================================================================

  /// 현재 선택된 지역 - 기본값은 '전체' (모든 지역)
  String _selectedRegion = '전체';

  /// 선택 가능한 지역 목록 - 바텀시트에서 사용자가 선택할 수 있는 옵션들
  final List<String> _regions = ['전체', '서울', '경기', '인천', '부산', '제주'];

  @override
  void initState() {
    super.initState();

    // ========================================================================
    // 1. API 구현체 주입 (의존성 주입의 핵심!)
    // ========================================================================
    /// PlaceApiHttp 인스턴스를 생성하여 _api에 할당
    /// - http.Client()를 주입하여 실제 네트워크 요청 가능
    /// - 나중에 GraphQL이나 다른 구현체로 쉽게 교체 가능
    /// - 테스트 시에는 MockPlaceApi로 교체하여 서버 없이 테스트 가능
    _api = PlaceApiHttp(client: http.Client()); // ← 실제 HTTP 구현체 생성 및 주입

    // ========================================================================
    // 2. 탭 컨트롤러 초기화 및 리스너 등록
    // ========================================================================
    _tab = TabController(length: 2, vsync: this); // 2개 탭: 관광지, 축제
    _tab.addListener(() {
      // indexIsChanging이 true인 동안은 아직 탭 전환이 진행 중이므로 무시
      // false가 되면 탭 전환이 완료된 것이므로 데이터 새로고침 실행
      if (_tab.indexIsChanging) return; // 중복 호출 방지
      _rebuildVmAndRefresh(); // 탭 변경 시 새로운 필터로 데이터 새로고침
    });

    // ========================================================================
    // 3. 스크롤 컨트롤러 리스너 등록 (무한 스크롤 핵심 로직)
    // ========================================================================
    _scroll.addListener(() {
      // extentAfter: 현재 스크롤 위치에서 하단까지 남은 픽셀 수
      // 600px 이내에 도달하면 다음 페이지를 미리 로드하여 끊김 없는 UX 제공
      if (_scroll.position.extentAfter < 600) {
        _vm.fetchNext(); // 다음 페이지 데이터 요청
      }
    });

    // ========================================================================
    // 4. ViewModel 초기화 및 첫 데이터 로드
    // ========================================================================
    /// 초기 필터를 구성하여 ViewModel 생성
    /// - 현재 선택된 지역과 탭을 기반으로 필터 생성
    /// - API 인스턴스를 ViewModel에 주입
    _vm = _buildVm(filters: _composeFilters());

    /// 화면이 로드되자마자 첫 번째 페이지 데이터 요청
    /// - refresh()는 기존 데이터를 모두 지우고 처음부터 로드
    _vm.refresh();
  }

  @override
  void dispose() {
    // 메모리 누수 방지를 위한 리소스 정리
    _tab.dispose(); // TabController 리소스 해제
    _scroll.dispose(); // ScrollController 리소스 해제
    _vm.dispose(); // ViewModel 리소스 해제 (ChangeNotifier)
    super.dispose();
  }

  /// 현재 상태(선택된 지역 + 탭)를 기반으로 서버 필터 객체 생성
  ///
  /// 반환값: ExploreFilters 객체
  /// - areacode: 지역 코드 (서울=1, 부산=6 등)
  /// - cat1/cat2/cat3: 카테고리 코드 (관광지/축제 구분)
  ExploreFilters _composeFilters() {
    // 선택된 지역명을 서버가 이해할 수 있는 지역 코드로 변환
    final areaCode = _mapAreaCode(_selectedRegion);

    // 카테고리 코드 초기화 - 서버 API 스펙에 따라 설정
    String? cat1; // 대분류 카테고리
    String? cat2; // 중분류 카테고리
    String? cat3; // 소분류 카테고리

    if (_tab.index == 0) {
      // 관광지 탭이 선택된 경우
      // TODO: 관광지에 해당하는 카테고리 코드 설정
      // 예: cat1 = 'A01'; // 자연 관광지
    } else {
      // 축제 탭이 선택된 경우
      // TODO: 축제에 해당하는 카테고리 코드 설정
      // 예: cat1 = 'A02'; // 문화 행사
    }

    return ExploreFilters(
      areacode: areaCode, // 지역 코드
      sigungucode: null, // 시군구 코드 (현재는 사용 안함)
      cat1: cat1, // 대분류
      cat2: cat2, // 중분류
      cat3: cat3, // 소분류
    );
  }

  /// 필터가 변경되었을 때 ViewModel을 새로 생성하고 데이터 새로고침
  ///
  /// 호출 시점:
  /// - 탭 변경 (관광지 ↔ 축제)
  /// - 지역 변경 (서울, 부산 등)
  /// - 검색 후
  void _rebuildVmAndRefresh() {
    // 1. 새로운 필터 조건 생성
    final newFilters = _composeFilters();

    // 2. 기존 ViewModel 정리 (메모리 누수 방지)
    _vm.dispose();

    // 3. 새로운 필터로 ViewModel 재생성
    _vm = _buildVm(filters: newFilters);

    // 4. 새로운 데이터로 처음부터 로드
    _vm.refresh();

    // 5. 스크롤을 맨 위로 부드럽게 이동 (UX 개선)
    _scroll.animateTo(
      0, // 맨 위 위치
      duration: const Duration(milliseconds: 250), // 0.25초 애니메이션
      curve: Curves.easeOut, // 부드러운 감속 곡선
    );

    // 6. UI 재빌드 트리거
    setState(() {});
  }

  /// ViewModel 팩토리 메서드 - 주어진 필터로 새로운 ViewModel 인스턴스 생성
  ///
  /// 매개변수:
  /// - filters: 서버에 전달할 필터 조건
  ///
  /// 반환값: 설정이 완료된 ExploreScrollVM 인스턴스
  ExploreScrollVM _buildVm({required ExploreFilters filters}) {
    return ExploreScrollVM(
      api: _api, // 주입된 API 구현체 전달
      filters: filters, // 필터 조건 전달
      pageSize: 20, // 한 번에 로드할 아이템 수
    );
  }

  /// 지역 선택 바텀시트를 열고 사용자의 선택을 처리
  ///
  /// 동작:
  /// 1. 모달 바텀시트에 지역 목록 표시
  /// 2. 사용자가 지역 선택 시 해당 값 반환
  /// 3. 선택된 지역으로 필터 업데이트 후 데이터 새로고침
  Future<void> _openRegionSelect() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFFF5ECD7), // 베이지 색상 배경
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(18),
        ), // 상단 모서리만 둥글게
      ),
      builder: (_) => RegionSelectSheet(
        title: '지역 선택',
        options: _regions, // 선택 가능한 지역 목록
        initial: _selectedRegion, // 현재 선택된 지역 (체크 표시용)
      ),
    );

    // 사용자가 지역을 선택했을 때만 처리 (취소 시 null 반환)
    if (result != null) {
      setState(() => _selectedRegion = result); // 선택된 지역 업데이트
      _rebuildVmAndRefresh(); // 새로운 지역으로 데이터 새로고침
    }
  }

  @override
  Widget build(BuildContext context) {
    // ========================================================================
    // AnimatedBuilder로 ViewModel 상태 변화 감지
    // ========================================================================
    /// ViewModel(_vm)이 ChangeNotifier를 상속받았으므로
    /// notifyListeners() 호출 시마다 이 builder가 자동으로 재실행됨
    ///
    /// 장점:
    /// - setState() 없이도 자동 UI 업데이트
    /// - 상태 변화에 따른 세밀한 UI 제어 가능
    return AnimatedBuilder(
      animation: _vm, // ViewModel을 애니메이션 소스로 등록
      builder: (_, __) {
        return Scaffold(
          backgroundColor: const Color(0xFFF6F6F6), // 연한 회색 배경
          // ================================================================
          // AppBar: 제목, 탭, 검색 버튼
          // ================================================================
          appBar: AppBar(
            title: const Text('Explore'),

            // 탭바 - 관광지와 축제를 구분
            bottom: TabBar(
              controller: _tab,
              labelColor: const Color(0xFF346145), // 선택된 탭 색상 (진한 녹색)
              unselectedLabelColor: Colors.black45, // 비선택 탭 색상 (회색)
              indicatorSize: TabBarIndicatorSize.tab, // 인디케이터가 탭 전체 너비
              indicatorColor: const Color(0xFF346145), // 인디케이터 색상
              tabs: const [
                Tab(text: '관광지'),
                Tab(text: '축제'),
              ],
            ),

            // 우측 액션 버튼들
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () async {
                  // ============================================================
                  // 검색 델리게이트 실행
                  // ============================================================
                  /// Flutter의 내장 검색 기능 사용
                  /// - 검색바와 결과 화면을 자동으로 생성
                  /// - 사용자가 검색어 입력 후 결과 선택 시 해당 값 반환
                  final result = await showSearch<String>(
                    context: context,
                    delegate: _SearchDelegateWithReturn(
                      initialQuery: '',
                    ), // 빈 검색어로 시작
                  );

                  // 검색 결과가 있으면 해당 조건으로 데이터 새로고침
                  if (result != null) {
                    // TODO: 검색어를 필터에 추가하는 로직 필요
                    _rebuildVmAndRefresh();
                  }
                },
              ),
            ],
          ),

          // ================================================================
          // Body: 필터 칩 + 그리드 뷰
          // ================================================================
          body: Column(
            children: [
              const SizedBox(height: 8), // 상단 여백
              // ============================================================
              // 필터 칩 영역 - 지역 선택 및 초기화 버튼
              // ============================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft, // 좌측 정렬
                  child: Wrap(
                    // 화면 너비를 초과하면 자동 줄바꿈
                    spacing: 10, // 가로 간격
                    runSpacing: 8, // 세로 간격 (줄바꿈 시)
                    children: [
                      // 현재 선택된 지역을 표시하는 칩
                      RegionFilterChip(
                        label: _selectedRegion,
                        selected:
                            _selectedRegion != '전체', // '전체'가 아니면 선택된 상태로 표시
                        onTap: _openRegionSelect, // 탭 시 지역 선택 바텀시트 열기
                      ),

                      // 지역이 선택된 경우에만 초기화 버튼 표시
                      if (_selectedRegion != '전체')
                        RegionFilterChip(
                          label: '초기화',
                          outlined: true, // 테두리만 있는 스타일
                          onTap: () {
                            setState(
                              () => _selectedRegion = '전체',
                            ); // 지역을 '전체'로 리셋
                            _rebuildVmAndRefresh(); // 데이터 새로고침
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ============================================================
              // 메인 콘텐츠 영역 - 그리드뷰로 장소 카드들 표시
              // ============================================================
              Expanded(child: _buildGridWithPaging(context)),
            ],
          ),
        );
      },
    );
  }

  /// 페이지네이션이 포함된 그리드뷰 구성
  ///
  /// 기능:
  /// - 로딩/에러/빈 상태 처리
  /// - 반응형 그리드 (모바일 1열, 태블릿 2열)
  /// - 동적 카드 비율 계산
  /// - 무한 스크롤 지원
  Widget _buildGridWithPaging(BuildContext context) {
    // ========================================================================
    // 상태별 UI 분기 처리
    // ========================================================================

    // 에러가 있고 아직 로드된 아이템이 없는 경우 (초기 로딩 실패)
    if (_vm.error != null && _vm.items.isEmpty) {
      return Center(child: Text('에러: ${_vm.error}'));
    }

    // 로딩 중이고 아직 로드된 아이템이 없는 경우 (초기 로딩 중)
    if (_vm.loading && _vm.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 로딩도 끝났는데 아이템이 하나도 없는 경우 (검색 결과 없음)
    if (_vm.items.isEmpty) {
      return const Center(child: Text('검색 결과가 없습니다.'));
    }

    // ========================================================================
    // 반응형 그리드 설정
    // ========================================================================

    /// 화면 너비에 따른 열 개수 결정
    /// - 1000px 이상 (태블릿/데스크톱): 2열
    /// - 1000px 미만 (모바일): 1열
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1000 ? 2 : 1;

    // ========================================================================
    // 동적 카드 비율 계산 (중요!)
    // ========================================================================
    /// PlaceCard의 세로형 레이아웃에 맞는 정확한 비율을 계산
    /// 이 계산이 없으면 카드가 찌그러지거나 잘릴 수 있음

    const hPad = 12.0; // 그리드 좌우 패딩
    const spacing = 12.0; // 카드 간의 간격

    /// 각 카드의 실제 너비 계산
    /// 공식: (전체 너비 - 좌우 패딩 - 카드 간격) ÷ 열 개수
    final tileWidth =
        (width - hPad * 2 - spacing * (crossAxisCount - 1)) / crossAxisCount;

    /// 카드 높이 계산
    const imageAspect = 14 / 9; // 이미지 비율 (PlaceCard와 동일해야 함!)
    const infoHeight = 100.0; // 이미지 하단 정보 영역 높이 (제목, 주소, 태그 등)
    final tileHeight = tileWidth / imageAspect + infoHeight;

    /// GridView가 요구하는 가로:세로 비율
    final childAspectRatio = tileWidth / tileHeight;

    /// 아이템 개수 = 실제 데이터 + 1 (로딩/완료 표시용 센티넬)
    final itemCount = _vm.items.length + 1;

    // ========================================================================
    // GridView 구성
    // ========================================================================
    return GridView.builder(
      controller: _scroll, // 스크롤 감지를 위한 컨트롤러 연결
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

      // 그리드 레이아웃 설정
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, // 열 개수
        mainAxisSpacing: spacing, // 세로 간격
        crossAxisSpacing: spacing, // 가로 간격
        childAspectRatio: childAspectRatio, // 카드 비율 (위에서 계산한 값)
      ),

      itemCount: itemCount, // 총 아이템 개수
      // ======================================================================
      // 아이템 빌더 - 각 그리드 셀을 구성하는 로직
      // ======================================================================
      itemBuilder: (_, i) {
        // 실제 데이터 아이템인 경우
        if (i < _vm.items.length) {
          final PlaceItem item = _vm.items[i]; // i번째 장소 데이터

          return PlaceCard(
            data: item, // 장소 기본 정보 (제목, 주소, 이미지 등)
            layout: PlaceCardLayout.vertical, // 세로형 레이아웃 (이미지 위, 정보 아래)
            // ================================================================
            // 옵션 파라미터들 - 현재는 주석 처리 (서버에서 데이터 오면 활성화)
            // ================================================================
            // priceLabel: '\$\$',                // 가격 배지 (우상단)
            // distance: '0.5km',                 // 거리 (주소 옆)
            // duration: '1-2시간',               // 소요 시간

            // categoryLabel: '카페',              // 카테고리 배지 (좌상단)
            categoryLabel: (item.cat3Name ?? '').isNotEmpty
                ? item.cat3Name
                : null,

            // simpleTags가 비어있으면 hashtags로 대체
            tags: (item.simpleTags.isNotEmpty)
                ? item.simpleTags
                : item.hashtags,
            // 필요하면 가격/거리/시간도 나중에 채워 넣을 수 있음
          );
        }

        // 마지막 아이템 이후의 센티넬 셀들

        // 로딩 중이면 로딩 인디케이터 표시
        if (_vm.loading) return const _GridLoaderCell();

        // 더 이상 로드할 데이터가 없으면 완료 메시지 표시
        if (!_vm.hasNext) return const _GridNoMoreCell();

        // 그 외의 경우 빈 공간 (보통 발생하지 않음)
        return const SizedBox.shrink();
      },
    );
  }

  /// 지역명을 서버 API가 인식할 수 있는 지역 코드로 매핑
  ///
  /// 매개변수:
  /// - region: 사용자가 선택한 지역명 (한글)
  ///
  /// 반환값:
  /// - null: '전체' 선택 시 (모든 지역)
  /// - int: 해당 지역의 코드 (서버 API 스펙에 따름)
  int? _mapAreaCode(String region) {
    switch (region) {
      case '전체':
        return null; // null이면 서버에서 모든 지역 데이터 반환
      case '서울':
        return 1; // 서울특별시 코드
      case '인천':
        return 2; // 인천광역시 코드
      case '부산':
        return 6; // 부산광역시 코드
      case '경기':
        return 31; // 경기도 코드
      case '제주':
        return 39; // 제주도 코드
      default:
        return null; // 알 수 없는 지역은 전체로 처리
    }
  }
}

// ==============================================================================
// 보조 위젯들 - 그리드의 특별한 셀들을 위한 위젯
// ==============================================================================

/// 로딩 중일 때 표시되는 그리드 셀
///
/// 위치: 실제 데이터 아이템들 다음 마지막 위치
/// 표시 조건: _vm.loading == true
class _GridLoaderCell extends StatelessWidget {
  const _GridLoaderCell();

  @override
  Widget build(BuildContext context) => const Card(
    child: Center(
      child: CircularProgressIndicator(), // 회전하는 로딩 인디케이터
    ),
  );
}

/// 더 이상 로드할 데이터가 없을 때 표시되는 그리드 셀
///
/// 위치: 실제 데이터 아이템들 다음 마지막 위치
/// 표시 조건: _vm.hasNext == false && _vm.loading == false
class _GridNoMoreCell extends StatelessWidget {
  const _GridNoMoreCell();

  @override
  Widget build(BuildContext context) => const Card(
    child: Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('No more results'), // 더 이상 결과가 없다는 메시지
      ),
    ),
  );
}

// ==============================================================================
// 검색 기능 - Flutter의 SearchDelegate 활용
// ==============================================================================

/// 검색 델리게이트 - Flutter 내장 검색 UI를 커스터마이징
///
/// 기능:
/// - 검색어 입력 바
/// - 검색 제안 목록
/// - 검색 결과 표시
/// - 검색어 선택 시 해당 값을 호출자에게 반환

class _SearchDelegateWithReturn extends SearchDelegate<String> {
  /// 생성자 - 초기 검색어 설정 가능
  _SearchDelegateWithReturn({String? initialQuery}) {
    query = initialQuery ?? ''; // 전달받은 초기 검색어 또는 빈 문자열
  }

  /// 검색바 우측 액션 버튼들 (예: 지우기 버튼)
  @override
  List<Widget> buildActions(BuildContext context) => [
    TextButton(
      onPressed: () => query = '', // 검색어 초기화
      child: const Text('모두 지우기'),
    ),
  ];

  /// 검색바 좌측 뒤로가기 버튼
  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, query), // 현재 검색어와 함께 검색 화면 닫기
  );

  /// 사용자가 검색어를 입력하고 엔터를 눌렀을 때의 결과 화면
  @override
  Widget buildResults(BuildContext context) => _ResultList(query: query);

  /// 사용자가 검색어를 입력하는 중에 보여지는 제안 화면
  @override
  Widget buildSuggestions(BuildContext context) => _ResultList(query: query);
}

// ==============================================================================
// 검색 결과/제안 목록
// ==============================================================================

/// 검색 제안 및 결과를 표시하는 위젯
///
/// 동작:
/// - 미리 정의된 지역명 목록에서 입력된 검색어를 포함하는 항목들 필터링
/// - 사용자가 항목 선택 시 해당 값을 반환하여 검색 화면 종료
class _ResultList extends StatelessWidget {
  final String query; // 현재 입력된 검색어

  const _ResultList({required this.query});

  @override
  Widget build(BuildContext context) {
    // ========================================================================
    // 검색어 필터링 로직
    // ========================================================================
    /// 하드코딩된 지역 목록에서 검색어가 포함된 항목들만 추출
    /// 실제 앱에서는 서버 API로 검색 결과를 가져올 수 있음
    final suggestions = [
      '서울',
      '부산',
      '제주',
      '강릉',
    ].where((s) => s.contains(query)).toList(); // 검색어가 포함된 항목만 필터링

    // 검색 결과가 없는 경우
    if (suggestions.isEmpty) {
      return Center(child: Text('검색어: $query')); // 입력한 검색어를 그대로 표시
    }

    // ========================================================================
    // 검색 결과 목록 표시
    // ========================================================================
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (_, i) => ListTile(
        title: Text(suggestions[i]),
        onTap: () =>
            Navigator.of(context).pop(suggestions[i]), // 선택 시 해당 값 반환 후 화면 종료
      ),
    );
  }
}
