// lib/features/foryou/domain/entities/context.dart
//
// 추천에 쓰이는 컨텍스트(간단 버전)
// - 요구: 감정 8개 + energy/social만 사용 → 여기서는 energy/social/location만 보관
class Context {
  final int energy; // 0~10
  final int social; // 0~10 (낮음=혼자, 높음=함께)
  final String location; // 'in' | 'out' | 'mix'
  const Context({
    required this.energy,
    required this.social,
    required this.location,
  });
}
