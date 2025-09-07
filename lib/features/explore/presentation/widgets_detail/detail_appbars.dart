// lib/features/explore/presentation/widgets_detail/detail_appbars.dart
import 'package:flutter/material.dart';

// 북마크 전역 스토어 & 인스타식 컬렉션 선택 시트
import 'package:heat_trip_flutter/features/bookmark/service/bookmark_store.dart';
import 'package:heat_trip_flutter/features/bookmark/presentation/collection_picker_sheet.dart';
import 'package:heat_trip_flutter/features/bookmark/service/collection_store.dart';
// 모든 컬렉션에서 해당 콘텐츠 제거 확장
import 'package:heat_trip_flutter/features/bookmark/service/collection_store_ext.dart';

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
class SliverDetailAppBar extends StatelessWidget {
  final String title;        // (이미지 위 텍스트 표시는 사용하지 않음)
  final String contentId;    // 저장/해제 대상
  final VoidCallback onBack;
  final Widget gallery;      // 배경(갤러리)
  final VoidCallback? onAfterChange;

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
    // 상세 화면에서도 스토어 초기화를 보장 (탭을 안 거치고 들어온 경우 대비)
    BookmarkStore.instance.ensureInitialized();

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
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('공유 기능은 이후 연결하세요.')),
            );
          },
          tooltip: '공유',
        ),

        // ❤️ 즐겨찾기(북마크) — 전역 스토어를 구독해 실시간 아이콘 상태 반영
        AnimatedBuilder(
          animation: BookmarkStore.instance,
          builder: (context, _) {
            final isOn = BookmarkStore.instance.isBookmarked(contentId);

            return IconButton(
              icon: Icon(isOn ? Icons.favorite : Icons.favorite_border),
              color: isOn ? Colors.red : null,
              tooltip: '북마크',
              onPressed: () async {
                try {
                  if (contentId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('콘텐츠 ID가 없어 북마크할 수 없어요')),
                    );
                    return;
                  }

                  // 보수적으로 재확인/초기화
                  await BookmarkStore.instance.ensureInitialized();
                  final wasOn = BookmarkStore.instance.isBookmarked(contentId);

                  // 인스타 스타일 시트
                  final res = await showCollectionPickerSheet(
                    context,
                    alreadyBookmarked: wasOn,
                  );
                  if (res == null) return; // 취소

                  // 작은 유틸: 실패해도 다음 작업 계속
                  Future<void> _ignoreError(Future<void> f) async {
                    try { await f; } catch (_) {}
                  }

                  // === 해제: 반드시 북마크 + 컬렉션 아이템 모두 제거 ===
                  if (res.removed) {
                    // 1) 북마크가 켜져 있으면 끄기 (실패해도 계속)
                    if (BookmarkStore.instance.isBookmarked(contentId)) {
                      await _ignoreError(BookmarkStore.instance.toggle(contentId));
                    }
                    // 2) 모든 컬렉션에서 해당 콘텐츠 제거 (실패해도 계속)
                    await _ignoreError(CollectionStore.instance.removeContentEverywhere(contentId));
                    // 3) 컬렉션 목록/카운트 강제 새로고침
                    await _ignoreError(CollectionStore.instance.refresh());

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('북마크에서 제거했어요')),
                      );
                    }
                    onAfterChange?.call();
                    return;
                  }

                  // === 저장(컬렉션 선택 여부 포함) ===
                  if (!wasOn) {
                    await BookmarkStore.instance.toggle(
                      contentId,
                      collectionId: res.collectionId?.toString(),
                    );
                    // 컬렉션에 붙였으면 즉시 반영
                    if (res.collectionId != null) {
                      await _ignoreError(CollectionStore.instance.refresh());
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            res.collectionId == null
                                ? '북마크에 저장했어요'
                                : '선택한 컬렉션에 저장했어요',
                          ),
                        ),
                      );
                    }
                  } else {
                    // 이미 저장 상태에서 다른 컬렉션을 선택: remove → add(해당 컬렉션)
                    if (res.collectionId != null) {
                      await _ignoreError(BookmarkStore.instance.toggle(contentId)); // remove
                      await BookmarkStore.instance.toggle(
                        contentId,
                        collectionId: res.collectionId!.toString(),
                      ); // add+attach
                      await _ignoreError(CollectionStore.instance.refresh());
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('선택한 컬렉션에 저장했어요')),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('이미 북마크에 있어요')),
                        );
                      }
                    }
                  }

                  onAfterChange?.call();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('처리 중 오류가 발생했어요: $e')),
                    );
                  }
                }
              },
            );
          },
        ),
      ],
      // 제목을 이미지 위에 표시하지 않도록 title 생략
      flexibleSpace: FlexibleSpaceBar(
        background: gallery,
      ),
    );
  }
}


