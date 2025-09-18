# ForYou Presentation Layer — UI Architecture Guide

> **Scope**: `features/foryou/presentation/*`  
> **Goal**: Keep `screens/foryou_screen.dart` thin (layout + binding only). Move visual pieces into `widgets/*` for reuse and clear ownership.

---

## TL;DR
- **Edit page flow/state?** → `screens/foryou_screen.dart` (and your `ForYouVM` in `state/`).
- **Edit visual components?** → `widgets/` by category:
  - `widgets/cards/*` : the big cards at the top (insight, personalized, hero).
  - `widgets/category/*` : category grid & small tiles.
  - `widgets/place/*` : ranked place list tiles.
  - `widgets/feedback/*` : error/empty informational boxes.
  - `widgets/skeleton/*` : loading placeholders.
  - `widgets/ui/*` : tiny reusable atoms (CardShell, TinyChip, BadgePill, SectionHeader).
- **Import all at once?** → `widgets/widgets.dart` (barrel export).

---

## Folder Tree
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
   └─ presentation/widgets/widgets.dart   (barrel export)
```

---

## Responsibilities by Folder

### `screens/`
- **`foryou_screen.dart`**  
  - Page-level scaffold, app bar, padding, and **composition** of widgets.
  - Wires view model (`ForYouVM`) to the UI (e.g., `vm.loading`, `vm.error`, `vm.categories`, `vm.places`).
  - Navigation to dialogs/sheets (e.g., `ForYouCurationSheet`).  
  - **Do not** put large visual widget implementations here.

### `widgets/ui/` (Atoms & small molecules)
- **`card_shell.dart`** — Common container with rounded corners/shadow for card-like blocks.
- **`section_header.dart`** — Row with a bold title and an optional trailing widget (e.g., counter pill).
- **`chip.dart`** — `TinyChip`, a compact label used in the insight card.
- **`badge.dart`** — `BadgePill`, small label used for place stats (e.g., “적합도 87%”).

> **Edit here when** you need to change shared styles (shadows, paddings, font sizes) used across multiple components.

### `widgets/cards/` (Hero/feature cards)
- **`emotion_insight_card.dart`** — Shows PAD values, energy/sociality, and goals. Has an action to open the curation sheet.
- **`personalized_card.dart`** — Describes the personalization feature and includes a “맞춤” tune button.
- **`theme_hero_card.dart`** — Visual hero banner (image + gradient + CTA placeholder).

> **Edit here when** you need to change what appears in the top “cards” section (copy, layout, icons, CTA behavior).

### `widgets/category/`
- **`category_grid.dart`** — Wrap-based grid; hosts `CategoryTile` items and an “전체 보기” button.
- **`category_tile.dart`** — Small rectangular tile with emoji, name, and match percentage.

> **Edit here when** you adjust category item layout, spacing, click behavior, or add badges/filters.

### `widgets/place/`
- **`place_tile.dart`** — Row card with thumbnail, name, cat3 code, and stat badges + bookmark icon.

> **Edit here when** you change the look of the place list, thumbnail sizes, or add new metadata (distance, open hours, etc.).

### `widgets/feedback/`
- **`error_box.dart`** — Red-bordered box with error message and “다시 시도” button.
- **`empty_box.dart`** — Neutral card shown when results are empty.

> **Edit here when** you update messaging, colors, or UX for errors/empty states.

### `widgets/skeleton/`
- **`skeleton_card.dart`** — Single rectangular loading block (optional shimmer stripe included).
- **`skeleton_list.dart`** — Repeated skeleton rows for loading list states.

> **Edit here when** you change the loading visuals (height, corner radius, shimmer speed).

---

## Component Index & Where to Edit

| UI Area | Component/Class | File Path |
|---|---|---|
| Insight at top | `EmotionInsightCard` | `widgets/cards/emotion_insight_card.dart` |
| Personalized block | `PersonalizedCard` | `widgets/cards/personalized_card.dart` |
| Hero banner | `ThemeHeroCard` | `widgets/cards/theme_hero_card.dart` |
| Category section (container) | `CategoryGrid` | `widgets/category/category_grid.dart` |
| Category chip/tile | `CategoryTile` | `widgets/category/category_tile.dart` |
| Place row item | `PlaceTile` | `widgets/place/place_tile.dart` |
| Section title row | `SectionHeader` | `widgets/ui/section_header.dart` |
| Card container | `CardShell` | `widgets/ui/card_shell.dart` |
| Tiny value chip | `TinyChip` | `widgets/ui/chip.dart` |
| Small badge pill | `BadgePill` | `widgets/ui/badge.dart` |
| Error message | `ErrorBox` | `widgets/feedback/error_box.dart` |
| Empty state | `EmptyBox` | `widgets/feedback/empty_box.dart` |
| Loading (single) | `SkeletonCard` | `widgets/skeleton/skeleton_card.dart` |
| Loading (list) | `SkeletonList` | `widgets/skeleton/skeleton_list.dart` |

---

## Common Tasks → Edit This

- **Change PAD labels/goals mapping** → `widgets/cards/emotion_insight_card.dart` (`_goalLabel`).
- **Change tune/맞춤 button action** → `widgets/cards/personalized_card.dart` (its `onTune` callback is passed from screen).
- **Update hero image/gradient/text** → `widgets/cards/theme_hero_card.dart`.
- **Change category tile width/spacing** → `widgets/category/category_tile.dart` & `category_grid.dart` (Wrap spacing, `MediaQuery` width calc).
- **Add a new stat to place item** (e.g., distance) → `widgets/place/place_tile.dart` (and extend `RankedPlace` if needed).
- **Change section titles or trailing pill** → `widgets/ui/section_header.dart` (and in screen composition).  
- **Tune card styling (padding, shadow)** → `widgets/ui/card_shell.dart`.
- **Update empty/error messages** → `widgets/feedback/*`.
- **Change loading visuals** → `widgets/skeleton/*`.

---

## Barrel Export

Import everything via one line in the screen:
```dart
import '../widgets/widgets.dart';
```

Maintain this file:
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

## Naming & Style Conventions
- **PascalCase** for widget class names (e.g., `EmotionInsightCard`), **snake_case** for file names.
- Keep **stateless** by default; use local `StatefulWidget` only for animations (e.g., shimmer).
- Prefer `const` constructors/children whenever possible to reduce rebuilds.
- Use `SizedBox(height/width: ...)` for spacing; avoid magic numbers scattered across files — centralize if needed.

---

## Performance Notes
- Large lists → switch to `ListView.builder` or `SliverList` when list grows.
- Memoize heavy calculations in the VM; keep widgets dumb.
- Provide stable `keys` for reorderable or dynamic lists if needed.

---

## Testing Hints
- Widget tests for each atom/molecule in `widgets/*` are easy and valuable (golden tests for visuals).
- Mock `ForYouVM` when testing `foryou_screen.dart` composition.
- Keep business logic covered in `state/` unit tests.

---

## Quick Checklist for PRs
- [ ] Screen file remains lean (< ~150 lines ideally) and only composes widgets.
- [ ] New UI pieces live under appropriate `widgets/` subfolder.
- [ ] Reused styles elevated to `widgets/ui/*`.
- [ ] Barrel export updated when adding/removing public widgets.
- [ ] All new public widgets have `const` constructors where possible.
- [ ] No business logic in widgets — logic stays in the VM/service layer.
