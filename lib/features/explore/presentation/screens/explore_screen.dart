import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/explore/data/repositories/place_repository_impl.dart';
import 'package:heat_trip_flutter/features/explore/data/sources/place_api.dart';
import 'package:heat_trip_flutter/features/explore/domain/entities/place_item.dart';
import 'package:heat_trip_flutter/features/explore/domain/usecases/get_place_items.dart';
import 'package:heat_trip_flutter/features/explore/presentation/widgets/place_card.dart';
import 'package:heat_trip_flutter/features/explore/presentation/widgets/region_filter_chip.dart';
import 'package:heat_trip_flutter/features/explore/presentation/widgets/region_select_sheet.dart';

/// ExploreScreen – 관광지 / 축제 목록을 보여주는 화면
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleTickerProviderStateMixin {
  late final GetPlaceItems _getPlaceItems; // 유스케이스 (데이터 불러오기)
  late TabController _tab; // TabBar 제어용 컨트롤러

  // 현재 선택된 지역 (기본값: '전체')
  String _selectedRegion = '전체';
  // 지역 선택 옵션 목록
  final List<String> regions = ['전체', '서울', '경기', '인천', '부산', '제주'];

  late Future<List<PlaceItem>> _future; // 비동기 데이터 (관광지/축제 목록)

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this); // TabController 생성 (탭 2개)
    _tab.addListener(() { // 탭 변경 이벤트 감지 → index가 변경 완료되면(_indexIsChanging false) 데이터 새로 로드
      if (_tab.indexIsChanging) return; // 변경 중에는 무시
      _reload(); // 탭 전환 시 재조회
    });

    // Repository와 API 연결 (현재 Mock API 사용 => 수정 예정)
    final repo = PlaceRepositoryImpl(MockPlaceApi());
    _getPlaceItems = GetPlaceItems(repo);
    _future = _getPlaceItems(); // 최초 전체 로드
  }

  @override
  void dispose() {
    // 컨트롤러 메모리 해제
    _tab.dispose();
    super.dispose();
  }

  /// 데이터 새로 불러오기
  void _reload() {
    setState(() {
      _future = _getPlaceItems(category: _tab.index == 0 ? null : '축제'); // 관광지:null, 축제:'축제'
    });
  }

  /// 지역 필터 적용 (선택이 '전체'면 그대로 반환)
  List<PlaceItem> _applyClientFilter(List<PlaceItem> items) {
    if (_selectedRegion == '전체') return items;
    return items.where((p) {
      // addr1(주소)에서 앞 2글자만 추출해 지역 비교
      final region =
      p.addr1.isNotEmpty ? String.fromCharCodes(p.addr1.runes.take(2)) : '';
      return region == _selectedRegion;
    }).toList();
  }

  /// 지역 선택 바텀시트 열기
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
    // 선택 값이 null이 아니면 상태 업데이트 + 재조회
    if (result != null) {
      setState(() => _selectedRegion = result);
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      /// 상단 AppBar + TabBar
      appBar: AppBar(
        title: const Text('Explore'),
        bottom: TabBar(
          controller: _tab, // 직접 생성한 TabController 사용 (DefaultTabController 혼용 ❌)
          labelColor: Color(0xFF346145),//Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.black45,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorColor: Color(0xFF346145),
          tabs: const [
            Tab(text: '관광지'),
            Tab(text: '축제'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              // Flutter 기본 SearchDelegate 사용 예시
              final result = await showSearch<String>(
                context: context,
                delegate: CustomSearchDelegate(),
              );
              if (result != null) {
                print('검색 결과: $result'); // TODO: 검색 결과 처리
              }
            },
          ),
        ],
      ),

      /// 본문
      body: Column(
        children: [
          const SizedBox(height: 8),
          /// 지역 필터칩 영역
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft, // ← 왼쪽 정렬을 강제
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
                        _reload();
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          /// 데이터 목록
          Expanded(
            child: FutureBuilder<List<PlaceItem>>(
              future: _future,
              builder: (context, snapshot) {
                // 로딩 중
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // 에러 발생
                if (snapshot.hasError) {
                  return const Center(child: Text('데이터를 불러올 수 없습니다.'));
                }
                // 데이터 필터 적용
                final items = _applyClientFilter(snapshot.data ?? const []);
                // 결과 없음
                if (items.isEmpty) {
                  return const Center(child: Text('검색 결과가 없습니다.'));
                }
                // 결과 표시 (그리드)
                return GridView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2열
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72, // 카드 비율
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) => PlaceCard(data: items[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

///
class CustomSearchDelegate extends SearchDelegate<String> {
  // 검색창 오른쪽 액션 버튼
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () {
          query = ''; // 입력 내용 초기화
        },
        child: const Text('모두 지우기'),
      ),
    ];
  }

  // 검색창 왼쪽 뒤로가기 버튼
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, ''); // 검색창 닫기
      },
    );
  }

  // 검색 결과 표시
  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text('검색 결과: $query'),
    );
  }

  // 검색 제안 표시
  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = [
      '서울',
      '부산',
      '제주',
      '강릉',
    ].where((item) => item.contains(query)).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]),
          onTap: () {
            query = suggestions[index];
            showResults(context); // 선택 시 결과 화면으로
          },
        );
      },
    );
  }
}
