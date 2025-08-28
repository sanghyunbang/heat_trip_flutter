// lib/features/foryou/domain/entities/context.dart
class Context {
  // PAD: -2, -1, 1, 2
  final int P, A, D;
  // 선호: -1 or 1
  final int sociality, noise, crowdedness;
  // "in" | "out" | "mix"
  final String location;

  const Context({
    required this.P,
    required this.A,
    required this.D,
    required this.sociality,
    required this.noise,
    required this.crowdedness,
    required this.location,
  });
}
