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

      bottomNavigationBar: AppBottomNavBar(
        currentIndex: selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
