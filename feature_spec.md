# 📊 Quantity Tracking Feature Specification

## 🎯 Overview

Add quantity tracking capabilities to habits and vices, allowing users to log specific amounts per day (e.g., "Smoked 3 times today", "Drank 2 cups of coffee", "Exercised for 45 minutes"). This enables more granular progress tracking and better insights for habit modification.

## 🧩 Core Concept

Extend the current boolean tracking system to support:
- **Quantity Input**: Numeric values for daily entries
- **Unit Support**: Flexible units (times, cups, minutes, etc.)
- **Progress Visualization**: Track quantity trends over time
- **Goal Integration**: Set quantity-based goals alongside frequency goals

## 📱 User Experience Flow

### **Current State**
- User taps habit → Simple yes/no toggle
- Vices: "Avoided" vs "Not Avoided"
- Habits: "Done" vs "Not Done" + optional details

### **Enhanced State**
- User taps habit → Quantity input sheet appears
- Input: Number + Unit (e.g., "3 times", "45 minutes", "2 cups")
- Save → Updates daily entry with quantity data
- Visual indicators show quantity in UI

## 🗂 Data Model Extensions

### **MetricEntry Model Updates**
```swift
// Add to existing MetricEntry
var quantity: Int?           // Numeric value (3, 45, 2)
var unit: String?           // Unit descriptor ("times", "minutes", "cups")
var hasQuantity: Bool       // Computed: quantity != nil && quantity! > 0
```

### **Metric Model Updates**
```swift
// Add to existing Metric
var defaultUnit: String?    // Default unit for this habit ("times", "minutes", etc.)
var enableQuantity: Bool     // Whether quantity tracking is enabled
var maxDailyQuantity: Int?  // Optional daily limit (e.g., max 5 cigarettes)
```

## 🎨 UI Design Patterns

### **Home View Integration**
- **Quantity Indicator**: Show "3x" or "45min" next to habit name
- **Quick Toggle**: Tap to increment quantity (+1) - **DISABLED FOR VICES**
- **Detail Sheet**: Long press or tap indicator to open quantity input

### **Quantity Input Sheet - Positive Habits**
```
┌─────────────────────────┐
│ Exercise - Today        │
├─────────────────────────┤
│ Quantity: [30] [min ▼]  │
│                         │
│ [Quick Presets]         │
│ [15] [30] [45] [60]     │
│                         │
│ [Cancel] [Save]         │
└─────────────────────────┘
```

### **Quantity Input Sheet - Vices (SAFE DESIGN)**
```
┌─────────────────────────┐
│ Smoking - Today         │
├─────────────────────────┤
│ Status: [Avoided ✓]     │
│                         │
│ If you did smoke today: │
│ Amount: [3] [times ▼]   │
│                         │
│ ⚠️ Remember: Your goal  │
│ is to reduce this habit │
│                         │
│ [Cancel] [Log Amount]   │
└─────────────────────────┘
```

### **Enhanced Metric Row - Positive Habits**
```
┌─────────────────────────────────┐
│ 🏃 Exercise             ✓ 30min │
│ 🔥 5 day streak                 │
│                                 │
│ Today: Done                      │
│ Quantity: 30 minutes            │
│ [Edit] [Quick +15min]           │
└─────────────────────────────────┘
```

### **Enhanced Metric Row - Vices (SAFE DESIGN)**
```
┌─────────────────────────────────┐
│ 🚬 Smoking              ✓ Clean │
│ 🔥 5 days clean                 │
│                                 │
│ Today: Avoided                   │
│ Last slip: 2 cigarettes         │
│ [Edit] [Log Slip]               │
└─────────────────────────────────┘
```

## 📊 Visualization Enhancements

### **Charts View Updates**
- **Line Charts**: Show quantity trends over time
- **Bar Charts**: Average daily quantities per week/month
- **Heatmap**: Color intensity based on quantity levels
- **Goal Progress**: Track against quantity targets

### **History View Updates**
- **Calendar Cells**: Show quantity indicators (3x, 45min)
- **Entry Details**: Display quantity in entry cards
- **Search**: Filter by quantity ranges

## 🎯 Goal System Integration

