# ForYou 프레젠테이션 레이어 — UI 아키텍처 가이드 (KO)

> **범위**: `features/foryou/presentation/*`  
> **목표**: `screens/foryou_screen.dart`는 **레이아웃 + 데이터 바인딩**만 담당하도록 얇게 유지하고, 시각 요소는 재사용을 위해 `widgets/*`로 분리합니다.

---

## 한눈에 보기 (TL;DR)
- **페이지 흐름/상태 바꾸기?** → `screens/foryou_screen.dart` (상태는 `state/ForYouVM`).
- **시각 컴포넌트 수정?** → `widgets/` 하위 폴더별로 편집:
  - `widgets/cards/*` : 상단 주요 카드(인사이트/맞춤/히어로).
  - `widgets/category/*` : 카테고리 그리드/타일.
  - `widgets/place/*` : 추천 장소 타일(리스트 아이템).
  - `widgets/feedback/*` : 에러/빈 상태 박스.
  - `widgets/skeleton/*` : 로딩 스켈레톤.
  - `widgets/ui/*` : 원자 컴포넌트(CardShell, TinyChip, BadgePill, SectionHeader).
- **한 번에 임포트?** → `widgets/widgets.dart` (배럴 익스포트).

---

## 폴더 트리
```
features/
└─ foryou/
   ├─ presentation/
   │  ├─ screens/
   │  │  └─ foryou_screen.dart
   │  └─ widgets/
   │     ├─ cards/
   │     │  ├─ emotion_insight_card.dart
   │     │  ├─ personalized_card.dart
   │     │  └─ theme_hero_card.dart
   │     ├─ category/
   │     │  ├─ category_grid.dart
   │     │  └─ category_tile.dart
   │     ├─ place/
   │     │  └─ place_tile.dart
   │     ├─ feedback/
   │     │  ├─ error_box.dart
   │     │  └─ empty_box.dart
   │     ├─ skeleton/
   │     │  ├─ skeleton_card.dart
   │     │  └─ skeleton_list.dart
   │     └─ ui/
   │        ├─ card_shell.dart
   │        ├─ section_header.dart
   │        ├─ chip.dart
   │        └─ badge.dart
   └─ presentation/widgets/widgets.dart   (배럴 익스포트)
```

---

## 폴더별 역할

### `screens/`
- **`foryou_screen.dart`**
  - 페이지 스캐폴드, AppBar, 패딩 등 화면 **구성(컴포지션)** 전담.
  - 뷰모델(`ForYouVM`) 바인딩 (`vm.loading`, `vm.error`, `vm.categories`, `vm.places` 등).
  - 다이얼로그/시트 네비게이션(`ForYouCurationSheet`) 연결.
  - **주의**: 큰 시각 위젯 구현은 여기 두지 말 것.

### `widgets/ui/` (원자·소형 컴포넌트)
- **`card_shell.dart`** — 공통 카드 컨테이너(라운드 + 그림자).
- **`section_header.dart`** — 굵은 제목 + 선택적 trailing 위젯(예: 카운트 뱃지).
- **`chip.dart`** — `TinyChip`, 인사이트 카드에서 쓰는 작은 라벨.
- **`badge.dart`** — `BadgePill`, 장소 지표(“적합도 87%”) 같은 작은 뱃지.

> **여기를 수정**: 다수 컴포넌트가 공유하는 스타일(패딩, 폰트, 그림자 등)을 바꿀 때.

### `widgets/cards/` (히어로/피처 카드)
- **`emotion_insight_card.dart`** — PAD 값, 에너지/사회성, 목표 표시 + 시트 호출 버튼.
- **`personalized_card.dart`** — 개인화 설명 + “맞춤” 버튼.
- **`theme_hero_card.dart`** — 상단 히어로 배너(이미지 + 그라디언트 + CTA 자리).

> **여기를 수정**: 상단 카드 섹션의 문구/아이콘/레이아웃/버튼 동작을 바꿀 때.

### `widgets/category/`
- **`category_grid.dart`** — `Wrap` 기반 그리드, `CategoryTile` 모음 + “전체 보기” 버튼.
- **`category_tile.dart`** — 이모지/이름/점수 표시 타일.

> **여기를 수정**: 카테고리 레이아웃, 간격, 클릭 동작, 보조 배지/필터 추가.

### `widgets/place/`
- **`place_tile.dart`** — 썸네일 + 이름 + cat3 코드 + 지표 배지 + 북마크 아이콘.

> **여기를 수정**: 장소 리스트 스타일, 썸네일 크기, 새 메타데이터(거리/영업시간 등) 추가.

### `widgets/feedback/`
- **`error_box.dart`** — 빨간색 테두리 에러 박스 + “다시 시도” 버튼.
- **`empty_box.dart`** — 결과가 없을 때의 중립 박스.

> **여기를 수정**: 에러/빈 상태 문구, 색상, UX.

### `widgets/skeleton/`
- **`skeleton_card.dart`** — 단일 로딩 카드(선택: 간단한 쉐이더/스트라이프 애니메이션 포함).
- **`skeleton_list.dart`** — 리스트 로딩 상태용 반복 스켈레톤.

