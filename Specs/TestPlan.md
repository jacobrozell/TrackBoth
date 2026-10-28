# TrackBoth Test Plan

> Spec governance: behavior changes update the matching spec in the same commit.


## 11. Test plan

### 11.1 Unit tests (target ≥80% on core files)

| File | Must cover |
|------|-----------|
| `DayMathTests` | anchor is noon; endOfDay; days(from:through:) inclusive; DST spring and fall; leap day |
| `RecoveryMathTests` | V1–V7; slip exactly at startedAt; multiple slips same day; window larger than history; `counted` excludes before-start and today-pending |
| `HabitMathTests` | H1–H5; bestRun with gaps; doneCount window edges; startedAt today |
| `MilestonePolicyTests` | reached() incl. 730/1095; next(); pending() picks highest; re-earn after run drop; habit list |
| `TriggerTagTests` | encode/decode round-trip; unknown raw values dropped; empty string |
| `PatternInsightsTests` | top-3 ordering/tie-break; `.other` rule; hardestTime buckets incl. 04:59/05:00 edges; <3 data points → nil; urgeSummary excludes inProgress |
| `RecoveryCopyTests` | plurals; clock formats; saved formatting with en_US locale |
| `RecoveryStoreTests` | upsert one-entry-per-day; markFree doesn't override slip; logSlip guard; setHabitDone false deletes; delete cascades; deleteAll; reorder; posts `.recoveryDataChanged` |
| `SnapshotsTests` | model → ViceHistory/HabitHistory (status mapping, day keys) |
| `BackupServiceTests` | v5 round-trip; legacy v1/v3/v4 fixtures; newer schema error; invalid file leaves store untouched |
| `ReminderPlanTests` | 7 check-ins; skip today when done or past time; milestone dates; discreet copy; cap |
| `MilestoneLedgerTests`, `PreferencesTests`, `BootstrapStoreRecoveryTests`, `WCAGContrastTests` | as named |
| View-model tests: `TodayViewModelTests`, `CheckInViewModelTests`, `UrgeViewModelTests`, `SlipViewModelTests`, `ProgressViewModelTests`, `MetricDetailViewModelTests`, `MetricFormViewModelTests`, `OnboardingViewModelTests` | outputs for the demo dataset; validation; write calls |

### 11.2 UI tests (launch args: `-ui_testing` always; `-skip_onboarding -seed_demo` unless testing onboarding)

`testLaunchShowsThreeTabs`, `testOnboardingCreatesViceAndLandsOnToday`, `testOnboardingHabitOnlyPath`, `testCheckInMarksVicesFree`, `testUrgeFlowResisted`, `testSlipFlowShowsCompassionateSummary`, `testEditPastDayToSlipUpdatesStats`, `testCrisisResourcesReachableFromSettings`, `testDeleteAllReturnsToOnboarding`.

### 11.3 Accessibility identifiers (`Support/AccessibilityIdentifiers.swift`)

`tab.today`, `tab.progress`, `tab.settings`, `today.checkInBanner`, `today.sosButton`, `today.viceCard.<uuid>`, `today.habitToggle.<uuid>`, `checkIn.free.<uuid>`, `checkIn.slipped.<uuid>`, `checkIn.done`, `urge.intensity.<1-5>`, `urge.passed`, `urge.slipped`, `urge.done`, `slip.save`, `slip.summary`, `celebration.continue`, `progress.metricCard.<uuid>`, `detail.calendarDay.<yyyy-MM-dd>`, `dayEditor.free`, `dayEditor.slipped`, `dayEditor.clear`, `settings.crisisResources`, `settings.deleteAll`, `onboarding.next`, `onboarding.vicePreset.<id>`, `onboarding.habitOnly`, `onboarding.finish`.


Domain tests use `Calendar.testNY` (Gregorian, `America/New_York`). Never call `Date()` or `Calendar.current` inside a Domain test.

UI tests launch with `-ui_testing` always, and `-skip_onboarding -seed_demo` unless the test is about onboarding.

## Verification

| Field | Value |
|-------|--------|
| Last verified | — |
| Commit | — |

