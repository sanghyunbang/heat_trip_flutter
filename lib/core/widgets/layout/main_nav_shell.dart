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
      // FAB를 그라데이션 배경으로 보이게 하는 방법:
      // 1) 바깥 Container에 원형 + 흰색 테두리 + LinearGradient 적용
      // 2) 내부 FloatingActionButton은 배경을 '투명'으로 만들어 컨테이너의 그라데이션이 그대로 비치도록 함
      floatingActionButton: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4), // 흰색 테두리 유지
          // 그라데이션 (#eb9c64 → #ff8789)
          gradient: const LinearGradient(
            colors: [Color(0xFFEB9C64), Color(0xFFFF8789)],
            begin: Alignment.centerLeft,   // 왼쪽(주황)에서
            end: Alignment.centerRight,    // 오른쪽(핑크)으로
            // 필요하면 대각선 느낌: begin: Alignment.bottomLeft, end: Alignment.topRight
          ),
        ),
        child: FloatingActionButton(
          // 배경을 투명하게 만들어야 컨테이너의 그라데이션이 보임
          backgroundColor: Colors.transparent,
          elevation: 0,                // 자체 그림자는 끄고(컨테이너가 담당)
          shape: const CircleBorder(), // 동그란 모양 유지
          onPressed: () => _onTabTapped(2),
          child: const Icon(Icons.dynamic_feed, color: Colors.white), // 아이콘만 표시
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
