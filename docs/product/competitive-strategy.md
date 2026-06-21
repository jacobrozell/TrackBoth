# TrackBoth — Competitive Strategy

**Created:** 2026-06-15  
**Status:** Active  
**Primary competitor reference:** [Clean Slate - Habit Tracker](https://apps.apple.com/us/app/clean-slate-habit-tracker/id6759494193) (App Store, William Wheeler, 2026)

Related: [Lean 1.0 Master Plan](../release/lean-1.0-master-plan.md) · [Feature Inventory](../feature-inventory.md)

---

## Executive summary

TrackBoth is **not** building a clone of Clean Slate. Clean Slate is a **quit / break-bad-habits** app. TrackBoth is a **dual tracker**: positive habits and vices in one daily log, with different semantics for each.

**Competitive wedge:** Clean Slate helps you quit. TrackBoth helps you become — build good habits *and* break bad ones in one honest daily log.

Win on **breadth + clarity + trust** (correct streak math, charts, goals, motivations), not on being the loudest quit app in a crowded App Store category.

---

## Naming

### Current choice: TrackBoth

| Pros | Cons |
|------|------|
| Accurate — “both” = habits + vices | “Both what?” needs subtitle or screenshots |
| Short, easy to spell | Utilitarian, not emotional |
| Already wired through the project | Generic on the App Store |

**Recommended App Store presentation:**

> **TrackBoth** — Habits & Vices  
> Build streaks. Track clean days. One daily log.

Use **TrackBoth** (one word) consistently in code and bundle ID; use subtitle for positioning.

### Names considered (not selected)

| Name | Notes |
|------|-------|
| Clean Slate | **Taken** on App Store — vice-quit app (see competitor section) |
| HabitHub / HabitMaster | Crowded, generic |
| ViceGuard / ViceBreaker | Vice-only; misses habit-building lane |
| BothWays | Same idea as TrackBoth, slightly more brandable |

**Retired internal names:** `LifeMetrics` (source folder), `QuickLog` (local repo folder) — both replaced by **TrackBoth**.

---

## Competitor profile: Clean Slate

### Links

| Resource | URL |
|----------|-----|
| App Store | https://apps.apple.com/us/app/clean-slate-habit-tracker/id6759494193 |
| Privacy policy | https://cleanslatehabittracker.github.io/CleanSlateHabitTracker.CleanSlateLegalPrivacy/ |
| Terms (Apple standard EULA) | https://www.apple.com/legal/internet-services/itunes/dev/stdfla/ |

### Their positioning (from App Store listing)

- **Tagline:** “Start fresh today.” / “Your clean slate starts now.”
- **Subtitle:** Quit Smoking, Drinking & More
- **Category:** Health & Fitness · iPhone only · Free with IAP
- **Pricing:** Clean Slate Pro — $2.99/mo, $14.99/yr
- **Age rating:** 13+ (alcohol, tobacco, drug references; health/wellness topics)

### Feature set (as marketed)

1. **Live streak timers** — days, hours, minutes, seconds
2. **Achievements** — unlock at key milestones
3. **Journal** — feelings, emotion tags, pattern reflection
4. **Preset vice categories** — smoking, alcohol, marijuana, vaping, caffeine, sugar, social media, gambling, pornography, shopping, gaming
5. **Money saved** — real-time savings as streak builds
6. **Themes** — visual customization
7. **Clean Slate Pro** — advanced tracking, enhanced insights, grounding tools (box breathing, 5-4-3-2-1 technique)

### Are we building the same app?

**No.** Same problem space (behavior change), different product.

| Dimension | Clean Slate | TrackBoth |
|-----------|-------------|-----------|
| Core pitch | Quit smoking, drinking, bad habits | Track habits you *do* and vices you *avoid* |
| Good habits | Not the focus | First-class (exercise, reading, etc.) |
| Tracking style | Live timers to the second | Daily yes/no log + calendar/history |
| Charts | Not emphasized | Line, bar, heatmap (core tab) |
| Goals | Milestones / achievements | Weekly / monthly / yearly goals |
| Motivations | Journaling + emotions | Personal motivation library tied to vices |
| Money saved | Yes | Not in 1.0 (planned 1.1 for quantity vices) |
| Grounding tools | Box breathing, 5-4-3-2-1 (Pro) | Not planned (motivations serve similar role) |
| Preset metrics | Wide vice template list | User-defined (presets planned 1.1) |
| Accessibility | Not declared on App Store | Ship + publish Nutrition Label |

---

## What to steal (high ROI)

### 1. Emotional first-run, not feature tour

Clean Slate sells identity change. Our onboarding should frame outcomes:

1. “What do you want to **build**?” (exercise, reading, …)
2. “What do you want to **break**?” (social media, snacks, …)
3. “One tap a day. We handle the math.”

End onboarding with **1–2 metrics created**, not an empty home screen.

### 2. Vice and habit presets

Reduce blank-page paralysis with templates (user can still add custom metrics):

| Preset | Type | Optional default unit |
|--------|------|------------------------|
| Social media | Vice | — |
| Smoking | Vice | cigarettes/day |
| Alcohol | Vice | drinks |
| Late-night snacks | Vice | — |
| Exercise | Habit | minutes |
| Reading | Habit | pages |
| Meditation | Habit | minutes |
| Drink water | Habit | — |

### 3. Lightweight milestones (not full achievement system)

Fixed thresholds with banner + haptic + copy — no badge cabinet:

- Habits: “7-day streak on Exercise”
- Vices: “14 days clean from Late-night snacks”

Ship ~5–6 milestones in 1.1. Full achievement spec stays in `Specs/planned/AchievementsSpec.md` (cut from 1.0).

### 4. Money saved (quantity vices only)

Leverage existing quantity logging:

- User sets cost per unit (e.g. $8/pack, $15/drink)
- Show estimated savings on vice detail / home row since last slip

One number on the card — not a finance product.

### 5. Prominent streak / clean counters

Big day count on home rows:

- Habits: “12-day streak”
- Vices: “23 days clean”

Day-based primary. Optional “time since last slip” later — not second-by-second default (avoids anxiety).

### 6. Motivations over generic journal

Our motivation library tied to vices is more actionable than a free-form journal:

- Prompt to add a motivation when creating a vice
- Surface motivations in LoggingSheet / vice detail
- Future: notification with a random motivation on high-risk times

### 7. App Store copy that names the category

Mirror their specificity with our wedge:

> **TrackBoth — Habits & Vices**  
> Build streaks. Track clean days. One daily log.

Screenshots must show **both** habits and vices sections on Home — visual proof we are not another quit-only app.

---

## Mistakes to avoid (learned from Clean Slate + category)

| Their weakness | Our counter-move |
|----------------|------------------|
| Vice-only product | Lead every screenshot with habits *and* vices |
| Crowded “quit app” SEO | Target “habit and vice tracker”, “build and break habits” |
| Accessibility not declared | VoiceOver, Dynamic Type, contrast; publish checklist |
| Live second timers as default | Day-based streaks; optional elapsed time later |
| Feature pile (journal + achievements + money + breathing + Pro) | Lean core: log → streak → goal → chart; one layer per release |
| Pro may gate core-feeling features | Free: unlimited metrics, logging, streaks, goals. Pro: sync, export, premium themes, advanced insights |
| Generic “Habit Tracker” name while vice-focused | Subtitle carries the pitch |
| Trust / math opacity | Canonical `TrackingSemantics`, tests, no phantom streaks |

---

## Side-by-side: how we win

| User question | Clean Slate | TrackBoth |
|---------------|-------------|-----------|
| “I quit smoking *and* want to track gym” | Awkward fit | Native |
| “Show me patterns over months” | Weak | Charts tab |
| “Set a monthly goal” | Milestones | Boolean + quantity goals |
| “Why am I doing this?” | Journal | Motivation library |
| “I slipped — edit history?” | Unknown | History + edit |
| “Can I trust the streak?” | Unknown | Tested semantics + `hasBeenLogged` |

---

## Phased roadmap

### 1.0 — Valid competitor (current lean release)

Ship per [Lean 1.0 Master Plan](../release/lean-1.0-master-plan.md):

- Home, Goals, History, Charts, Motivations, Settings
- P0 bug fixes (vice semantics, phantom streaks, migration wired)
- Tests, CI, privacy page, accessibility baseline

**Small Clean Slate steals that fit 1.0 if time allows:**

- Bigger streak/clean display on home rows
- App Store copy + screenshots with dual positioning

### 1.1 — Quit-app parity where it matters

| Feature | Priority | Notes |
|---------|----------|-------|
| Onboarding presets | P0 | Templates + create 1–2 metrics in onboarding |
| Milestone banners | P1 | 5–6 fixed thresholds |
| Money saved (quantity vices) | P1 | Cost per unit on vice |
| Motivation prompt on vice create | P2 | Tie to `AddMetricView` / `AddMotivationView` |

### 1.2 — Pull ahead

| Feature | Priority | Notes |
|---------|----------|-------|
| Home Screen Widget | P1 | Phased widget family — [`Specs/planned/WidgetSpec.md`](../Specs/planned/WidgetSpec.md); `ProductSurface` gates |
| Optional “time since last slip” | P2 | Toggle per vice, off by default |
| One-field mood on log | P3 | Not a full journal — optional note on `LoggingSheet` |

### Explicitly skip (unless strategy pivots vice-first)

- Full achievement / gamification system (see cut list in master plan)
- Box breathing / 5-4-3-2-1 as default UX
- Second-precision live timers as primary streak UI
- Recovery-app packaging that hides habit-building

---

## Monetization contrast

**Clean Slate:** $2.99/mo · $14.99/yr (Pro)

**TrackBoth (locked 2026-06-21):** **Free always** — unlimited habits/vices, daily log, streaks, goals (row progress), motivations, charts, export. No Pro tier planned for 1.0.

---

## Implementation pointers (codebase)

| Strategy item | Existing hook |
|---------------|---------------|
| Presets | `AddMetricView`, `OnboardingView`, `DemoDataGenerator` |
| Quantity + money saved | `Metric`, `LoggingSheet`, quantity goals in `GoalUtils` |
| Streak display | `HomeView`, `CompactMetricRow`, `StreakUtils` |
| Milestones | New lightweight module; avoid `Specs/planned/AchievementsSpec.md` scope |
| Motivations | `MotivationsView`, `AddMotivationView`, vice association on `Metric` |
| Scope gating | `ProductSurface.swift`, `Specs/ProductSurfaceSpec.md` |

---

## Maintenance

1. Re-check Clean Slate App Store listing quarterly for feature/marketing changes.
2. When shipping 1.1 items, update [Feature Inventory](../feature-inventory.md) and this doc.
3. PRs that implement competitive features should reference the phased table above.
