# Motivation View Redesign Specification

## Overview
Redesign the MotivationView to have a clearer structure with Primary Motivations at the top in their own section, followed by Daily Motivations below. Add a floating action button for creating custom motivations with a sheet interface.

## Current State Analysis

### Existing Structure
- **Primary Motivations**: Displayed from `Metric.primaryMotivation` field
- **Daily Motivations**: Displayed from `MetricEntry.motivation` field
- **Add Functionality**: Currently uses `AddMotivationView` sheet
- **Layout**: Responsive design with landscape/portrait layouts
- **Filtering**: Vice metric filtering available

### Current Components
- `PrimaryMotivationCardView`: Displays primary motivations with star styling
- `MotivationCardView`: Displays daily motivations with success indicators
- `AddMotivationView`: Sheet for adding motivations to specific vices

## Redesign Requirements

### 1. Layout Structure (HomeView Style)
```
┌─────────────────────────────────────┐
│ Navigation Title: "Motivation"      │
├─────────────────────────────────────┤
│ [Filter Chips - if multiple vices]  │
│ Background: currentSecondaryBackground │
├─────────────────────────────────────┤
│ ⭐ Primary Motivations              │
│ ┌─────────────────────────────────┐ │
│ │ [Primary Motivation Cards]       │ │
│ │ Background: currentSecondaryBackground │
│ │ Corner Radius: 12pt             │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ 🕐 Daily Motivations               │
│ ┌─────────────────────────────────┐ │
│ │ [Daily Motivation Cards]         │ │
│ │ Background: currentSecondaryBackground │
│ │ Corner Radius: 12pt             │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│                    [+ Add Button]   │
│ (FloatingActionButton style)        │
└─────────────────────────────────────┘
```

### 2. Section Headers (HomeView Style)
- **Primary Motivations Section**:
  - Icon: `star.fill` with `Color.currentWarning`
  - Title: "Primary Motivations" (`.headline` font, `Color.currentText`)
  - Subtitle: "Your core reasons for avoiding vices" (`.caption`, `Color.currentSecondaryText`)
  - Background: `Color.currentSecondaryBackground` (matches HomeView section headers)
  - Padding: Horizontal 4pt, Vertical 8pt (matches HomeView)
  - Always visible when primary motivations exist

- **Daily Motivations Section**:
  - Icon: `clock` with `Color.currentSecondaryText`
  - Title: "Daily Motivations" (`.headline` font, `Color.currentText`)
  - Subtitle: "Recent motivation entries" (`.caption`, `Color.currentSecondaryText`)
  - Background: `Color.currentSecondaryBackground` (matches HomeView section headers)
  - Padding: Horizontal 4pt, Vertical 8pt (matches HomeView)
  - Only visible when daily motivations exist

### 3. Floating Action Button (HomeView Style)
- **Position**: Bottom-right corner (matches HomeView FAB placement)
- **Icon**: `plus.circle.fill`
- **Action**: Opens motivation creation sheet
- **Styling**: Use existing `FloatingActionButton` component from HomeView
- **Background**: Consistent with HomeView FAB styling
- **Accessibility**: "Add Motivation" label

### 4. New Motivation Form (HomeView Style)

#### Form Structure
```
┌─────────────────────────────────────┐
│ Add Motivation              [×]    │
├─────────────────────────────────────┤
│ Write your own motivation to help   │
│ you stay strong when struggling.    │
│ Font: .body, Color: currentSecondaryText │
├─────────────────────────────────────┤
│ Select Vice                         │
│ Font: .headline, Color: currentText │
│ ┌─────────────────────────────────┐ │
│ │ [Picker with currentSecondaryBackground] │ │
│ │ Corner Radius: 12pt             │ │
│ │ Padding: 16pt horizontal, 12pt vertical │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ Your Motivation                     │
│ Font: .headline, Color: currentText │
│ ┌─────────────────────────────────┐ │
│ │ [Text Editor - multiline]       │ │
│ │ Background: currentSecondaryBackground │ │
│ │ Corner Radius: 12pt             │ │
│ │ Padding: 16pt                   │ │
│ │ Min Height: 200pt               │ │
│ │ Placeholder: "Why do you want to avoid this vice?" │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ [Cancel]              [Save]        │
│ Font: .caption, Color: currentPrimary │
│ Save disabled until both fields filled │
└─────────────────────────────────────┘
```

#### Form Features (HomeView Style)
- **Vice Selection**: 
  - Picker with `currentSecondaryBackground` and 12pt corner radius
  - Padding: 16pt horizontal, 12pt vertical
  - Shows all vice metrics with icons
- **Text Editor**: 
  - Multi-line text input with `currentSecondaryBackground` background
  - 12pt corner radius, 16pt padding
  - Minimum height: 200pt
  - Placeholder text: "Why do you want to avoid this vice?"
- **Typography**: 
  - Use HomeView font styles (`.headline`, `.caption`, `.body`)
  - Consistent with HomeView form elements
- **Colors**: 
  - Use HomeView color scheme (`currentText`, `currentSecondaryText`, `currentPrimary`)
  - Consistent with HomeView form styling
- **Validation**: 
  - Require both vice selection and motivation text
  - Save button disabled until both fields filled
- **Save Action**: 
  - Create new MetricEntry with motivation for selected vice
  - Set `value: false` (avoided), `hasBeenLogged: true`
  - Date: Always save to current date

### 5. Empty State (HomeView Style)

#### No Motivations At All
```
┌─────────────────────────────────────┐
│ Background: currentBackground        │
│           📖                        │
│        No Motivations Yet           │
│ Font: .headline, Color: currentText │
│                                     │
│ Start building your motivation      │
│ library to stay accountable and     │
│ inspired.                           │
│ Font: .body, Color: currentSecondaryText │
│                                     │
│           [+ Add Motivation]        │
│ FloatingActionButton (bottom-right) │
└─────────────────────────────────────┘
```

