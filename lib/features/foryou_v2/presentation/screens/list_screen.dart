import 'package:flutter/material.dart';
import '../../state/foryou_vm.dart';
import '../widgets/place_tile.dart';
import 'place_detail_screen.dart';

/// 추천 장소 목록 (카드 리스트)
class ListScreen extends StatelessWidget {
  final ForYouVM vm;
  const ListScreen({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final places = vm.places;
    if (places.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('추천 장소가 없습니다.'),
        ),
      );
    }
    return Column(
      children: places
          .map(
            (p) => Card(
              elevation: 0.6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: PlaceTile(
                place: p,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PlaceDetailScreen(place: p),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
