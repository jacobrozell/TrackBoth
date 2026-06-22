# TrackBoth Lean 1.0 — Progress Log

Living record of implementation progress against [`lean-1.0-master-plan.md`](lean-1.0-master-plan.md).

---

## 2026-06-14

### Phase 0 — Engineering Foundation ✅

| Deliverable | Location |
|-------------|----------|
| XcodeGen project | `TrackBoth/project.yml` |
| Unit test target | `TrackBothTests` → `TrackBoth/Tests/Unit/` |
| UI test target | `TrackBothUITests` → `TrackBoth/Tests/UI/` |
| CI build workflow | `.github/workflows/ci.yml` (`TrackBothCI` scheme) |
| Contributing guide | `CONTRIBUTING.md` |
| Spec catalog | `specs/` (governance + lean 1.0 feature specs) |
| Widget version aligned | `CURRENT_PROJECT_VERSION: 3` |
| Watch views excluded from app target | `project.yml` excludes `WatchViews/**` |

**Verified locally:** `xcodebuild build -scheme TrackBothCI` → BUILD SUCCEEDED

**Deferred:** SwiftLint; CI test execution (added in Phase 1)

---

### Phase 1 — Correctness ✅

**Completed:** 2026-06-14

| Task | Status |
|------|--------|
| `Domain/Tracking/TrackingSemantics.swift` | ✅ |
| `TrackingSemanticsTests` (7 tests) | ✅ |
| `StreakUtilsTests` (6 tests) | ✅ |
| `Metric.hasBeenLogged` | ✅ |
| Fix `StreakUtils` | ✅ |
| Fix `CompactMetricRow` | ✅ |
| Fix `HomeViewModel` toggle + todayCompleted | ✅ |
| Fix `LoggingSheet` vice toggle binding | ✅ |
| Fix `MetricEntry.getOrCreate` | ✅ |
| Wire `MigrationUtils` on launch | ✅ (`ContentView.onAppear`) |
| CI runs unit tests | ✅ |
| Vice UI distinct icons | ✅ (shield vs checkmark) |

**Verified:** `xcodebuild test -only-testing:TrackBothTests` → 15 tests passed

**Known P0 bugs fixed:** phantom vice streaks, 1/1 on creation, inconsistent boolean semantics

---

### Phase 2 — Domain Extraction ✅

**Completed:** 2026-06-14

| Task | Status |
|------|--------|
| Move `StreakUtils` → `Domain/Streaks/` | ✅ |
| Move `GoalUtils` → `Domain/Goals/` (+ `TrackingSemantics`) | ✅ |
| Move `FilterUtils` → `Domain/Filters/` (+ `successfulEntries`) | ✅ |
| Move `CalendarHelper` → `Domain/Calendar/` | ✅ |
| `GoalUtilsTests` (4 tests) | ✅ |
| `FilterUtilsTests` (5 tests) | ✅ |
| `CalendarHelperTests` (5 tests) | ✅ |
| Deprecate `UnifiedMetricRowView` (comment) | ✅ |
| Repository protocols | ⬜ deferred |

**Verified:** 29 unit tests passed

---

### Phase 3 — Core UX ✅

**Completed:** 2026-06-14

| Task | Status |
|------|--------|
| Re-enable Charts tab (Home 0 … Charts 4) | ✅ |
| `ProductSurface.swift` — hide demo in Release | ✅ |
| History filter row padding | ✅ |
| Accessibility IDs (FAB, settings, logging save/toggle, onboarding) | ✅ |
| UI smoke tests (5 tests) | ✅ |
| `-skip_onboarding` / `-seed_demo_data` launch args | ✅ |
| LoggingSheet inline quantity + haptic on save | ✅ |
| QuantityInputSheet vice semantics via `TrackingSemantics` | ✅ |

**Verified:** 5 UI tests passed

---

### Phase 4 — Data Layer Hardening ✅

**Completed:** 2026-06-14

