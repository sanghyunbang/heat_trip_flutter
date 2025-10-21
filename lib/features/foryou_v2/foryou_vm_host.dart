import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:heat_trip_flutter/core/config/env.dart';
import 'package:heat_trip_flutter/features/foryou_v2/data/api_client.dart';
import 'package:heat_trip_flutter/features/foryou_v2/data/foryou_repository_impl.dart';
import 'package:heat_trip_flutter/features/foryou_v2/domain/models.dart';
import 'package:heat_trip_flutter/features/foryou_v2/state/foryou_vm.dart';
import 'package:heat_trip_flutter/features/foryou_v2/presentation/screens/home_screens.dart';

class ForYouVMHost extends StatefulWidget {
  const ForYouVMHost({super.key});

  @override
  State<ForYouVMHost> createState() => _ForYouVMHostState();
}

class _ForYouVMHostState extends State<ForYouVMHost> {
  late final ForYouVM vm = ForYouVM(
    repo: ForYouRepositoryImpl(ApiClient(baseUrl: _resolveBaseUrl())),
    initial: const RankRequest(
      pad: Pad(pleasure: 0, arousal: 0, dominance: 0),
      energy: 0,
      socialNeed: 0,
      purposeKeywords: [],
      topK: 50,
    ),
  );

  String _resolveBaseUrl() {
    final raw = Env.apiBase.trim(); // dart-define || .env
    final picked = raw.isEmpty ? 'http://10.0.2.2:8080' : raw;
    return picked.replaceFirst(RegExp(r'/*$'), ''); // 말단 / 제거
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ForYouVM>.value(
      value: vm, // 이미 생성된 인스턴스 재사용 → 상태 유지
      child: ForYouHomeScreen(vm: vm),
    );
  }
}
