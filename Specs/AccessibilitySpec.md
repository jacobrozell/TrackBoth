# Accessibility Specification

## 1. Purpose

Define accessibility requirements for TrackBoth lean 1.0.0 — WCAG 2.1 AA on core screens.

---

## 2. Lean 1.0 Scope

### In scope
- VoiceOver labels on all interactive controls (toggles, FAB, tab bar, save buttons)
- Dynamic Type support on Home rows, Goals cards, History cells
- Semantic colors with sufficient contrast (text on background)
- `accessibilityIdentifier` on elements referenced by UI tests
- Reduce Motion respected for non-essential animations

### Out of scope (1.0)
- Full WCAG audit trail per screen (Dart Buddy style)
- Localization (English only for 1.0)

---

## 3. Required Identifiers (UI tests)

| Element | Identifier |
|---------|------------|
| Tab: Home | `tab_home` |
| Tab: Goals | `tab_goals` |
| Tab: Motivation | `tab_motivation` |
| Tab: History | `tab_history` |
| Tab: Charts | `tab_charts` |
| FAB add metric | `fab_add_metric` |
| Settings gear | `button_settings` |
| LoggingSheet save | `logging_save` |
| Delete all data confirm | `settings_delete_confirm` |

---

## 4. VoiceOver Contracts

| Screen | Requirements |
|--------|--------------|
| Home metric row | "{name}, {status}, {streak if any}" |
| Vice row | Must say "Avoided" or "Not Avoided" — not "checked" |
| Goals card | "{name}, {progress} of {target}" |
| History cell | "{date}, {metric}, {status}" |

---

## 5. Dynamic Type

- Use semantic fonts from `Typography.swift` — avoid fixed `.system(size:)` for body text
- Test at AX5 (XXXL) on Home and Goals — no clipped streak labels

---

## 6. Testing

- `WCAGContrastTests` — theme token pairs
- `AccessibilityLabelTests` — key views expose labels
- Manual VoiceOver smoke on Home + Settings

Checklist: `accessibility/1.0-nutrition-label-checklist.md` (create in Phase 7)

---

## 7. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-14 |
| **Commit** | (partial) |
| **Code** | `Utils/UI/Typography.swift`, `Tabs/*.swift` |
