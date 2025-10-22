import 'package:flutter/material.dart';
// 리스트/기타 화면에서 쓰던 하트 위젯 그대로 재사용
import 'package:heat_trip_flutter/features/bookmark/presentation/widgets/bookmark_heart.dart';

/// 로딩/에러 화면 전용 AppBar.
class FallbackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final VoidCallback onBack;

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
/// - 갤러리/공유/하트(BookmarkHeart 재사용)
class SliverDetailAppBar extends StatelessWidget {
  final String title;        // (이미지 위 텍스트 표시는 사용하지 않음)
  final String contentId;    // 저장/해제 대상
  final VoidCallback onBack;
  final Widget gallery;      // 배경(갤러리)
  final VoidCallback? onAfterChange; // (BookmarkHeart가 전역 스토어 갱신하므로 보통 불필요)

  const SliverDetailAppBar({
    super.key,
    required this.title,
    required this.contentId,
    required this.onBack,
    required this.gallery,
    this.onAfterChange,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: 260,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBack,
        tooltip: '뒤로가기',
      ),
      actions: [
        // ❤️ 즐겨찾기(북마크): 리스트에서 쓰던 위젯을 그대로 사용
        // - 토글/컬렉션 선택/전역 스토어 갱신/컬렉션 동기화까지 처리됨
        BookmarkHeart(
          contentId: contentId,
          iconSize: 30,
        ),

        // IconButton(
        //   icon: const Icon(Icons.share_outlined),
        //   onPressed: () {
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       const SnackBar(content: Text('공유 기능은 이후 연결하세요.')),
        //     );
        //   },
        //   tooltip: '공유',
        // ),
      ],
      // 제목을 이미지 위에 표시하지 않도록 title 생략
      flexibleSpace: FlexibleSpaceBar(
        background: gallery,
      ),
    );
  }
}
