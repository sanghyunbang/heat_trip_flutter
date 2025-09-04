import 'package:flutter/material.dart';

/// 큰 배너 카드(이미지 + 그라데이션 + 버튼)
/// - 로컬 에셋 없이 네트워크 URL만 사용
/// - 주 URL이 실패하면 다음 URL로 자동 폴백
class ThemeCard extends StatelessWidget {
  /// 우선 시도할 URL(목에서 넘김)
  final String primaryImageUrl;

  /// 폴백용 URL들(미리 검증된 Unsplash 샘플)
  /// - primary가 실패하면 순서대로 시도
  final List<String> fallbackImageUrls;

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ThemeCard({
    super.key,
    required this.primaryImageUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.fallbackImageUrls = const [
      // 자연/정원 느낌
      'https://images.unsplash.com/photo-1526779259212-939e64788e3c?auto=format&fit=crop&w=1600&q=80',
      // 사찰/평온 느낌
      'https://images.unsplash.com/photo-1542038784456-1ea8e935640e?auto=format&fit=crop&w=1600&q=80',
      // 숲/힐링 느낌
      'https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=1600&q=80',
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _MultiUrlImage(
                urls: [primaryImageUrl, ...fallbackImageUrls],
              ),
            ),
            // 하단 그라데이션
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
              ),
            ),
            // 텍스트 & 버튼
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: onTap,
                    child: const Text('테마 여행지 보기'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 여러 개의 네트워크 이미지를 순차적으로 시도하는 위젯.
/// - 현재 URL이 에러면 다음 URL로 자동 전환
/// - 모든 URL 실패 시 심플한 플레이스홀더 표시
class _MultiUrlImage extends StatefulWidget {
  final List<String> urls;
  const _MultiUrlImage({required this.urls});

  @override
  State<_MultiUrlImage> createState() => _MultiUrlImageState();
}

class _MultiUrlImageState extends State<_MultiUrlImage> {
  int idx = 0;

  @override
  Widget build(BuildContext context) {
    // 빈 컨테이너로 시작하면 배너 높이가 사라지므로, 항상 영역을 채워줍니다.
    return Image.network(
      widget.urls[idx],
      fit: BoxFit.cover,
      // 에러 발생 시 다음 URL로 교체
      errorBuilder: (_, __, ___) {
        if (idx < widget.urls.length - 1) {
          // 다음 프레임에 안전하게 setState
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => idx++);
          });
        }
        // 전환 동안엔 은은한 배경만
        return const ColoredBox(color: Color(0xFFEDEDED));
      },
      // 첫 프레임 수신 시 자연스러운 페이드인
      frameBuilder: (context, child, frame, _) {
        if (frame == null) {
          return const ColoredBox(color: Color(0xFFEDEDED));
        }
        return AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 200),
          child: child,
        );
      },
      filterQuality: FilterQuality.medium,
    );
  }
}
