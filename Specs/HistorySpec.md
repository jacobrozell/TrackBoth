**Estimated release:** `1.0.0`

# History Specification

## 1. Purpose

Define calendar-based history view, entry list, filtering, search, and editing.

---

## 2. Lean 1.0 Scope

### In scope
- Calendar grid with color-coded success/failure per day
- Filter bar: All, All Habits, All Vices, Boolean, Quantity, specific metric
- Entries list below calendar
- Tap entry → edit sheet (`EditEntryView`)
- Search by habit details text
- Month/year navigation

### Out of scope
- Year-over-year analytics
- Export from History tab ( lives in Settings)

---

## 3. UI Specification

### Calendar cell
- Day number
- Status indicator dot
- Details text when present (truncated)

### Filters
- Consistent with Charts filters (`MetricFilter` enum)
- Adequate horizontal padding on filter row (known polish item)

### Entry list
- `HistoryEntryCardView` / `EditableEntryCell`
- Shows metric name, date, status, details/motivation snippet
- Edit affordance

---

## 4. Data Rules

- Respects TrackingSemantics for success coloring
- Only entries with `hasContent` shown in list (or all logged entries — align with filter)
- Edits persist immediately to SwiftData

---

## 5. Testing

### Unit
- `HistoryViewModelTests` — filter, search

### UI
- `HistoryNavigationUITests` — pick day, edit entry

---

## 6. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-14 |
| **Commit** | (current) |
| **Code** | `HistoryView.swift`, `HistoryViewModel.swift`, `Components/Common/CalendarGridView.swift` |
