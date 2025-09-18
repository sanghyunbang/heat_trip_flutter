import 'package:go_router/go_router.dart';
import 'package:heat_trip_flutter/features/journey/domain/models.dart';
import 'package:heat_trip_flutter/features/journey/presentation/screens/diary_detail_screen.dart';
import 'package:heat_trip_flutter/features/journey/presentation/screens/journey_detail_screen.dart';
import 'package:heat_trip_flutter/features/journey/presentation/screens/new_diary_screen.dart';
import 'presentation/screens/journey_screen.dart';
import 'package:flutter/material.dart';

/// Journey(저니/라이브러리) 기능 라우트 모음
/// 중앙 라우터에서: `StatefulShellBranch(routes: journeyRoutes)` 형태로 끼워 넣습니다.
final List<RouteBase> journeyRoutes = [
  GoRoute(
    path: '/journey',
    name: 'journey',
    builder: (context, state) => const JourneyScreen(),
    routes: [
      GoRoute(
        path: 'journey/:id',
        name: 'journeyDetail',
        builder: (context, state) {
          final idStr = state.pathParameters['id']!;
          final id = int.parse(idStr); // String → int 변환
          final schedule = state.extra as Schedule?; // (선택) 초기 렌더용
          return JourneyDetailScreen(id: id, initial: schedule);
        },
        routes: [
          // ✅ 스케줄 연동 새 일기
          GoRoute(
            path: 'diary/new',
            name: 'newDiaryForSchedule',
            builder: (context, state) => NewDiaryForScheduleRoute(state: state),
          ),
          GoRoute(
            path: 'diary/:entryId',
            name: 'diaryDetail',
            builder: (context, state) {
              final entryIdStr = state.pathParameters['entryId']!;
              final entryId = int.parse(entryIdStr);
              final diaryEntry = state.extra as DiaryEntry?;

              if (diaryEntry == null) {
                return Scaffold(
                  body: Center(child: Text('Diary entry not found')),
                );
              }

              return DiaryDetailScreen(entry: diaryEntry);
            },
          ),
        ],
      ),
      // ✅ Diary 탭에서 진입 (스케줄 미연동)
      GoRoute(
        path: 'diary/new',
        name: 'newDiary',
        builder: (context, state) => const NewDiaryScreen(),
      ),
    ],
  ),
];
