# TrackBoth Design System Spec

> Spec governance: behavior changes update the matching spec in the same commit.


## 8. Design system

### 8.1 Palette (asset catalog color sets with Any + Dark appearances)

| Token | Light | Dark | Use |
|-------|-------|------|-----|
| `Background` | `#F6F7F5` | `#0B0F10` | Screen background |
| `Surface` | `#FFFFFF` | `#161B1D` | Cards |
| `SurfaceMuted` | `#EEF1EF` | `#1F2629` | Chips, inactive cells |
| `TextPrimary` | `#111827` | `#F3F4F6` | Body text |
| `TextSecondary` | `#4B5563` | `#A3AAB5` | Captions |
| `Brand` | `#0F766E` | `#2DD4BF` | Free state, primary buttons, tint |
| `BrandSoft` | `#CCFBF1` | `#134E4A` | Presumed-free cells, soft fills |
| `OnBrand` | `#FFFFFF` | `#042F2E` | Text on `Brand` fills |
| `Habit` | `#4F46E5` | `#A5B4FC` | Habit done |
| `HabitSoft` | `#E0E7FF` | `#312E81` | Habit soft fills |
| `Slip` | `#B45309` | `#FBBF24` | Slip dot, at-risk hint (**never red**) |
| `SlipSoft` | `#FEF3C7` | `#451A03` | Slip backgrounds |
| `Calm` | `#1E3A5F` | `#1E3A5F` | Urge flow background (white text on top) |

`AccentColor` = `Brand`. `LaunchBackground` = `Background`. Expose them as `extension Color { static let tbBackground = Color("Background") … }` in `Palette.swift`. Don't use any raw colors in views.

### 8.2 Spacing and radius

`Spacing.xs 4 · s 8 · m 12 · l 16 · xl 24 · xxl 32`. `Radius.card 20 · control 14 · chip = Capsule`. Screen horizontal padding = `Spacing.l`. Gap between cards = `Spacing.m`.

> Adaptive-ready rules for 1.0 (iPad and landscape come later, D6) are in §8.7. Follow them from Phase 4 on.

### 8.3 Type

Use Dynamic Type text styles only (`.largeTitle`, `.title2`, `.headline`, `.body`, `.subheadline`, `.footnote`, `.caption`). Big numbers (days free, run counts): `.system(.largeTitle, design: .rounded).weight(.bold).monospacedDigit()`. Section headers: `.footnote.weight(.semibold)`, uppercase, `TextSecondary`. No custom fonts.

### 8.4 Components (each one gets a `#Preview` in light, dark, and AX3)

| Component | API sketch | Notes |
|-----------|-----------|-------|
| `PrimaryButton` | `PrimaryButton(title:, systemImage:, action:)` | Full width, min height 52, `Brand` fill, `OnBrand` text |
| `SecondaryButton` | same | `SurfaceMuted` fill, `TextPrimary` text |
| `Card` | `Card { content }` | `Surface`, `Radius.card`, padding `Spacing.l` |
| `StatTile` | `StatTile(value:, label:, systemImage:)` | VoiceOver reads "label, value" |
| `Chip` / `ChipGrid` | `ChipGrid(items:, selection: Binding<Set<…>>)` | Adaptive grid, min 44pt height, selected = `Brand` fill |
| `EmptyState` | `EmptyState(systemImage:, title:, message:, actionTitle:, action:)` | |
| `BreathingCircle` | `BreathingCircle(inhale: 4, exhale: 6)` | Reduce Motion → text-only cue |
| `DayDots` | `DayDots(states: [DayVisualState])` | 7 dots. Each dot has a VoiceOver label ("Monday, free"). Shape and color both encode state (solid, ring, triangle for slip) so it works without color. |
| `MonthCalendar` | `MonthCalendar(month:, stateFor: (Date) -> DayVisualState, onSelect:)` | `firstWeekday` from `Calendar.current`. Cells ≥44pt. |
| `SectionHeader` | `SectionHeader("Quitting")` | Adds the `.isHeader` accessibility trait |
| `IconBadge` | `IconBadge(systemImage:, tint:)` | 36pt rounded square |
| `ReadableColumn` | `ReadableColumn { content }` | Max width 640, centered, `Spacing.l` side padding. Wraps every screen (§8.7) |

