# TrackBoth — Lean 1.0.0 Master Plan

**Created:** 2026-06-14  
**Status:** Active  
**Goal:** Ship a lean, trustworthy 1.0.0 release with Dart Buddy–level engineering discipline — core habit/vice tracking only.

**Reference app:** [Dart Buddy](/Users/jrozell/Desktop/personal/Dart-Buddy) — production-ready bar for tests, CI, scope gating, and release ops.

---

## Executive Summary

TrackBoth is a feature-rich prototype with solid foundations (SwiftUI, SwiftData, themes, iCloud backup) but **known logic bugs**, **no automated tests**, **no CI**, and **surfaces that aren't ready to ship** (widgets, watch, motivation game).

Lean 1.0 strips the app to **daily habit/vice logging, goals, history, basic charts, motivations, and settings** — nothing else ships. Widget and Watch are **explicitly out of scope** for 1.0.0 and will be removed or gated from Release builds.

**Estimated timeline:** ~8–10 weeks part-time (~6–7 weeks full-time).

---

## Lean 1.0.0 — What Ships

### Core user loop (must work flawlessly)

| Feature | Description |
|---------|-------------|
| **Home** | Daily logging for habits and vices; week mini-calendar; habits/vices sections; LoggingSheet |
| **Goals** | Boolean goals (weekly/monthly/yearly); quantity goals where already implemented |
| **History** | Calendar view, entry list, edit past entries, filters |
| **Charts** | Line, bar, heatmap — re-enabled in tab bar |
| **Motivations** | Basic feed: add/view motivations tied to vices (not the gamified scroll system) |
| **Settings** | Export JSON, delete all data, iCloud backup/restore, themes, onboarding reset |
| **Onboarding** | First-launch intro |

### Supporting infrastructure (must ship)

| Area | Requirement |
|------|-------------|
| **Correctness** | Unified vice/habit boolean semantics; no phantom streaks |
| **Data** | SwiftData persistence, migration on launch, export/import round-trip |
| **Themes** | Curated theme set (not every experimental theme) |
| **Accessibility** | VoiceOver labels, Dynamic Type, WCAG AA contrast on core screens |
| **Tests** | Unit tests on domain logic; UI smoke suite; CI on every PR |
| **Release ops** | Ship checklist, privacy page, feature inventory, TestFlight RC |

---

## Lean 1.0.0 — What Does NOT Ship

These exist in the repo today but are **cut from 1.0.0**. Code may remain on `dev` behind flags; Release builds must not expose them.

| Feature | Action for 1.0 |
|---------|----------------|
| **Home Screen Widget** | Remove from Release scheme or gate via `ProductSurface`; no App Groups work |
| **Widget extension target** | Do not ship; stub code stays out of Release |
| **Apple Watch app** | Delete or move orphaned `Views/WatchViews/` to `Archive/`; no watchOS target |
| **Live Activities** | Cut |
| **Control Widget** | Cut |
| **Motivation game** | Cut (scroll points, shop, infinite feed) |
| **Achievements / badges** | Cut |
| **Smart notifications** | Cut |
| **Shortcuts / Siri** | Cut |
| **Predictive analytics** | Cut |
| **Custom app icons** | Cut |
| **Donate button** | Cut |
| **Demo data in Release** | Hide "Try Demo Data" behind DEBUG or remove from Release |
| **Android / React Native ports** | Specs only; no work |

---

## Known Bugs — P0 Before Any Polish

These block a trustworthy 1.0 and are fixed in Phase 1.

| Bug | Root cause |
|-----|------------|
| Vices show 1/1 today after creation | Inconsistent vice boolean semantics in `CompactMetricRow` vs `HomeViewModel` |
| 365-day streak on backdated vice toggle | `hasBeenLogged` half-implemented; `StreakUtils` ignores it; `getOrCreate` marks logged on touch |
| Vice uses same checkmark toggle as habits | UX mismatch — vices need "Avoided / Not Avoided" |
| `MigrationUtils.runMigrationIfNeeded()` never called | Migration exists but not wired to app launch |

### Canonical boolean semantics (single source of truth)

```
Habits:  done     = value == true
Vices:   avoided  = value == false
Logged:  user explicitly saved an entry for that day (hasBeenLogged)
Streak:  only counts days after first log; missing day after first log breaks streak
```

Implement in `Domain/Tracking/TrackingSemantics.swift` and use everywhere.

---

## Engineering Bar (Dart Buddy Parity)

