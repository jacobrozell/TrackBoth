**Estimated release:** `1.0.0`

# Onboarding Specification

## 1. Purpose

Define first-launch introduction to TrackBoth tabs and core concepts.

---

## 2. Lean 1.0 Scope

### In scope
- Multi-page swipe intro (TabView paging style)
- Pages covering: Home logging, Goals, Motivations, History, Charts
- Skip / Get Started completes onboarding
- `hasCompletedOnboarding` UserDefaults flag

### Out of scope
- Account sign-in
- Permission prompts (notifications — post-1.0)
- Interactive tutorial with real data entry

---

## 3. UI Specification

- Gradient background using theme colors
- Page indicator dots
- Previous / Next / Get Started buttons
- Completing onboarding posts `"OnboardingCompleted"` notification

---

## 4. Behavior

| State | Result |
|-------|--------|
| First launch | Show onboarding |
| `hasCompletedOnboarding == true` | Skip to TabView |
| Reset (optional dev tool) | Clear flag → onboarding shows again |

Delete all data: **does not** reset onboarding by default (see DeleteAllDataSpec).

---

## 5. Testing

### UI
- `OnboardingUITests` — complete flow → Home visible
- Launch arg `-skip_onboarding` for other UI tests

---

## 6. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-14 |
| **Commit** | (current) |
| **Code** | `OnboardingView.swift`, `ContentView.swift` |
