# Product Surface Specification

## 1. Purpose

Define lean 1.0.0 release gating — what users see in App Store builds vs full development builds.

Mirrors Dart Buddy `ProductSurface.lean1_0` pattern.

**Decisions locked:** 2026-06-21 — see [`FutureIdeas/ProductUXHandoff.md`](../FutureIdeas/ProductUXHandoff.md).

---

## 2. Surfaces

| Surface | Build | Audience |
|---------|-------|----------|
| `lean1_0` | Release / TestFlight | App Store users |
| `development` | Debug (no `-lean_ui`) | Local dev, dogfood |
| `lean1_0` simulated | Debug + `-lean_ui` | UI tests, screenshots |

---

## 3. Lean 1.0 Feature Matrix (2026-06-21)

| Feature | lean1_0 | development |
|---------|---------|-------------|
| Track daily logging | ✅ | ✅ |
| Extended row metadata (goals progress, savings, slip timer) | ✅ | ✅ |
| Milestone banners | ✅ | ✅ |
| History + edit | ✅ | ✅ |
| Charts tab (line, bar, heatmap) | ✅ | ✅ |
| Charts — quantity type | ❌ | ✅ |
| Motivation tab | ✅ | ✅ |
| Goals tab | ❌ | ✅ |
| Settings + export JSON | ✅ | ✅ |
| Onboarding + placeholder rows on skip | ✅ | ✅ |
| Themes (2 ship themes) | ✅ | ✅ |
| Themes (4 extended) | ❌ | ✅ |
| Extended logging upfront | ❌ | ✅ |
| Advanced metric setup | ❌ | ✅ |
| Demo data | ❌ | ✅ |
| Widget extension | ❌ | ✅ (dev scheme) |
| Watch / motivation game | ❌ | ❌ |
| Monetization | **Free** | **Free** |

---

## 4. Release tab bar

| Tab | Ships 1.0 |
|-----|-------------|
| Track | ✅ |
| History | ✅ |
| Settings | ✅ |
| Motivation | ✅ |
| Charts | ✅ |
| Goals | Dev only |

---

## 5. Implementation

Target: `Support/Release/ProductSurface.swift`

Use `isFullDevelopment` for dev-only flags. Ship features return `true` in both Release and `-lean_ui` DEBUG.

---

## 6. Launch Arguments (UI tests)

| Argument | Effect |
|----------|--------|
| `-lean_ui` | Simulate Release ship surface in DEBUG |
| `-ui_test_reset` | Fresh UserDefaults + empty store |
| `-skip_onboarding` | Bypass onboarding for smoke tests |

---

## 7. Testing

- `ProductSurfaceTests` — flag matrix + chart type availability
- `TrackBothUITests` — lean tabs: Track, History, Settings, Motivation, Charts

---

## 8. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-21 |
| **Code** | `Support/Release/ProductSurface.swift` |
