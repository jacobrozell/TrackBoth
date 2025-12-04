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
Query: Landscape needs a lot of work. 


Left side (top to bottom):
    Quick Stats centered and top aligned
    Spacer
    Add new habit button

Right Side (top to bottom):
    Date selector
    List

Am i missing anything?

```

---

## Empty State
- Component: `EmptyStateView`
- Trigger: No metrics
- CTA: "Add Your First Habit"

Design notes:

```

Query: Empty State should be the same as the other empty state's found in Goals/Motivations

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
Query:  Since we are only targeting a week now, I'm thinking this should be a small calendar that shows each day (kind of like History)

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
Query:  This section is really cool. However, when the values are zero, the card isnt needed. So when they dont have any streaks / habits / vice maybe we don't draw the card at all. 

```

---

## Metrics List
- Container: `ScrollView` → `LazyVStack`
- Item: `UnifiedMetricRowView.enhanced(metric:selectedDate:)`
- Context Menu per item: Edit, Delete

List presentation and spacing:

```
Query:  I want to seperate the vices / habits into different sections. Each section header can display some stats. Like "Here is my vice section; I have 2 vices; The section header could have information like 0/2 logged today.

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
Query: 

IMPORTANT: This is the main part that I want to redesign. 
I dont like how bulky the cards are, espcailly if the user isnt going to use Motivations / Quanitiies. But I want to show the user that its there. I think we should remove the Textfelds on the cell and when the user presses the cell show a basic edit form that allows them to enter that information. I want the main functionality to be toggling if they did that habit/vice or not.

```

---

## Floating Action Button (FAB)
- Purpose: Add metric
- Placement: Bottom trailing overlay
- Interaction: Opens Add Metric sheet

Look and feel:

```
Query: No notes looks great.

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
