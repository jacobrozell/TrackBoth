# TrackBoth — Architecture Refactor Plan

_Status: proposal · Author: senior iOS review · Target: scalable, stable foundation for new features_

This plan takes the **ambitious / restructure** path: a deliberate move to a consistent, feature-modular architecture with a clean data layer and explicit dependency injection. It is sequenced so the app stays shippable after every phase — no big-bang rewrite.

---

## 1. Where the codebase is today

TrackBoth is a SwiftData-backed SwiftUI habit/vice tracker, ~23k LOC across ~200 Swift files, with an iOS app, a widget extension, and solid unit-test coverage (40 unit test files). The bones are good. The problem is **architectural drift**: the repo is visibly mid-migration between two structures, and several cross-cutting concerns (data access, navigation, DI) are implemented two or three different ways.

### What's already good (keep and build on)

- **SwiftData models** are clean and isolated in `Models/` (`Metric`, `MetricEntry`, `Goal`, all `@Model`).
- **A real domain layer exists** in `Domain/` — `StreakUtils`, `GoalUtils`, `ChartDataProcessor`, `MilestoneEvaluator`, `ViceSavingsCalculator`, etc. — mostly pure and well-tested.
- **A repository seam exists**: `Domain/Data/EntryStore` and `MetricStore` wrap `ModelContext` with typed fetch/insert/delete.
- **Strong test coverage** of domain logic and view models.
- **`@Observable`** is already the chosen view-model mechanism (modern, correct).
- **Adaptive layout system** (`DeviceLayout`, per-orientation layout files) is a genuine asset.

### The core problems

**P1 — Two competing UI structures coexist.** The `Track` tab has been migrated to a modular `Features/Track/` layout (Screen + Components + Layouts), but `Insights`, `Goals`, `Motivation`, `History`, and `Settings` still live in the older flat `Tabs/` folder. View files are scattered across four top-level folders with overlapping roles: `Tabs/`, `Views/`, `Features/`, `Components/`. There's even a dead shim — `Tabs/HomeView.swift` just returns `TrackScreen()`.

**P2 — Data access is inconsistent.** A repository layer exists, but ~17 views bypass it with `@Query` directly, and several views call `modelContext.insert/delete` inline (`SettingsView`, `GoalsViewModel`, plus archived files). So persistence rules live in three places: stores, views, and the model itself (`MetricEntry.getOrCreate(...)`). This is the single biggest scalability risk — every new feature has to guess which pattern to follow.

**P3 — View models are adopted unevenly and aren't really view models.** Five `@Observable` VMs exist, but `ChartsViewModel`, `GoalsViewModel`, and `MotivationViewModel` are referenced in only one place each, while the views still hold their own `@Query` state. The VMs are largely **stateless function bags** — e.g. `HomeViewModel.totalHabits(from:)` takes the data as a parameter rather than owning it — so they don't actually decouple the view from the store.

**P4 — No dependency injection story.** Collaborators are reached three ways: `.shared` singletons (`ThemeManager`, others), SwiftUI `@Environment`, and ad-hoc construction inside views. Navigation/coordination uses `NotificationCenter` (`AppEvent`) with **timing hacks** — `ContentView` posts an event then `DispatchQueue.main.asyncAfter(deadline: .now() + 0.35)` to present a sheet. That's fragile and untestable.

**P5 — God files & misplaced logic.** `SettingsView` (555 lines) mixes UI, persistence, and export wiring. `AddGoalView` (504), `QuantityInputSheet` (454), `MotivationalInsightsView` (388) are large multi-responsibility views. Models carry behavior (`MetricEntry.getOrCreate`) that belongs in a store.

**P6 — Dead weight in the tree.** `Archive/` (~1,550 LOC of Watch + `UnifiedMetricRowView`) ships in the source tree, plus `tmp/`, `TODOs/`, `FutureIdeas/`, `ongoing/`. This inflates build/search surface and confuses navigation.

---

## 2. Target architecture

A **feature-modular MVVM** with a clean data boundary and explicit composition. One pattern, applied everywhere, so adding a feature is mechanical rather than improvisational.

