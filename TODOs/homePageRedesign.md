## homePageRedesign TODO (Spec-Only)

Status: Draft for review

---

NOTES:
When user presses cell, show a new sheet that is a LoggingSheet for that day. This will have all information that is possible to have. At the top will be a simple toggle on if they did it or not. (Habits should default to not done, and vices should default to Avoided with a success state (although this causes issues with back supporting / maybe we could add a setting for if it defaults to Avoided or Not Avoided))

### Landscape Layout
- [ ] Define left panel: Quick Stats centered top, Date Selector
- [ ] Define right panel: Metrics list, FAB
- [ ] Audit missing elements for landscape ("Am I missing anything?")


### Empty State
- [ ] Align Home empty state visuals/behavior with Goals/Motivations patterns

### Date / Week Selector
- [ ] Replace date header with mini week calendar (History-style)
- [ ] Specify interactions: select day, Today jump, scroll behavior, 7-day constraints

### Quick Stats
- [ ] Define visibility rules: hide cards when corresponding value is zero
- [ ] Update layout/spacing for portrait vs landscape given conditional visibility

### Metrics List Structure
- [ ] Split list into two sections: Habits and Vices
- [ ] Design section headers to show per-section stats (e.g., logged today x/total)

### Metric Row Redesign
- [ ] Make row compact and prioritize quick toggle
- [ ] Remove inline text fields (details, motivation, quantity) from row
- [ ] Finalize toggle size/placement and touch target
- [ ] Add Log that shows logging sheet
- [ ] Ensure context menu actions (Log / Edit Habit / Delete) remain discoverable

### LoggingSheet (New)
- [ ] Define LoggingSheet content: top-level toggle, details, motivation, quantity
- [ ] Set defaults: Habits → Not Done; Vices → Avoided (success state)
- [ ] Decide on app setting to control vice default (Avoided vs Not Avoided)

### FAB
- [ ] Confirm FAB placement/behavior across orientations post layout changes

### Visuals & Assets
- [ ] Add/update thumbnail wireframes for portrait and landscape

#### Wireframe: Portrait (thumbnail)

```
┌──────────────────────────── TrackBoth ────────────────────────────┐
│  <  Today (Day, Mon 12)  >                ⚙︎                     │
├──────────────────────────────────────────────────────────────────┤
│  [Habits] [Vices] [Streaks] [Today x/y]                           │
│                                                                  │
├──────────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────────┐  │
│  │  ◼︎ Name                (qty chip)             ⭕ toggle    │  │
│  │  🔥 Streak   🎯 Goal x/y                                    │  │
│  │  Today/Selected Day status                                  │  │
│  └────────────────────────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │  (repeat metric rows)                                      │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                  │
│                                                      ⊕ FAB       │
└──────────────────────────────────────────────────────────────────┘
```

Notes:

```
- Quick toggle is primary; tap row opens edit sheet
- Hide zero-value stat cards
```

#### Wireframe: Landscape (thumbnail)

```
┌────────────────────────────── TrackBoth ──────────────────────────────┐
│                                                                       │
│ ┌──────── Left Panel (min 280 / 40%) ─────────┐ ┌──── Right Content ─────────────┐
│ │ [Quick Stats centered, top-aligned]         │ │      │
│ │                                             │ │                                  │
│ │ [Week Mini-Calendar / Date Selector]        │ │  ┌──────────────────────────┐   │
│ │                                             │ │  │  Metrics List (rows)    │   │
│ │                                             │ │  │  …                      │   │
│ └─────────────────────────────────────────────┘ └──┴──────────────────────────┘   │
│                                                             (⊕ FAB overlays)      │
└───────────────────────────────────────────────────────────────────────────────────┘
```

Notes:

```
- Left: Stats, then Week Mini-Calendar / Date Selector
- Right: Date selector header, then list; FAB overlays right panel
- Confirm any missing elements
```

### Feedback (Spec Only)
- [ ] Define haptics/animations for toggle and deletes (subtle, consistent)


