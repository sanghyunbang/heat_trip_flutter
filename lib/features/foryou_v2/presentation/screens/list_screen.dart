import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../state/foryou_vm.dart';
import '../widgets/place_tile.dart';

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
      children: places.map((p) {
        return Card(
          elevation: 0.6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: PlaceTile(
            place: p,
            onTap: () {
              final typeId = p.contentTypeId ?? 12;
              context.pushNamed(
                'explore_detail',
                pathParameters: {
                  'contentId': '${p.placeId}',
                  'contentTypeId': '$typeId',
                },
                extra: p.firstImageUrl,
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
