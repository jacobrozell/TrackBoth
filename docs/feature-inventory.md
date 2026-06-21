# TrackBoth — Feature Inventory

Living register of what exists vs what ships in lean 1.0.0. Updated alongside the [Lean 1.0 Master Plan](release/lean-1.0-master-plan.md).

**Last reviewed:** 2026-06-15  
**App status:** Release candidate — core locked; device QA + TestFlight pending.  
**Scope lock:** [`release/1.0.0-core-scope.md`](release/1.0.0-core-scope.md)  
**Spec catalog:** [`specs/README.md`](../specs/README.md)  
**Product strategy:** [Competitive strategy](product/competitive-strategy.md) · [Planned competitive features](../specs/planned/CompetitiveFeaturesSpec.md)

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
| Home — daily logging | **Ships 1.0** | `TrackingSemantics`; vice/habit toggles fixed |
| Home — week mini-calendar | **Ships 1.0** | Last 7 days ending today |
| Home — habits/vices sections | **Ships 1.0** | `CompactMetricRow` |
| LoggingSheet | **Ships 1.0** | Inline quantity; vice toggle semantics |
| Goals — boolean | **Ships 1.0** | Weekly/monthly/yearly |
| Goals — quantity | **Partial** | Implemented; manual QA on picker |
| History — calendar | **Ships 1.0** | VoiceOver labels on cells |
| History — entry editing | **Ships 1.0** | |
| History — filters | **Ships 1.0** | Padding polish done |
| Charts — line/bar/heatmap | **Ships 1.0** | Tab re-enabled |
| Charts — quantity | **Partial** | Manual QA with demo data |
| Motivations — basic feed | **Ships 1.0** | |
| Motivations — primary motivation | **Ships 1.0** | |
| Settings — export JSON | **Ships 1.0** | Schema v4 |
| Settings — import JSON | **Ships 1.0** | File picker + confirm |
| Settings — delete all data | **Ships 1.0** | |
| Settings — themes | **Ships 1.0** | 4 curated themes; WCAG tests |
| Settings — share app | **Ships 1.0** | |
| Onboarding | **Ships 1.0** | Emotional flow + habit/vice presets create metrics |
| Home — milestone banners | **Ships 1.0** | 7–365 day thresholds; dismissible |
| Home — prominent streak badge | **Ships 1.0** | Large day count on metric rows |
| Vice — money saved estimate | **Ships 1.0** | Home + History detail; `Metric.costPerUnit` syncs via SwiftData |
| Add Metric — preset chips | **Ships 1.0** | Quick-add suggestions by habit type |
| Vice — slip timer (optional) | **Ships 1.0** | Per-vice toggle in Edit; days/hours on Home |
| Logging — mood chips | **Ships 1.0** | Emoji mood on LoggingSheet; History + export |
| Demo data | **Dev only** | Deterministic screenshot dataset; `-screenshot_demo` launch arg |

---

## Cut / archived (not in lean 1.0 Release)

| Feature | Status | Location / target |
|---------|--------|-------------------|
| Home Screen Widget | **Dev / 1.2–1.3** | 9 widgets + Control Center — `TrackBothWidget` scheme |
| Widget utilities | **Cut 1.0** | Merge into extension at 1.2; `WidgetSyncCoordinator` ready |
| Live Activities | **Cut 1.0** | 1.1+ |
| Control Widget | **Cut 1.0** | 1.1+ |
| Apple Watch UI | **Archived** | `Archive/Watch/` — target 1.2 |
| Motivation game | **Cut 1.0** | |
| Achievements / badges | **Cut 1.0** | 1.3 |
| Smart notifications | **Cut 1.0** | 1.2 |
| Shortcuts / Siri | **Cut 1.0** | 1.2 |

---

## Engineering infrastructure

| Area | Status | Notes |
|------|--------|-------|
| Unit tests | **Ships 1.0** | Domain, export v4, bootstrap recovery, a11y |
| UI smoke tests | **Ships 1.0** | 5 flows |
| CI (GitHub Actions) | **Ships 1.0** | Build + unit tests |
| XcodeGen | **Ships 1.0** | `TrackBoth/project.yml` |
| ProductSurface gating | **Ships 1.0** | Demo, widget, watch flags |
| BootstrapStoreRecovery | **Ships 1.0** | Local-only persistent + in-memory fallback |
| Schema baseline | **Ships 1.0** | `TrackBothSchemaV1` + export v4 — see `docs/release/1.0.0-schema-baseline.md` |
| Domain layer | **Ships 1.0** | Tracking, streaks, goals, export |
| Accessibility IDs | **Ships 1.0** | `Support/Accessibility/` |
| Privacy page | **Ships 1.0** | `docs/privacy.html` |
| Ship checklist | **Ships 1.0** | `docs/release/1.0.0-ship-checklist.md` |
| SwiftLint | **Planned** | Optional for 1.0 |

---

## Tab bar — lean 1.0

| Tab | Ships |
|-----|-------|
| Home | ✅ |
| Goals | ✅ |
| Motivation | ✅ |
| History | ✅ |
| Charts | ✅ |
| Settings | ✅ (sheet from gear icon) |

---

## Maintenance

1. When shipping a feature — update status here and the master plan exit criteria.
2. When cutting scope — move row to "Cut / archived" with post-1.0 target.
3. PRs that change ship status should update this doc in the same PR.
