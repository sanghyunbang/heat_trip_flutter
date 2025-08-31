/// content_detail_view.dart
/// detailSpec(스키마)에 따라 detailRaw의 값이 있는 항목만 자동으로 렌더링
import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/explore/domain/entity_detail/place_detail.dart';
import 'package:heat_trip_flutter/features/explore/domain_detail/detail_spec.dart';
import 'package:heat_trip_flutter/features/explore/domain_detail/field_descriptor.dart';

class ContentDetailView extends StatelessWidget {
  final PlaceDetail detail;
  const ContentDetailView({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final spec = detailSpec[detail.contentType] ?? const <FieldDescriptor>[];
    final tiles = <Widget>[];

    for (final d in spec) {
      final raw = detail.detailRaw[d.key];
      if (raw == null) continue;
      final text = d.format != null ? d.format!(raw) : raw.toString().trim();
      if (text.isEmpty) continue;

      tiles.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(d.icon, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(text),
                ],
              ),
            ),
          ],
        ),
      );
      tiles.add(const Divider(height: 20));
    }

    if (tiles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('표시할 상세 항목이 없습니다.'),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(children: tiles),
      ),
    );
  }
}
