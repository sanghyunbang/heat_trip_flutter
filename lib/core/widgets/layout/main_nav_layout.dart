import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/core/widgets/nav/bottom_nav_bar.dart';
import 'package:heat_trip_flutter/core/widgets/nav/tab_navigator.dart';
import 'package:heat_trip_flutter/features/curation/presentation/screens/select_emotion_screen.dart';
import 'package:heat_trip_flutter/features/explore/presentation/screens/explore_screen.dart';
import 'package:heat_trip_flutter/features/record/schedule_list_screen.dart';
import 'package:heat_trip_flutter/features/journey/presentation/screens/journey_screen.dart';
import 'package:heat_trip_flutter/features/profile/profile_screen.dart';

class MainNavLayout extends StatefulWidget {
  const MainNavLayout({super.key});

  @override
  State<MainNavLayout> createState() => _MainNavLayoutState();
}

class _MainNavLayoutState extends State<MainNavLayout> {
  int _selectedIndex = 2;
  final _navigatorKeys = List.generate(5, (_) => GlobalKey<NavigatorState>());

  void _onTabTapped(int index) {
    if (_selectedIndex == index) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Offstage(
          offstage: _selectedIndex != 0,
          child: TabNavigator(navigatorKey: _navigatorKeys[0], child: const ExploreScreen()),
        ),
        Offstage(
          offstage: _selectedIndex != 1,
          child: TabNavigator(navigatorKey: _navigatorKeys[1], child: const ScheduleListScreen()),
        ),
        Offstage(
          offstage: _selectedIndex != 2,
          child: TabNavigator(navigatorKey: _navigatorKeys[2], child: const SelectEmotionScreen()),
        ),
        Offstage(
          offstage: _selectedIndex != 3,
          child: TabNavigator(navigatorKey: _navigatorKeys[3], child: const JourneyScreen()),
        ),
        Offstage(
          offstage: _selectedIndex != 4,
          child: TabNavigator(navigatorKey: _navigatorKeys[4], child: const ProfileScreen()),
        ),
      ]),
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
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
