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
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.travel_explore), label: 'explore'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'record'),
        BottomNavigationBarItem(
          icon: Opacity(opacity: 0.0, child: Icon(Icons.dynamic_feed)),
          label: 'for you',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'journey'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'profile'),
      ],
    );
  }
}
