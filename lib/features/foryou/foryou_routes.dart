import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'domain/entities.dart';
import 'data/api_client.dart';
import 'data/foryou_repository_impl.dart';
import 'state/foryou_vm.dart';
import 'presentation/screens/foryou_screen.dart';
import '../curation/presentation/screens/curation_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:heat_trip_flutter/core/config/env.dart';

final String kBaseUrl = Env.apiBase ?? '';

final List<RouteBase> forYouRoutes = [
  GoRoute(
    path: '/foryou',
    name: 'forYou',
    // 👇 builder에서 Provider를 만들고, 반드시 "새 컨텍스트"로 ForYouScreen을 빌드
    builder: (context, state) {
      final vm = ForYouVM(
        repo: ForYouRepositoryImpl(ApiClient(baseUrl: kBaseUrl)),
        initial: const RankRequest(
          pad: Pad(pleasure: 1, arousal: -1, dominance: 1),
          energy: 0,
          socialNeed: -1,
          goals: ['quiet_reflection'],
          topK: 10,
        ),
      );

      return ChangeNotifierProvider<ForYouVM>(
        create: (_) => vm..load(),
        // ⬇️ 이 Builder가 핵심: Provider "아래"의 컨텍스트로 화면을 빌드
        child: Builder(builder: (_) => const ForYouScreen()),
      );
    },
    routes: [
      GoRoute(
        path: 'curation',
        name: 'forYouCuration',
        builder: (_, __) => const CurationScreen(),
      ),
    ],
  ),
];
