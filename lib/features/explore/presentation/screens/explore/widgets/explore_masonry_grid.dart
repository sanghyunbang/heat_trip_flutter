// lib/features/explore/presentation/screens/explore/widgets/explore_masonry_grid.dart
//
// MasonryGridView + 페이지네이션
// - VM 상태에 따라 에러/로딩/빈 화면 처리
// - 화면 폭에 따라 2/3/4열 반응형
// - 각 카드에 가변 이미지 높이 전달(imageHeight)로 자연스러운 Masonry 구성

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:heat_trip_flutter/features/explore/presentation/state/explore_scroll_vm.dart';
import 'package:heat_trip_flutter/features/explore/data/models/place_item_dto.dart';

// 새 경로의 PlaceCard 배럴 import
import 'package:heat_trip_flutter/features/explore/presentation/widgets/place_card/index.dart';

import 'loader_cells.dart';

class ExploreMasonryGrid extends StatelessWidget {
  final ExploreScrollVM vm;
  final ScrollController scrollController;

  const ExploreMasonryGrid({
    super.key,
    required this.vm,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    // 상태 분기
    if (vm.error != null && vm.items.isEmpty) {
      return Center(child: Text('에러: ${vm.error}'));
    }
    if (vm.loading && vm.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.items.isEmpty) {
      return const Center(child: Text('검색 결과가 없습니다.'));
    }

    // 반응형 열 수
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1200 ? 4 : (width >= 900 ? 3 : 2);

    // 간격/패딩
    const hPad = 0.0;
    const spacing = 5.0;

    // 각 타일 폭 (이미지 높이 추정에 사용)
    final tileWidth =
        (width - hPad * 2 - spacing * (crossAxisCount - 1)) / crossAxisCount;

    // +1: 마지막 센티넬 셀(로더/종료)
    final itemCount = vm.items.length + 1;

    return MasonryGridView.count(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      cacheExtent: 800,
      itemCount: itemCount,
      itemBuilder: (_, i) {
        if (i < vm.items.length) {
          final PlaceItem item = vm.items[i];
          final imgH = _estimateImageHeight(tileWidth, item);

          return PlaceCard(
            data: item,
            layout: PlaceCardLayout.vertical,
            imageHeight: imgH,
            compact: true,
            categoryLabel: (item.cat3Name ?? '').isNotEmpty ? item.cat3Name : null,
            tags: (item.simpleTags.isNotEmpty) ? item.simpleTags : item.hashtags,
          );
        }

        if (vm.loading) {
          return const SizedBox(height: 80, child: GridLoaderCell());
        }
        if (!vm.hasNext) {
          return const SizedBox(height: 56, child: GridNoMoreCell());
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// 간단한 이미지 높이 추정
  /// - 실제로는 (원본세로/원본가로)*tileWidth 가 가장 자연스러움
  double _estimateImageHeight(double tileWidth, PlaceItem item) {
    final bucket = (item.contentid.hashCode.abs() % 3);
    const ratios = [0.75, 1.0, 1.35]; // height = width * ratio
    return tileWidth * ratios[bucket];
  }
}
