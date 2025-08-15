/// ===== Domain Layer(핵심 모델) =====
/// WHAT: UI/저장 구현과 분리된 순수 모델. 테스트/재사용 용이.

/// 사용자가 선택하는 PAD 원시값 (-2, -1, 1, 2 / 0=미선택)
class PadRaw {
  final int pleasure;
  final int arousal;
  final int dominance;
  const PadRaw({
    required this.pleasure,
    required this.arousal,
    required this.dominance,
  });

  /// 세 축 모두 유효값이면 PAD 선택 완료로 간주
  bool get isComplete => [
    pleasure,
    arousal,
    dominance,
  ].every((v) => v == -2 || v == -1 || v == 1 || v == 2);

  /// WHAT: 유사도 계산을 위해 0.0~1.0 정규화 값으로 변환
  PadNormalized toNormalized() =>
      PadNormalized(p: _map(pleasure), a: _map(arousal), d: _map(dominance));

  /// -2,-1,1,2 → 0.0,0.25,0.75,1.0으로 사상(HTML 버전과 동일 규칙)
  static double _map(int value) {
    switch (value) {
      case -2:
        return 0.0;
      case -1:
        return 0.25;
      case 1:
        return 0.75;
      case 2:
        return 1.0;
      default:
        return 0.5; // 미선택/예외의 안전값
    }
  }

  Map<String, dynamic> toJson() => {
    'pleasure': pleasure,
    'arousal': arousal,
    'dominance': dominance,
  };

  /// 저장소에서 읽을 때의 방어적 파싱
  factory PadRaw.fromJson(Map<String, dynamic> json) => PadRaw(
    pleasure: (json['pleasure'] as int?) ?? 0,
    arousal: (json['arousal'] as int?) ?? 0,
    dominance: (json['dominance'] as int?) ?? 0,
  );
}

/// 정규화된 PAD 값(0.0~1.0). 거리 계산에 사용
class PadNormalized {
  final double p, a, d;
  const PadNormalized({required this.p, required this.a, required this.d});
}

/// 사용자의 환경(공간/사회성/소음/혼잡/실내외) 선택 스냅샷
class EnvironmentSelection {
  final String? space; // cozy | open
  final String? sociality; // alone | with-people
  final String? noise; // quiet | loud
  final String? congestion; // empty | crowded
  final String? indoorOutdoor; // indoor | outdoor

  const EnvironmentSelection({
    this.space,
    this.sociality,
    this.noise,
    this.congestion,
    this.indoorOutdoor,
  });

  Map<String, dynamic> toJson() => {
    'space': space,
    'sociality': sociality,
    'noise': noise,
    'congestion': congestion,
    'indoorOutdoor': indoorOutdoor,
  };

  factory EnvironmentSelection.fromJson(Map<String, dynamic> json) =>
      EnvironmentSelection(
        space: json['space'] as String?,
        sociality: json['sociality'] as String?,
        noise: json['noise'] as String?,
        congestion: json['congestion'] as String?,
        indoorOutdoor: json['indoorOutdoor'] as String?,
      );

  /// WHY: 불변값 + copyWith 패턴 → 예측 가능한 상태 변경
  EnvironmentSelection copyWith({
    String? space,
    String? sociality,
    String? noise,
    String? congestion,
    String? indoorOutdoor,
  }) => EnvironmentSelection(
    space: space ?? this.space,
    sociality: sociality ?? this.sociality,
    noise: noise ?? this.noise,
    congestion: congestion ?? this.congestion,
    indoorOutdoor: indoorOutdoor ?? this.indoorOutdoor,
  );
}

/// 사용자가 저장하는 최종 선택 묶음(도메인 진입점)
class UserSelection {
  final PadRaw pad;
  final String? subEmotionEnglish; // 예: "Glee"
  final String? travelPurpose; // relaxation | mood-enhancement | ...
  final EnvironmentSelection environment;

  const UserSelection({
    required this.pad,
    required this.environment,
    this.subEmotionEnglish,
    this.travelPurpose,
  });

  Map<String, dynamic> toJson() => {
    'pad': pad.toJson(),
    'selectedEmotion': subEmotionEnglish,
    'travelPurpose': travelPurpose,
    'environment': environment.toJson(),
  };

  factory UserSelection.fromJson(Map<String, dynamic> json) => UserSelection(
    pad: PadRaw.fromJson((json['pad'] as Map).cast<String, dynamic>()),
    environment: EnvironmentSelection.fromJson(
      (json['environment'] as Map).cast<String, dynamic>(),
    ),
    subEmotionEnglish: json['selectedEmotion'] as String?,
    travelPurpose: json['travelPurpose'] as String?,
  );
}

/// 하위 감정(정규화 PAD 좌표 포함)
class SubEmotion {
  final String name; // 한국어 라벨
  final String english; // 내부 키/영문 라벨
  final double P, A, D; // 0..1
  const SubEmotion({
    required this.name,
    required this.english,
    required this.P,
    required this.A,
    required this.D,
  });
}
