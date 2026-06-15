**Estimated release:** `1.1`

# Home Screen Widget Specification

## 1. Purpose

Define home screen widgets for quick daily habit check-ins.

**Status:** Planned — **cut from lean 1.0.0**. See [`ProductSurfaceSpec.md`](../ProductSurfaceSpec.md).

---

## 2. Scope (when implemented)

- Small widget: today's completion summary
- Medium widget: top habits with quick-log
- App Groups data sharing
- App Intents for log-without-opening-app

---

## 3. Current codebase

| Location | State |
|----------|-------|
| `TrackBoth-Widget/` | Xcode template (placeholder emoji UI) |
| `Widgets/` | Alternate implementation with data models |
| `WidgetDataManager.swift` | App Groups ID configured but entitlements missing |

---

## 4. Prerequisites before implementation

1. App Groups entitlement on main + widget targets
2. Consolidate duplicate widget folders
3. TrackingSemantics stable and tested
4. Widget excluded from 1.0 Release scheme until ready

Legacy checklist: [`TODOs/todo_widget.md`](../../TODOs/todo_widget.md)

---

## 5. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.1` |
| **Last verified** | 2026-06-14 |
| **Commit** | (not started) |
| **Code** | `TrackBoth-Widget/`, `Widgets/` |
