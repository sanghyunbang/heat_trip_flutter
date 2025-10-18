import 'package:flutter/material.dart';
import '../../state/foryou_vm.dart';

/// 지도 자리(목업). google_maps_flutter / flutter_map으로 교체 예정.
class MapScreen extends StatelessWidget {
  final ForYouVM vm;
  const MapScreen({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F2),
        border: Border.all(color: Colors.orange.shade100),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text('지도 컴포넌트 연결 위치'),
    );
  }
}
