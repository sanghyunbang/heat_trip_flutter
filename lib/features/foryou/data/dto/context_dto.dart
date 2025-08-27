// lib/features/foryou/data/dto/context_dto.dart

/// 사용자의 감정 상태(PAD) 및 환경 선호를 담은 추천 입력 모델.
/// 서버의 /rank/categories API에 요청 시 사용됨.
/// → (클라이언트 → 서버) POST JSON 형태로 전송됨
class ContextDto {
  final int P, A, D; // Pleasure, Arousal, Dominance (각각 -2, -1, 1, 2 중 하나)
  final int sociality, noise, crowdedness; // -1 or 1
  final String location; // "in" | "out" | "mix"

  const ContextDto({
    required this.P,
    required this.A,
    required this.D,
    required this.sociality,
    required this.noise,
    required this.crowdedness,
    required this.location,
  });

  /// 서버로 보낼 수 있도록 Map 형태로 직렬화
  Map<String, dynamic> toJson() => {
    "P": P,
    "A": A,
    "D": D,
    "sociality": sociality,
    "noise": noise,
    "crowdedness": crowdedness,
    "location": location,
  };
}
