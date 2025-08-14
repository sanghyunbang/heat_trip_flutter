import 'package:flutter/material.dart';

/// "Continue watching" 카드 위젯
class CourseItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String author;
  final double progress;

  const CourseItem({
    super.key,
    required this.icon,
    required this.title,
    required this.author,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final p = (progress * 100).round();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: 상세 이동
        },
        child: Container(
          height: 74,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              // 좌측 컬러 바
              Container(
                width: 6,
                height: double.infinity,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              CircleAvatar(radius: 18, child: Icon(icon)),
              const SizedBox(width: 12),

              // 텍스트
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(author,
                        style:
                        const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // 진행률
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 42,
                    height: 42,
                    child: CircularProgressIndicator(value: progress, strokeWidth: 4),
                  ),
                  Text('$p%',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600)
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