| Practice | Dart Buddy | TrackBoth 1.0 target |
|----------|------------|----------------------|
| Unit tests | ~169 files | Start with domain + view models; ≥35% line coverage |
| UI smoke tests | Lean1_0SmokeUITests | Onboarding → log → history → settings |
| CI | GitHub Actions | Lint → build → unit tests on PR |
| SwiftLint | Enforced | Ban `print()`, warn force-unwrap |
| Architecture | Domain / Data / Features | Extract pure logic from views |
| Scope gating | `ProductSurface.lean1_0` | Hide widget, watch, debug tools in Release |
| Migration recovery | BootstrapStoreRecovery | Retry + user-facing recovery UI |
| Release checklist | `docs/release/1.0.0-ship-checklist.md` | Create equivalent |
| Privacy | Hosted `docs/privacy.html` | Create equivalent |

---

## Verification Loop

No iOS Simulator MCP is available. Every phase ends with agent-run shell verification:

```bash
# Lint
swiftlint lint --strict

# Unit tests
xcodebuild test \
  -scheme TrackBoth \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:TrackBothTests

# UI smoke (Release config)
xcodebuild test \
  -scheme TrackBoth \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:TrackBothUITests/Lean1_0SmokeUITests

# Release build
xcodebuild -scheme TrackBoth \
  -configuration Release \
  -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Manual simulator smoke after each phase: create habit → log → check streak → history edit → export.

---

## Phases

### Phase 0 — Engineering Foundation (Week 1)

**Status:** ✅ Done (2026-06-14)

**Objective:** CI green, test target exists, lint enforced.

| Task | Detail | Status |
|------|--------|--------|
| Add XcodeGen `project.yml` | App + widget + test targets | ✅ |
| Add test targets | `TrackBothTests`, `TrackBothUITests` | ✅ |
| Add CI | `.github/workflows/ci.yml` — build only (`TrackBothCI`) | ✅ |
| Fix version mismatch | Widget `CURRENT_PROJECT_VERSION` → 3 | ✅ |
| Add SwiftLint | `.swiftlint.yml` | ⬜ follow-up |
| Create docs | `CONTRIBUTING.md`, this plan, feature inventory | ✅ |
| Update README | XcodeGen workflow | ✅ |

**Tests:** `TrackBothTests`, `BuildConfigurationTests` (placeholders in `TrackBoth/Tests/`)

**Exit criteria:**
- [x] CI build on PR (`TrackBothCI` scheme)
- [x] Test targets compile
- [ ] SwiftLint passes (deferred)
- [ ] Unit tests execute in CI (deferred to Phase 1)

---

### Phase 1 — Correctness: Vice Logic & Logged Status (Week 1–2)

**Status:** ✅ Done (2026-06-14)

**Objective:** Trustworthy daily logging.

| Task | Detail | Status |
|------|--------|--------|
| Create `TrackingSemantics.swift` | `Domain/Tracking/TrackingSemantics.swift` | ✅ |
| Fix `CompactMetricRow` | Uses TrackingSemantics; distinct vice icons | ✅ |
| Fix `LoggingSheet` | Inverted vice toggle binding | ✅ |
| Fix `HomeViewModel.toggleMetricCompletion` | Explicit success/failure values | ✅ |
| Fix `MetricEntry.getOrCreate` | No auto-log on create | ✅ |
| Finish `hasBeenLogged` | On `Metric` + entry; streak gating | ✅ |
| Wire migration | `ContentView.onAppear` | ✅ |
| Vice UI | Shield/checkmark vs habit checkmark | ✅ |

**Tests:** `TrackingSemanticsTests`, `StreakUtilsTests`, placeholders — **15 tests passing**

**Exit criteria:**
- [x] All Phase 1 unit tests pass
- [ ] Manual vice/habit smoke on simulator (recommended)

---

### Phase 2 — Domain Extraction & Unit Tests (Week 2–3)

**Objective:** Testable pure logic, Dart Buddy `Domain/` layer.

| Extract | From | To |
|---------|------|-----|
| Streaks | `StreakUtils.swift` | `Domain/Streaks/` |
| Goals | `GoalUtils.swift` | `Domain/Goals/` |
| Filters | `FilterUtils.swift` | `Domain/Filters/` |
| Calendar | `CalendarHelper.swift` | `Domain/Calendar/` |
| Chart aggregation | `ChartsViewModel` | `Domain/Charts/` |

| Task | Detail |
|------|--------|
| Repository protocols | `MetricRepository`, `EntryRepository`, `GoalRepository` |
| Consolidate row components | Pick `CompactMetricRow` OR `UnifiedMetricRowView`; deprecate the other |

**Tests:** `GoalUtilsTests`, `FilterUtilsTests`, `CalendarHelperTests`, `ChartsAggregationTests`, `RepositoryContractTests`

**Coverage target:** 30%+ on Domain layer

**Exit criteria:**
- [ ] Domain folder has zero SwiftUI imports
- [ ] ViewModels ≤ 200 lines each

---

### Phase 3 — Core UX Completion (Week 3–4)

**Objective:** Finish daily-use screens.

| Task | Detail |
|------|--------|
| Home redesign | Complete `TODOs/homePageRedesign.md` items |
| Re-enable Charts tab | Uncomment in `ContentView.swift` |
| History polish | Filter row padding; quantity filter behavior |
| LoggingSheet | Reuse `QuantityInputSheet`; explicit save sets `hasBeenLogged` |
| Settings | Hide demo data in Release; remove bi-weekly period if present |
| Haptics | Toggle and save feedback |

**UI tests (first suite):**
- `OnboardingSmokeUITests`
- `DailyLoggingUITests`
- `ViceLoggingUITests`
- `HistoryNavigationUITests`

Add `accessibilityIdentifier` to FAB, toggles, tab bar, LoggingSheet save.

**Exit criteria:**
- [ ] 4 UI smoke tests green
- [ ] Charts in tab bar
- [ ] Home redesign ≥ 90% complete

---

### Phase 4 — Data Layer Hardening (Week 4–5)

**Objective:** Resilient persistence and backup.

| Task | Detail |
|------|--------|
| `BootstrapStoreRecovery` | Retry open, in-memory fallback, user prompt |
| `MigrationRecoveryView` | User-facing "couldn't load data" + export + reset |
| iCloud round-trip | Backup → wipe → restore tested |
| JSON export/import | Schema version field; round-trip test |
| Strip widget/watch code from Release | `ProductSurface` gates or `#if DEBUG` |

