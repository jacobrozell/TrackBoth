**Estimated release:** `1.0.0`

# Charts Specification

## 1. Purpose

Define data visualizations for habit adherence, streaks, and quantity trends.

---

## 2. Lean 1.0 Scope

### In scope
- Line chart — adherence over time
- Bar chart — weekly/monthly completion
- Heatmap — calendar success grid
- Quantity chart — when quantity entries exist
- Shared filter controls (All / Habits / Vices / specific metric)
- Chart export to image (PNG) if already implemented in Settings/utils
- Empty state when no data

### Out of scope
- Year-over-year comparison
- Predictive analytics
- Widget-embedded charts

---

## 3. UI Specification

### Tab placement
Charts is tab index 4 — must be visible in `ContentView` TabView.

### Controls
- `ChartControlsView` — metric filter, period selector
- Streak stats section where applicable

### Chart types

| Chart | Data source |
|-------|-------------|
| Line | Daily success rate per filtered metrics |
| Bar | Aggregated by week/month |
| Heatmap | Day-level success grid |
| Quantity | `MetricEntry.quantity` over time |

All charts use TrackingSemantics for success counting.

---

## 4. Testing

### Unit
- `ChartsAggregationTests` — data points match fixture entries

### Manual
- Load demo data → each chart type renders
- Filter changes update all chart types consistently

---

## 5. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-14 |
| **Commit** | (tab disabled in ContentView) |
| **Code** | `ChartsView.swift`, `ChartsViewModel.swift`, `Components/Charts/` |
