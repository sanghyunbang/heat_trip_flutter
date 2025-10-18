import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heat_trip_flutter/features/foryou_v2/presentation/screens/home_screens.dart';
import 'package:provider/provider.dart';

import '../../core/config/env.dart';
import 'data/api_client.dart';
import 'data/foryou_repository_impl.dart';
import 'domain/models.dart';
import 'state/foryou_vm.dart';

final String kBaseUrl = Env.apiBase ?? '';

/// 단일 엔트리: /foryou_v2
final List<RouteBase> forYouV2Routes = [
  GoRoute(
    path: '/foryou_v2',
    name: 'forYouV2',
    builder: (context, state) {
      final vm = ForYouVM(
        repo: ForYouRepositoryImpl(ApiClient(baseUrl: kBaseUrl)),
        initial: const RankRequest(
          pad: Pad(pleasure: 0.0, arousal: 0.0, dominance: 0.0),
          energy: 0.0,
          socialNeed: 0.0,
          purposeKeywords: [],
          topK: 20,
        ),
      );
      return ChangeNotifierProvider(
        create: (_) => vm,
        child: ForYouHomeScreen(vm: vm),
      );
    },
  ),
];
