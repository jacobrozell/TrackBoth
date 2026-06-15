# Architecture Cleanup Plan

Phased cleanup from the LifeMetrics architecture audit (June 2026). Goal: consistent MVVM layering, single sources of truth for shared logic, and removal of compiled dead code.

**Status:** Phase 1 complete.

---

## Phase 1 — Quick wins (low risk, high clarity)

| # | Task | Status |
|---|------|--------|
| 1.1 | Delete `Views/WatchViews/` duplicate (mirrors `Archive/Watch/`, not in target) | Done (already absent) |
| 1.2 | Remove unused `ViewModifiers` helpers (`cardStyle`, `sectionStyle`, `emptyStateStyle`) | Done |
| 1.3 | Remove deprecated `FilterUtils.filteredEntries(..., value:)` overload | Done |
| 1.4 | Remove unused `TrackBothExport` typealiases | Done |
| 1.5 | Remove unused `import Combine` from `ContentView` | Done |
| 1.6 | Add `FilterUtils.filteredMetrics(_:in:)`; replace inline `MetricFilter` metric switches | Done |
| 1.7 | Delegate `StreakUtils.filteredMetrics` to `FilterUtils` | Done |
| 1.8 | Exclude widget sync services from main app target (`WidgetDataSync`, `WidgetIntegration`, `WidgetDataManager`) | Done |
| 1.9 | Add `FilterUtils.filteredMetrics` unit tests | Done |

**Exit criteria:** Build succeeds; unit tests pass; no duplicate metric-filter switches in tabs/ViewModels targeted above.

---

## Phase 2 — Restore MVVM consistency

| # | Task | Status |
|---|------|--------|
| 2.1 | Move `HistoryView` filtering/search/calendar logic into `HistoryViewModel`; delete view duplicates | Pending |
| 2.2 | Move `MotivationsView` filter/motivation logic into `MotivationViewModel` | Pending |
| 2.3 | Move `GoalsView` `selectedFilter` into `GoalsViewModel` | Pending |
| 2.4 | Wire `SettingsView` → `SettingsViewModel` **or** delete VM + tests (pick one) | Pending |
| 2.5 | Fix `SettingsViewModel.metricsWithGoals` bug if VM is kept | Pending |
| 2.6 | Remove misleading performance logging on trivial array filters | Pending |

**Exit criteria:** Each tab delegates business logic to its ViewModel; views are primarily layout and bindings.

---

## Phase 3 — Structural consolidation

| # | Task | Status |
|---|------|--------|
| 3.1 | Extract `MetricTabShell` (NavigationStack + GeometryReader + split layout) | Pending |
| 3.2 | Extract `PortraitLandscapeContent` to eliminate portrait/landscape duplication | Pending |
| 3.3 | Promote `*View2` cards to `Components/`; remove superseded goal/motivation card files | Pending |
| 3.4 | Add `ChartCopy` + `ChartDataProcessor` in `Domain/` | Pending |
| 3.5 | Make `ChartControlsView` compose `MetricFilterChipRow` / sidebar | Pending |
| 3.6 | Unify `StatCard` layout (`StatsSectionView` or shared helper) | Pending |
| 3.7 | Refactor `GoalsViewModel` six goal-query methods into one parameterized API | Pending |
| 3.8 | Adopt `cardStyle()` or delete unused modifier infrastructure | Pending |
| 3.9 | Remove other compiled-dead components (`EntriesListView`, `ThemeSelectionView`, etc.) | Pending |

**Exit criteria:** Shared tab shell and card/chart primitives; no `*View2` types living in tab files.

---

## Phase 4 — Scale path (when data or surfaces grow)

| # | Task | Status |
|---|------|--------|
| 4.1 | Repository layer over SwiftData (`MetricStore`, `EntryStore`) | Pending |
| 4.2 | Scoped `@Query` predicates per screen instead of full-table fetches | Pending |
| 4.3 | Migrate `ThemeManager` to `@Observable` + environment injection | Pending |
| 4.4 | Single source of truth for theme (`@AppStorage` vs `UserDefaults`) | Pending |
| 4.5 | Typed app events instead of `NotificationCenter` strings | Pending |
| 4.6 | Re-enable widget sync in main target when `ProductSurface.showsWidget` ships | Pending |
| 4.7 | Log/surface `modelContext.save()` failures on destructive operations | Pending |

**Exit criteria:** Data access behind repositories; queries scoped per feature; theme and cross-cutting state unified.

---

## Reference

- Audit context: architecture audit conversation (June 2026)
- Related: `Specs/ArchitectureSpec.md`, `LifeMetrics/Archive/README.md`, `LifeMetrics/Support/Release/ProductSurface.swift`
