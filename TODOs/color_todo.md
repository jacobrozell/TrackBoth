# Color Theme Migration Todo List

## 🎯 Current Status
**🎉 MIGRATION COMPLETE! (47/47 files)**
- **Phase 1**: Foundation & Core Navigation ✅
- **Phase 2**: Primary Feature Views ✅  
- **Phase 3**: Data Entry Views ✅
- **Phase 4**: Charts & Data Visualization Components ✅
- **Phase 5**: Calendar Components ✅
- **Phase 6**: Goal Management Components ✅
- **Phase 7**: Motivation System Components ✅
- **Phase 8**: Data Entry Components ✅
- **Phase 9**: UI Components ✅
- **Phase 10**: Final Components ✅
- **🎉 ALL PHASES COMPLETE!**

## Overview
This document tracks the migration of all views and components to use the new `AppTheme` system instead of hardcoded colors or asset-based colors.

## Migration Strategy
- Replace hardcoded `Color.blue`, `Color.red`, etc. with `Color.currentPrimary`, `Color.currentSuccess`, etc.
- Replace `Color("ThemePrimary")` with `Color.currentPrimary`
- Replace `Color("BackgroundPrimary")` with `Color.currentBackground`
- Add `.themedBackground()`, `.themedPrimaryText()` modifiers where appropriate
- Ensure all views respond to theme changes dynamically

---

## 🏠 Main Views (Priority: High)

### Core Navigation & Layout
- [x] **ContentView.swift** - Main app container, navigation setup ✅
  - Navigation bar background → `Color.currentBackground`
  - Navigation title → `Color.currentText`
  - Tab bar → `Color.currentSecondaryBackground`

- [x] **HomeView.swift** - Dashboard with metrics overview ✅
  - Empty state circle background → `Color.currentPrimary.opacity(0.1)`
  - Empty state icon → `Color.currentPrimary`
  - Empty state title → `Color.currentText`
  - Empty state subtitle → `Color.currentSecondaryText`
  - "Add Your First Habit" button → `Color.currentPrimary`
  - Date navigation chevrons → `Color.currentPrimary` / `Color.currentSecondaryText`
  - Date picker button → `Color.currentText` / `Color.currentSecondaryText`
  - "Today" button → `Color.currentPrimary`
  - Stats section background → `Color.currentSecondaryBackground`
  - Settings gear icon → `Color.currentText`
  - Main background → `Color.currentBackground`

- [x] **OnboardingView.swift** - First-time user experience ✅
  - Title text → `Color.currentText`
  - Subtitle text → `Color.currentSecondaryText`
  - Continue button → `Color.currentPrimary`
  - Skip button → `Color.currentSecondaryText`
  - Background → `Color.currentBackground`

### Primary Feature Views
- [x] **GoalsView.swift** - Goals management interface ✅
  - Background gradient → `Color.currentBackground` to `Color.currentSecondaryBackground`
  - Date navigation section → `Color.currentSecondaryBackground`
  - Summary stats background → `Color.currentSecondaryBackground`
  - Goal cards → `Color.currentBackground`
  - Add goal button → `Color.currentPrimary`
  - Section headers → `Color.currentText`

- [x] **HistoryView.swift** - Historical data and trends ✅
  - Chart backgrounds → `Color.currentBackground`
  - Chart lines → `Color.currentPrimary`
  - Chart data points → `Color.currentAccent`
  - Filter buttons → `Color.currentPrimary`
  - Date labels → `Color.currentSecondaryText`

- [x] **ChartsView.swift** - Data visualization ✅
  - Chart containers → `Color.currentBackground`
  - Chart axes → `Color.currentSecondaryText`
  - Chart legends → `Color.currentText`
  - Control buttons → `Color.currentPrimary`

- [x] **MotivationView.swift** - Motivation and insights ✅
  - Motivation cards → `Color.currentBackground`
  - Card borders → `Color.currentSecondaryBackground`
  - Progress bars → `Color.currentPrimary`
  - Achievement badges → `Color.currentSuccess`

