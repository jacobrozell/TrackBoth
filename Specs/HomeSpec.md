**Estimated release:** `1.0.0`

# Home Specification

## 1. Purpose

Define the primary daily logging experience — habit/vice list, week calendar, quick stats, and LoggingSheet entry point.

Authoritative tracking rules: [`TrackingSemanticsSpec.md`](TrackingSemanticsSpec.md).

---

## 2. Lean 1.0 Scope

### In scope
- Week mini-calendar (7 days ending today — no future dates)
- Quick stats row (habits done, vices avoided, active streaks — hide zero values)
- Habits and Vices sections with per-section completion counts
- `CompactMetricRow` — quick toggle + tap to open LoggingSheet
- Edit mode for row actions (Log / Edit / Delete)
- `LoggingSheet` — full log for selected day
- FAB — add metric
- Landscape: left panel (stats + week), right panel (list + FAB)
- Empty state — "Add Your First Habit" CTA
- Settings gear → sheet
- Date navigation up to 30 days back

### Out of scope (1.0)
- Widget quick-log
- Watch companion
- Inline details/motivation/quantity on row (moved to LoggingSheet)

---

## 3. UI Specification

### Portrait layout
1. Quick stats row
2. Week mini-calendar
3. Edit / Today buttons
4. Habits section header + rows
5. Vices section header + rows
6. FAB (bottom trailing)

### Metric row (`CompactMetricRow`)

| Element | Behavior |
|---------|----------|
| Toggle | Quick complete/avoided — see TrackingSemantics |
| Row tap | Opens LoggingSheet |
| Status pill | Top-right: Completed / Incomplete / Avoided / Not Avoided |
| Streak | Flame + "X day streak" or "X days clean" when > 0 and logged |
| Goal chip | `{current}/{target}` when boolean goal exists |
| Quantity | Bottom-right quantity string when set |

**Vice rows:** Must not use habit checkmark semantics. See TrackingSemantics §5.

### LoggingSheet

| Section | Content |
|---------|---------|
| Status | Habit: "Did it" toggle. Vice: "Avoided" toggle (inverted value) |
| Details | Optional multiline |
| Motivation | Optional multiline |
| Quantity | Opens `QuantityInputSheet` |

Save marks `Metric.hasBeenLogged = true`.

---

## 4. View Model (`HomeViewModel`)

| Responsibility | Notes |
|----------------|-------|
| `selectedDate` | Drives all row state |
| `todayCompleted` | Uses TrackingSemantics |
| `toggleMetricCompletion` | Explicit set — not naive toggle for vices |
| Date navigation | ±1 day, jump to today, 30-day back limit |

---

## 5. Demo Data

- **Development only** — toolbar or settings trigger
- Must not appear in Release (`ProductSurfaceSpec.md`)
- Demo metrics include quantity samples for chart testing

---

## 6. Accessibility

- Identifiers: `fab_add_metric`, `button_settings`, row toggles
- VoiceOver: metric name + status + streak

See [`AccessibilitySpec.md`](AccessibilitySpec.md).

---

## 7. Testing

### Unit
- `HomeViewModelCompletionTests`
- Date navigation bounds

### UI
- `DailyLoggingUITests`, `ViceLoggingUITests`

### Manual
- Landscape iPad split
- Empty → add first habit flow

---

## 8. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-14 |
| **Commit** | (vice bugs open) |
| **Code** | `HomeView.swift`, `HomeViewModel.swift`, `CompactMetricRow.swift`, `LoggingSheet.swift` |

Legacy wireframes: [`Specs/home-view-redesign-spec.md`](../Specs/home-view-redesign-spec.md)