### **Quantity-Based Goals**
- **Frequency Goals**: "Do this habit X days per month" (current)
- **Quantity Goals**: "Keep under X per day" or "Average X per day"
- **Combined Goals**: Both frequency and quantity targets

### **Goal Types**
```swift
enum GoalType {
    case frequency(days: Int)           // Current system
    case maxQuantity(amount: Int)      // Keep under X per day
    case avgQuantity(amount: Int)      // Average X per day
    case combined(days: Int, max: Int) // Both frequency and quantity
}
```

## 🔧 Implementation Strategy

### **Phase 1: Core Quantity Tracking**
1. **Data Model Updates**
   - Add quantity/unit fields to MetricEntry
   - Add quantity settings to Metric
   - Update storage methods

2. **UI Components**
   - Quantity input sheet
   - Enhanced metric row view
   - Quick increment buttons

3. **Basic Integration**
   - Home view quantity display
   - History view quantity indicators

### **Phase 2: Advanced Features**
1. **Visualization Updates**
   - Charts with quantity data
   - Enhanced heatmaps
   - Quantity trend analysis

2. **Goal System**
   - Quantity-based goals
   - Combined goal types
   - Progress tracking

3. **Smart Features**
   - Quantity presets
   - Unit suggestions
   - Daily limits

### **Phase 3: Polish & Optimization**
1. **User Experience**
   - Onboarding for quantity features
   - Help text and examples
   - Accessibility improvements

2. **Advanced Analytics**
   - Quantity insights
   - Pattern recognition
   - Predictive suggestions

## 🎨 Design Considerations

### **Visual Hierarchy**
- **Primary**: Completion status (✓/✗)
- **Secondary**: Quantity indicator (3x, 45min)
- **Tertiary**: Streak information

### **Interaction Patterns**
- **Quick Actions**: Tap to increment (+1)
- **Detailed Input**: Long press for full input sheet
- **Visual Feedback**: Animate quantity changes

### **Accessibility**
- **VoiceOver**: "Smoking, 3 times today, avoided"
- **Dynamic Type**: Scale quantity text appropriately
- **High Contrast**: Ensure quantity indicators are visible

## 📱 Use Cases

### **Vice Reduction (SAFE APPROACH)**
- **Smoking**: "Logged 3 cigarettes today" → Track reduction over time
- **Alcohol**: "Logged 2 drinks today" → Monitor consumption patterns
- **Social Media**: "Logged 45 minutes today" → Track usage reduction
- **Key Principle**: Always frame as "logging slips" not "achieving targets"

### **Habit Building**
- **Exercise**: "30 minutes today" → Track duration and progress
- **Reading**: "25 pages today" → Monitor reading progress
- **Water**: "8 glasses today" → Ensure hydration goals

### **Medication Tracking**
- **Pills**: "2 pills today" → Ensure compliance
- **Supplements**: "1 vitamin today" → Track intake

## 🔄 Migration Strategy

### **Existing Data**
- **Backward Compatibility**: Existing entries work without quantity
- **Optional Fields**: Quantity/unit are optional
- **Default Behavior**: Habits without quantity enabled work as before

### **User Onboarding**
- **Progressive Disclosure**: Show quantity option when creating habits
- **Examples**: Provide common quantity use cases
- **Tutorial**: Guide users through first quantity entry

## ⚠️ Safety & Ethical Considerations

### **Vice Tracking Safety**
- **NO Quick Increment**: Disable +1 buttons for vices to avoid encouraging use
- **"Log Slip" Language**: Always frame vice quantities as "logging slips" not achievements
- **Warning Messages**: Include gentle reminders about reduction goals
- **Visual Cues**: Use caution colors (orange/yellow) for vice quantities, not celebration colors
- **Goal Framing**: Vice goals are "maximum limits" not "targets to reach"

### **UI Safety Patterns**
- **Conditional Quick Actions**: Only show +1 buttons for positive habits
- **Contextual Messaging**: Different language for habits vs vices
- **Progress Visualization**: Show reduction trends, not increase celebrations
- **Accessibility**: Clear distinction between habit building and vice reduction

### **Content Guidelines**
- **Positive Habits**: "Great job! 30 minutes of exercise"
- **Vices**: "Logged 3 cigarettes today. Remember your goal is to reduce this habit"
- **Charts**: Show downward trends as positive for vices
- **Goals**: Frame vice goals as "stay under X" not "reach X"

