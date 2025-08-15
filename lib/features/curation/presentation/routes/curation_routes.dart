import 'package:go_router/go_router.dart';
import '../screens/curation_screen.dart';
import '../screens/curation_result_screen.dart';

/// WHAT: 큐레이션 기능 전용 라우트 번들
/// WHY: 기능별(List<RouteBase>)로 내보내 최상단 라우터에서 단순 병합
final List<RouteBase> routes = [
  GoRoute(
    path: '/curation',
    name: 'curation',
    builder: (context, state) => const CurationScreen(),
    routes: [
      GoRoute(
        path: 'result',
        name: 'curationResult',
        builder: (context, state) => const CurationResultScreen(),
      ),
    ],
  ),
];
