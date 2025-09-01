// lib/features/explore/presentation/screens/explore/widgets/explore_filters_bar.dart
//
// 지역 필터 칩 영역
// - 현재 선택된 지역을 보여주고, 선택/초기화 액션 제공

import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/explore/presentation/widgets/region_filter_chip.dart';

class ExploreFiltersBar extends StatelessWidget {
  final String selectedRegion;
  final bool showReset;
  final VoidCallback onTapRegion;
  final VoidCallback onReset;

  const ExploreFiltersBar({
    super.key,
    required this.selectedRegion,
    required this.showReset,
    required this.onTapRegion,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            RegionFilterChip(
              label: selectedRegion,
              selected: selectedRegion != '전체',
              onTap: onTapRegion,
            ),
            if (showReset)
              RegionFilterChip(
                label: '초기화',
                outlined: true,
                onTap: onReset,
              ),
          ],
        ),
      ),
    );
  }
}