**Tests:** `BootstrapStoreRecoveryTests`, `ExportImportTests`, `iCloudBackupServiceTests`

**Exit criteria:**
- [ ] Migration runs every launch
- [ ] Export/import round-trip test passes
- [ ] Recovery UI exists for container failure

---

### Phase 5 — ProductSurface & Scope Lock (Week 5)

**Objective:** Release build = lean 1.0 only.

Create `Support/Release/ProductSurface.swift`:

```swift
enum ProductSurface {
    case lean1_0    // App Store / TestFlight
    case development // Full dev surface on main branch

    var showsCharts: Bool { true }
    var showsWidget: Bool { false }      // 1.0: no widget
    var showsWatch: Bool { false }         // 1.0: no watch
    var showsMotivationGame: Bool { false }
    var showsDemoData: Bool { false }      // Release only
    var showsDebugLogging: Bool { false }
}
```

| Release build must NOT show | Action |
|-------------------------------|--------|
| Widget extension | Excluded from Release scheme |
| Watch views / promos | Removed or archived |
| Motivation game UI | Gated off |
| Demo data buttons | DEBUG only |
| Incomplete experimental themes | Curated subset in lean |

**Tests:** `ProductSurfaceTests`, `Lean1_0SmokeUITests`

**Exit criteria:**
- [ ] `docs/feature-inventory.md` matches Release build
- [ ] Lean smoke UI test passes on Release config

---

### Phase 6 — Strip Widget & Watch (Week 5)

**Objective:** Clean repo; no dead code in Release.

| Task | Detail |
|------|--------|
| Widget extension | Remove from Release scheme; keep on `dev` branch only if needed for future 1.1 |
| Consolidate widget folders | `TrackBoth-Widget/` vs `Widgets/` — archive one; document in inventory |
| Watch views | Move `Views/WatchViews/` → `Archive/Watch/` or delete |
| Update specs | Mark widget/watch specs as post-1.0 in `docs/feature-inventory.md` |
| Remove App Groups work | Not needed for 1.0 |

**No widget/watch tests in 1.0.**

**Exit criteria:**
- [ ] Release build has no widget extension embedded
- [ ] No Watch Swift files compiled in Release target
- [ ] `Archive/` or deletion documented in inventory

---

### Phase 7 — Accessibility & Polish (Week 6–7)

**Objective:** App Store–quality UX on core screens.

| Task | Detail |
|------|--------|
| VoiceOver labels | All toggles, charts, calendar cells |
| Dynamic Type | Audit `Typography.swift` |
| Contrast | Theme tokens pass WCAG AA |
| Empty states | Consistent across Home, Goals, History, Charts |
| Error feedback | Save failures, iCloud errors |
| Performance | Chart rendering with 365 days × 20 metrics |

**Tests:** `WCAGContrastTests`, `AccessibilityLabelTests`, `WCAGAccessibilityUITests` (light)

**Exit criteria:**
- [ ] `accessibility/1.0-nutrition-label-checklist.md` complete
- [ ] No P0 layout breaks at XXXL Dynamic Type

---

### Phase 8 — Observability & Logging (Week 7)

**Objective:** Production-grade logging.

| Task | Detail |
|------|--------|
| `AppLogger` protocol | Structured categories; OSLog in Release |
| Remove noisy logging | e.g. `HabitType.displayName` logs on every access |
| SwiftLint `no_print` | Zero `print()` in app target |