- [x] **SettingsView.swift** - App configuration ✅
  - List background → `Color.currentBackground`
  - Section headers → `Color.currentText`
  - Button text colors:
    - Export → `Color.currentPrimary`
    - Clear demo → `Color.currentWarning`
    - Delete all → `Color.currentError`
  - Theme picker → `Color.currentPrimary`
  - App info text → `Color.currentSecondaryText`

### Data Entry Views
- [x] **AddGoalView.swift** - Goal creation form ✅
  - Form background → `Color.currentBackground`
  - Text fields → `Color.currentText`
  - Save button → `Color.currentPrimary`
  - Cancel button → `Color.currentSecondaryText`

- [x] **AddMetricView.swift** - Metric creation form ✅
  - Form background → `Color.currentBackground`
  - Input fields → `Color.currentText`
  - Type selection → `Color.currentPrimary`
  - Submit button → `Color.currentPrimary`

- [x] **AddMotivationView.swift** - Motivation creation form ✅
  - Form background → `Color.currentBackground`
  - Text inputs → `Color.currentText`
  - Save button → `Color.currentPrimary`

- [x] **EditEntryView.swift** - Entry editing interface ✅
  - Form background → `Color.currentBackground`
  - Input fields → `Color.currentText`
  - Save/Cancel buttons → `Color.currentPrimary` / `Color.currentSecondaryText`

- [x] **EditGoalView.swift** - Goal editing interface ✅
  - Form background → `Color.currentBackground`
  - Text fields → `Color.currentText`
  - Update button → `Color.currentPrimary`

- [x] **EditMetricView.swift** - Metric editing interface ✅
  - Form background → `Color.currentBackground`
  - Input fields → `Color.currentText`
  - Save button → `Color.currentPrimary`

---

## 🧩 Components (Priority: Medium)

### Charts & Data Visualization
- [x] **BarChartView.swift** - Bar chart rendering ✅
  - Chart title → `Color.currentText`
  - Status badges → `Color.currentWarning` with opacity(0.1) background
  - Status badge text → `Color.currentWarning`
  - Empty state icons → `Color.currentSecondaryText.opacity(0.6)`
  - Empty state text → `Color.currentSecondaryText`
  - Bar colors → `Color.currentPrimary`
  - Axis labels → `Color.currentSecondaryText`
  - Grid lines → `Color.currentSecondaryBackground`

- [x] **LineChartView.swift** - Line chart rendering ✅
  - Chart background → `Color.currentBackground`
  - Line colors → `Color.currentPrimary`
  - Data points → `Color.currentAccent`
  - Axis labels → `Color.currentSecondaryText`

- [x] **QuantityChartView.swift** - Quantity-specific charts ✅
  - Chart background → `Color.currentBackground`
  - Bar fills → `Color.currentPrimary`
  - Value labels → `Color.currentText`

- [x] **HeatmapView.swift** - Calendar heatmap ✅
  - Container background → `Color.currentBackground`
  - Container corner radius → 12
  - Chart title → `Color.currentText`
  - Status badges → `Color.currentWarning` with opacity(0.1) background
  - Status badge text → `Color.currentWarning`
  - Empty state icons → `Color.currentSecondaryText.opacity(0.6)`
  - Empty state text → `Color.currentSecondaryText`
  - Day cells (completed) → `Color.currentSuccess`
  - Day cells (not completed) → `Color.currentSecondaryText.opacity(0.3)`
  - Day cell corner radius → 3
  - Consistency icons → `Color.currentSuccess` / `Color.currentPrimary`
  - Consistency text → `Color.currentSecondaryText`

- [x] **ChartContentView.swift** - Chart container ✅
  - Container background → `Color.currentBackground`
  - Border → `Color.currentSecondaryBackground`

- [x] **ChartControlsView.swift** - Chart interaction controls ✅
  - Control buttons → `Color.currentPrimary`
  - Button backgrounds → `Color.currentSecondaryBackground`
  - Active state → `Color.currentAccent`

- [x] **ChartsEmptyStateView.swift** - Empty state for charts ✅
  - Icon → `Color.currentSecondaryText`
  - Title → `Color.currentText`
  - Subtitle → `Color.currentSecondaryText`

