// lib/features/foryou/domain/foryou_repository.dart

// 데이터 레이어에서 API 호출을 추상화해주는 리포지토리 클래스.
// presentation → domain → data 흐름을 명확하게 분리해주는 역할입니다.
// (presentation 레이어는 이 클래스를 통해 API 호출을 하게 됩니다)

import 'package:heat_trip_flutter/features/foryou/data/dto/context_dto.dart'; // 추천 요청에 사용될 DTO
import 'package:heat_trip_flutter/features/foryou/data/dto/feedback_dto.dart'; // 피드백 전송 DTO
import 'package:heat_trip_flutter/features/foryou/data/dto/rank_item_dto.dart'; // 추천 결과 DTO
import 'package:heat_trip_flutter/features/foryou/data/remote/recsys_api.dart'; // 실제 API 호출 클래스

class ForYouRepository {
  final RecSysApi api; // REST API 핸들러 클래스 의존성

  // 생성자: 외부에서 RecSysApi를 주입 받음
  ForYouRepository(this.api);

  /// 추천 목록 요청 함수
  /// - [ctx]: 입력 컨텍스트(PAD + 환경)
  /// - [k]: 추천 개수 (Top-K)
  /// - 반환: 추천 결과 리스트 (category, score)
  Future<List<RankItemDto>> getTopK(ContextDto ctx, {int k = 8}) =>
      api.rankCategories(ctx, k: k);

  /// 사용자 행동 기반 피드백 전송
  /// - [fb]: 컨텍스트 + 선택된 카테고리 + 보상값 포함
  Future<void> sendFeedback(FeedbackDto fb) => api.sendFeedback(fb);
}
