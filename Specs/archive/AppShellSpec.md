# App Shell Specification

## 1. Purpose

Define app entry, SwiftData bootstrap, onboarding gate, and root navigation container.

---

## 2. Launch Flow

```
TrackBothApp
  ├─ Create ModelContainer
  ├─ MigrationUtils.runMigrationIfNeeded (required)
  ├─ Apply theme (AppStorage selectedTheme)
  └─ ContentView
       ├─ hasCompletedOnboarding == false → OnboardingView
       └─ else → TabView (5 tabs)
```

---

## 3. Onboarding Gate

- Key: `UserDefaults.hasCompletedOnboarding`
- Onboarding completion posts `NotificationCenter` `"OnboardingCompleted"`
- ContentView re-checks on notification

See [`OnboardingSpec.md`](OnboardingSpec.md).

---

## 4. Theme Application

- `AppStorage("selectedTheme")` → `Theme` enum → `preferredColorScheme`
- `ThemeManager.shared` drives semantic colors in views

---

## 5. Error Paths

| Failure | Current | Target |
|---------|---------|--------|
| Container creation | In-memory fallback → fatalError | `MigrationRecoveryView` |

---

## 6. Testing

- Fresh install shows onboarding
- Completed onboarding skips on relaunch
- Migration runs without crash on existing data

---

## 7. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-14 |
| **Commit** | (current) |
| **Code** | `TrackBothApp.swift`, `ContentView.swift` |
