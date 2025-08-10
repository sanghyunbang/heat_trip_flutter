import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/explore/data/repositories/place_repository_impl.dart';
import 'package:heat_trip_flutter/features/explore/data/sources/place_api.dart';
import 'package:heat_trip_flutter/features/explore/domain/entities/place_item.dart';
import 'package:heat_trip_flutter/features/explore/domain/usecases/get_place_items.dart';
import 'package:heat_trip_flutter/features/explore/presentation/widgets/filter_chip_button.dart';
import 'package:heat_trip_flutter/features/explore/presentation/widgets/place_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {

  final List<String> _filters = const ['전체', '지역', '관광지타입'];
  late final GetPlaceItems _getPlaceItems;

  String _selected = '전체';
  late Future<List<PlaceItem>> _future;

  @override
  void initState() {
    super.initState();
    // DI 대체: 지금은 간단히 직접 주입 (나중에 get_it/riverpod로 이동)
    final repo = PlaceRepositoryImpl(MockPlaceApi());
    _getPlaceItems = GetPlaceItems(repo);
    _future = _getPlaceItems(); // 최초 전체 로드
  }

  void _applyFilter(String label) {
    setState(() {
      _selected = label;
      final category = (label == '전체') ? null : label;
      _future = _getPlaceItems(category: category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 검색 구현
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 필터
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _filters.map((label) {
                return FilterChipButton(
                  label: label,
                  selected: _selected == label,
                  onSelected: () => _applyFilter(label),
                );
              }).toList(),
            ),
          ),
          // 목록
          Expanded(
            child: FutureBuilder<List<PlaceItem>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('데이터를 불러올 수 없습니다.'));
                }
                final items = snapshot.data ?? const <PlaceItem>[];
                if (items.isEmpty) {
                  return const Center(child: Text('검색 결과가 없습니다.'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
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