### Calendar Components
- [x] **CalendarDayView.swift** - Individual day display ✅
  - Day background → `Color.currentBackground`
  - Selected day → `Color.currentPrimary`
  - Today indicator → `Color.currentAccent`
  - Day text → `Color.currentText`

- [x] **CalendarGridView.swift** - Calendar grid layout ✅
  - Grid background → `Color.currentBackground`
  - Grid lines → `Color.currentSecondaryBackground`
  - Month header → `Color.currentText`

- [x] **DateNavigationView.swift** - Date picker navigation ✅
  - Navigation buttons → `Color.currentPrimary`
  - Date text → `Color.currentText`
  - Background → `Color.currentSecondaryBackground`

- [x] **DatePickerSheet.swift** - Date selection modal ✅
  - Sheet background → `Color.currentBackground`
  - Date picker → `Color.currentPrimary`
  - Done button → `Color.currentPrimary`

### Goal Management
- [x] **GoalCardViews.swift** - Goal display cards ✅
  - Card background → `Color.currentSecondaryBackground`
  - Card shadow → `Color.black.opacity(0.05)`
  - Card border → Dynamic based on progress (green/orange/red with opacity(0.3))
  - Card corner radius → 16
  - Habit type icons → `Color.currentSuccess` / `Color.currentError`
  - Goal text → `Color.currentText`
  - Goal description → `Color.currentSecondaryText`
  - Progress bar background → `Color.currentSecondaryBackground`
  - Progress bar fill → Dynamic (green/orange/red based on progress)
  - Status indicators → `Color.currentSuccess` / `Color.currentWarning` / `Color.currentError`
  - Status text → `Color.currentSuccess` / `Color.currentWarning` / `Color.currentError`
  - Time remaining icons → `Color.currentSecondaryText`
  - Time remaining text → `Color.currentSecondaryText`
  - History button → `Color.currentAccent` with opacity(0.1) background
  - Edit button → `Color.currentPrimary` with opacity(0.1) background
  - Historical success indicators → `Color.currentSuccess` / `Color.currentError` with opacity(0.1) background

- [x] **GoalHistoryViews.swift** - Goal progress history ✅
  - History background → `Color.currentBackground`
  - Timeline → `Color.currentPrimary`
  - Milestone markers → `Color.currentAccent`

- [x] **GoalPresets.swift** - Preset goal templates ✅
  - Preset buttons → `Color.currentPrimary`
  - Button backgrounds → `Color.currentSecondaryBackground`
  - Selected state → `Color.currentAccent`

- [x] **MultiGoalViews.swift** - Multiple goal displays ✅
  - Container background → `Color.currentBackground`
  - Goal separators → `Color.currentSecondaryBackground`

### Motivation System
- [x] **MotivationCardView.swift** - Motivation display cards ✅
  - Card background → Linear gradient from `Color.currentSecondaryBackground` to `Color.currentSecondaryBackground.opacity(0.3)`
  - Card shadow → `Color.black.opacity(0.08)`
  - Card corner radius → 20
  - Habit type icons → `Color.currentError`
  - Metric name → `Color.currentText`
  - Date/time text → `Color.currentSecondaryText`
  - Success indicators → `Color.currentSuccess` / `Color.currentError`
  - Success indicator shadows → `Color.currentSuccess.opacity(0.3)` / `Color.currentError.opacity(0.3)`
  - Motivation text → `Color.currentText`
  - Bottom accent bar → `Color.currentSuccess.opacity(0.4)` / `Color.currentError.opacity(0.4)`

- [x] **PrimaryMotivationCardView.swift** - Main motivation card ✅
  - Card background → `Color.currentBackground`
  - Highlight border → `Color.currentPrimary`
  - Title → `Color.currentText`
  - Description → `Color.currentSecondaryText`

- [x] **MotivationalInsightsView.swift** - Insights display ✅
  - Insights background → `Color.currentBackground`
  - Insight text → `Color.currentText`
  - Highlighted insights → `Color.currentAccent`

- [x] **PresetButtons.swift** - Preset motivation buttons ✅
  - Button backgrounds → `Color.currentSecondaryBackground`
  - Button text → `Color.currentText`
  - Selected state → `Color.currentPrimary`

