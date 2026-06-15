# Architecture Specification

## 1. Purpose

Define the production architecture for TrackBoth — a lean habit and vice tracker with clean boundaries between UI, domain logic, and persistence.

---

## 2. Architectural Style

- Feature-first modular monolith
- `SwiftUI` presentation
- `MVVM` per feature (`@Observable` view models)
- Pure domain services for streaks, goals, filters, chart aggregation
- Repository pattern for SwiftData access
- Unidirectional state updates inside each feature

---

## 3. Module Boundaries

### `App`
- App entry point (`TrackBothApp.swift`)
- Root tab shell (`ContentView.swift`)
- Onboarding gate
- SwiftData container bootstrap

### `Features` (current: `Tabs/`, `Views/`)
- `HomeFeature` — daily logging
- `GoalsFeature` — goal CRUD and progress
- `HistoryFeature` — calendar and entry editing
- `ChartsFeature` — visualizations
- `MotivationsFeature` — motivation feed
- `SettingsFeature` — data management and preferences

### `Domain` (target — Phase 2 of master plan)
- `TrackingSemantics` — canonical habit/vice boolean rules
- `StreakCalculator` — streak math (from `StreakUtils`)
- `GoalProgressCalculator` — goal math (from `GoalUtils`)
- `FilterLogic`, `ChartAggregator`, `CalendarLogic`
- No SwiftUI or SwiftData imports

### `Data`
- SwiftData `@Model` classes (`Metric`, `MetricEntry`, `Goal`)
- Repository protocols + SwiftData implementations
- Migration utilities

### `DesignSystem` (current: `Utils/UI/`, `Assets.xcassets/`)
- `ThemeManager`, semantic colors, typography
- Reusable components (`StatCard`, `EmptyStateView`, `FloatingActionButton`)

### `Support`
- Logging (`Logger.swift` → `AppLogger`)
- `ProductSurface` release gating
- Demo data fixtures (DEBUG only)

---

## 4. Dependency Rules

- `Features` may depend on `Domain`, `Data` interfaces, `DesignSystem`, `Support`.
- `Domain` depends on no UI or persistence framework types.
- `Data` can depend on `Domain` contracts and SwiftData.
- `DesignSystem` has no feature/domain knowledge.
- No circular dependencies.

---

## 5. State Management Rules

- ViewModels own screen state and intent handling.
- Domain services perform deterministic computation.
- Repositories perform IO only.
- Views remain declarative; no business rules in SwiftUI views.

---

## 6. Error Handling Model

- Domain errors return typed failures (invalid date, unlogged metric).
- Data errors map to user-safe messages in ViewModel.
- Fatal persistence/migration issues route to recovery UI (`MigrationRecoverySpec.md`).

---

## 7. Codebase Map (target layout)

| Layer | Current path | Target path |
|-------|--------------|-------------|
| App shell | `TrackBothApp.swift`, `Views/ContentView.swift` | `App/` |
| Features | `Tabs/`, `Views/AddViews/`, `Views/EditViews/` | `Features/{Home,Goals,…}/` |
| Domain | `Utils/Data/StreakUtils.swift`, etc. | `Domain/` |
| Data | `Models/` | `Data/Models/` + `Data/Repositories/` |
| DesignSystem | `Utils/UI/`, `Assets.xcassets/` | `DesignSystem/` |
| Support | `Utils/Services/Logger.swift` | `Support/` |
| Tests | (none) | `Tests/Unit/`, `Tests/UI/` |

Migration to target layout is incremental — do not block 1.0 on full folder restructure. New code follows target paths; existing code moves in Phase 2.

---

## 8. Definition of Done (Lean 1.0)

- Core features conform to module boundaries (domain logic not in views)
- No direct SwiftData calls from views (via ViewModel or repository)
- Unit tests exist for `TrackingSemantics`, streaks, goals, filters
- `ProductSurface.lean1_0` hides non-shipping surfaces in Release

---

## 9. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-14 |
| **Commit** | (pre-refactor) |
| **Code** | `LifeMetrics/` flat structure |
