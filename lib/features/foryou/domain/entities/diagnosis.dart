// lib/features/foryou/domain/entities/diagnosis.dart
//
// 감정 기록 결과(간단):
// - mood: 8개 중 하나
// - energy/social: 0~10
class Diagnosis {
  final String
  mood; // 'HAPPY' | 'CALM' | 'CURIOUS' | 'PROUD' | 'ANXIOUS' | 'ANGRY' | 'SAD' | 'TIRED'
  final int energy; // 0~10
  final int social; // 0~10
  const Diagnosis({
    required this.mood,
    required this.energy,
    required this.social,
  });
}
