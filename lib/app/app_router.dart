import 'package:go_router/go_router.dart';
import '../features/curation/presentation/routes/curation_routes.dart'
    as curation;

/// 전역 라우터: 각 기능(Feature)이 export한 라우트를 단순 병합
/// WHY: 기능별 라우트가 자기 파일에서만 변경되므로 Git 충돌이 적음
final GoRouter appRouter = GoRouter(
  routes: [
    ...curation.routes, // 큐레이션 기능 라우트 묶음
  ],
);
