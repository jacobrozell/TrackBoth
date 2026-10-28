**Estimated release:** `1.0.0`

# Motivations Specification

## 1. Purpose

Define the basic motivation feed — personal reasons for vice avoidance and habit reflection. **Not** the gamified motivation game.

---

## 2. Lean 1.0 Scope

### In scope
- Social-style card feed of past motivations
- Filter by vice or view all
- Add motivation via FAB (`AddMotivationView`)
- Primary motivation card on vice metrics
- Starred motivations surfaced in feed
- Success/failure indicator per entry (TrackingSemantics)

### Out of scope (see `planned/MotivationGameSpec.md`)
- Scroll distance currency
- Infinite scroll / curated quote database
- Cosmetic shop
- GameCenter

---

## 3. UI Specification

### Feed layout
- Card per motivation: metric name, date, text, status icon
- Pull-to-refresh not required for 1.0
- Empty state with add CTA

### Primary motivation
- Set at metric creation (`AddMetricView`)
- Displayed in `PrimaryMotivationCardView`
- Starred daily motivations also appear after first daily motivation log

### Add flow
- Select vice (or habit if allowing habit motivations)
- Multiline text
- Optional star
- Does not auto-toggle daily status unless combined in LoggingSheet

---

## 4. Data Rules

- Motivations stored on `MetricEntry.motivation` or dedicated entries
- `starred` flag for primary display
- Motivation-only entries must not imply daily completion without explicit status

---

## 5. Testing

### Unit
- `MotivationViewModelTests` — filter, sort

### UI
- Add motivation → appears in feed

---

## 6. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-14 |
| **Commit** | (current) |
| **Code** | `MotivationsView.swift`, `MotivationViewModel.swift`, `Components/Motivations/` |

Legacy: [`Specs/motivation-view-redesign-spec.md`](../Specs/motivation-view-redesign-spec.md)
