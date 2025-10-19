import 'package:meta/meta.dart';

double _clampUnit(double v) => v < -1 ? -1 : (v > 1 ? 1 : v);

@immutable
class Pad {
  final double pleasure; // -1..1
  final double arousal; // -1..1
  final double dominance; // -1..1
  const Pad({
    required this.pleasure,
    required this.arousal,
    required this.dominance,
  });

  Pad copyWith({double? pleasure, double? arousal, double? dominance}) => Pad(
    pleasure: _clampUnit(pleasure ?? this.pleasure),
    arousal: _clampUnit(arousal ?? this.arousal),
    dominance: _clampUnit(dominance ?? this.dominance),
  );

  Map<String, dynamic> toJson() => {
    'pleasure': pleasure,
    'arousal': arousal,
    'dominance': dominance,
  };

  factory Pad.fromJson(Map<String, dynamic> j) => Pad(
    pleasure: _clampUnit((j['pleasure'] ?? 0).toDouble()),
    arousal: _clampUnit((j['arousal'] ?? 0).toDouble()),
    dominance: _clampUnit((j['dominance'] ?? 0).toDouble()),
  );
}

/// 서버 /api/curation/recommend 요청 바디(클라 측)
@immutable
class RankRequest {
  final Pad pad; // -1..1
  final double energy; // -1..1
  final double socialNeed; // -1..1
  final List<String> goals; // ex) ["nature_healing","quiet_reflection"]
  final List<String> purposeKeywords;
  final int topK; // UI에선 topK로 들고 다니되, 전송 시 topN으로 변환
  final String? notes; // → emotionNote
  final String? moodKey; // → primaryMood
  final String? moodEmoji; // UI 표시에만 사용

  const RankRequest({
    required this.pad,
    this.energy = 0.0,
    this.socialNeed = 0.0,
    this.goals = const [],
    this.purposeKeywords = const [],
    this.topK = 50,
    this.notes,
    this.moodKey,
    this.moodEmoji,
  }) : assert(topK > 0);

  RankRequest copyWith({
    Pad? pad,
    double? energy,
    double? socialNeed,
    List<String>? goals,
    List<String>? purposeKeywords,
    int? topK,
    String? notes,
    String? moodKey,
    String? moodEmoji,
  }) => RankRequest(
    pad: pad ?? this.pad,
    energy: _clampUnit(energy ?? this.energy),
    socialNeed: _clampUnit(socialNeed ?? this.socialNeed),
    goals: goals ?? this.goals,
    purposeKeywords: purposeKeywords ?? this.purposeKeywords,
    topK: topK ?? this.topK,
    notes: notes ?? this.notes,
    moodKey: moodKey ?? this.moodKey,
    moodEmoji: moodEmoji ?? this.moodEmoji,
  );

  /// **주의**: 여기서는 서버가 원하는 키로 직렬화하지 않습니다.
  /// (서버 키 변환/위치 평탄화는 repository에서 책임집니다)
  Map<String, dynamic> toJson() => {
    'pad': pad.toJson(),
    'energy': energy,
    'socialNeed': socialNeed,
    'goals': goals,
    'purposeKeywords': purposeKeywords,
    'topK': topK,
    if (notes != null && notes!.trim().isNotEmpty) 'notes': notes,
    if (moodKey != null && moodKey!.trim().isNotEmpty) 'moodKey': moodKey,
    if (moodEmoji != null && moodEmoji!.trim().isNotEmpty)
      'moodEmoji': moodEmoji,
  };
}

/// 서버 응답: 장소
@immutable
class Place {
  final int placeId;
  final String name;
  final String cat3Code;
  final double traitMatch;
  final double popularity;
  final double finalScore;
  final double? distanceKm; // 서버가 준다
  final double? distanceScore; // 서버가 준다
  final double? lat, lng; // (서버가 주지 않으면 null)

  const Place({
    required this.placeId,
    required this.name,
    required this.cat3Code,
    required this.traitMatch,
    required this.popularity,
    required this.finalScore,
    this.distanceKm,
    this.distanceScore,
    this.lat,
    this.lng,
  });

