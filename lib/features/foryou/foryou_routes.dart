import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:heat_trip_flutter/features/foryou/domain/entities.dart';
import 'package:heat_trip_flutter/features/foryou/data/api_client.dart';
import 'package:heat_trip_flutter/features/foryou/data/foryou_repository_impl.dart';
import 'package:heat_trip_flutter/features/foryou/state/foryou_vm.dart';
import 'package:heat_trip_flutter/features/foryou/presentation/screens/foryou_screen.dart';
import 'package:heat_trip_flutter/features/foryou/presentation/widgets/foryou_curation_sheet.dart';

// kBaseUrl을 이 파일에서 확실히 정의
import 'package:heat_trip_flutter/core/config/env.dart';

final String kBaseUrl = Env.apiBase ?? '';

final List<RouteBase> forYouRoutes = [
  GoRoute(
    path: '/foryou',
    name: 'forYou',
    builder: (context, state) {
      final vm = ForYouVM(
        repo: ForYouRepositoryImpl(ApiClient(baseUrl: kBaseUrl)),
        initial: const RankRequest(
          pad: Pad(pleasure: 1, arousal: -1, dominance: 1),
          energy: 0,
          socialNeed: -1,
          goals: ['quiet_reflection'], // 표준 키
          topK: 10,
        ),
      );

      return ChangeNotifierProvider<ForYouVM>(
        create: (_) => vm..load(),
        child: const ForYouScreen(),
      );
    },
    routes: [
      GoRoute(
        path: 'curation',
        name: 'forYouCuration',
        builder: (context, state) {
          // VM에서 현재 RankRequest를 꺼내어 시트에 전달
          final vm = context.read<ForYouVM>();
          final RankRequest req = vm.request; // ← ForYouVM에 getter 추가 필요
          return ForYouCurationSheet(initial: req);
        },
      ),
    ],
  ),
];
