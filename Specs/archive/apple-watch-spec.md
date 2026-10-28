# ⌚ Apple Watch Companion App - TrackBoth

## 🎯 Core Concept

A streamlined Apple Watch companion app that focuses on **today-only** habit and vice tracking. The watch app provides quick, frictionless logging without the complexity of historical data, goals, or advanced features. It's designed for immediate daily check-ins and basic progress visualization.

---

## 🎮 Core Features

### **Today-Only Focus**
- **Single Day View**: Only show and track today's habits/vices
- **No Historical Data**: No access to past entries or complex analytics
- **No Goal Management**: No goal setting, editing, or progress tracking
- **No Motivation System**: No access to motivation feed or content

### **Quick Logging**
- **One-Tap Toggle**: Simple checkmark/cross for habit/vice completion
- **Quantity Input**: Basic quantity entry for quantity-based habits
- **Voice Input**: Siri integration for quick logging
- **Haptic Feedback**: Immediate tactile confirmation

### **Basic Historical View**
- **Simple Streak Display**: Show current streak for each habit/vice
- **Weekly Summary**: Basic completion rate for the past 7 days
- **No Complex Charts**: No detailed analytics or visualizations

---

## 📱 App Structure

### **Main Interface**
- **Single Screen Design**: No complex navigation or tabs
- **Today's Date**: Clear date display at top
- **Habits Section**: List of positive habits with toggle buttons
- **Vices Section**: List of vices with toggle buttons
- **Quick Stats**: Simple completion counter (e.g., "3/5 completed")

### **Navigation**
- **No Tabs**: Single main view with scrollable content
- **No Settings**: No configuration options on watch
- **No Add/Edit**: No ability to create or modify habits/vices
- **No History**: No access to past data beyond basic streaks

---

## 🎨 User Interface Design

### **Main Screen Layout**
```
┌─────────────────────────┐
│  📅 Today, Dec 19      │
│                         │
│  ✅ Habits (2/3)       │
│  ┌─────────────────────┐│
│  │ ✓ Exercise          ││
│  │ ○ Read              ││
│  │ ✓ Meditate          ││
│  └─────────────────────┘│
│                         │
│  ❌ Vices (1/2)         │
│  ┌─────────────────────┐│
│  │ ✗ Social Media      ││
│  │ ○ Smoking           ││
│  └─────────────────────┘│
│                         │
│  📊 3/5 Complete        │
└─────────────────────────┘
```

### **Visual Design Principles**
- **Large Touch Targets**: Easy-to-tap buttons for watch interaction
- **Clear Typography**: Readable text sizes for small screen
- **High Contrast**: Clear visual distinction between completed/incomplete
- **Minimal Scrolling**: Fit most content on single screen
- **Consistent Icons**: Use SF Symbols for familiarity

### **Color Scheme**
- **Habits**: Green checkmarks and accents
- **Vices**: Red X marks and accents
- **Background**: Dark theme optimized for OLED
- **Text**: High contrast white/black

---

## 🔧 Technical Implementation

### **Data Synchronization**
- **Shared Data Model**: Use existing `Metric` and `MetricEntry` models
- **iCloud Sync**: Automatic sync with iPhone app data
- **Read-Only Access**: Watch can only read and update entries, not create metrics
- **Today Filter**: Only sync today's entries and active metrics

### **Watch-Specific Models**
```swift
// Simplified metric representation for watch
struct WatchMetric {
    let id: UUID
    let name: String
    let habitType: HabitType
    let isCompleted: Bool
    let hasQuantity: Bool
    let currentQuantity: Int?
    let unit: String?
    let streak: Int
}

// Today's summary data
struct TodaySummary {
    let totalHabits: Int
    let completedHabits: Int
    let totalVices: Int
    let completedVices: Int
    let overallProgress: Double
}
```

### **Core Functionality**
- **Metric Loading**: Load all active metrics from shared data
- **Entry Updates**: Update today's entries via shared context
- **Streak Calculation**: Calculate current streaks for display
- **Quantity Input**: Simple number input for quantity-based habits

---

## 🎯 User Experience Flow

### **Primary Use Cases**
1. **Morning Check-in**: Quick review of today's habits/vices
2. **Throughout Day**: Log completions as they happen
3. **Evening Review**: Final check of daily progress
4. **Streak Motivation**: See current streaks for motivation

