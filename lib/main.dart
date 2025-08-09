import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:heat_trip_flutter/features/auth/presentation/login_screen.dart';
import 'package:heat_trip_flutter/features/auth/service/auth_flow_manager.dart';
import 'package:heat_trip_flutter/core/theme/theme.dart';
import 'package:heat_trip_flutter/presentation/screens/start_screen.dart';

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
      // home: AuthFlowManager(
      //   homeScreen: const StartScreen(),
      //   loginScreen: LoginScreen(),
      // ),
      home: const StartScreen(),
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
