// lib/features/foryou/domain/reward.dart

/// 사용자의 행동 데이터를 기반으로 보상 점수를 계산하는 함수
/// → 서버로 전송될 reward 값 [0.0 ~ 1.0] 을 산출합니다.
///
/// 입력 값:
/// - clicked: 실제로 해당 카테고리를 선택/탭했는지
/// - dwellS: 해당 카테고리 상세에서 머문 시간(초 단위)
/// - bounced: 클릭 후 바로 이탈했는지 여부 (e.g. 3초 이내 나감)
///
/// 계산 방식:
/// - 클릭 시 1.0점 부여 (가장 큰 신호)
/// - 체류 시간에 따라 최대 +0.3점 추가 보너스
/// - 바운스(bounce) 시 -0.2점 감점
/// - 전체 범위를 [0.0 ~ 1.0]으로 클램핑하여 반환
double computeReward({
  required bool clicked,
  double dwellS = 0, // 체류 시간 (기본값 0초)
  bool bounced = false,
}) {
  double r = clicked ? 1.0 : 0.0; // 클릭하면 1.0, 아니면 0.0

  // dwell time이 최대 30초라 가정하고, 최대 0.3점 보너스
  r += (dwellS / 30.0).clamp(0.0, 1.0) * 0.3;

  // 바로 나간 경우(바운스) -0.2점 감점
  if (bounced) r -= 0.2;

  // 0.0 ~ 1.0 범위로 보상값 클램핑
  return r.clamp(0.0, 1.0);
}