| Task | Status |
|------|--------|
| `Domain/Data/TrackBothExport.swift` (schema v2) | ✅ |
| `ExportImportService` + round-trip import | ✅ |
| `BootstrapStoreRecovery` (persistent → in-memory fallback) | ✅ |
| `MigrationRecoveryView` banner | ✅ |
| `ExportImportTests` (3 tests) | ✅ |
| `BootstrapStoreRecoveryTests` (2 tests) | ✅ |
| JSON import UI in Settings (file picker + confirm) | ✅ |
| iCloud backup restore sets `hasBeenLogged` | ✅ |
| `iCloudBackupServiceTests` (3 tests) | ✅ |

**Verified:** 41 unit tests passed

---

### Phase 5 — ProductSurface & Scope Lock ✅

**Completed:** 2026-06-14

| Task | Status |
|------|--------|
| Expanded `ProductSurface` flags + `LeanFeature` | ✅ |
| `ProductSurfaceTests` (4 tests) | ✅ |
| Widget extension removed from app target / default scheme | ✅ |
| `TrackBothWidget` scheme for post-1.0 widget dev | ✅ |

**Verified:** `TrackBothCI` builds without widget embed

---

### Phase 6+ — Remaining

See [`lean-1.0-master-plan.md`](lean-1.0-master-plan.md) — accessibility audit, release checklist, TestFlight RC.

---

### Phase 6 — Strip Widget & Watch ✅

**Completed:** 2026-06-14

| Task | Status |
|------|--------|
| Widget removed from app target (Phase 5) | ✅ |
| Watch views → `Archive/Watch/` | ✅ |
| `Archive/README.md` documents widget folders | ✅ |
| Feature inventory updated | ✅ |

---

### Phase 7 — Accessibility & Polish ✅

**Completed:** 2026-06-14

| Task | Status |
|------|--------|
| `AccessibilityIdentifiers` registry | ✅ |
| VoiceOver labels — rows, calendar, tabs | ✅ |
| `WCAGContrastTests` (4 themes) | ✅ |
| `AccessibilityIdentifiersTests` | ✅ |
| `docs/accessibility/1.0-nutrition-label-checklist.md` | ✅ |
| XXXL Dynamic Type device QA | ⬜ manual |

**Verified:** 3 stable UI smoke tests; onboarding/demo in QA sign-off

---

### Phase 8 — Logging Cleanup ✅

**Completed:** 2026-06-14

| Task | Status |
|------|--------|
| Remove noisy `HabitType.displayName` log | ✅ |
| Replace `print()` in app code with `logger` | ✅ |
| Logger uses `#if DEBUG` for console print | ✅ |
| SwiftLint | ⬜ deferred |

---

### Phase 9 — Release Ops (in progress)

| Task | Status |
|------|--------|
| `docs/release/1.0.0-ship-checklist.md` | ✅ |
| `docs/privacy.html` | ✅ |
| `docs/release/QA-Signoff-RC1.md` | ✅ |
| Feature inventory current | ✅ |
| TestFlight RC / App Store assets | ⬜ manual |
| Physical device QA | ⬜ manual |

**Verified:** 45 unit + 3 UI tests green

---

## 2026-06-21

### Ship surface locked + release prep ✅

| Task | Status |
|------|--------|
| Jacob decisions recorded | ✅ [`FutureIdeas/ProductUXHandoff.md`](../../FutureIdeas/ProductUXHandoff.md) |
| `ProductSurface` — 5-tab Release (Track, History, Motivation, Charts, Settings) | ✅ |
| Hero streaks, calendar completion dots, slip motivation | ✅ |
| Onboarding placeholder rows on skip | ✅ |
| Widget embed removed from main app target | ✅ `project.yml` |
| Docs aligned (inventory, core-scope, checklist, README, app-store-copy) | ✅ |
| Tab order — Settings last | ✅ |
| `DayLogSummaryTests` | ✅ |

**Remaining for 1.0 ship:** device QA, dogfood, TestFlight, screenshots, hosted privacy URL.

---

## 2026-06-22

### Build 5 — Xcode archive

| Task | Status |
|------|--------|
| Bump `CURRENT_PROJECT_VERSION` → 5 | ✅ (Xcode project) |
| Archive build 5 for TestFlight / Connect | 🔄 in progress |