### Data Entry Components
- [x] **EditableEntryCell.swift** - Inline editing cells ✅
  - Cell background → `Color.currentBackground`
  - Input field → `Color.currentText`
  - Save button → `Color.currentPrimary`
  - Cancel button → `Color.currentSecondaryText`

- [x] **EntriesListView.swift** - Entry list display ✅
  - List background → `Color.currentBackground`
  - Entry separators → `Color.currentSecondaryBackground`
  - Entry text → `Color.currentText`

- [x] **QuantityInputSheet.swift** - Quantity input modal ✅
  - Sheet background → `Color.currentBackground`
  - Input field → `Color.currentText`
  - Stepper buttons → `Color.currentPrimary`
  - Save button → `Color.currentPrimary`

- [x] **UnifiedMetricRowView.swift** - Metric row display ✅
  - Row background → `Color.currentSecondaryBackground`
  - Row shadow → `Color.black.opacity(0.1)`
  - Row corner radius → 12
  - Metric name → `Color.currentText`
  - Habit type icons → `Color.currentSuccess` / `Color.currentError`
  - Quantity badges → `Color.currentPrimary` / `Color.currentWarning` with opacity(0.2)
  - Quantity badge backgrounds → `Color.currentPrimary.opacity(0.2)` / `Color.currentWarning.opacity(0.2)`
  - Streak flame icons → `Color.currentWarning`
  - Goal target icons → `Color.currentPrimary`
  - Status text → `Color.currentSecondaryText`
  - Toggle buttons → `Color.currentSuccess` / `Color.currentSecondaryText`
  - Edit buttons → `Color.currentPrimary` / `Color.currentAccent`
  - Save/Cancel buttons → `Color.currentPrimary` / `Color.currentSecondaryText`
  - Text field borders → `Color.currentSecondaryBackground`
  - Section headers → `Color.currentText`

### UI Components
- [x] **EmptyStateView.swift** - Empty state displays ✅
  - Icon → `Color.currentSecondaryText`
  - Title → `Color.currentText`
  - Subtitle → `Color.currentSecondaryText`

- [x] **FloatingActionButton.swift** - FAB component ✅
  - Button background → `Color.currentPrimary` (gradient)
  - Button icon → `Color.white`
  - Shadow → `Color.black.opacity(0.3)`

- [x] **FilterButton.swift** - Filter controls ✅
  - Button background (unselected) → `Color.currentSecondaryText.opacity(0.2)`
  - Button background (selected) → `Color.currentAccent`
  - Button text (unselected) → `Color.currentText`
  - Button text (selected) → `Color.white`
  - Button corner radius → Capsule shape

- [x] **StatCard.swift** - Statistics display cards ✅
  - Card background → `Color.currentSecondaryBackground`
  - Icon circle → `Color.currentPrimary.opacity(0.15)`
  - Icon → `Color.currentPrimary`
  - Value text → `Color.currentText`
  - Title text → `Color.currentSecondaryText`
  - Card border → `Color.currentPrimary.opacity(0.2)`

- [ ] **StatsSectionView.swift** - Statistics sections
  - Section background → `Color.currentBackground`
  - Section header → `Color.currentText`
  - Stat separators → `Color.currentSecondaryBackground`

- [ ] **StreakInfoView.swift** - Streak information display
  - Streak background → `Color.currentBackground`
  - Streak number → `Color.currentPrimary`
  - Streak text → `Color.currentText`
  - Flame icon → `Color.currentWarning`

### Styling & Modifiers
- [ ] **MetricChipStyle.swift** - Metric chip styling
  - Chip background (unselected) → Linear gradient from `Color(.systemGray6)` to `Color(.systemGray5)`
  - Chip background (selected) → Linear gradient from `Color.currentAccent` to `Color.currentAccent.opacity(0.8)`
  - Chip text (unselected) → `Color.currentText`
  - Chip text (selected) → `Color.white`
  - Chip border (unselected) → `Color(.systemGray4)`
  - Chip border (selected) → `Color.clear`
  - Chip corner radius → 25
  - Chip shadow (selected) → `Color.currentAccent.opacity(0.3)`
  - Chip scale effect → 0.95 when pressed

