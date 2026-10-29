# TrackBoth — Feature inventory

Living register for the recovery overhaul. Every new feature starts as **Planned** until the phase that builds it lands.

**Last reviewed:** 2026-10-28
**Stage:** Overhaul in progress

## Status legend

| Status | Meaning |
|--------|---------|
| **Planned** | In the approved plan, not built yet |
| **Ships 1.0** | Implemented for this overhaul |
| **Cut** | Removed on purpose. Do not bring it back in 1.0 |
| **Later** | After 1.0 |

## Core loop

| Feature | Status | Notes |
|---------|--------|-------|
| Today — check-in banner, vice cards, habit rows | **Ships 1.0** | Phase 5. Urge, slip, and detail from Today are stubs until Phases 6 and 7 |
| Daily check-in sheet | **Ships 1.0** | Phase 5. "I slipped" opens a stub until Phase 6 |
| Urge flow (ride it out) | **Ships 1.0** | Phase 6 |
| Slip flow | **Ships 1.0** | Phase 6. Amber, no guilt copy |
| Milestone celebration, re-earnable after a slip | **Ships 1.0** | Phase 6. Ledger records when Keep going is tapped |
| Progress + metric detail + day editor | **Planned** | Phase 7. Progress already shows the urges-beaten count |
| Add / edit metric | **Planned** | Phase 7 |
| Onboarding (quit date, reason, reminders, lock, disclaimer) | **Planned** | Phase 8 |
| Daily reminder + milestone notifications | **Planned** | Phase 9. At most one check-in a day |
| App lock and app-switcher privacy cover | **Planned** | Phase 9. Off by default |
| Settings, backup/restore, delete all, crisis resources | **Planned** | Phase 10 |
| Home-screen quick action and `trackboth://urge` | **Ships 1.0** | Phase 6 |

## Cut from the pre-overhaul app

| Feature | Status | Why |
|---------|--------|-----|
| Goals tab and quantity goals | **Cut** | A monthly vice target fights quitting |
| Quantity, units, mood chips, starred entries | **Cut** | Friction. Trigger tags replace mood on slips and urges |
| Charts tab and chart export | **Cut** | Replaced by a calendar and three recovery stats |
| Color themes and font picker | **Cut** | One palette, follows the system |
| Per-device layout files | **Cut** | iPhone portrait only. Adaptive rules stay |
| Widget, Watch, Live Activities, Shortcuts | **Later** | A single days-free widget is optional after launch |
| Launch splash animation | **Cut** | The system launch screen is enough |
| Placeholder "My habit / My vice" rows | **Cut** | Onboarding requires a real choice |
| Demo data in Release | **Cut** | Debug and screenshots only |

## Later

| Feature | Status | Notes |
|---------|--------|-------|
| One "days free" widget | **Later** | Optional post-launch |
| iPad and landscape | **Later** | Separate release. Screens stay adaptive-ready |
