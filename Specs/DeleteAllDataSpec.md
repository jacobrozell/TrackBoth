# Delete All Local Data Specification

## 1. Purpose

Define what **Delete All Data** must wipe and how tests prevent inventory drift.

**Entry point:** [`SettingsSpec.md`](SettingsSpec.md). Schema: [`DataSchemaSpec.md`](DataSchemaSpec.md).

---

## 2. Lean 1.0 Scope

### In scope
- Settings → **Delete All Data** (destructive, confirmed)
- Migration recovery → reset (same end state)
- Clears all SwiftData entities and relevant UserDefaults

### Out of scope
- Selective delete (single metric)
- Automatic pre-delete export prompt

---

## 3. User-Facing Behavior

1. User taps **Delete All Data** in Settings.
2. Confirmation alert with destructive action.
3. On confirm: delete all `Metric`, `MetricEntry`, `Goal`; clear `hasCompletedOnboarding` if full reset desired (product decision: keep or reset onboarding — **default: keep onboarding completed**).
4. Clear demo data flag (`hasDemoData`).
5. On failure: show error; user may retry.

---

## 4. Reset Inventory

| Surface | Action |
|---------|--------|
| SwiftData `Metric` | Delete all |
| SwiftData `MetricEntry` | Delete all |
| SwiftData `Goal` | Delete all |
| UserDefaults `hasDemoData` | Remove |
| UserDefaults `selectedTheme` | Keep (user preference) |
| UserDefaults `weekStartDay` | Keep |
| iCloud | Not affected (backup remains until overwritten) |

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
| **Last verified** | 2026-06-14 |
| **Commit** | (current) |
| **Code** | `SettingsView.swift`, `DemoDataGenerator.swift` |
