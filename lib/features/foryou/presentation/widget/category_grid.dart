import 'package:flutter/material.dart';

/// TSX 목처럼 2열 카드로 "여행 카테고리"를 표시.
/// 아래에 "감정 기반 추천 안내" 배너를 추가합니다.
class CategoryGrid extends StatelessWidget {
  final List<CategoryTileData> items;
  final VoidCallback onSeeAll; // "전체 보기" 버튼
  final void Function(String id) onTap;

  const CategoryGrid({
    super.key,
    required this.items,
    required this.onSeeAll,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          children: [
            // 제목
            Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: Colors.blue),
                const SizedBox(width: 6),
                Text('여행 카테고리', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),

            // ---- 2열 그리드 (오버플로 방지: 높이를 넉넉히 줌)
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                // ↓ 값이 낮을수록 세로가 넓어져서 overflow를 방지합니다.
                childAspectRatio: 2.2, // (기존 3.7 → 2.4 로 조정)
              ),
              itemBuilder: (_, i) => _CategoryTile(
                data: items[i],
                onTap: () => onTap(items[i].id),
              ),
            ),

            const SizedBox(height: 12),

            // ---- 감정 기반 추천 안내
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF1FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.psychology_alt_outlined,
                    color: Colors.indigo,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '지금 기록한 감정과 에너지/소셜 수준을 반영해\n맞춤 카테고리를 추천해요.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onSeeAll,
                child: const Text('전체 보기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryTileData {
  final String id; // 'nature' ...
  final String labelKo; // '자연'
  final int count; // 45
  final IconData icon;
  final Color color;
  const CategoryTileData({
    required this.id,
    required this.labelKo,
    required this.count,
    required this.icon,
    required this.color,
  });
}

class _CategoryTile extends StatelessWidget {
  final CategoryTileData data;
  final VoidCallback onTap;
  const _CategoryTile({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          // 패딩을 줄이고 아이콘/텍스트 크기를 최적화
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: data.color.withOpacity(.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(data.icon, color: data.color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.labelKo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${data.count}곳',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