> **여기를 수정**: 로딩 비주얼(높이, 라운드, 애니메이션 속도).

---

## 컴포넌트 인덱스 — 어디를 고치나?

| UI 영역 | 컴포넌트/클래스 | 파일 경로 |
|---|---|---|
| 상단 인사이트 | `EmotionInsightCard` | `widgets/cards/emotion_insight_card.dart` |
| 개인화 카드 | `PersonalizedCard` | `widgets/cards/personalized_card.dart` |
| 히어로 배너 | `ThemeHeroCard` | `widgets/cards/theme_hero_card.dart` |
| 카테고리 섹션 | `CategoryGrid` | `widgets/category/category_grid.dart` |
| 카테고리 타일 | `CategoryTile` | `widgets/category/category_tile.dart` |
| 장소 리스트 아이템 | `PlaceTile` | `widgets/place/place_tile.dart` |
| 섹션 헤더 | `SectionHeader` | `widgets/ui/section_header.dart` |
| 카드 컨테이너 | `CardShell` | `widgets/ui/card_shell.dart` |
| 작은 칩 | `TinyChip` | `widgets/ui/chip.dart` |
| 작은 배지 | `BadgePill` | `widgets/ui/badge.dart` |
| 에러 박스 | `ErrorBox` | `widgets/feedback/error_box.dart` |
| 빈 상태 박스 | `EmptyBox` | `widgets/feedback/empty_box.dart` |
| 로딩(단일) | `SkeletonCard` | `widgets/skeleton/skeleton_card.dart` |
| 로딩(리스트) | `SkeletonList` | `widgets/skeleton/skeleton_list.dart` |

---

## 자주 하는 변경 → 이 파일을 수정하세요

- **PAD 라벨/목표 매핑 변경** → `widgets/cards/emotion_insight_card.dart` (`_goalLabel`).
- **맞춤 버튼 동작 변경** → `widgets/cards/personalized_card.dart` (스크린에서 `onTune` 전달).
- **히어로 이미지/그라디언트/텍스트 변경** → `widgets/cards/theme_hero_card.dart`.
- **카테고리 너비/간격 변경** → `widgets/category/category_tile.dart` & `category_grid.dart` (`Wrap` 간격, `MediaQuery` 계산).
- **장소 지표 추가(예: 거리)** → `widgets/place/place_tile.dart` (필요 시 `RankedPlace` 확장).
- **섹션 타이틀/트레일링 변경** → `widgets/ui/section_header.dart` (스크린 조립부도 함께).
- **카드 스타일(패딩/그림자) 튜닝** → `widgets/ui/card_shell.dart`.
- **빈/에러 문구/색상 변경** → `widgets/feedback/*`.
- **로딩 비주얼 변경** → `widgets/skeleton/*`.

---

## 배럴 익스포트

스크린에서 한 줄로 임포트:
```dart
import '../widgets/widgets.dart';
```

배럴 파일 유지:
```dart
// features/foryou/presentation/widgets/widgets.dart
export 'ui/card_shell.dart';
export 'ui/section_header.dart';
export 'ui/chip.dart';
export 'ui/badge.dart';

export 'skeleton/skeleton_card.dart';
export 'skeleton/skeleton_list.dart';

export 'feedback/error_box.dart';
export 'feedback/empty_box.dart';

export 'cards/emotion_insight_card.dart';
export 'cards/personalized_card.dart';
export 'cards/theme_hero_card.dart';

export 'category/category_grid.dart';
export 'category/category_tile.dart';

export 'place/place_tile.dart';
```

---

## 네이밍/스타일 규칙
- 위젯 클래스는 **PascalCase**, 파일은 **snake_case**.
- 기본은 **StatelessWidget**; 애니메이션 등 필요한 곳만 `StatefulWidget` 사용.
- 가능하면 `const` 생성자/자식 사용 → 리빌드 비용 절감.
- 간격은 `SizedBox(height/width)` 사용. 매직 넘버는 상수·토큰으로 중앙화 권장.

---

## 퍼포먼스 메모
- 리스트가 커질 경우 `ListView.builder` 또는 슬리버 계열 전환 고려.
- 무거운 계산은 VM에서 메모이즈/가공하고, 위젯은 덤하게 유지.
- 재정렬/동적 리스트에는 안정적인 `Key` 부여.

---

## 테스트 팁
- `widgets/*` 원자/소형 컴포넌트는 위젯 테스트(골든 테스트)로 커버 용이.
- `foryou_screen.dart`는 VM을 목킹하여 조립 여부만 테스트.
- 비즈니스 로직은 `state/` 유닛 테스트로 분리.

---

## PR 체크리스트
- [ ] 스크린 파일은 슬림(이상적으로 ~150줄 내)하며 **조립만** 담당.
- [ ] 새 UI는 적절한 `widgets/` 하위 폴더에 위치.
- [ ] 공통 스타일은 `widgets/ui/*`로 승격.
- [ ] 배럴 익스포트 갱신(추가/삭제 반영).
- [ ] 공개 위젯은 가능한 `const` 생성자 제공.
- [ ] 비즈니스 로직은 위젯에 넣지 않고 VM/서비스 레이어에 위치.