### **Interaction Patterns**
- **Tap to Toggle**: Single tap to mark complete/incomplete
- **Force Touch**: Long press for quantity input (if applicable)
- **Crown Scroll**: Navigate through long lists
- **Voice Input**: "Log exercise" for quick entry

### **Error Handling**
- **Offline Mode**: Graceful degradation when iPhone unavailable
- **Sync Conflicts**: Simple conflict resolution (iPhone wins)
- **Data Validation**: Prevent invalid quantity entries

---

## 📊 Basic Historical Features

### **Streak Display**
- **Current Streak**: Show active streak for each habit/vice
- **Streak Icons**: Visual indicators for streak status
- **Streak Motivation**: Simple encouragement messages

### **Weekly Summary**
- **Completion Rate**: Percentage of habits/vices completed this week
- **Trend Indicators**: Simple up/down arrows for progress
- **Weekly Goal**: Basic "complete X days this week" tracking

### **No Complex Analytics**
- **No Charts**: No detailed visualizations or graphs
- **No Historical Data**: No access to past entries beyond streaks
- **No Goal Tracking**: No progress toward specific goals
- **No Motivation System**: No access to motivation content

---

## 🚀 Implementation Phases

### **Phase 1: Core Functionality**
- Basic metric loading and display
- Simple toggle functionality
- Today-only focus
- Basic haptic feedback

### **Phase 2: Enhanced Features**
- Quantity input for quantity-based habits
- Streak calculation and display
- Voice input integration
- Weekly summary view

### **Phase 3: Polish & Optimization**
- Advanced haptic patterns
- Performance optimization
- Error handling improvements
- Accessibility enhancements

---

## 🎯 Success Metrics

### **Engagement Metrics**
- **Daily Active Users**: Users logging on watch daily
- **Session Duration**: Time spent in watch app
- **Completion Rate**: Percentage of habits/vices logged
- **Streak Maintenance**: Users maintaining streaks via watch

### **Usability Metrics**
- **Logging Speed**: Time to log a habit/vice
- **Error Rate**: Failed logging attempts
- **User Satisfaction**: Watch app usage vs iPhone app
- **Feature Adoption**: Usage of quantity input and voice features

---

## 🔮 Future Enhancements

### **Advanced Features**
- **Complications**: Watch face complications for quick status
- **Notifications**: Smart reminders for habit logging
- **Workout Integration**: Connect with Apple Health for exercise tracking
- **Shortcuts**: Siri shortcuts for voice logging

### **Integration Features**
- **Health App**: Sync with Apple Health for health-related habits
- **Calendar**: Integration with calendar for time-based habits
- **Location**: Location-based reminders for context-aware logging

---

## 💡 Key Benefits

### **For Users**
- **Immediate Access**: Log habits/vices without reaching for iPhone
- **Frictionless Logging**: One-tap completion tracking
- **Streak Motivation**: See progress without complexity
- **Privacy-First**: All data stays on device

### **For App Retention**
- **Daily Engagement**: Watch app encourages daily usage
- **Habit Formation**: Immediate logging reinforces habit formation
- **Streak Maintenance**: Visual streak display motivates consistency
- **Simplicity**: No overwhelming features or complexity

### **For Habit Formation**
- **Immediate Feedback**: Instant logging reinforces behavior
- **Visual Progress**: Clear completion status and streaks
- **Reduced Friction**: No need to open iPhone app
- **Context Awareness**: Log habits in the moment they occur

---

## 🎨 Design Considerations

### **Watch-Specific Constraints**
- **Small Screen**: Optimize for 40mm and 44mm displays
- **Battery Life**: Minimize background processing
- **Performance**: Fast, responsive interactions
- **Accessibility**: VoiceOver and accessibility support

### **User Experience Principles**
- **Simplicity**: One purpose, one screen
- **Speed**: Immediate response to user actions
- **Clarity**: Clear visual feedback for all interactions
- **Consistency**: Match iPhone app design language

---

*This Apple Watch companion app provides a focused, streamlined experience for daily habit and vice tracking, emphasizing simplicity and immediate accessibility over complex features and historical data.*
