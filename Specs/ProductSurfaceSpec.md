# Product Surface Specification

## 1. Purpose

Define lean 1.0.0 release gating — what users see in App Store builds vs full development builds.

Mirrors Dart Buddy `ProductSurface.lean1_0` pattern.

---

## 2. Surfaces

| Surface | Build | Audience |
|---------|-------|----------|
| `lean1_0` | Release / TestFlight | App Store users |
| `development` | Debug | Local dev, dogfood |

---

## 3. Lean 1.0 Feature Matrix

| Feature | lean1_0 | development |
|---------|---------|-------------|
| Home daily logging | ✅ | ✅ |
| Goals (boolean + quantity) | ✅ | ✅ |
| History + edit | ✅ | ✅ |
| Charts tab | ✅ | ✅ |
| Motivations (basic feed) | ✅ | ✅ |
| Settings + export + iCloud | ✅ | ✅ |
| Onboarding | ✅ | ✅ |
| Themes (curated subset) | ✅ | ✅ |
| Demo data | ❌ | ✅ |
| Widget extension | ❌ | ❌ (removed from scheme) |
| Watch views / promos | ❌ | ❌ |
| Motivation game | ❌ | ❌ |
| Achievements | ❌ | ❌ |
| Notifications | ❌ | ❌ |
| Shortcuts | ❌ | ❌ |

---

## 4. Implementation

Target: `Support/Release/ProductSurface.swift`

```swift
enum ProductSurface {
    case lean1_0
    case development

    static var current: ProductSurface {
        #if DEBUG
        return .development
        #else
        return .lean1_0
        #endif
    }
}
```

Gate demo buttons, debug menus, and any resurrected widget/watch entry points through `ProductSurface.current`.

**Release scheme:** Exclude `TrackBoth-WidgetExtension` target.

---

## 5. Launch Arguments (UI tests)

| Argument | Effect |
|----------|--------|
| `-ui_test_reset` | Fresh UserDefaults + empty store |
| `-skip_onboarding` | Bypass onboarding for smoke tests |

---

## 6. Testing

- `ProductSurfaceTests` — flag matrix
- `Lean1_0SmokeUITests` — Release config has no demo/widget UI

---

## 7. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-14 |
| **Commit** | (not implemented) |
| **Code** | Target: `Support/Release/ProductSurface.swift` |
