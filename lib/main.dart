// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// [0816] go_router 설정 객체만 받아오면 됨 (화면은 라우터 파일에서 import)
import 'package:heat_trip_flutter/app/app_router.dart';

// [0816] 기존 테마 그대로 사용
import 'package:heat_trip_flutter/core/theme/theme.dart';

Future<void> main() async {
  // WHY: dotenv, SharedPreferences 등 비동기 초기화 전에 바인딩 필요
  WidgetsFlutterBinding.ensureInitialized();

  // WHY: .env를 먼저 로드해두면 라우터나 서비스에서 곧바로 사용 가능
  // (기본은 프로젝트 루트의 `.env`; 파일명이 다르면 fileName 옵션으로 지정)
  await dotenv.load(); // e.g., await dotenv.load(fileName: '.env');

  runApp(const HeatTrip());
}

class HeatTrip extends StatelessWidget {
  const HeatTrip({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // WHY: go_router를 쓰면 네비게이션/URL/딥링크를 일원화할 수 있음
      routerConfig: appRouter, // ← app/app_router.dart 에서 구성
      theme: theme(), // ← core/theme/theme.dart (그대로 재사용)
      title: '여행의 온도',
      debugShowCheckedModeBanner: false, // 개발 중 배너 보려면 true
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:heat_trip_flutter/features/auth/presentation/login_screen.dart';
// import 'package:heat_trip_flutter/features/auth/service/auth_flow_manager.dart';
// import 'package:heat_trip_flutter/core/theme/theme.dart';
// import 'package:heat_trip_flutter/presentation/screens/start_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized(); // 비동기 작업 전 필수
//   await dotenv.load(); // dotenv 초기화
//   runApp(const HeatTrip());
// }

// class HeatTrip extends StatelessWidget {
//   const HeatTrip({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: '여행의 온도',
//       debugShowCheckedModeBanner: true, // 디버그 태그 보려면 true, 보지 않으려면 false
//       // 로그인 화면이 먼저 뜨고, 로그인 돼 있으면 home으로 아니면 로그인 화면으로
//       // home: AuthFlowManager(
//       //   homeScreen: const StartScreen(),
//       //   loginScreen: LoginScreen(),
//       // ),
//       home: const StartScreen(),
//       theme: theme(),
//       /*
//        * <컴포넌트 자체에서 route없이 이동시키는 방법>
//        * TextButton(  // 버튼에서의 활용 예시 => 다른 버튼도 마찬가지!! (위젯에 따라 onTab으로 쓰는 것도 있음)
//        *     onPressed: () {
//        *     Navigator.push(                                            // 해당 부분을
//        *       context,                                                 // 활용해서
//        *       MaterialPageRoute(                                       // 이동이 가능합니다.
//        *         builder: (context) => **MenuDetailPage(menu: menu)**,  // => 다음 **사이에 있는 부분에
//        *       ),                                                       // 이동하고자 하는 페이지(위젯)의 클래스명을
//        *     );                                                         // 적어주시면 됩니다.
//        *   },
//        *   child: Text('상세'),
//        * )
//        */
//     );
//   }
// }
