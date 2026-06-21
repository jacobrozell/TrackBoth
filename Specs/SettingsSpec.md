**Estimated release:** `1.0.0`

# Settings Specification

## 1. Purpose

Define app preferences, data management, and configuration for lean 1.0.

Related: [`DeleteAllDataSpec.md`](DeleteAllDataSpec.md), [`ExportImportSpec.md`](ExportImportSpec.md).

---

## 2. Lean 1.0 Scope

### In scope
- Export Data (JSON share sheet)
- Import Data (JSON file)
- Reset All Local Data (confirmed destructive)
- Theme selection (curated themes for lean 1.0)
- Light / Dark / System appearance
- Week start day preference
- Share app (native share text)
- App version and stats (habit count, entry count)
- Clear demo data (development only)

### Out of scope
- Custom app icons
- Donate button
- Notification preferences
- Widget configuration

---

## 3. UI Specification

Grouped list sections:

| Section | Contents |
|---------|----------|
| Data Management | Export, Import, Clear Demo (dev) |
| Appearance | Theme picker, light/dark/system |
| Preferences | Week start day |
| About | Version, date joined, share app |

Presented as sheet from gear icon — not a tab.

---

## 4. Data and Persistence

| Setting | Storage |
|---------|---------|
| Theme | `AppStorage("selectedTheme")` + `ThemeManager` |
| Week start | `AppStorage("weekStartDay")` |
| Onboarding | `UserDefaults.hasCompletedOnboarding` |

SwiftData entities managed via export/delete/restore flows — not individual Settings toggles.

---

## 5. Destructive Actions

All require confirmation alert with clear consequence copy. See DeleteAllDataSpec.

---

## 6. Testing

### Unit
- Export generates valid JSON
- Delete clears inventory per spec

### UI
- `SettingsUITests` — export sheet, delete confirmation

---

## 7. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-14 |
| **Commit** | (current) |
| **Code** | `SettingsView.swift`, `SettingsViewModel.swift` |
