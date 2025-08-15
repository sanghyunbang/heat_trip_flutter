import 'package:go_router/go_router.dart';
import 'presentation/screens/explore_screen.dart';

/// Explore(탐색) 기능 라우트 모음
/// 중앙 라우터에서: `StatefulShellBranch(routes: exploreRoutes)` 형태로 끼워 넣습니다.
final List<RouteBase> exploreRoutes = [
  GoRoute(
    path: '/explore',
    name: 'explore',
    builder: (context, state) => const ExploreScreen(),
  ),
];
