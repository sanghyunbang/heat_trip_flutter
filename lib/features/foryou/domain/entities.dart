import 'package:meta/meta.dart';

// ===== Core value objects & DTOs =====

@immutable
class Pad {
  final double pleasure; // -2..2
  final double arousal; // -2..2
  final double dominance; // -2..2
  const Pad({
    required this.pleasure,
    required this.arousal,
    required this.dominance,
  });

  Pad copyWith({double? pleasure, double? arousal, double? dominance}) => Pad(
    pleasure: pleasure ?? this.pleasure,
    arousal: arousal ?? this.arousal,
    dominance: dominance ?? this.dominance,
  );

  Map<String, dynamic> toJson() => {
    'pleasure': pleasure,
    'arousal': arousal,
    'dominance': dominance,
  };
}

@immutable
class RankRequest {
  final Pad pad;
  final int energy; // -1,0,1
  final double socialNeed; // -1..1
  final List<String> goals; // ex) ['quiet_reflection']
  final int topK;

  const RankRequest({
    required this.pad,
    this.energy = 0,
    this.socialNeed = 0,
    this.goals = const [],
    this.topK = 10,
  });

  RankRequest copyWith({
    Pad? pad,
    int? energy,
    double? socialNeed,
    List<String>? goals,
    int? topK,
  }) => RankRequest(
    pad: pad ?? this.pad,
    energy: energy ?? this.energy,
    socialNeed: socialNeed ?? this.socialNeed,
    goals: goals ?? this.goals,
    topK: topK ?? this.topK,
  );

  Map<String, dynamic> toJson() => {
    'pad': pad.toJson(),
    'energy': energy,
    'socialNeed': socialNeed,
    'goals': goals,
    'topK': topK,
  };
}

@immutable
class RankedPlace {
  final int placeId;
  final String name;
  final String cat3Code;
  final double traitMatch;
  final double popularity;
  final double finalScore;

  const RankedPlace({
    required this.placeId,
    required this.name,
    required this.cat3Code,
    required this.traitMatch,
    required this.popularity,
    required this.finalScore,
  });

  factory RankedPlace.fromJson(Map<String, dynamic> j) => RankedPlace(
    placeId: j['placeId'] is int ? j['placeId'] : int.parse('${j['placeId']}'),
    name: j['name'] ?? '',
    cat3Code: j['cat3Code'] ?? '',
    traitMatch: (j['traitMatch'] ?? 0).toDouble(),
    popularity: (j['popularity'] ?? 0).toDouble(),
    finalScore: (j['finalScore'] ?? 0).toDouble(),
  );
}

@immutable
class CategoryScore {
  final int categoryId;
  final String categoryName;
  final String emoji;
  final double score;
  final List<RankedPlace> topPlaces;

  const CategoryScore({
    required this.categoryId,
    required this.categoryName,
    required this.emoji,
    required this.score,
    required this.topPlaces,
  });

  factory CategoryScore.fromJson(Map<String, dynamic> j) => CategoryScore(
    categoryId: j['categoryId'] is int
        ? j['categoryId']
        : int.parse('${j['categoryId']}'),
    categoryName: j['categoryName'] ?? '',
    emoji: j['emoji'] ?? '🗺️',
    score: (j['score'] ?? 0).toDouble(),
    topPlaces: (j['topPlaces'] as List? ?? const [])
        .map((e) => RankedPlace.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
