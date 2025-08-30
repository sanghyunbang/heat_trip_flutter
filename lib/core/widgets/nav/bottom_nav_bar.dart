import 'package:flutter/material.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.travel_explore),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_note),
          label: 'Schedule',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.stars_rounded),
          activeIcon: Icon(Icons.stars_rounded),
          label: 'For You',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Diary'),
        BottomNavigationBarItem(
          icon: Icon(Icons.stars_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
