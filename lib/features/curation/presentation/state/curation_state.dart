import '../../domain/entities.dart';
import '../../domain/repositories.dart';
import '../../domain/usecases.dart';

/// WHY: 위젯에서 비즈니스 로직을 분리 → 테스트 용이/프레임워크 의존성 축소
class CurationState {
  // --- 사용자 입력(가변) ---
  PadRaw pad = const PadRaw(pleasure: 0, arousal: 0, dominance: 0);
  String? selectedSubEmotionEnglish;
  String? travelPurpose;
  EnvironmentSelection environment = const EnvironmentSelection();

  // --- 파생 데이터 ---
  List<SubEmotion> suggestedSubEmotions = const [];

  // --- 의존성 ---
  final SubEmotionSource subEmotionSource;
  final SubEmotionMatcher matcher;
  final SaveSelection saveSelection;
  final LoadSelection loadSelection;
  final ResetSelection resetSelection;

  CurationState({
    required this.subEmotionSource,
    required this.matcher,
    required CurationRepository repository,
  }) : saveSelection = SaveSelection(repository),
       loadSelection = LoadSelection(repository),
       resetSelection = ResetSelection(repository);

  bool get padComplete => pad.isComplete;

  // WHAT: PAD 한 축이라도 바뀌면 상태 갱신. 모두 선택되면 하위 감정 추천 갱신
  void setPad({int? pleasure, int? arousal, int? dominance}) {
    pad = PadRaw(
      pleasure: pleasure ?? pad.pleasure,
      arousal: arousal ?? pad.arousal,
      dominance: dominance ?? pad.dominance,
    );
    if (padComplete) _refreshSubEmotions();
  }

  void setSubEmotion(String english) {
    selectedSubEmotionEnglish = english;
  }

  void setTravelPurpose(String value) {
    travelPurpose = value;
  }

  void setEnvironment({
    String? space,
    String? sociality,
    String? noise,
    String? congestion,
    String? indoorOutdoor,
  }) {
    environment = environment.copyWith(
      space: space,
      sociality: sociality,
      noise: noise,
      congestion: congestion,
      indoorOutdoor: indoorOutdoor,
    );
  }

  Future<void> save() async {
    final selection = UserSelection(
      pad: pad,
      environment: environment,
      subEmotionEnglish: selectedSubEmotionEnglish,
      travelPurpose: travelPurpose,
    );
    await saveSelection(selection);
  }

  Future<bool> load() async {
    final loaded = await loadSelection();
    if (loaded == null) return false;
    pad = loaded.pad;
    environment = loaded.environment;
    selectedSubEmotionEnglish = loaded.subEmotionEnglish;
    travelPurpose = loaded.travelPurpose;
    if (padComplete) _refreshSubEmotions();
    return true;
  }

  Future<void> reset() async {
    pad = const PadRaw(pleasure: 0, arousal: 0, dominance: 0);
    selectedSubEmotionEnglish = null;
    travelPurpose = null;
    environment = const EnvironmentSelection();
    suggestedSubEmotions = const [];
    await resetSelection();
  }

  void _refreshSubEmotions() {
    final target = pad.toNormalized();
    suggestedSubEmotions = matcher.topMatches(
      target: target,
      pool: subEmotionSource.all(),
      topN: 8,
    );
  }
}