`DayVisualState` cases: confirmed free (solid circle, brand), presumed free (ring), slip (triangle), habit done (rounded square, habit), missed (hollow square), today pending (dashed ring), inactive (muted dot). Vice `DayState` and habit days map onto these in `Snapshots.swift`. Text on the urge background uses `Color.tbOnCalm` (white in both appearances) because `OnBrand` is not white in dark mode.

### 8.5 Motion and haptics

- Check-in done: `.symbolEffect(.bounce)` on the checkmark + `.sensoryFeedback(.success, trigger:)`.
- Habit toggle: `.sensoryFeedback(.selection, trigger:)`.
- Slip saved: `.sensoryFeedback(.impact(weight: .light), trigger:)`.
- Celebration: scale-in + soft glow (`TrackBothMotion.celebrationSpring`). **No confetti libraries.** Under Reduce Motion: no scale, just a fade.
- Wrap every animation in `trackBothAnimation(_:value:reduceMotion:)`.

### 8.6 Accessibility gates (each is a test or a manual check)

- **Contrast** (unit test with `WCAGContrast`): `TextPrimary`/`TextSecondary` on `Background` and on `Surface` ≥ 4.5:1 in both modes. `OnBrand` on `Brand` ≥ 4.5:1. `Slip` on `Surface` ≥ 3:1 (non-text) and ≥ 4.5:1 where it's used as text. White on `Calm` ≥ 4.5:1. If a pair fails, **adjust the hex** and update §8.1 in the spec.
- Dynamic Type: every screen works at AX5 (scrolls, nothing truncated mid-word, buttons stack vertically). Use `ViewThatFits` or `dynamicTypeSize.usesAccessibilityLayout` to switch HStack → VStack.
- VoiceOver: every interactive element has a label. ViceCard reads as one element: "Alcohol, 12 days free, 96 dollars saved, button". The live clock is announced only on focus (`.accessibilityElement(children: .combine)`).
- Reduce Motion: breathing, celebration, and the number transitions all honor it.
- Tap targets ≥ 44×44pt.

### 8.7 Adaptive-ready rules (D6: iPad + landscape in a future release)

1.0 ships iPhone portrait only. Build every screen so that turning on iPad and landscape (Phase 15) means **adding** layouts, not rewriting screens:

1. **No device checks.** Never use `UIDevice.current.userInterfaceIdiom`, screen-size constants, or `UIScreen.main.bounds`. Use `@Environment(\.horizontalSizeClass)` / `verticalSizeClass` and the size the view is given.
2. **One readable column.** Wrap each screen's scroll content in `ReadableColumn` (a DesignSystem component: `frame(maxWidth: 640)` centered, with `Spacing.l` side padding). On iPhone portrait it's full width. On iPad it stays readable.
3. **No fixed widths or heights** on cards, grids, or the calendar. Use flexible frames, `GridItem(.adaptive(minimum:))`, and `ViewThatFits`.
4. **Navigation that can split.** Progress → Metric Detail uses `NavigationStack` with value-based `navigationDestination(for: UUID.self)`, so Phase 15 can swap it for `NavigationSplitView` on regular width without touching the detail screen.
5. **Full-screen flows** (Urge, Onboarding, Lock) center their content in a `ReadableColumn` and never assume portrait height. Put the breathing circle and the buttons in a `ViewThatFits(in: .vertical)` that falls back to a horizontal arrangement when height is short.
6. **Previews:** every screen gets one extra landscape preview (`#Preview(traits: .landscapeLeft)`). It doesn't have to look final, but nothing may clip or overlap. That keeps Phase 15 small.


## Verification

| Field | Value |
|-------|--------|
| Last verified | 2026-10-28 |
| Commit | Phase 4 |

