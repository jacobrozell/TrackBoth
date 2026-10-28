# Competitive Features Spec (Post-1.0)

**Status:** Planned · **Target:** 1.1 / 1.2  
**Parent:** [`docs/product/competitive-strategy.md`](../../docs/product/competitive-strategy.md)

Features adopted from competitive analysis (primarily [Clean Slate](https://apps.apple.com/us/app/clean-slate-habit-tracker/id6759494193)) that fit TrackBoth’s dual habit/vice wedge without cloning a quit-only product.

---

## 1.1 — Onboarding presets

### Goal

First launch ends with at least one habit and/or vice created — no empty home screen.

### UX

1. After intro slides (or replacing generic tab tour), show “What do you want to build?” and “What do you want to break?”
2. Multi-select from preset chips; optional “Custom” opens `AddMetricView` flow.
3. Presets create `Metric` records with sensible defaults (`habitType`, optional quantity unit).

### Preset table

| Name | `habitType` | Default unit |
|------|-------------|--------------|
| Exercise | positive | minutes |
| Reading | positive | pages |
| Meditation | positive | minutes |
| Drink water | positive | — |
| Social media | vice | — |
| Smoking | vice | cigarettes |
| Alcohol | vice | drinks |
| Late-night snacks | vice | — |

### Verification

- [x] New user completes onboarding with ≥1 metric persisted
- [x] Presets appear on Home immediately
- [x] Custom path still works

---

## 1.1 — Milestone banners

### Goal

Celebrate 7 / 14 / 30 / 60 / 90 / 365 day thresholds without full achievement system.

### Rules

- **Habits:** consecutive successful days (`value == true`) per `TrackingSemantics`
- **Vices:** consecutive avoided days (`value == false`)
- Respect `hasBeenLogged` — no phantom milestones
- Show once per threshold per metric; dismissible banner on Home or after log

### Out of scope

- Badge grid, points, shop (`Specs/planned/AchievementsSpec.md`)

### Verification

- [x] Milestone fires at correct day count for habit and vice
- [x] No repeat banner for same threshold
- [x] Backdated entries do not award false milestones

---

## 1.1 — Money saved (quantity vices)

### Goal

Tangible motivation for vice tracking using existing quantity model.

### Data

- Optional `costPerUnit: Decimal?` on vice `Metric` (or UserDefaults keyed by metric ID until schema migration)
- Savings = (days clean or units avoided) × cost — define formula in domain layer

### UI

- Edit in `EditMetricView` / vice setup
- Summary on home row or `HistoryEntryDetailView` for quantity vices

### Verification

- [x] Savings hidden when cost not set
- [x] Updates after log edit in History
- [x] Unit tests for savings calculation

---

## 1.1 — Motivation prompt on vice create

### Goal

Every new vice nudges user to attach “why I’m avoiding this.”

### UX

- After saving new vice in `AddMetricView`, sheet: “Add a motivation?” → `AddMotivationView` pre-linked to metric
- Skippable

### Verification

- [x] Motivation links to correct `Metric`
- [x] Skip leaves vice without motivation

---

## 1.2 — Optional time since last slip

### Goal

Offer elapsed-time display for vices without making it default (Clean Slate uses live timers; we stay day-first).

### UX

- Per-vice setting: “Show recovery timer” (default off)
- Display days + hours since last `value == true` entry on vice row (`ViceSlipTimer`)
- **History entry detail:** same recovery label as of that entry’s date (avoided days only)
- **Widgets:** dedicated Vice Recovery widget + subtitles on TrackBoth Log / Streak Spotlight — see [`WidgetSpec.md`](WidgetSpec.md)

### Verification

- [x] Off by default for new vices
- [x] Correct after historical edit (demo)
- [x] History detail shows recovery when timer on and entry is avoided

---

## 1.2 — One-field mood on log

### Goal

Light reflection without full journal.

### UX

- Optional “How are you feeling?” on `LoggingSheet` — single line or emoji chip
- Stored on `MetricEntry.mood`

### Verification

- [x] Mood saves on LoggingSheet
- [x] Mood appears in History detail
- [x] Mood round-trips in JSON export

### Out of scope

- Emotion tags, journal feed, pattern analytics (Clean Slate scope)

---

## 1.2 — Home Screen Widgets

### Goal

Retention and glanceable logging without opening the app — **multiple widgets, multiple focuses** (not one generic tile).

### Authoritative spec

Full catalog, snapshot schema, intents, and phased rollout: [`WidgetSpec.md`](WidgetSpec.md).

### Phase A (1.2.0) — ship first

| Widget | Focus |
|--------|-------|
| Today's Progress | `todayCompleted / total` + unlogged chips |
| TrackBoth Log | Habits + vices toggles; recovery subtitle on vice rows |
| Streak Spotlight | One pinned metric; recovery when pinned vice |
| **Vice Recovery** | **Time recovering since last slip** |

### Phase B–C

Week Glance, Daily Motivation, Control Widget (incl. recovery preset).

### Verification

- [ ] Phase A widgets in gallery with correct copy
- [ ] TrackBoth Log matches Home after toggle
- [ ] Vice Recovery matches `ViceSlipTimer` + Edit Metric toggle
- [ ] Gated by `ProductSurface.showsWidget`

---

## References

- Competitive strategy: `docs/product/competitive-strategy.md`
- Widgets: `Specs/planned/WidgetSpec.md`
- Tracking rules: `Specs/TrackingSemanticsSpec.md`
- Achievements (deferred): `Specs/planned/AchievementsSpec.md`