```
TrackBoth/
├── App/                      # Composition root
│   ├── TrackBothApp.swift
│   ├── AppContainer.swift    # builds & injects dependencies
│   ├── RootView.swift        # was ContentView (tab host)
│   └── AppRouter.swift       # replaces NotificationCenter coordination
│
├── Core/                     # Cross-cutting, app-agnostic
│   ├── Persistence/          # ModelContainer, schema, migrations, recovery
│   ├── Repositories/         # MetricRepository, EntryRepository, GoalRepository (protocols + SwiftData impls)
│   ├── Services/             # Widget sync, export/import, logging, events
│   ├── Theme/                # ThemeManager + assets
│   └── DesignSystem/         # reusable, feature-agnostic UI (was Components/Common)
│
├── Domain/                   # Pure logic + models (mostly already here)
│   ├── Models/               # Metric, MetricEntry, Goal (moved from /Models)
│   ├── Streaks/ Goals/ Charts/ Metrics/ Milestones/ ...
│
├── Features/                 # One folder per feature, self-contained
│   ├── Track/   {TrackScreen, TrackViewModel, Components/, Layouts/}
│   ├── Insights/
│   ├── Goals/
│   ├── Motivation/
│   ├── History/
│   └── Settings/
│
├── Widget/                   # widget extension + WidgetShared
└── Tests/                    # mirrors the structure above
```

### Layering rules (the contract)

1. **Views never touch `ModelContext` or `@Query` directly.** They read from a feature view model.
2. **View models depend on repository _protocols_, never on `ModelContext`.** This makes them unit-testable with in-memory fakes and removes the `@Query`/store split.
3. **Repositories are the only place SwiftData is imported outside `Core/Persistence` and `Domain/Models`.** All fetch/insert/delete/save lives here.
4. **Domain logic stays pure** (no SwiftUI, no SwiftData) — it already mostly is.
5. **Cross-feature navigation goes through `AppRouter`**, an `@Observable` injected object — no `NotificationCenter`, no timing delays.
6. **Dependencies are constructed once in `AppContainer`** and passed down via `@Environment`; `.shared` singletons are retired.

### Dependency direction

`Features → Core (Repositories/Services/DesignSystem) → Domain`. Domain depends on nothing app-specific. Features never depend on each other directly — only through `Domain` and `Core`.

---

## 3. Phased execution

Each phase is independently shippable and leaves the app green. Phases 0–3 are the high-value structural core; 4–6 are polish and hardening.

### Phase 0 — Cut the dead weight (½ day, near-zero risk)
- Delete `Archive/` from the build target (move to a `legacy` git branch/tag if you want history reachable).
- Remove the `Tabs/HomeView.swift` shim; route `ContentView` straight to `TrackScreen` (already does).
- Move `tmp/`, `TODOs/`, `FutureIdeas/`, `ongoing/` out of the app's source group (keep in repo root or `/docs` if useful, but out of the compiled target).
- **Outcome:** ~1,500+ LOC and several folders gone; smaller search/build surface for everything after.

### Phase 1 — Establish the data boundary (2–3 days, the keystone)
This is the highest-leverage change. Do it before any feature work.
- Define repository **protocols** in `Core/Repositories`: `EntryRepositoryProtocol`, `MetricRepositoryProtocol`, `GoalRepositoryProtocol`. Promote the existing `EntryStore`/`MetricStore` to be the SwiftData implementations behind them.
- Move `MetricEntry.getOrCreate(...)` and any insert/save logic out of the models into `EntryRepository`.
- Add an in-memory fake implementation of each protocol in `Tests/` for fast view-model tests.
- **Do not migrate views yet** — just stand up the seam and point the existing stores at it. Ship.

