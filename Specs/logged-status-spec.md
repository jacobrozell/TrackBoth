# Logged Status Implementation Spec

## Overview
This spec outlines a major logic change to fix the streak calculation issue where vices start as "Avoided" and immediately create massive streaks. The solution is to add a `hasBeenLogged` boolean field to the `Metric` model to track whether a metric has ever been logged by the user.

## Problem Statement
Currently, the streak calculation assumes that:
- **Positive habits**: Missing entries = not done (breaks streak)
- **Vices**: Missing entries = avoided (extends streak)

This causes vices to immediately show large streaks upon creation since there are no entries, and the system assumes they've been "avoided" for all previous days. However, **both habits and vices should be treated equally** - neither should have streaks calculated until they've been explicitly logged by the user.

## Solution
Add a `hasBeenLogged` boolean field to the `Metric` model that tracks whether the user has ever logged this metric. Only start streak calculations after the first log entry. Once logged, missing days count as "success" for streak purposes regardless of whether it's a habit or vice.

## Data Model Changes

### Metric Model Updates
```swift
@Model
class Metric {
    var id: UUID = UUID()
    var name: String = ""
    var createdAt: Date = Date()
    var habitType: HabitType?
    var primaryMotivation: String?
    var hasBeenLogged: Bool = false  // NEW FIELD - defaults to false
    
    // ... existing fields ...
}
```

### MetricEntry Model Updates
```swift
@Model
class MetricEntry {
    var id: UUID = UUID()
    var metricID: UUID = UUID()
    var date: Date = Date()
    var value: Bool = false  // ALWAYS defaults to false
    var motivation: String?
    var starred: Bool?
    var details: String?
    var quantity: Int?
    var unit: String?
    
    // ... existing fields ...
}
```

### Migration Strategy
- All existing metrics will have `hasBeenLogged = false` by default
- All existing entries will have `value = false` by default (if not already set)
- Existing metrics with entries will need to be updated to `hasBeenLogged = true`
- Migration script will check for existing entries and update accordingly

## Logic Changes

### 1. Streak Calculation (`StreakUtils.swift`)

#### Current Logic (PROBLEMATIC):
```swift
// For vices: Missing means avoided → extend streak
if isVice {
    streak += 1
} else {
    // Missing means not done for habits → break streak
    break
}
```

#### New Logic:
```swift
// No entry found
if !metric.hasBeenLogged {
    // Never logged = no streak yet (applies to both habits and vices)
    break
} else {
    // If it's been logged before, count it in the streak regardless of type
    streak += 1
}
```


### 2. Entry Creation Logic

#### Current Behavior:
- First tap creates entry with `value: true`
- Subsequent taps toggle the value

#### New Behavior:
- **First tap**: Creates entry with `value: true` AND sets `metric.hasBeenLogged = true`
- **Subsequent taps**: Toggle the value between `true` and `false`
- **Default state**: Both `value` and `hasBeenLogged` are `false` by default
- **No automatic streak calculation** until `hasBeenLogged = true` (applies to both habits and vices)

### 3. UI Display Logic

#### Streak Display:
- **Before first log**: Show "Not logged yet" or hide streak (applies to both habits and vices)
- **After first log**: Show actual streak calculation

#### Metric Status Indicators:
- **Never logged**: Show neutral state (gray/outline) for both habits and vices
- **Logged**: Show current status (completed for habits, avoided for vices)

## Files Requiring Updates

### Core Models
1. **`TrackBoth/Models/Metric.swift`**
   - Add `hasBeenLogged: Bool = false` property
   - Update initializer to accept `hasBeenLogged` parameter
   - Add migration logic for existing metrics

### Streak Calculation
2. **`TrackBoth/Utils/StreakUtils.swift`**
   - Update `calculateCurrentStreak()` method
   - Update `calculateLongestStreak()` method
   - Add logic to check `hasBeenLogged` before calculating streaks
   - Handle "never logged" state in streak calculations

### Entry Management
3. **`TrackBoth/Models/MetricEntry.swift`**
   - Update `getOrCreate()` method to set `hasBeenLogged = true`
   - Update `updateOrCreate()` method to set `hasBeenLogged = true`
   - Ensure all entry creation paths update the metric's logged status

### View Models
4. **`TrackBoth/ViewModels/HomeViewModel.swift`**
   - Update `toggleMetricCompletion()` method
   - Set `hasBeenLogged = true` when creating first entry
   - Update streak calculation calls

5. **`TrackBoth/ViewModels/ChartsViewModel.swift`**
   - Update streak calculations to respect `hasBeenLogged`
   - Handle "never logged" state in chart data

6. **`TrackBoth/ViewModels/GoalsViewModel.swift`**
   - Update goal progress calculations
   - Handle "never logged" metrics in goal tracking

### UI Components
7. **`TrackBoth/Components/StreakInfoView.swift`**
   - Update streak display logic
   - Show "Not logged yet" for unlogged metrics
   - Handle empty state for never-logged metrics

8. **`TrackBoth/Components/UnifiedMetricRowView.swift`**
   - Update toggle logic to set `hasBeenLogged = true`
   - Update visual indicators for logged vs unlogged state
   - Handle streak display for unlogged metrics

