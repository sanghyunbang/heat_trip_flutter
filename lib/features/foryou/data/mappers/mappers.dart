// lib/features/foryou/data/mappers/mappers.dart

// domain 엔티티를 가져올 때 dom.* 라는 alias 사용
import '../../domain/entities/context.dart' as dom;
import '../../domain/entities/rank_item.dart' as dom;
import '../../domain/entities/feedback_event.dart' as dom;

// 서버와 통신할 때 쓰는 DTO(Data Transfer Object)
import '../dto/context_dto.dart';
import '../dto/rank_item_dto.dart';
import '../dto/feedback_dto.dart';

/// ----------------------
/// Context 변환용 Mapper
/// ----------------------
/// Domain의 Context 객체를 → DTO(ContextDto)로 변환하는 extension
extension ContextDomainToDto on dom.Context {
  /// Domain Context → DTO ContextDto
  ContextDto toDto() => ContextDto(
    P: P,
    A: A,
    D: D, // 감정 상태 (Pleasure, Arousal, Dominance)
    sociality: sociality, // 사회성 (사람과 어울리기 vs 혼자)
    noise: noise, // 소음 선호 (조용/시끄러운 곳)
    crowdedness: crowdedness, // 혼잡도 (북적거림 vs 한산함)
    location: location, // 실내/실외/혼합
  );
}

/// ----------------------
/// RankItem 변환용 Mapper
/// ----------------------
/// 서버에서 받은 RankItemDto → Domain RankItem으로 변환
extension RankItemDtoToDomain on RankItemDto {
  /// DTO RankItemDto → Domain RankItem
  dom.RankItem toDomain() => dom.RankItem(
    category: category, // 관광지/추천 카테고리
    score: score, // 점수(추천 우선순위)
  );
}

/// ----------------------
/// Feedback 변환용 Mapper
/// ----------------------
/// Domain의 FeedbackEvent → DTO FeedbackDto 변환
extension FeedbackDomainToDto on dom.FeedbackEvent {
  /// Domain FeedbackEvent → DTO FeedbackDto
  FeedbackDto toDto() => FeedbackDto(
    context: context.toDto(), // Feedback 당시 사용자의 Context(PAD 등)
    targetCategory: targetCategory, // 사용자가 반응한 대상 카테고리
    reward: reward, // 보상 값(체류시간, 클릭 여부 등)
  );
}