### Phase 2 — Composition root & DI (1–2 days)
- Create `AppContainer` that builds the `ModelContainer` and the three repositories, exposed via `@Environment` (custom `EnvironmentKey`s or an injected `@Observable AppEnvironment`).
- Convert `ThemeManager` from `.shared` singleton to a container-owned instance injected via environment (it's already `@Observable`, so the call sites barely change).
- Introduce `AppRouter` (`@Observable`) with explicit intents: `selectedTab`, `presentAddMetric()`, `switchToTrack()`. Replace the `AppEvent`/`NotificationCenter` plumbing and delete the `asyncAfter(0.35)` hack — the router sets state synchronously and the view reacts.
- **Outcome:** one obvious place dependencies come from; navigation becomes testable.

### Phase 3 — Migrate features onto the standard (1–2 days each; parallelizable)
Per feature, in this order (lowest-risk first): **Settings → History → Goals → Motivation → Insights**. (Track is already the reference implementation.) For each:
- Create `Features/<Name>/` with `Screen`, `<Name>ViewModel` (`@Observable`, holds state, depends on repository protocols), `Components/`, `Layouts/`.
- Remove `@Query` and `modelContext.insert/delete` from the views; the VM owns data access via repositories and exposes ready-to-render state.
- Break up the god files while you're in there: split `SettingsView` (extract export/import section, data-management section, appearance section into subviews); same for `AddGoalView` and `QuantityInputSheet`.
- Keep/extend the unit tests against the now-injectable VMs.
- Ship after each feature — no phase-wide freeze.

### Phase 4 — Design system consolidation (1–2 days)
- Collapse `Components/`, `Views/`, and feature-agnostic UI into `Core/DesignSystem` (cards, buttons, empty states, chips, headers). Anything feature-specific moves into that feature's `Components/`.
- Establish naming/file conventions (one type per file, `Feature + Role` naming) and a short `ARCHITECTURE.md` describing the layering rules above so contributors stay on the rails.

### Phase 5 — Test & tooling hardening (ongoing)
- Add view-model tests using the in-memory repository fakes (now trivial post-Phase 1).
- Add SwiftLint/SwiftFormat with rules that enforce the boundaries (e.g. ban `import SwiftData` outside `Core/Persistence`, `Domain/Models`, `Core/Repositories`; ban `@Query` outside repositories).
- Wire the lint + test gate into the existing CI (`.github/`).

### Phase 6 — Modularization (optional, longer-term north star)
Once folders are clean and boundaries are enforced by convention, promote them to **Swift Package Manager local packages**: `TrackBothDomain`, `TrackBothCore`, `TrackBothDesignSystem`, and feature packages. This turns the layering rules into _compiler-enforced_ module boundaries, speeds incremental builds, and lets the widget extension depend on `Domain`/`Core` without pulling in the whole app. Only worth doing after Phases 1–4 land.

---

## 4. Sequencing & risk

| Phase | Effort | Risk | Ship-safe? |
|------|--------|------|-----------|
| 0 — Dead code | ½ day | Very low | Yes |
| 1 — Repositories | 2–3 days | Low | Yes |
| 2 — DI + Router | 1–2 days | Medium | Yes |
| 3 — Feature migration | ~1–2 days × 5 | Low (per feature) | Yes, per feature |
| 4 — Design system | 1–2 days | Low | Yes |
| 5 — Tests/tooling | Ongoing | Low | Yes |
| 6 — SPM modules | 1–2 weeks | Medium | Yes, per module |

**Guardrails:** Phase 1 is a prerequisite for everything; don't skip it to chase feature migrations. Do Phase 0 first so you're not refactoring code you'll delete. Phase 3 is per-feature and reversible — if a feature migration goes sideways, only that tab is affected. Keep the test suite green as the definition of "done" for each phase.

---

## 5. The one-paragraph rationale

The reason new features will get harder over time is **P2 + P4**: there's no single answer to "where does data come from" or "where do dependencies come from," so every feature re-litigates it. Fixing the data boundary (Phase 1) and the composition root (Phase 2) removes that ambiguity, and the feature-folder standard (Phase 3) makes adding a screen a copy-of-Track exercise instead of a design decision. Everything else — deleting `Archive/`, splitting god files, the design system, SPM modules — is valuable but secondary to nailing those two seams.
