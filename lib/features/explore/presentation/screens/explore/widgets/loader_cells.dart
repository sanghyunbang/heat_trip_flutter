// lib/features/explore/presentation/screens/explore/widgets/loader_cells.dart
//
// 그리드의 특별 셀: 로딩/마지막 도달 안내

import 'package:flutter/material.dart';

class GridLoaderCell extends StatelessWidget {
  const GridLoaderCell({super.key});
  @override
  Widget build(BuildContext context) =>
      const Card(child: Center(child: CircularProgressIndicator()));
}

class GridNoMoreCell extends StatelessWidget {
  const GridNoMoreCell({super.key});
  @override
  Widget build(BuildContext context) => const Card(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('No more results'),
          ),
        ),
      );
}