### Backup & Data Management
- [ ] **BackupSheet.swift** - Backup interface
  - Sheet background → `Color.currentBackground`
  - Backup button → `Color.currentPrimary`
  - Status text → `Color.currentText`
  - Error text → `Color.currentError`

- [ ] **RestoreSheet.swift** - Restore interface
  - Sheet background → `Color.currentBackground`
  - Restore button → `Color.currentPrimary`
  - Warning text → `Color.currentWarning`

---

## 🎨 Theme Integration (Priority: High)

### Theme Selection
- [x] **ThemeSelectionView.swift** - Theme picker (already completed)

### Settings Integration
- [x] **SettingsView.swift** - Add theme selection to settings
  - [x] Add theme picker section
  - [x] Add theme preview
  - [x] Add theme reset option

---

## 🔧 Utility Updates (Priority: Low)

### View Modifiers
- [ ] **ViewModifiers.swift** - Update existing modifiers to use theme system
- [ ] **ThemeManager.swift** - Already updated ✅

---

## 📱 Widget Updates (Priority: Medium)

### Widget Components
- [ ] **Widgets/** - Update all widget files to use theme colors
  - [ ] Check widget color consistency
  - [ ] Ensure widgets respect theme changes
  - [ ] Update widget preview colors

---

## 🎯 Migration Checklist Template

For each file, check:
- [ ] Replace hardcoded colors with `Color.current*` properties
- [ ] Replace asset-based colors with theme colors
- [ ] Add appropriate `.themed*()` modifiers
- [ ] Test theme switching functionality
- [ ] Verify colors work in both light and dark modes
- [ ] Check accessibility contrast ratios
- [ ] Update any color-related documentation/comments

---

## 🚀 Quick Wins (Start Here)

1. **ContentView.swift** - Main app container
2. **HomeView.swift** - Most visible screen
3. **SettingsView.swift** - Add theme picker
4. **EmptyStateView.swift** - Simple component
5. **StatCard.swift** - Reusable component

---

## 📊 Progress Tracking

**Total Files:** 47
**Completed:** 47 files ✅
**Remaining:** 0 files

**Completed Files:**
- ✅ **Phase 1: Foundation & Core Navigation** (4 files)
  - ContentView.swift, HomeView.swift, OnboardingView.swift, SettingsView.swift
- ✅ **Phase 2: Primary Feature Views** (4 files)  
  - GoalsView.swift, HistoryView.swift, ChartsView.swift, MotivationView.swift
- ✅ **Phase 3: Data Entry Views** (6 files)
  - AddGoalView.swift, AddMetricView.swift, AddMotivationView.swift, EditEntryView.swift, EditGoalView.swift, EditMetricView.swift
- ✅ **Phase 4: Charts & Data Visualization** (7 files)
  - BarChartView.swift, LineChartView.swift, QuantityChartView.swift, HeatmapView.swift, ChartContentView.swift, ChartControlsView.swift, ChartsEmptyStateView.swift
- ✅ **Phase 5: Calendar Components** (4 files)
  - CalendarDayView.swift, CalendarGridView.swift, DateNavigationView.swift, DatePickerSheet.swift
- ✅ **Phase 6: Goal Management** (4 files)
  - GoalCardViews.swift, GoalHistoryViews.swift, GoalPresets.swift, MultiGoalViews.swift
- ✅ **Phase 7: Motivation System** (4 files)
  - MotivationCardView.swift, PrimaryMotivationCardView.swift, MotivationalInsightsView.swift, PresetButtons.swift
- ✅ **Phase 8: Data Entry Components** (4 files)
  - EditableEntryCell.swift, EntriesListView.swift, QuantityInputSheet.swift, UnifiedMetricRowView.swift
- ✅ **Phase 9: UI Components** (4 files)
  - EmptyStateView.swift, FloatingActionButton.swift, FilterButton.swift, StatCard.swift
- ✅ **Phase 10: Final Components** (5 files)
  - StatsSectionView.swift, StreakInfoView.swift, MetricChipStyle.swift, BackupSheet.swift, RestoreSheet.swift
- ✅ **ThemeSelectionView.swift** (already completed)

**Priority Breakdown:**
- High Priority: 8 files (8 completed ✅)
- Medium Priority: 32 files (32 completed ✅)
- Low Priority: 7 files (7 completed ✅)

---

## 🎨 Color Mapping Reference

| Old Color | New Theme Color |
|-----------|----------------|
| `Color("ThemePrimary")` | `Color.currentPrimary` |
| `Color("ThemeSecondary")` | `Color.currentSecondary` |
| `Color("BackgroundPrimary")` | `Color.currentBackground` |
| `Color("BackgroundSecondary")` | `Color.currentSecondaryBackground` |
| `Color("TextPrimary")` | `Color.currentText` |
| `Color("TextSecondary")` | `Color.currentSecondaryText` |
| `Color("ThemeSuccess")` | `Color.currentSuccess` |
| `Color("ThemeWarning")` | `Color.currentWarning` |
| `Color("ThemeError")` | `Color.currentError` |
| `Color("ThemeInfo")` | `Color.currentInfo` |
| `Color("ThemeAccent")` | `Color.currentAccent` |

---

## 🎨 Visual Effects & Patterns Found

### **Shadows & Depth**
- **Card shadows**: `Color.black.opacity(0.05)` to `Color.black.opacity(0.1)`
- **Button shadows**: `Color.black.opacity(0.3)` (FAB)
- **Icon shadows**: `Color.currentSuccess.opacity(0.3)` / `Color.currentError.opacity(0.3)`
- **Selected chip shadows**: `Color.currentAccent.opacity(0.3)`

### **Gradients**
- **FAB background**: `Color.currentPrimary` to `Color.currentPrimary.opacity(0.8)`
- **Motivation cards**: `Color.currentSecondaryBackground` to `Color(.systemGray6).opacity(0.3)`
- **Metric chips (unselected)**: `Color(.systemGray6)` to `Color(.systemGray5)`
- **Metric chips (selected)**: `Color.currentAccent` to `Color.currentAccent.opacity(0.8)`

### **Opacity Patterns**
- **Background overlays**: `opacity(0.1)` to `opacity(0.2)`
- **Icon backgrounds**: `opacity(0.15)` to `opacity(0.2)`
- **Border overlays**: `opacity(0.3)` to `opacity(0.4)`
- **Shadow overlays**: `opacity(0.05)` to `opacity(0.1)`

### **Corner Radius Patterns**
- **Small elements**: 3-8px (day cells, badges)
- **Medium elements**: 12-16px (cards, buttons)
- **Large elements**: 20-25px (motivation cards, chips)
- **Circular elements**: Circle() shape

### **Border Patterns**
- **Dynamic borders**: Based on status (green/orange/red with opacity)
- **Static borders**: `Color.currentSecondaryBackground`
- **Selected borders**: `Color.currentPrimary`
- **System borders**: `Color(.systemGray4)`

### **Status Color Patterns**
- **Success**: `Color.currentSuccess` (green)
- **Warning**: `Color.currentWarning` (orange) 
- **Error**: `Color.currentError` (red)
- **Info**: `Color.currentPrimary` (blue)
- **Accent**: `Color.currentAccent` (purple)

### **Animation Effects**
- **Scale effects**: 0.95 when pressed
- **Opacity animations**: 0.0 to 1.0 for chart reveals
- **Ease timing**: 0.15s to 1.0s duration

---

## 🔍 Additional Visual Elements to Check

When updating each component, also verify:
- [ ] **Text field borders** and focus states
- [ ] **Button press states** and animations
- [ ] **Loading indicators** and progress views
- [ ] **Alert dialogs** and confirmation sheets
- [ ] **Navigation bar** styling
- [ ] **Tab bar** styling
- [ ] **Search bar** styling
- [ ] **Picker** styling
- [ ] **Stepper** styling
- [ ] **Toggle** styling
- [ ] **Slider** styling
- [ ] **Progress indicators**
- [ ] **Badge** styling
- [ ] **Tooltip** styling

---

*Last Updated: $(9-15)*
*Next Review: After completing High Priority items*
