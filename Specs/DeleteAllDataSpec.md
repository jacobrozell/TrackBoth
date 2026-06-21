# Delete All Local Data Specification

## 1. Purpose

Define what **Reset All Local Data** must wipe and how tests prevent inventory drift.

**Entry point:** [`SettingsSpec.md`](SettingsSpec.md). Schema: [`DataSchemaSpec.md`](DataSchemaSpec.md).

---

## 2. Lean 1.0 Scope

### In scope
- Settings → **Reset All Local Data** (destructive, confirmed)
- Migration recovery → reset (same end state)
- Clears all SwiftData entities and relevant UserDefaults on **this device only**

### Out of scope
- Selective delete (single metric)
- Automatic pre-delete export prompt
- Cloud sync / iCloud purge (local-only for 1.0)

---

## 3. User-Facing Behavior

1. User taps **Reset All Local Data** in Settings.
2. Confirmation alert: *"This deletes all habits and entries on this device. This cannot be undone."*
3. On confirm: delete all `Metric`, `MetricEntry`, `Goal`; clear side stores.
4. Clear demo data flag (`hasDemoData`).
5. On failure: show error; user may retry.

---

## 4. Reset Inventory

| Surface | Action |
|---------|--------|
| SwiftData `Metric` | Delete all (local) |
| SwiftData `MetricEntry` | Delete all (local) |
| SwiftData `Goal` | Delete all (local) |
| UserDefaults `hasDemoData` | Remove |
| UserDefaults `metricCostPerUnit` (legacy) | Clear |
| UserDefaults `selectedTheme` | Keep (user preference) |
| UserDefaults `weekStartDay` | Keep |

---

## 5. Testing

- Post-reset: zero metrics, zero entries
- Demo data flag cleared
- UI shows Home empty state
- Regression test fails if new `@Model` added without inventory update

---

## 6. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-15 |
| **Commit** | (current) |
| **Code** | `SettingsView.swift`, `DemoDataGenerator.swift` |
