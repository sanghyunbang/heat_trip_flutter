import 'package:flutter/material.dart';
import '../../domain/models.dart';

/// 리스트/그리드 공용 타일(간단)
class PlaceTile extends StatelessWidget {
  final Place place;
  final VoidCallback? onTap;
  const PlaceTile({super.key, required this.place, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: const CircleAvatar(child: Icon(Icons.park_outlined)),
      title: Text(place.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${place.cat3Code} • ${place.distanceKm != null ? '${place.distanceKm!.toStringAsFixed(1)}km' : '거리 정보 없음'}',
      ),
      trailing: Chip(
        label: Text('${(place.finalScore * 100).toStringAsFixed(0)}%'),
        backgroundColor: Colors.orange.shade50,
        shape: StadiumBorder(side: BorderSide(color: Colors.orange.shade200)),
      ),
    );
  }
}