  Place withDistanceKm(double d) => Place(
    placeId: placeId,
    name: name,
    cat3Code: cat3Code,
    traitMatch: traitMatch,
    popularity: popularity,
    finalScore: finalScore,
    distanceKm: d,
    distanceScore: distanceScore,
    lat: lat,
    lng: lng,
  );

  factory Place.fromJson(Map<String, dynamic> j) => Place(
    placeId: j['placeId'] is int ? j['placeId'] : int.parse('${j['placeId']}'),
    name: j['name'] ?? '',
    cat3Code: j['cat3Code'] ?? '',
    traitMatch: (j['traitMatch'] ?? 0).toDouble(),
    popularity: (j['popularity'] ?? 0).toDouble(),
    finalScore: (j['finalScore'] ?? 0).toDouble(),
    distanceKm: (j['distanceKm'] as num?)?.toDouble(),
    distanceScore: (j['distanceScore'] as num?)?.toDouble(),
    lat: (j['lat'] as num?)?.toDouble(),
    lng: (j['lng'] as num?)?.toDouble(),
  );
}

/// 서버 응답: LLM 메타 블록
@immutable
class LlmMeta {
  final int schemaVersion;
  final String emotionDiagnosis;
  final String themeName;
  final String themeDescription;
  final List<Activity> activities;
  final List<String> keywords;
  final List<CategoryGroup> categoryGroups;
  final String comfortLetter;

  const LlmMeta({
    required this.schemaVersion,
    required this.emotionDiagnosis,
    required this.themeName,
    required this.themeDescription,
    required this.activities,
    required this.keywords,
    required this.categoryGroups,
    required this.comfortLetter,
  });

  factory LlmMeta.fromJson(Map<String, dynamic> j) => LlmMeta(
    schemaVersion: (j['schema_version'] ?? 2) as int,
    emotionDiagnosis: j['emotion_diagnosis'] ?? '',
    themeName: j['theme_name'] ?? '',
    themeDescription: j['theme_description'] ?? '',
    activities: (j['activities'] as List? ?? const [])
        .map((e) => Activity.fromJson(e))
        .toList(),
    keywords: (j['keywords'] as List? ?? const []).map((e) => '$e').toList(),
    categoryGroups: (j['category_groups'] as List? ?? const [])
        .map((e) => CategoryGroup.fromJson(e))
        .toList(),
    comfortLetter: j['comfort_letter'] ?? '',
  );
}

@immutable
class Activity {
  final String title;
  final String description;
  const Activity({required this.title, required this.description});

  factory Activity.fromJson(Map<String, dynamic> j) =>
      Activity(title: j['title'] ?? '', description: j['description'] ?? '');
}

@immutable
class CategoryGroup {
  final String groupName;
  final List<String> categories;
  const CategoryGroup({required this.groupName, required this.categories});

  factory CategoryGroup.fromJson(Map<String, dynamic> j) => CategoryGroup(
    groupName: j['group_name'] ?? '',
    categories: (j['categories'] as List? ?? const [])
        .map((e) => '$e')
        .toList(),
  );
}

/// 최종 응답(신규): places + llm + cat3FromLlm
@immutable
class ForYouRecommendationResponse {
  final List<Place> places;
  final LlmMeta llm;
  final List<String> cat3FromLlm;

  const ForYouRecommendationResponse({
    required this.places,
    required this.llm,
    required this.cat3FromLlm,
  });

  factory ForYouRecommendationResponse.fromJson(Map<String, dynamic> j) =>
      ForYouRecommendationResponse(
        places: (j['places'] as List? ?? const [])
            .map((e) => Place.fromJson(e))
            .toList(),
        llm: LlmMeta.fromJson(j['llm'] as Map<String, dynamic>),
        cat3FromLlm: (j['cat3FromLlm'] as List? ?? const [])
            .map((e) => '$e')
            .toList(),
      );
}
