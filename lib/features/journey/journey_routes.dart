import 'package:go_router/go_router.dart';
import 'presentation/screens/journey_screen.dart';

/// Journey(저니/라이브러리) 기능 라우트 모음
/// 중앙 라우터에서: `StatefulShellBranch(routes: journeyRoutes)` 형태로 끼워 넣습니다.
final List<RouteBase> journeyRoutes = [
  GoRoute(
    path: '/journey',
    name: 'journey',
    builder: (context, state) => const JourneyScreen(),
  ),
];