// /// detail_appbars.dart
// /// - FallbackAppBar: 로딩/에러/빈 상태에서 '뒤로가기' 보장
// /// - SliverDetailAppBar: 성공 시 확장 앱바(갤러리/공유/즐겨찾기)
// import 'package:flutter/material.dart';
//
// // 북마크 전역 스토어 & 인스타식 컬렉션 선택 시트
// import 'package:heat_trip_flutter/features/bookmark/service/bookmark_store.dart';
// import 'package:heat_trip_flutter/features/bookmark/presentation/collection_picker_sheet.dart';
//
// /// 로딩/에러 화면 전용 AppBar.
// /// PreferredSizeWidget을 구현해 Scaffold.appBar에 바로 사용 가능.
// class FallbackAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String titleText; // 상단 타이틀
//   final VoidCallback onBack; // 뒤로가기 콜백
//
//   const FallbackAppBar({
//     super.key,
//     required this.titleText,
//     required this.onBack,
//   });
//
//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
//
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       title: Text(titleText),
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back),
//         onPressed: onBack,
//         tooltip: '뒤로가기',
//       ),
//     );
//   }
// }
//
// /// 상세 성공 화면에서 쓰는 SliverAppBar.
// /// - 상단 갤러리/공유/하트/뒤로가기 제공
// /// - FlexibleSpaceBar로 타이틀 + 배경 위젯(갤러리)을 구성
// class SliverDetailAppBar extends StatelessWidget {
//   final String title;
//   final String contentId;        // ✅ 어떤 장소를 저장/해제할지
//   final VoidCallback onBack;
//   final Widget gallery;          // 배경으로 들어갈 갤러리 위젯
//   final VoidCallback? onAfterChange; // 저장/해제 후 부모에서 추가로 리빌드가 필요하면 사용(선택)
//
//   const SliverDetailAppBar({
//     super.key,
//     required this.title,
//     required this.contentId,
//     required this.onBack,
//     required this.gallery,
//     this.onAfterChange,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // ✅ 상세 화면에서도 스토어 초기화를 보장 (탭을 안 거치고 들어온 경우 대비)
//     BookmarkStore.instance.ensureInitialized();
//
//     return SliverAppBar(
//       pinned: true,           // 스크롤해도 상단 바는 고정
//       stretch: true,          // 오버스크롤시 신축 애니메이션
//       expandedHeight: 260,    // 확장 높이
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back),
//         onPressed: onBack,
//         tooltip: '뒤로가기',
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.share_outlined),
//           onPressed: () {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('공유 기능은 이후 연결하세요.')),
//             );
//           },
//           tooltip: '공유',
//         ),
//
//         // ❤️ 즐겨찾기(북마크) — 전역 스토어를 구독해 실시간 아이콘 상태 반영
//         AnimatedBuilder(
//           animation: BookmarkStore.instance,
//           builder: (context, _) {
//             final isOn = BookmarkStore.instance.isBookmarked(contentId);
//             return IconButton(
//               icon: Icon(isOn ? Icons.favorite : Icons.favorite_border),
//               color: isOn ? Colors.red : null,
//               tooltip: '북마크',
//               onPressed: () async {
//                 try {
//                   if (contentId.isEmpty) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('콘텐츠 ID가 없어 북마크할 수 없어요')),
//                     );
//                     return;
//                   }
//
//                   // 눌렀을 때도 초기화 보장
//                   await BookmarkStore.instance.ensureInitialized();
//                   final isOnNow = BookmarkStore.instance.isBookmarked(contentId);
//
//                   // 인스타 스타일 바텀시트로 저장 위치/해제 선택
//                   final res = await showCollectionPickerSheet(
//                     context,
//                     alreadyBookmarked: isOnNow,
//                   );
//                   if (res == null) return; // 취소
//
//                   // 해제
//                   if (res.removed) {
//                     if (isOnNow) {
//                       await BookmarkStore.instance.toggle(contentId);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('북마크에서 제거했어요')),
//                       );
//                       onAfterChange?.call();
//                     }
//                     return;
//                   }
//
//                   // 저장(컬렉션 선택 여부 포함)
//                   if (!isOnNow) {
//                     await BookmarkStore.instance.toggle(
//                       contentId,
//                       collectionId: res.collectionId?.toString(),
//                     );
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text(
//                           res.collectionId == null
//                               ? '북마크에 저장했어요'
//                               : '선택한 컬렉션에 저장했어요',
//                         ),
//                       ),
//                     );
//                   } else {
//                     // 이미 저장되어 있는데 컬렉션을 고른 경우: remove → add(컬렉션첨부)
//                     if (res.collectionId != null) {
//                       await BookmarkStore.instance.toggle(contentId); // remove
//                       await BookmarkStore.instance.toggle(
//                         contentId,
//                         collectionId: res.collectionId!.toString(),
//                       ); // add+attach
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('선택한 컬렉션에 저장했어요')),
//                       );
//                     } else {
//                       // '그냥 저장하기'를 눌렀고 이미 저장된 상태
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('이미 북마크에 있어요')),
//                       );
//                     }
//                   }
//
//                   onAfterChange?.call();
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('처리 중 오류가 발생했어요: $e')),
//                   );
//                 }
//               },
//             );
//           },
//         ),
//       ],
//       flexibleSpace: FlexibleSpaceBar(
//         background: gallery, // 위에서 전달된 갤러리
//         title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
//       ),
//     );
//   }
// }
