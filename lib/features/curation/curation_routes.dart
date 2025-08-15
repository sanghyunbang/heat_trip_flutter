import 'package:go_router/go_router.dart';
import 'presentation/screens/curation_screen.dart';
import 'presentation/screens/curation_result_screen.dart';

final List<RouteBase> curationRoutes = [
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
