// lib/core/widgets/layout/main_nav_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heat_trip_flutter/core/widgets/nav/bottom_nav_bar.dart';

class MainNavShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainNavShell({super.key, required this.navigationShell});

  void _onTabTapped(int index) {
    final reselect = index == navigationShell.currentIndex;
    navigationShell.goBranch(index, initialLocation: reselect);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell, // 탭별 Navigator를 포함한 IndexedStack을 렌더링
      // 기존 디자인과 동일한 FAB: curation 탭(2)로 이동
      floatingActionButton: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.indigo,
          shape: const CircleBorder(),
          onPressed: () => _onTabTapped(2),
          elevation: 4.0,
          child: const Icon(Icons.dynamic_feed, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: AppBottomNavBar(
        currentIndex: selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
