import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:heat_trip_flutter/auth/presentation/login_screen.dart';
import 'package:heat_trip_flutter/auth/service/auth_flow_manager.dart';
import 'package:heat_trip_flutter/theme.dart';
import 'package:heat_trip_flutter/home/start_screen.dart';
import 'package:heat_trip_flutter/home/recommendation_screen.dart';
import 'package:heat_trip_flutter/record/schedule_list_screen.dart';
import 'package:heat_trip_flutter/social/feed_screen.dart';
import 'package:heat_trip_flutter/social/bookmark_screen.dart';
import 'package:heat_trip_flutter/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 비동기 작업 전 필수
  await dotenv.load(); // dotenv 초기화
  runApp(const HeatTrip());
}

class HeatTrip extends StatelessWidget {
  const HeatTrip({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '여행의 온도',
      debugShowCheckedModeBanner: true, // 디버그 태그 보려면 true, 보지 않으려면 false
      // 로그인 화면이 먼저 뜨고, 로그인 돼 있으면 home으로 아니면 로그인 화면으로
      home: AuthFlowManager(
        homeScreen: const StartScreen(),
        loginScreen: LoginScreen(),
      ),
      // home: const StartScreen(),
      theme: theme(),
      /*
       * <컴포넌트 자체에서 route없이 이동시키는 방법>
       * TextButton(  // 버튼에서의 활용 예시 => 다른 버튼도 마찬가지!! (위젯에 따라 onTab으로 쓰는 것도 있음)
       *     onPressed: () {
       *     Navigator.push(                                            // 해당 부분을
       *       context,                                                 // 활용해서
       *       MaterialPageRoute(                                       // 이동이 가능합니다.
       *         builder: (context) => **MenuDetailPage(menu: menu)**,  // => 다음 **사이에 있는 부분에
       *       ),                                                       // 이동하고자 하는 페이지(위젯)의 클래스명을
       *     );                                                         // 적어주시면 됩니다.
       *   },
       *   child: Text('상세'),
       * )
       */
    );
  }
}

/* main Layout 화면 구현 : 하단 메뉴바 */
class HeatTripLayout extends StatefulWidget {
  const HeatTripLayout({super.key});

  @override
  State<HeatTripLayout> createState() => _HeatTripLayoutState();
}

class _HeatTripLayoutState extends State<HeatTripLayout> {
  int _selectedIndex = 2;

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          ScheduleListScreen(), // index 0 : 여행 스케줄러 화면
          FeedScreen(), // index 1 : 피드 화면
          RecommendationScreen(), // index 2 : 관광지 추천 화면
          BookmarkScreen(), // index 3 : 북마크 화면
          ProfileScreen(), // index 4 : 마이페이지 화면
        ],
      ),

      /* 하단 메뉴바 */
      // 가운데 버튼 디자인 : 관광지 추천 화면
      floatingActionButton: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4), // 흰색 테두리
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.indigo,
          shape: const CircleBorder(),
          onPressed: () {
            _onTabTapped(2); // 추천 관광지
          },
          elevation: 4.0,
          child: Icon(Icons.travel_explore, color: Colors.white),
        ),
      ),
      // 흰색 부분 메뉴 디자인
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          _onTabTapped(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'record'),
          BottomNavigationBarItem(
            icon: Icon(Icons.dynamic_feed),
            label: 'feed',
          ),
          BottomNavigationBarItem(
            icon: Opacity(
              opacity: 0.0,
              child: Icon(Icons.travel_explore),
            ), // 아이콘 위치 유지하면서 보이지 않게 설정
            label: 'for you',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'bookmark',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'profile'),
        ],
      ),
    );
  }
}