**Exit criteria:**
- [ ] SwiftLint passes with no print violations

---

### Phase 9 — Release Ops (Week 8–10)

**Objective:** TestFlight → App Store.

| Deliverable | Path |
|-------------|------|
| Ship checklist | `docs/release/1.0.0-ship-checklist.md` |
| Privacy page | `docs/privacy.html` |
| Feature inventory | `docs/feature-inventory.md` |
| QA sign-off | `roadmap/release/QA-Signoff-RC1.md` |
| App Store assets | Screenshots, description, keywords |
| CI maturity | `ci.yml` (PR) + `nightly-ui.yml` (optional) |
| TestFlight | Xcode Cloud or manual archive |

**Physical device QA:**
- iPhone fresh install
- iPad landscape Home (if supporting iPad)
- iCloud signed-in backup/restore
- 7-day dogfood: daily logging

**Exit criteria:**
- [ ] Coverage ≥ 35%
- [ ] All unit + UI smoke tests green
- [ ] TestFlight RC approved
- [ ] App Store submission ready

---

## Post-1.0 Backlog (1.1+)

| Feature | Target |
|---------|--------|
| Home Screen Widget | 1.1 |
| Apple Watch companion | 1.2 |
| Smart notifications | 1.2 |
| Shortcuts / Siri | 1.2 |
| Achievements | 1.3 |
| Motivation game | Separate milestone |
| Custom app icons | 1.x |
| Advanced analytics | 1.x |

---

## Test Strategy

| Phase | Tests added |
|-------|-------------|
| 0 | CI plumbing, placeholder tests |
| 1 | Domain correctness (highest ROI) |
| 2 | Repository + aggregation |
| 3 | UI smoke (4 flows) |
| 4 | Data recovery + export |
| 5 | ProductSurface + lean smoke |
| 7 | Accessibility |
| 9 | Coverage gate ≥ 35% |

**Coverage targets by layer:**

| Layer | Target |
|-------|--------|
| Domain (TrackingSemantics, StreakUtils, GoalUtils) | 90%+ |
| ViewModels | 60%+ |
| Services (iCloud, export) | 70%+ on encode/decode |
| Overall app | 35%+ |

---

## Timeline

| Week | Phase | Outcome |
|------|-------|---------|
| 1 | 0 + 1 | CI green; vice/streak bugs fixed |
| 2 | 1 + 2 | Domain extracted; 20+ unit tests |
| 3 | 3 | Home done; Charts back; UI smoke |
| 4 | 4 | Data recovery; export tests |
| 5 | 5 + 6 | Scope locked; widget/watch stripped |
| 6–7 | 7 + 8 | Accessibility; logging |
| 8–10 | 9 | TestFlight RC → App Store |

---

## Execution Order (When Work Starts)

1. Phase 0 — XcodeGen + test target + CI
2. Phase 1 — Failing tests for vice/streak bugs, then fix
3. Phase 2 — Extract `Domain/` + repository protocols
4. Phase 3 — Home + Charts + UI smoke tests
5. Phase 4 — Data hardening
6. Phase 5 + 6 — ProductSurface + strip widget/watch
7. Phase 7 + 8 — Accessibility + logging
8. Phase 9 — Release ops

---

## Related Docs

| Doc | Purpose |
|-----|---------|
| [`specs/README.md`](../../specs/README.md) | **Spec catalog** — authoritative product + system specs |
| [`specs/SpecGovernance.md`](../../specs/SpecGovernance.md) | Source of truth, PR rules, audit checklist |
| [`docs/feature-inventory.md`](../feature-inventory.md) | Built vs ships register |
| [`docs/release/1.0.0-ship-checklist.md`](1.0.0-ship-checklist.md) | Pre-submission checklist (create in Phase 9) |
| [`specs/TrackingSemanticsSpec.md`](../../specs/TrackingSemanticsSpec.md) | Habit/vice boolean rules, streaks, logged status |
| [`specs/HomeSpec.md`](../../specs/HomeSpec.md) | Home UX spec |
| [`docs/product/competitive-strategy.md`](../product/competitive-strategy.md) | Naming, Clean Slate analysis, post-1.0 competitive roadmap |
| [`specs/planned/CompetitiveFeaturesSpec.md`](../../specs/planned/CompetitiveFeaturesSpec.md) | Actionable 1.1/1.2 features from competitive analysis |
| [`TODOs/TODO.md`](../../TODOs/TODO.md) | Legacy TODO — superseded by specs + this plan for 1.0 |

---

*This plan supersedes ad-hoc 1.0 priorities in `TODOs/TODO.md` for release scope. Feature work not listed under "What Ships" is out of scope for 1.0.0.*
