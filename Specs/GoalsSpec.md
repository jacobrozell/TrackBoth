**Estimated release:** `1.0.0`

# Goals Specification

## 1. Purpose

Define goal creation, display, and progress tracking for boolean and quantity goals.

Progress math: `GoalUtils` + [`TrackingSemanticsSpec.md`](TrackingSemanticsSpec.md).

---

## 2. Lean 1.0 Scope

### In scope
- Boolean goals: weekly, monthly, yearly periods
- Quantity goals: maxDaily, avgDaily, totalPeriod
- Goal cards with progress bars
- Add / edit / delete goals
- Per-metric multiple goals (boolean + quantity)
- Vice goal copy: "days avoided" framing

### Out of scope
- Bi-weekly period (removed)
- Achievements on goal completion

---

## 3. UI Specification

### Goals list
- Card per goal showing metric name, type icon, period, progress bar
- Empty state aligned with Home/Motivations pattern
- FAB → Add Goal sheet

### Add Goal flow
1. Select metric (habit/vice indicator)
2. Goal type: Boolean or Quantity
3. Period picker
4. Target value (+ quantity-specific fields)

### Progress display

| Type | Habit | Vice |
|------|-------|------|
| Boolean | Days done / target | Days avoided / target |
| Quantity | Per QuantityGoalType | Max daily emphasis for vices |

---

## 4. Data Rules

- Goals belong to `Metric` via relationship (cascade delete)
- One boolean goal per period per metric (enforced in UI)
- Progress calculated from entries in current period window

---

## 5. Testing

### Unit
- `GoalUtilsTests` — boolean + quantity, habit vs vice, period boundaries

### UI
- Add goal → verify progress updates after Home log

---

## 6. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-14 |
| **Commit** | (current) |
| **Code** | `GoalsView.swift`, `GoalsViewModel.swift`, `GoalUtils.swift`, `Components/Goals/` |
