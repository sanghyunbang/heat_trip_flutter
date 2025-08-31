/// detail_appbars.dart
/// - FallbackAppBar: 로딩/에러/빈 상태에서 '뒤로가기' 보장
/// - SliverDetailAppBar: 성공 시 확장 앱바(갤러리/공유/즐겨찾기)
import 'package:flutter/material.dart';

/// 로딩/에러 화면 전용 AppBar.
/// PreferredSizeWidget을 구현해 Scaffold.appBar에 바로 사용 가능.
class FallbackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText; // 상단 타이틀
  final VoidCallback onBack; // 뒤로가기 콜백

  const FallbackAppBar({
    super.key,
    required this.titleText,
    required this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(titleText),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBack,
        tooltip: '뒤로가기',
      ),
    );
  }
}

/// 상세 성공 화면에서 쓰는 SliverAppBar.
/// - 상단 갤러리/공유/하트/뒤로가기 제공
/// - FlexibleSpaceBar로 타이틀 + 배경 위젯(갤러리)을 구성
class SliverDetailAppBar extends StatelessWidget {
  final String title;
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onToggleFavorite;
  final Widget gallery; // 배경으로 들어갈 갤러리 위젯

  const SliverDetailAppBar({
    super.key,
    required this.title,
    required this.isFavorite,
    required this.onBack,
    required this.onToggleFavorite,
    required this.gallery,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true, // 스크롤해도 상단 바는 고정
      stretch: true, // 오버스크롤시 신축 애니메이션
      expandedHeight: 260, // 확장 높이
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBack,
        tooltip: '뒤로가기',
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('공유 기능은 이후 연결하세요.')));
          },
          tooltip: '공유',
        ),
        IconButton(
          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
          color: isFavorite ? Colors.red : null,
          onPressed: onToggleFavorite,
          tooltip: '즐겨찾기',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: gallery, // 위에서 전달된 갤러리
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
