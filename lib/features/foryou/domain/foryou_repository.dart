// lib/features/foryou/domain/foryou_repository.dart

// Domain 레이어의 엔티티들
import 'entities/context.dart';
import 'entities/rank_item.dart';
import 'entities/feedback_event.dart';

/// -----------------------------------------
/// Repository 인터페이스 (추상 클래스)
/// -----------------------------------------
/// - Domain Layer에서 정의됨
/// - "무엇을 할 수 있는가?"만 선언 (구현은 없음)
/// - Data Layer (구현체)가 이 인터페이스를 따름으로써
///   Domain → Data 의존성을 단방향으로 유지
/// - 클린 아키텍처/DDD(도메인 주도 설계) 패턴의 핵심 구조
abstract class ForYouRepository {
  /// Top-K 추천 결과를 가져오는 메서드
  /// - 입력: 사용자의 Context (PAD 감정 상태, 환경 선호 등)
  /// - 출력: 추천된 RankItem 리스트
  /// - 기본 k 값은 8 (즉, 상위 8개 추천)
  Future<List<RankItem>> getTopK(Context ctx, {int k = 8});

  /// 사용자 피드백을 서버에 전송하는 메서드
  /// - 입력: FeedbackEvent (Context, 대상 카테고리, 보상 등)
  /// - 출력: 없음 (Future<void>)
  Future<void> sendFeedback(FeedbackEvent fb);
}





// lib/features/foryou/domain/foryou_repository.dart

// 데이터 레이어에서 API 호출을 추상화해주는 리포지토리 클래스.
// presentation → domain → data 흐름을 명확하게 분리해주는 역할입니다.
// (presentation 레이어는 이 클래스를 통해 API 호출을 하게 됩니다)

// import 'package:heat_trip_flutter/features/foryou/data/dto/context_dto.dart'; // 추천 요청에 사용될 DTO
// import 'package:heat_trip_flutter/features/foryou/data/dto/feedback_dto.dart'; // 피드백 전송 DTO
// import 'package:heat_trip_flutter/features/foryou/data/dto/rank_item_dto.dart'; // 추천 결과 DTO
// import 'package:heat_trip_flutter/features/foryou/data/remote/recsys_api.dart'; // 실제 API 호출 클래스

// class ForYouRepository {
//   final RecSysApi api; // REST API 핸들러 클래스 의존성

//   // 생성자: 외부에서 RecSysApi를 주입 받음
//   ForYouRepository(this.api);

//   /// 추천 목록 요청 함수
//   /// - [ctx]: 입력 컨텍스트(PAD + 환경)
//   /// - [k]: 추천 개수 (Top-K)
//   /// - 반환: 추천 결과 리스트 (category, score)
//   Future<List<RankItemDto>> getTopK(ContextDto ctx, {int k = 8}) =>
//       api.rankCategories(ctx, k: k);

//   /// 사용자 행동 기반 피드백 전송
//   /// - [fb]: 컨텍스트 + 선택된 카테고리 + 보상값 포함
//   Future<void> sendFeedback(FeedbackDto fb) => api.sendFeedback(fb);
// }

