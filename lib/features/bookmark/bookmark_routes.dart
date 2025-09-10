// lib/features/bookmark/bookmark_routes.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:heat_trip_flutter/features/bookmark/presentation/collection_list_screen.dart';
import 'package:heat_trip_flutter/features/bookmark/presentation/collection_detail_screen.dart';

/// 북마크(컬렉션) 관련 라우트 묶음.
/// - 이름: collection_list, collection_detail
/// - 경로: /bookmarks, /bookmarks/collections/:collectionId
/// - title은 query param로 전달 (예: ?title=여행코스)
final List<RouteBase> bookmarkRoutes = <RouteBase>[
  GoRoute(
    path: '/bookmarks',
    name: 'collection_list',
    // 브랜치(탭) 안에서 pushNamed로 쌓이도록 parentNavigatorKey 설정은 하지 않습니다.
    pageBuilder: (_, __) => const MaterialPage(child: CollectionListScreen()),
  ),
  GoRoute(
    path: '/bookmarks/collections/:collectionId',
    name: 'collection_detail',
    pageBuilder: (context, state) {
      // collectionId 안전 파싱
      final idStr = state.pathParameters['collectionId'];
      final id = int.tryParse(idStr ?? '');

      // 제목은 쿼리에서 옵셔널로 받음 (없으면 기본값)
      final title = state.uri.queryParameters['title'] ?? '컬렉션';

      // 파라미터가 비정상이면 목록으로 대체 렌더(탭바 유지)
      if (id == null) {
        return const MaterialPage(child: CollectionListScreen());
      }

      return MaterialPage(
        child: CollectionDetailScreen(
          collectionId: id,
          title: title,
        ),
      );
    },
  ),
];
