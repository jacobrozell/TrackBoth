# Tracking Semantics Specification

**Estimated release:** `1.0.0`

## 1. Purpose

Define the **single source of truth** for habit/vice completion, logging state, and streak eligibility. All views, view models, widgets (future), and charts must delegate to these rules.

Supersedes legacy [`Specs/logged-status-spec.md`](../Specs/logged-status-spec.md) for authoritative behavior.

---

## 2. Core Rules

### 2.1 Boolean semantics

| Type | State | `value` | UI label |
|------|-------|---------|----------|
| Positive habit | Done | `true` | "Completed" / "Did it" |
| Positive habit | Not done | `false` | "Incomplete" |
| Vice | Avoided | `false` | "Avoided" |
| Vice | Did it (failed) | `true` | "Not Avoided" |

**Critical:** Vices use **inverted** boolean meaning vs habits. Never use `value == true` as "avoided" for vices.

### 2.2 Logged state

| Field | Location | Meaning |
|-------|----------|---------|
| `Metric.hasBeenLogged` | Metric | User has **ever** explicitly saved a log for this metric |

Rules:

- Default `hasBeenLogged = false` on new metric.
- Set `true` only on **explicit user save** (toggle, LoggingSheet save) — not on `getOrCreate` alone.
- While `hasBeenLogged == false`: streak = 0, today stats do not count metric as completed.

### 2.3 Streak calculation

After `hasBeenLogged == true`:

- Walk backward from selected date day-by-day.
- **Habit:** streak day counts when entry exists and `value == true`.
- **Vice:** streak day counts when entry exists and `value == false`.
- **Missing entry** after first log: breaks streak (both types).
- **Before first log:** streak = 0 regardless of missing entries.

### 2.4 Today completion count (Home stats)

A metric counts toward "completed today" only if:

1. An entry exists for today, AND
2. Habit: `value == true`; Vice: `value == false`

Unlogged metrics (no entry today) do not count as completed.

---

## 3. Domain API (target)

```swift
enum TrackingSemantics {
    static func isCompleted(metric: HabitType, entry: MetricEntry?) -> Bool
    static func isAvoided(vice entry: MetricEntry?) -> Bool
    static func countsTowardTodayCompleted(metric: Metric, entry: MetricEntry?) -> Bool
    static func streakEligible(metric: Metric) -> Bool
}
```

All UI components (`CompactMetricRow`, `UnifiedMetricRowView`, charts) call these functions — no inline boolean logic.

---

## 4. Entry creation rules

| Action | Behavior |
|--------|----------|
| First explicit log | Create entry; set `Metric.hasBeenLogged = true` |
| Habit quick toggle | Set `value` to done/undone; mark logged |
| Vice quick toggle | Set avoided / not avoided per semantics; mark logged |
| LoggingSheet save | Persist all fields; mark logged |
| Motivation-only add | Does not affect daily `value` unless user also sets status |

`getOrCreate` must **not** set `hasBeenLogged` or imply completion.

---

## 5. Vice UI requirements

Vices must **not** use the same checkmark toggle as habits.

| Control | Habit | Vice |
|---------|-------|------|
| Primary control | Checkmark circle | "Avoided" / "Not Avoided" pill or distinct icon |
| Success color | Green check | Green "Avoided" label |
| Failure color | Gray incomplete | Red "Not Avoided" |

---

## 6. Known violations (fix in Phase 1)

| File | Issue |
|------|-------|
| `CompactMetricRow.swift` | Vice completed uses `value == true` |
| `HomeViewModel.toggleMetricCompletion` | Naive `toggle()` ignores vice semantics |
| `MetricEntry.getOrCreate` | Sets `hasBeenLogged: true` on creation |
| `StreakUtils.swift` | Does not check `Metric.hasBeenLogged` |
| `MigrationUtils` | Never called on app launch |

---

## 7. Migration

1. Add `hasBeenLogged` to `Metric` if not present.
2. For existing metrics with any entry: set `hasBeenLogged = true`.
3. Run on launch via `MigrationUtils.runMigrationIfNeeded`.

---

## 8. Testing

### Unit (required before merge)

- `TrackingSemanticsTests` — all completion combinations
- `StreakUtilsTests` — no phantom streak on new vice; backdated toggle; gap breaks streak
- `HomeViewModelCompletionTests` — today count
- `MetricEntryStoreTests` — getOrCreate does not mark logged

### Manual smoke

1. Create vice → 0/1 today, streak hidden
2. Mark avoided → 1/1, streak = 1
3. Navigate to pre-creation date → streak = 0

---

## 9. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-14 |
| **Commit** | Phase 1 implementation |
| **Code** | `Domain/Tracking/TrackingSemantics.swift`, `StreakUtils.swift`, `CompactMetricRow.swift`, `HomeViewModel.swift` |
