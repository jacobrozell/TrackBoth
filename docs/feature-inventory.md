# TrackBoth — Feature Inventory

Living register of what exists vs what ships in lean 1.0.0.

**Last reviewed:** 2026-06-21  
**App status:** Release candidate — ship surface locked; device QA + TestFlight pending.  
**Scope lock:** [`release/1.0.0-core-scope.md`](release/1.0.0-core-scope.md)  
**Ship surface:** [`Specs/ProductSurfaceSpec.md`](../Specs/ProductSurfaceSpec.md) · [`FutureIdeas/ProductUXHandoff.md`](../FutureIdeas/ProductUXHandoff.md)

---

## Status legend

| Status | Meaning |
|--------|---------|
| **Ships 1.0** | Included in lean 1.0.0 Release build |
| **Partial** | Exists but needs manual QA or polish |
| **Dev only** | DEBUG builds only via `ProductSurface` |
| **Cut 1.0** | Not compiled or not exposed in Release |
| **Archived** | Moved to `TrackBoth/Archive/` |
| **Planned** | Spec only; no implementation |

---

## Core features

| Feature | Status | Notes |
|---------|--------|-------|
| Track — daily logging | **Ships 1.0** | `TrackingSemantics`; vice/habit toggles |
| Track — week mini-calendar | **Ships 1.0** | Completion dots (none / partial / complete) |
| Track — habits/vices sections | **Ships 1.0** | `TrackMetricRow` with hero streak + metadata |
| Track — milestone banners | **Ships 1.0** | 7–365 day thresholds; dismissible |
| Track — goal progress on rows | **Ships 1.0** | Monthly goal `current/target` inline |
| LoggingSheet | **Ships 1.0** | Slip motivation reminder for vices |
| LoggingSheet — extended fields | **Dev only** | Mood/quantity behind “More options” in Release |
| Goals tab | **Dev only** | Boolean + quantity goals UI |
| Goals — data | **Ships 1.0** | Created via onboarding presets; progress on Track rows |
| History — calendar | **Ships 1.0** | VoiceOver labels on cells |
| History — entry editing | **Ships 1.0** | |
| History — filters | **Ships 1.0** | |
| Charts — line/bar/heatmap | **Ships 1.0** | Charts tab |
| Charts — quantity | **Dev only** | Partial polish; gated in Release |
| Motivation tab | **Ships 1.0** | Feed + primary motivation |
| Settings — export JSON | **Ships 1.0** | Schema v4 |
| Settings — import JSON | **Ships 1.0** | |
| Settings — delete all data | **Ships 1.0** | |
| Settings — themes | **Ships 1.0** | 2 ship themes (Ocean, Midnight) |
| Settings — share app | **Ships 1.0** | |
| Onboarding | **Ships 1.0** | Presets + placeholder rows on skip |
| Vice — money saved | **Ships 1.0** | Track rows + History detail |
| Vice — slip timer | **Ships 1.0** | Per-vice toggle in Edit; on rows when enabled |
| Add Metric — preset chips | **Ships 1.0** | |
| Demo data | **Dev only** | `-screenshot_demo` launch arg |

---

## Cut / archived (not in lean 1.0 Release)

| Feature | Status | Location / target |
|---------|--------|-------------------|
| Home Screen Widget | **Cut 1.0** | `TrackBothWidget` scheme only — not embedded in app |
| Widget utilities | **Cut 1.0** | `WidgetSyncCoordinator` in app; extension separate |
| Live Activities | **Cut 1.0** | 1.1+ |
| Apple Watch UI | **Archived** | `Archive/Watch/` |
| Motivation game | **Cut 1.0** | |
| Achievements / badges | **Cut 1.0** | 1.3 |
| Smart notifications | **Cut 1.0** | 1.2 |
| Shortcuts / Siri | **Cut 1.0** | 1.2 |

---

## Engineering infrastructure

| Area | Status | Notes |
|------|--------|-------|
| Unit tests | **Ships 1.0** | Domain, export v4, ProductSurface, DayLogSummary |
| UI smoke tests | **Ships 1.0** | Lean 5-tab flows |
| CI (GitHub Actions) | **Ships 1.0** | Build + unit tests |
| ProductSurface gating | **Ships 1.0** | Release vs dev matrix |
| BootstrapStoreRecovery | **Ships 1.0** | |
| Privacy page | **Ships 1.0** | `docs/privacy.html` |
| Monetization | **Free** | No IAP |

---

## Tab bar — lean 1.0 Release

| Tab | Ships |
|-----|-------|
| Track | ✅ |
| History | ✅ |
| Motivation | ✅ |
| Charts | ✅ |
| Settings | ✅ |
| Goals | Dev only |

---

## Maintenance

1. When shipping a feature — update status here and the master plan.
2. When cutting scope — move row to "Cut / archived" with post-1.0 target.
3. PRs that change ship status should update this doc in the same PR.
