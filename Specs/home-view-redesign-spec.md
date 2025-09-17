## Home View UI Redesign Spec

Author: You
Date: 
Status: Draft

---

### Goals
- Clarify the information hierarchy and daily flow
- Reduce friction for logging/toggling
- Make streaks and progress more motivating
- Keep parity across portrait and landscape

---

## Page Structure

### Overall Navigation
- **Container**: `NavigationStack`
- **Title**: "TrackBoth"
- **Toolbar**:
  - Leading: Demo Data controls (contextual)
  - Trailing: Settings gear

Your notes:

```

```

### Layout Modes
- **Portrait**: Stats header, then scrollable metrics list, FAB overlay
- **Landscape**: Left stats/date panel, right scrollable metrics list, FAB overlay

Orientation-specific notes:

```

```

---

## Empty State
- Component: `EmptyStateView`
- Trigger: No metrics
- CTA: "Add Your First Habit"

Design notes:

```

```

---

## Date Navigation Header
- Elements:
  - Prev day button (chevron.left, disabled by 30-day limit)
  - Center date button (Day name + full date, opens date picker)
  - Next day button (chevron.right, disabled on today)
- Conditional: "Today" shortcut button when not on today

Design and behavior:

```

```

---

## Quick Stats Section
- Component: `StatCard`
- Cards:
  - Habits (count of positive)
  - Vices (count of vice)
  - Streaks (number active)
  - Today (completed/total)
- Placement:
  - Portrait: row of 4
  - Landscape: two rows of 2 in side panel

Visual + layout specs:

```

```

---

## Metrics List
- Container: `ScrollView` → `LazyVStack`
- Item: `UnifiedMetricRowView.enhanced(metric:selectedDate:)`
- Context Menu per item: Edit, Delete

List presentation and spacing:

```

```

---

## Metric Row (UnifiedMetricRowView)
- Header:
  - Icon based on habit type
  - Name
  - Optional quantity chip (if quantity exists today)
  - Toggle completion button (checkmark/circle)
- Subheader (enhanced mode):
  - Streak indicator
  - Goal progress (current/target)
- Sections:
  - Today/Selected Day status
  - Details (editable for positive habits)
  - Quantity (optional editing flow)
  - Motivation (editable; defaults to primary motivation)

Visual hierarchy, paddings, and interactions:

```

```

---

## Floating Action Button (FAB)
- Purpose: Add metric
- Placement: Bottom trailing overlay
- Interaction: Opens Add Metric sheet

Look and feel:

```

```

---

## Sheets & Modals
- **AddMetricView**: Create new habit/vice
- **EditMetricView(metric:)**: Edit selected metric
- **SettingsView**: App settings
- **DatePickerSheet(selectedDate:)**: Pick arbitrary date
- **QuantityInputSheet(metric:selectedDate:)**: Edit quantity for a day

Presentation + content guidelines:

```

```

---

## Alerts
- Delete confirmation for metric

Copy, buttons, and tone:

```

```

---

## Landscape Left Panel
- Contains: Date Navigation Header, Today button (if shown), Quick Stats
- Width: min(280, 40% of screen)
- Background: secondary background color

Design specifics:

```

```

---

## Theming
- Colors: `Color.current*` palette (Primary, SecondaryText, Success, Error, Warning, Accent, Backgrounds)
- Shadows, corner radii, dividers: consistent with existing design language

Theme rules and examples:

```

```

---

## Accessibility
- Minimum touch targets for toggles and buttons
- Dynamic Type support for labels and chips
- VoiceOver labels for state (e.g., "Done", "Avoided")

Notes:

```

```

---

## Animations & Feedback
- Subtle animations on toggle and card appearance
- Haptics on completion toggle and deletes

Ideas and specifics:

```

```

---

## Open Questions
- Do we surface primary motivations on the Home view (e.g., featured card)?
- Should quantity be inline or always via sheet?
- Any additional quick filters for the list?

Your answers/decisions:

```

```

---

## Sketch Space
Freeform area for wireframes or layout notes.

```

```


