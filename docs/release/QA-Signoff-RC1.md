# QA Sign-off — TrackBoth 1.0.0 RC1

Use this document to record TestFlight RC1 validation before App Store submission.

**Ship surface:** Track · History · Motivation · Charts · Settings (Goals tab = dev only)

**Build:** _______________  
**Tester:** _______________  
**Device(s):** _______________  
**Date:** _______________

---

## Smoke flows

| # | Flow | Pass | Notes |
|---|------|------|-------|
| 1 | Fresh install → complete onboarding (with presets) | ☐ | |
| 2 | Fresh install → skip onboarding → placeholder rows (`My habit` / `My vice`) | ☐ | |
| 3 | Add positive habit → toggle done on Track | ☐ | |
| 4 | Add vice → toggle avoided; verify shield icon | ☐ | |
| 5 | Vice slip → LoggingSheet shows “Remember why” (if motivation set) | ☐ | |
| 6 | Track row shows goal progress + streak metadata | ☐ | |
| 7 | Milestone banner appears and dismisses | ☐ | |
| 8 | History calendar + filters + edit entry | ☐ | |
| 9 | Charts tab — line / bar / heatmap (no Quantity in Release) | ☐ | |
| 10 | Motivation — add/view primary + daily motivations | ☐ | |
| 11 | Settings → Export JSON | ☐ | |
| 12 | Settings → Import JSON (test file round-trip) | ☐ | |
| 13 | Settings → Delete all data | ☐ | |
| 14 | Support + Privacy links open in Safari | ☐ | |

---

## Regression (P0 fixed in 1.0)

| Bug | Pass | Notes |
|-----|------|-------|
| No phantom vice streak on create | ☐ | |
| Vice/habit boolean semantics consistent | ☐ | |
| Migration on launch | ☐ | |
| Week calendar completion dots accurate | ☐ | |

---

## Accessibility spot-check

| Check | Pass | Notes |
|-------|------|-------|
| VoiceOver — Track row (single streak label, no duplicate) | ☐ | |
| VoiceOver — Save in LoggingSheet | ☐ | |
| Largest Dynamic Type — Track | ☐ | |
| Midnight theme readable | ☐ | |

---

## Blockers

_List any P0/P1 issues blocking release:_

1. 
2. 

---

## Decision

- [ ] **Approved** for App Store submission
- [ ] **Rejected** — return to engineering

**Signature:** _________________________ **Date:** __________
