// lib/features/bookmark/presentation/widgets/bookmark_heart.dart
import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/bookmark/service/bookmark_store.dart';
import 'package:heat_trip_flutter/features/bookmark/service/collection_store.dart';
import 'package:heat_trip_flutter/features/bookmark/service/collection_store_ext.dart';
import 'package:heat_trip_flutter/features/bookmark/presentation/collection_picker_sheet.dart';

/// contentId만 주면 하트 토글 + 컬렉션 선택 시트
class BookmarkHeart extends StatelessWidget {
  const BookmarkHeart({
    super.key,
    required this.contentId,
    this.collectionId,        // 특정 컬렉션에 바로 저장하고 싶을 때만 사용(보통은 null)
    this.iconSize = 24,
  });

  final String contentId;
  final String? collectionId;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final store = BookmarkStore.instance;

    return FutureBuilder(
      future: store.ensureInitialized(),
      builder: (context, _) {
        return AnimatedBuilder(
          animation: store,
          builder: (context, __) {
            final isOn = store.isBookmarked(contentId);

            return InkWell(
              customBorder: const CircleBorder(),
              onTap: () async {
                try {
                  // 1) 현재 상태 다시 확인
                  await store.ensureInitialized();
                  final isOnNow = store.isBookmarked(contentId);

                  // 2) 인스타 스타일 바텀 시트 표시
                  final res = await showCollectionPickerSheet(
                    context,
                    alreadyBookmarked: isOnNow,
                  );
                  if (res == null) return; // 사용자가 닫음

                  // 3) 해제 선택
                  if (res.removed) {
                    if (isOnNow) {
                      await store.toggle(contentId); // 북마크 해제
                      await CollectionStore.instance.removeContentEverywhere(contentId); // 컬렉션에서도 제거
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('북마크에서 제거했어요')),
                      );
                    }
                    return;
                  }

                  // 4) 저장(컬렉션 선택 여부)
                  if (!isOnNow) {
                    // 아직 저장 안됨 → 선택한 컬렉션과 함께 저장
                    await store.toggle(
                      contentId,
                      collectionId: res.collectionId?.toString(),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          res.collectionId == null
                              ? '북마크에 저장했어요'
                              : '선택한 컬렉션에 저장했어요',
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(milliseconds: 900),
                      ),
                    );
                  } else {
                    // 이미 저장됨 → 컬렉션을 골랐다면 이동/추가(간단히 remove→add)
                    if (res.collectionId != null) {
                      await store.toggle(contentId); // remove
                      await store.toggle(
                        contentId,
                        collectionId: res.collectionId!.toString(),
                      ); // add+attach
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('선택한 컬렉션에 저장했어요')),
                      );
                    } else {
                      // '그냥 저장하기'를 눌렀고 이미 저장 상태면 알림만
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('이미 북마크에 있어요')),
                      );
                    }
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('처리 중 오류가 발생했어요: $e')),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  isOn ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: iconSize,
                  color: isOn ? Colors.redAccent : null,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
