// lib/features/explore/presentation/screens/explore/widgets/explore_app_bar.dart
//
// Explore 상단 AppBar
// - TabBar(관광지/축제)와 Search 버튼을 포함
// - TabController는 상위에서 관리(탭 변경 시 VM 재빌드 목적)

import 'package:flutter/material.dart';

class ExploreAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final VoidCallback onPressSearch;

  const ExploreAppBar({
    super.key,
    required this.tabController,
    required this.onPressSearch,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Explore'),
      bottom: TabBar(
        controller: tabController,
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
        IconButton(icon: const Icon(Icons.search), onPressed: onPressSearch),
      ],
    );
  }
}
