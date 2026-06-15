# Navigation Specification

## 1. Purpose

Define tab structure, modal sheets, and navigation patterns for lean 1.0.

---

## 2. Tab Bar (Lean 1.0)

| Tag | Tab | Icon | Root view |
|-----|-----|------|-----------|
| 0 | Home | house.fill | `HomeView` |
| 1 | Goals | target | `GoalsView` |
| 2 | Motivation | heart.fill | `MotivationsView` |
| 3 | History | calendar.badge.clock | `HistoryView` |
| 4 | Charts | chart.line.uptrend.xyaxis | `ChartsView` |

**Settings** is not a tab — presented as sheet from gear icon on each root view.

**Charts** must be re-enabled in `ContentView` for 1.0 (currently commented out).

---

## 3. Modal Sheets

| Sheet | Trigger | Source tabs |
|-------|---------|-------------|
| Settings | Gear toolbar | All tabs |
| Add Metric | FAB / empty state CTA | Home |
| Add Goal | FAB | Goals |
| Add Motivation | FAB | Motivations |
| LoggingSheet | Row tap / log action | Home |
| Edit Metric / Goal / Entry | Context menu / edit | Home, Goals, History |
| Backup / Restore | Settings | Settings |
| Theme selection | Settings | Settings |

---

## 4. Navigation Rules

- Each tab owns a `NavigationStack`
- Sheets use `.sheet(item:)` or `.sheet(isPresented:)` — dismiss on save
- No deep linking in 1.0

---

## 5. Product Surface

Release builds: exactly 5 tabs above. No widget promo, no watch promo.

See [`ProductSurfaceSpec.md`](ProductSurfaceSpec.md).

---

## 6. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-14 |
| **Commit** | (Charts tab disabled) |
| **Code** | `ContentView.swift` |
