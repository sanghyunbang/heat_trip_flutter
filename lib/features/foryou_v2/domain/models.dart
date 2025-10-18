import 'package:meta/meta.dart';

/// -1..1에 맞춰 클램프
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

/// 프론트가 스프링에 넘기는 단일 요청 바디
@immutable
class RankRequest {
  final Pad pad; // -1..1
  final double energy; // -1..1
  final double socialNeed; // -1..1
  final List<String> goals; // 내부 분석용(유지)
  final List<String> purposeKeywords; // LLM 목적 키워드(자연치유, 조용한산책 등)
  final int topK;
  final String? notes; // emotion-note
  final String? moodKey; // 사용자 선택 감정 레이블(표시용)
  final String? moodEmoji; // 사용자 선택 이모지(표시용)

  const RankRequest({
    required this.pad,
    this.energy = 0.0,
    this.socialNeed = 0.0,
    this.goals = const [],
    this.purposeKeywords = const [],
    this.topK = 10,
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

/// LLM 분석 결과(서버에서 되돌려줌)
@immutable
class EmotionAnalysis {
  final Pad pad;
  final double energy; // -1..1
  final double socialNeed; // -1..1
  final String summary; // 요약 문장
  final List<String> tags; // 키워드/태그

  const EmotionAnalysis({
    required this.pad,
    required this.energy,
    required this.socialNeed,
    required this.summary,
    required this.tags,
  });

  factory EmotionAnalysis.fromJson(Map<String, dynamic> j) => EmotionAnalysis(
    pad: Pad.fromJson(j['pad'] as Map<String, dynamic>),
    energy: _clampUnit((j['energy'] ?? 0).toDouble()),
    socialNeed: _clampUnit((j['socialNeed'] ?? 0).toDouble()),
    summary: j['summary'] ?? '',
    tags: (j['tags'] as List? ?? const []).map((e) => '$e').toList(),
  );
}

/// 추천 테마(화면 상단 카드)
@immutable
class TravelTheme {
  final String key;
  final String title;
  final String description;
  const TravelTheme({
    required this.key,
    required this.title,
    required this.description,
  });
  factory TravelTheme.fromJson(Map<String, dynamic> j) => TravelTheme(
    key: j['key'] ?? '',
    title: j['title'] ?? '',
    description: j['description'] ?? '',
  );
}

/// 장소
@immutable
class Place {
  final int placeId;
  final String name;
  final String cat3Code;
  final double traitMatch;
  final double popularity;
  final double finalScore;
  final double? lat, lng; // 서버 좌표
  final double? distanceKm; // 클라 계산 주입

  const Place({
    required this.placeId,
    required this.name,
    required this.cat3Code,
    required this.traitMatch,
    required this.popularity,
    required this.finalScore,
    this.lat,
    this.lng,
    this.distanceKm,
  });

  Place withDistanceKm(double d) => Place(
    placeId: placeId,
    name: name,
    cat3Code: cat3Code,
    traitMatch: traitMatch,
    popularity: popularity,
    finalScore: finalScore,
    lat: lat,
    lng: lng,
    distanceKm: d,
  );

  factory Place.fromJson(Map<String, dynamic> j) => Place(
    placeId: j['placeId'] is int ? j['placeId'] : int.parse('${j['placeId']}'),
    name: j['name'] ?? '',
    cat3Code: j['cat3Code'] ?? '',
    traitMatch: (j['traitMatch'] ?? 0).toDouble(),
    popularity: (j['popularity'] ?? 0).toDouble(),
    finalScore: (j['finalScore'] ?? 0).toDouble(),
    lat: (j['lat'] as num?)?.toDouble(),
    lng: (j['lng'] as num?)?.toDouble(),
  );
}

/// 카테고리 묶음(상위 6개 등)
@immutable
class TravelCategory {
  final int categoryId;
  final String categoryName;
  final double score;
  final List<Place> topPlaces;

  const TravelCategory({
    required this.categoryId,
    required this.categoryName,
    required this.score,
    required this.topPlaces,
  });

  factory TravelCategory.fromJson(Map<String, dynamic> j) => TravelCategory(
    categoryId: j['categoryId'] is int
        ? j['categoryId']
        : int.parse('${j['categoryId']}'),
    categoryName: j['categoryName'] ?? '',
    score: (j['score'] ?? 0).toDouble(),
    topPlaces: (j['topPlaces'] as List? ?? const [])
        .map((e) => Place.fromJson(e))
        .toList(),
  );
}

/// 최종 응답(LLM → 카테고리 → 스코어링 집계)
@immutable
class ForYouRecommendationResponse {
  final int schemaVersion;
  final EmotionAnalysis analysis;
  final TravelTheme theme;
  final List<TravelCategory> categories;
  final List<Place> places;
  final String comfortLetter;

  const ForYouRecommendationResponse({
    required this.schemaVersion,
    required this.analysis,
    required this.theme,
    required this.categories,
    required this.places,
    required this.comfortLetter,
  });

  factory ForYouRecommendationResponse.fromJson(Map<String, dynamic> j) =>
      ForYouRecommendationResponse(
        schemaVersion: j['schemaVersion'] ?? 2,
        analysis: EmotionAnalysis.fromJson(j['analysis']),
        theme: TravelTheme.fromJson(j['theme']),
        categories: (j['categories'] as List? ?? const [])
            .map((e) => TravelCategory.fromJson(e))
            .toList(),
        places: (j['places'] as List? ?? const [])
            .map((e) => Place.fromJson(e))
            .toList(),
        comfortLetter: j['comfortLetter'] ?? '',
      );
}
