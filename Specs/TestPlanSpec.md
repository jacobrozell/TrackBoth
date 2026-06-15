# Test Plan Specification

## 1. Purpose

Define test strategy, ownership, and quality gates for TrackBoth lean 1.0.0.

Test-first policy: core logic must have unit tests before merge once Phase 0 CI is in place.

---

## 2. Test Layers

### Unit Tests (`Tests/Unit/`)

| Area | Priority |
|------|----------|
| `TrackingSemantics` | P0 |
| `StreakUtils` / streak calculator | P0 |
| `GoalUtils` | P0 |
| `FilterUtils` | P1 |
| `CalendarHelper` | P1 |
| Chart aggregation | P1 |
| ViewModels (Home, Goals, History) | P1 |
| `MigrationUtils` | P0 |
| Export/import encode-decode | P1 |

### UI Tests (`Tests/UI/`)

| Suite | Flow |
|-------|------|
| `Lean1_0SmokeUITests` | Onboarding skip → Home → add habit → log → History |
| `DailyLoggingUITests` | Habit toggle + status label |
| `ViceLoggingUITests` | Vice avoided / not avoided labels |
| `SettingsUITests` | Export sheet, delete confirmation |
| `OnboardingUITests` | Complete onboarding |

### Accessibility Tests (`Tests/Accessibility/` — optional 1.0)

- WCAG contrast on theme tokens
- Accessibility label presence on core controls

---

## 3. CI Quality Gates (PR)

1. SwiftLint passes
2. Build succeeds (Debug, iOS Simulator)
3. All unit tests pass
4. No new force-unwraps in Domain layer

### Release branch additional gates

1. `Lean1_0SmokeUITests` pass on Release configuration
2. Line coverage ≥ 35% on app target
3. `ProductSurface.lean1_0` smoke — no widget/watch/demo UI visible

---

## 4. Regression Matrix (Lean 1.0)

| Scenario | Type |
|----------|------|
| New vice → 0/1 today, no streak | Unit + UI |
| Habit done → streak increments | Unit |
| Vice avoided → streak increments | Unit |
| Backdated log before first log → streak 0 | Unit |
| Gap day breaks streak | Unit |
| Boolean goal progress (habit vs vice) | Unit |
| Quantity goal progress | Unit |
| Export → delete all → import round-trip | Integration |
| Onboarding → first habit | UI |
| Charts render with demo data | UI (manual until Charts UI test) |

---

## 5. Simulator Verification Commands

```bash
# Unit tests
xcodebuild test -scheme TrackBoth \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:TrackBothTests

# UI smoke
xcodebuild test -scheme TrackBoth \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:TrackBothUITests/Lean1_0SmokeUITests
```

---

## 6. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-14 |
| **Commit** | (no test target yet) |
| **Code** | Target: `Tests/` |
