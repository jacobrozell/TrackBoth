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

**Status:** Phase 4 complete.

---

## Phase 2 — Restore MVVM consistency

| # | Task | Status |
|---|------|--------|
| 2.1 | Move `HistoryView` filtering/search/calendar logic into `HistoryViewModel`; delete view duplicates | Done |
| 2.2 | Move `MotivationsView` filter/motivation logic into `MotivationViewModel` | Done |
| 2.3 | Move `GoalsView` `selectedFilter` into `GoalsViewModel` | Done |
| 2.4 | Wire `SettingsView` → `SettingsViewModel` **or** delete VM + tests (pick one) | Done (deleted unused VM + tests) |
| 2.5 | Fix `SettingsViewModel.metricsWithGoals` bug if VM is kept | N/A (VM removed) |
| 2.6 | Remove misleading performance logging on trivial array filters | Done |
| 2.7 | Remove compiled-dead components superseded by inline `*View2` types | Done |

**Exit criteria:** Each tab delegates business logic to its ViewModel; views are primarily layout and bindings.

---

## Phase 3 — Structural consolidation

| # | Task | Status |
|---|------|--------|
| 3.1 | Extract `MetricTabShell` (NavigationStack + GeometryReader + split layout) | Done |
| 3.2 | Extract `FilteredSplitTabLayout` to eliminate portrait/landscape duplication | Done |
| 3.3 | Promote `*View2` cards to `Components/`; remove superseded goal/motivation card files | Done |
| 3.4 | Add `ChartCopy` + `ChartDataProcessor` in `Domain/Charts/` | Done |
| 3.5 | Make `ChartControlsView` compose `MetricFilterChipRow` / sidebar | Done |
| 3.6 | Extract `HomeStatsSection` for unified home stats layout | Done |
| 3.7 | Refactor `GoalsViewModel` six goal-query methods into one parameterized API | Done |
| 3.8 | Add `metricCardStyle()` view modifier for shared card chrome | Done |
| 3.9 | Remove other compiled-dead components (`EntriesListView`, `ThemeSelectionView`, etc.) | Done (Phase 2) |

**Exit criteria:** Shared tab shell and card/chart primitives; no `*View2` types living in tab files.

---

## Phase 4 — Scale path (when data or surfaces grow)

| # | Task | Status |
|---|------|--------|
| 4.1 | Repository layer over SwiftData (`MetricStore`, `EntryStore`) | Done |
| 4.2 | Scoped `@Query` predicates per screen instead of full-table fetches | Done (History month, Home streak lookback) |
| 4.3 | Migrate `ThemeManager` to `@Observable` + environment injection | Done |
| 4.4 | Single source of truth for theme (`ThemePreferences` keys) | Done |
| 4.5 | Typed app events instead of `NotificationCenter` strings | Done (`AppEvent`) |
| 4.6 | Re-enable widget sync in main target when `ProductSurface.showsWidget` ships | Done (`WidgetSyncCoordinator` stub) |
| 4.7 | Log/surface `modelContext.save()` failures on destructive operations | Done (`ModelContext.saveChanges`) |

**Exit criteria:** Data access behind repositories; queries scoped per feature; theme and cross-cutting state unified.

---

## Follow-up (post Phase 4)

| # | Task | Status |
|---|------|--------|
| F.1 | Scoped `@Query` for Goals (366d), Motivations (motivation text), Charts (90d) | Done |
| F.2 | Remove redundant `@Query goals` — use `metric.booleanGoals` / `quantityGoals` | Done |
| F.3 | Migrate remaining `try? modelContext.save()` in active views/sheets | Done |
| F.4 | Wire `WidgetDataSync` when `ProductSurface.showsWidget` becomes `true` | Pending |

---

## Reference

- Audit context: architecture audit conversation (June 2026)
- Related: `Specs/ArchitectureSpec.md`, `LifeMetrics/Archive/README.md`, `LifeMetrics/Support/Release/ProductSurface.swift`
