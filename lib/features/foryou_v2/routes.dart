import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:heat_trip_flutter/features/foryou_v2/foryou_vm_host.dart';

final List<RouteBase> forYouV2Routes = [
  GoRoute(
    path: '/foryou_v2',
    name: 'forYouV2',
    pageBuilder: (context, state) => const MaterialPage(child: ForYouVMHost()),
  ),
];