9. **`TrackBoth/Components/StatCard.swift`**
   - Update streak display logic
   - Handle "never logged" state in statistics

### Watch Views
10. **`TrackBoth/Views/WatchViews/WatchMainView.swift`**
    - Update toggle logic to set `hasBeenLogged = true`
    - Update streak calculation for watch
    - Handle unlogged metrics in watch UI

11. **`TrackBoth/Views/WatchViews/WatchWeeklySummaryView.swift`**
    - Update weekly summary to handle unlogged metrics
    - Filter out unlogged metrics from summaries

### Widget Integration
12. **`TrackBoth/Utils/WidgetIntegration.swift`**
    - Update widget data to respect `hasBeenLogged`
    - Handle unlogged metrics in widget display

13. **`TrackBoth/Widgets/WidgetDataModels.swift`**
    - Update widget data models to include logged status
    - Handle unlogged metrics in widget calculations

### Utility Functions
14. **`TrackBoth/Utils/DemoDataGenerator.swift`**
    - Update demo data generation to set `hasBeenLogged = true`
    - Ensure demo metrics have proper logged status

15. **`TrackBoth/Utils/GoalUtils.swift`**
    - Update goal progress calculations
    - Handle unlogged metrics in goal tracking

## Migration Strategy

### Database Migration
1. **Add new field**: Add `hasBeenLogged: Bool = false` to Metric model
2. **Update existing metrics**: Run migration to set `hasBeenLogged = true` for metrics with existing entries
3. **Verify data integrity**: Ensure all metrics with entries have `hasBeenLogged = true`

### Migration Script
```swift
// Pseudo-code for migration
func migrateLoggedStatus() {
    let metrics = fetchAllMetrics()
    for metric in metrics {
        let hasEntries = fetchEntries(for: metric.id).count > 0
        metric.hasBeenLogged = hasEntries
    }
    
    // Ensure all entries have value = false by default
    let entries = fetchAllEntries()
    for entry in entries {
        // Only set if not already explicitly set
        if entry.value == nil {
            entry.value = false
        }
    }
    
    saveContext()
}
```

## Testing Strategy

### Unit Tests
1. **Streak Calculation Tests**
   - Test streak calculation for never-logged metrics
   - Test streak calculation for logged metrics
   - Test migration of existing metrics

2. **Entry Creation Tests**
   - Test that first entry sets `hasBeenLogged = true`
   - Test that subsequent entries don't change logged status
   - Test entry creation for both habits and vices

3. **UI State Tests**
   - Test display of unlogged metrics
   - Test streak display for unlogged metrics
   - Test goal progress for unlogged metrics

### Integration Tests
1. **End-to-End Flow**
   - Create new metric → verify `hasBeenLogged = false`
   - Log first entry → verify `hasBeenLogged = true`
   - Verify streak calculation works correctly
   - Verify UI updates appropriately

2. **Migration Testing**
   - Test migration of existing data
   - Verify no data loss during migration
   - Test rollback scenarios

## Rollout Plan

### Phase 1: Core Implementation
1. Add `hasBeenLogged` field to Metric model
2. Update streak calculation logic
3. Update entry creation logic
4. Run migration for existing data

### Phase 2: UI Updates - Use HomeView2 as HomeView
1. Update streak display components
2. Update metric status indicators
3. Update watch views
4. Update widget integration

### Phase 3: Testing & Validation
1. Comprehensive testing
2. User acceptance testing
3. Performance validation
4. Data integrity verification


## Risk Mitigation

### Data Loss Prevention
- Backup existing data before migration
- Test migration on copy of production data
- Implement rollback mechanism

### Performance Considerations
- Index `hasBeenLogged` field for efficient queries
- Optimize streak calculations for large datasets
- Monitor performance impact of new logic

### User Experience
- Clear communication about the change
- Smooth transition for existing users
- Maintain familiar UI patterns where possible

## Success Metrics

### Technical Metrics
- Zero data loss during migration
- No performance degradation
- All tests passing

### User Experience Metrics
- Accurate streak calculations
- Intuitive UI for unlogged metrics
- No user confusion about logged status

### Business Metrics
- Maintained user engagement
- Accurate goal tracking
- Improved data quality

## Future Considerations

### Potential Enhancements
1. **Logging History**: Track when metrics were first logged
2. **Reset Functionality**: Allow users to reset logged status
3. **Bulk Operations**: Allow bulk logging of multiple metrics
4. **Analytics**: Track user logging patterns

### Scalability
- Ensure solution scales with user growth
- Optimize for large numbers of metrics
- Consider caching strategies for streak calculations

## Conclusion

This implementation will solve the streak calculation issue by ensuring that streaks are only calculated after a user has explicitly logged a metric. This applies equally to both habits and vices, providing more accurate and meaningful streak data while maintaining the existing user experience for logged metrics.

The change is backward-compatible and includes a comprehensive migration strategy to ensure existing user data is preserved and properly updated. Both habits and vices will now have consistent behavior - no streaks until explicitly logged by the user.