## 🎯 Success Metrics

### **User Engagement**
- **Quantity Entry Rate**: % of entries with quantity data
- **Feature Adoption**: % of habits with quantity enabled
- **Goal Completion**: Success rate of quantity-based goals
- **Safety Compliance**: Zero instances of encouraging vice use

### **User Satisfaction**
- **Feature Usage**: Frequency of quantity input
- **Goal Achievement**: Improvement in habit modification
- **App Retention**: Impact on overall app usage
- **User Feedback**: Positive response to safety measures

## 🚀 Future Enhancements

### **Advanced Quantity Features**
- **Smart Units**: Auto-suggest units based on habit type
- **Quantity Patterns**: Identify optimal quantities
- **Predictive Goals**: Suggest quantity targets based on history

### **Integration Opportunities**
- **Health Apps**: Sync with HealthKit for automatic tracking
- **Smart Notifications**: Remind users of quantity limits
- **Social Features**: Share quantity achievements (if desired)

---

## 📋 Implementation Phases

### **Phase 1: Data Foundation**
- [x] Extend MetricEntry model with quantity and unit fields
- [x] Add quantity tracking settings to Metric model
- [x] Update storage methods to handle quantity data
- [x] Ensure backward compatibility with existing data

### **Phase 2: Core UI Components**
- [x] Create QuantityInputSheet component with safety patterns
- [x] Update EnhancedMetricRowView to show quantity indicators
- [x] Implement conditional quick actions (only for positive habits)
- [x] Add safe language patterns for habits vs vices

### **Phase 3: View Integration**
- [x] Integrate quantity tracking into HomeView with conditional UI
- [x] Update HistoryView to display quantity data in calendar and entries
- [x] Connect quantity input to existing metric rows
- [x] Maintain current toggle behavior as fallback

### **Phase 4: Advanced Features**
- [x] Extend ChartsView to visualize quantity trends
- [x] Add quantity-based goal types to goal system
- [x] Update goal creation UI for quantity goals
- [x] Modify progress calculations for quantity tracking

### **Phase 5: Safety & Polish**
- [x] Test all vice-related UI to ensure no encouragement patterns
- [x] Verify accessibility compliance for quantity features
- [x] Validate safety measures across all user flows
- [x] Add comprehensive error handling and edge cases

---

## ✅ **Safety Validation Checklist**

### **Vice UI Safety Patterns - VERIFIED**
- ✅ **No Quick Increment**: Vices don't have +1 buttons, only "Log" buttons
- ✅ **Safe Language**: "Log Amount" vs "Save", "Log Slip" vs "Achieve Target"
- ✅ **Appropriate Colors**: Orange for vices, blue for habits (no celebration colors)
- ✅ **Warning Messages**: "Remember: Your goal is to reduce this habit"
- ✅ **Status Indicators**: "Avoided ✓" prominently displayed
- ✅ **Goal Framing**: "Keep under X per day" not "Reach X per day"

### **Component Safety Review**
- ✅ **QuantityInputSheet**: Different flows for habits vs vices with safety messaging
- ✅ **EnhancedMetricRowView**: Conditional buttons and color coding
- ✅ **HistoryView**: Safe quantity display with appropriate colors
- ✅ **ChartsView**: "Vice Quantities Logged" language, orange chart colors
- ✅ **Goal System**: "Max Daily" goals with "Keep under" language

### **Accessibility Compliance**
- ✅ **VoiceOver**: Clear distinction between habit and vice quantities
- ✅ **Dynamic Type**: Quantity text scales appropriately
- ✅ **High Contrast**: Orange/blue colors visible in high contrast mode
- ✅ **Clear Hierarchy**: Visual distinction between habit types

### **Error Handling**
- ✅ **Data Validation**: Quantity values validated (> 0) before storage
- ✅ **Empty States**: Helpful messaging when no quantity data exists
- ✅ **Backward Compatibility**: Existing habits work without quantity tracking
- ✅ **Safe Defaults**: Reasonable limits and fallback values

---

*This specification provides a comprehensive roadmap for implementing quantity tracking while maintaining the app's core simplicity and user experience.*
