import 'package:flutter/material.dart';

class PopularContent {
  final String title;
  final int views;
  const PopularContent(this.title, this.views);
}

/// 핑크 카메라 아이콘 리스트 + '>' 화살표
class PopularContentList extends StatelessWidget {
  final List<PopularContent> items;
  const PopularContentList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.camera_alt_outlined, color: Colors.pink),
                const SizedBox(width: 6),
                Text(
                  '인기 여행 콘텐츠',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((e) => _row(context, e)),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext ctx, PopularContent e) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.pink.withOpacity(.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.camera_alt_outlined, color: Colors.pink),
      ),
      title: Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${e.views} 조회수',
        style: Theme.of(ctx).textTheme.bodySmall,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {}, // TODO: 연결 시 상세로
    );
  }
}
