// lib/features/foryou/data/foryou_repository_impl.dart

// Domain 레이어 인터페이스
import 'package:heat_trip_flutter/features/foryou/domain/foryou_repository.dart';

// Domain 엔티티들 (alias dom으로 가져옴 → DTO와 혼동 방지)
import 'package:heat_trip_flutter/features/foryou/domain/entities/entities.dart'
    as dom;

// Domain ↔ DTO 변환을 담당하는 Mapper
import 'mappers/mappers.dart';

// 실제 서버 API (추천 시스템) 호출 객체
import 'remote/recsys_api.dart';

/// -----------------------------------------
/// Repository 구현체 (Data Layer)
/// -----------------------------------------
/// - ForYouRepository 인터페이스를 실제로 구현
/// - 내부에서 RecSysApi를 사용해 서버와 통신
/// - Domain ↔ DTO 변환도 여기서 처리
class ForYouRepositoryImpl implements ForYouRepository {
  final RecSysApi api; // 추천 시스템 API 의존성
  ForYouRepositoryImpl(this.api);

  /// -------------------------------
  /// Top-K 추천 요청
  /// -------------------------------
  /// 1. Domain Context → DTO ContextDto (toDto)
  /// 2. RecSysApi.rankCategories 호출
  /// 3. 응답(DTO 리스트) → Domain RankItem 리스트 (toDomain)
  @override
  Future<List<dom.RankItem>> getTopK(dom.Context ctx, {int k = 8}) async {
    final dtoList = await api.rankCategories(ctx.toDto(), k: k);
    return dtoList.map((e) => e.toDomain()).toList();
  }

  /// -------------------------------
  /// 피드백 전송
  /// -------------------------------
  /// 1. Domain FeedbackEvent → DTO FeedbackDto (toDto)
  /// 2. RecSysApi.sendFeedback 호출 (서버 전송)
  @override
  Future<void> sendFeedback(dom.FeedbackEvent fb) async {
    await api.sendFeedback(fb.toDto());
  }
}