**Empty State Logic:**
- Show when: No metrics have `primaryMotivation` AND no entries have `motivation` text
- Use existing `EmptyStateView` component
- Include `FloatingActionButton` for adding motivations
- Single unified empty state for all motivation scenarios

### 6. Card Design Updates (HomeView Style)

#### Primary Motivation Cards
- **Background**: `Color.currentSecondaryBackground` (matches HomeView metric rows)
- **Corner Radius**: 12pt (consistent with HomeView)
- **Padding**: 12pt (matches HomeView CompactMetricRow)
- **Icon**: Star fill in header with `Color.currentWarning`
- **Layout**: Metric name + "Primary Motivation" subtitle
- **Content**: Primary motivation text with proper typography
- **Accent**: Subtle warning color accent (no heavy borders)
- **Shadow**: Minimal shadow like HomeView cards

#### Daily Motivation Cards
- **Background**: `Color.currentSecondaryBackground` (matches HomeView metric rows)
- **Corner Radius**: 12pt (consistent with HomeView)
- **Padding**: 12pt (matches HomeView CompactMetricRow)
- **Icon**: Success/error indicator based on avoidance
- **Layout**: Metric name + date/time info
- **Content**: Daily motivation text with proper typography
- **Accent**: Subtle success/error color accent
- **Shadow**: Minimal shadow like HomeView cards

### 7. Responsive Design (HomeView Style)

#### Portrait Layout
- Single column layout (matches HomeView portrait)
- Filter chips in horizontal scroll with `currentSecondaryBackground`
- Sections stacked vertically with proper spacing (16pt between sections)
- FAB in bottom-right using `FloatingActionButton` component
- ScrollView with LazyVStack for performance

#### Landscape Layout
- Two-column layout (matches HomeView landscape)
- Filter sidebar on left with `currentSecondaryBackground`
- Content area on right with proper padding (16pt horizontal, 8pt vertical)
- Maintains section structure with pinned headers
- Divider between panels (matches HomeView)

### 8. Data Flow

#### Primary Motivations
- Source: `Metric.primaryMotivation` field
- Filter: Only vice metrics with primary motivation text
- Display: Always show when available

#### Daily Motivations
- Source: `MetricEntry.motivation` field
- Filter: Only entries with motivation text
- Sort: By date (newest first)
- Display: Show when available

#### Empty State Logic
- Show empty state when: No metrics have `primaryMotivation` AND no entries have `motivation` text
- Use existing `EmptyStateView` component
- Include `FloatingActionButton` for adding motivations

#### Add Motivation Flow
1. User taps FAB (from main view or empty state)
2. New motivation form opens with vice picker and text editor
3. User selects vice and writes motivation
4. Save creates MetricEntry with:
   - `metricID`: Selected vice ID
   - `date`: Current date
   - `value`: false (avoided)
   - `motivation`: User's text
   - `hasBeenLogged`: true

### 9. ViewModel Updates

#### New Methods Needed
```swift
// Enhanced filtering
func primaryMotivations(_ metrics: [Metric]) -> [Metric]
func dailyMotivations(_ entries: [MetricEntry]) -> [MetricEntry]

// Add motivation
func addCustomMotivation(
    text: String,
    for metric: Metric,
    in context: ModelContext,
    entries: [MetricEntry]
) -> MetricEntry

// Empty state check (simplified)
func hasAnyMotivations(_ metrics: [Metric], entries: [MetricEntry]) -> Bool {
    let hasPrimary = metrics.contains { $0.primaryMotivation != nil && !$0.primaryMotivation!.isEmpty }
    let hasDaily = entries.contains { $0.motivation != nil && !$0.motivation!.isEmpty }
    return hasPrimary || hasDaily
}
```

### 10. Accessibility

#### VoiceOver Support
- Section headers as headings
- Card content as accessible elements
- FAB with proper label
- Sheet form elements properly labeled

#### Dynamic Type
- Support for larger text sizes
- Maintain readability at all sizes

### 11. Performance Considerations

#### Lazy Loading
- Use `LazyVStack` for motivation cards
- Load sections independently
- Efficient filtering with performance logging

#### Memory Management
- Proper state management
- Efficient data queries
- Background processing for heavy operations

## Implementation Priority

### Phase 1: Core Structure
1. Update MotivationView layout
2. Implement section headers
3. Add FAB component
4. Update empty states

### Phase 2: Enhanced Functionality
1. Improve AddMotivationView
2. Update card designs
3. Add responsive behavior
4. Implement accessibility

### Phase 3: Polish
1. Performance optimization
2. Animation improvements
3. Final testing
4. Documentation updates

## Success Metrics

### User Experience
- Clear visual hierarchy between primary and daily motivations
- Easy access to add new motivations via FAB
- Intuitive navigation and interaction
- Consistent with HomeView interaction patterns

### Technical
- Maintains existing data structure
- Backward compatible with current data
- Performance remains optimal with LazyVStack
- Accessibility standards met
- Reuses existing components (FloatingActionButton, EmptyStateView)

### Design
- **Consistent with HomeView design language**:
  - Same color scheme (`currentBackground`, `currentSecondaryBackground`, `currentText`, etc.)
  - Same corner radius (12pt)
  - Same padding patterns (12pt for cards, 16pt horizontal, 8pt vertical)
  - Same typography (`.headline`, `.caption`, `.body`)
  - Same component styling (bordered buttons, secondary backgrounds)
- Responsive across device sizes
- Clear visual distinction between sections
- Intuitive empty states
