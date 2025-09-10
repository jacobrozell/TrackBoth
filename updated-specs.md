# 📱 QuickLog - Smart Habit & Vice Tracker

## 🎯 App Names (Suggested)
- **QuickLog** (current)
- **HabitHub**
- **ViceGuard**
- **TrackRight**
- **HabitFlow**
- **CleanSlate**
- **ViceBreaker**
- **HabitMaster**

---

## ✨ Core Concept

Track both positive habits (things you want to do) and vices (things you want to avoid) with smart boolean logging. The app intelligently tracks "days done" for positive habits and "days avoided" for vices, with comprehensive visualizations, streak tracking, and goal management.

---

## 🧩 Core Features ✅

### **Implemented Features**
- ✅ **Dual Habit Types**: Positive habits vs vices with distinct tracking logic
- ✅ **Smart Daily Logging**: Yes/no toggle with context-aware tracking
- ✅ **Habit Details System**: Optional subtitles/details for positive habits
- ✅ **Visual Indicators**: Green checkmarks for positive habits, red X's for vices
- ✅ **Streak Tracking**: "X day streak" for habits, "X days clean" for vices
- ✅ **Goal Management**: Monthly/yearly goals with progress bars
- ✅ **Motivation System**: Personal reasons library for vice avoidance
- ✅ **Social Media Feed**: Instagram-style motivation browsing
- ✅ **Calendar Search**: Search and filter by habit details
- ✅ **Advanced Filtering**: All Habits, All Vices, and specific metric filtering
- ✅ **Entries List View**: Editable past entries with details and motivations
- ✅ **Entry Editing**: Full editing capabilities for historical data
- ✅ **Improved Data Storage**: Duplicate prevention and content validation
- ✅ **Data Persistence**: SwiftData with migration support
- ✅ **Multiple Views**: Home, History, Goals, Charts, Motivation, Settings
- ✅ **Contextual UI**: Dynamic text and messaging based on habit type

### **Smart Tracking Logic**
- **Positive Habits**: Counts days when `value == true` (habit was done)
- **Vices**: Counts days when `value == false` (vice was avoided)
- **Goal Progress**: Automatically adjusts calculation based on habit type
- **Streak Calculation**: Consecutive days of success for each type

---

## 🗂 Data Model

### **Metric** (Habit/Vice)
```swift
- id: UUID
- name: String
- createdAt: Date
- habitType: HabitType? (optional for migration)
- safeHabitType: HabitType (computed, defaults to .positive)
```

### **HabitType** (Enum)
```swift
- positive: "Positive Habit" (green checkmark icon)
- vice: "Vice to Avoid" (red X icon)
```

### **MetricEntry** (Daily Log)
```swift
- id: UUID
- metricID: UUID
- date: Date
- value: Bool (true = done/avoided, false = not done/not avoided)
- motivation: String? (optional personal reasons/reflections)
- starred: Bool (primary motivation indicator)
- details: String? (optional habit details/subtitles)
- hasContent: Bool (computed - checks for meaningful content)
- getOrCreate(): Static method for duplicate prevention
- updateOrCreate(): Static method for unified entry management
- cleanupEmptyEntries(): Static method for data cleanup
```

### **Goal** (Target Setting)
```swift
- id: UUID
- metricID: UUID
- period: GoalPeriod (monthly/yearly)
- target: Int (number of successful days)
```

### **GoalPeriod** (Enum)
```swift
- monthly: "Monthly"
- yearly: "Yearly"
```

### **MetricFilter** (Enum)
```swift
- all: "All" (shows all entries)
- allHabits: "All Habits" (shows only positive habits)
- allVices: "All Vices" (shows only vices)
- specific(Metric): Shows specific metric entries
- displayName: String (user-friendly name)
- icon: String? (visual indicator)
- color: String? (color coding)
```

---

## 📱 UI Structure (SwiftUI)

### **Home View** 🏠
- List of all habits and vices with visual type indicators
- Smart daily toggle: Details input for positive habits, simple toggle for vices
- Optional habit details: "Lord of the Rings", "30 minutes", "Morning run"
- Streak display: "X day streak" or "X days clean"
- Add new habit/vice with type selection and primary motivation only
- Clean, focused interface for daily logging

### **History View** 📅
- Calendar-style view of past entries with habit details
- Color-coded success/failure indicators
- Details display: Shows "Lord of the Rings" in calendar cells
- **Advanced Filtering**: All, All Habits, All Vices, and specific metric filters
- **Entries List View**: Scrollable list of recent entries under calendar
- **Editable Entry Cells**: Edit past entries with full details and motivations
- **Entry Editing Sheet**: Comprehensive editing interface for historical data
- Search functionality: Filter by habit details
- Metric name display: Small, unobtrusive metric names in entry cells
- Monthly/yearly navigation

### **Goals View** 🎯
- Cards showing goal progress with visual indicators
- Progress bars with percentage completion
- Add new goals with habit type context
- Dynamic messaging based on habit type

### **Charts View** 📊
- Multiple visualization types
- **Advanced Filtering**: All, All Habits, All Vices, and specific metric filters
- Line charts for trends (supports filtered data)
- Bar charts for weekly/monthly completion (supports filtered data)
- Heatmap for calendar-style overview (supports filtered data)
- Streak statistics (supports filtered data)
- Consistent filtering UI across all chart types

### **Motivation View** 💭
- Social media-style feed of past motivations
- Filter by specific vice or view all
- Add new motivations with "+" button
- Visual cards with success/failure indicators
- Time-stamped entries with personal reflections

### **Settings View** ⚙️
- **Data Management**: Export all data as JSON, delete all data with confirmation
- **App Information**: Version, total habits, entries, and goals count
- **Future Features**: Light/dark mode, custom app icons, donate button, export graphs, share app
- **Clean Interface**: Organized sections with clear visual hierarchy

---

## 🎯 Goal Tracking System

### **Smart Goal Logic**
- **Positive Habits**: "Track days when you do this positive habit"
- **Vices**: "Track days when you avoid this vice" (maximum days concept)
- **Progress Calculation**: Automatically counts appropriate days based on habit type
- **Vice Goals**: Shows "X/Y days" with maximum limit instead of target
- **Visual Feedback**: Progress bars with contextual colors and messaging

### **Goal Creation**
- Select metric with habit type indicators
- Choose period (monthly/yearly)
- Set target number of days
- Dynamic help text explains goal tracking

---

## 📝 Habit Details System

### **Optional Subtitles for Positive Habits**
- **Smart Input**: Only positive habits prompt for details
- **Optional Field**: Users can skip details if they want
- **Rich Context**: Capture what was actually done
- **Examples**: "Lord of the Rings", "30 minutes", "Morning run"

### **Details Input Flow**
- **Tap Positive Habit**: Details input sheet appears
- **Dynamic Title**: "What did you do for [Habit Name]?"
- **Helpful Examples**: Shows common detail patterns
- **Flexible Entry**: Multi-line text input with examples

### **Calendar Integration**
- **Visual Display**: Details shown in calendar cells
- **Smart Layout**: Day number → Status dot → Details text
- **Responsive Design**: Calendar cells expand to show details
- **Contextual**: Only shows details when available

### **Search & Filtering**
- **Real-time Search**: "Search details..." bar in History view
- **Case Insensitive**: Finds matches regardless of case
- **Calendar Filtering**: Shows only matching entries
- **Clear Function**: Easy way to reset search

### **Use Cases**
- **Reading**: Track specific books, articles, or topics
- **Exercise**: Log workout types, duration, or intensity
- **Learning**: Record subjects, courses, or skills
- **Meditation**: Note techniques, duration, or focus areas

---

## 🔍 Advanced Filtering System

### **Comprehensive Filter Options**
- **All**: Shows all entries across all metrics
- **All Habits**: Shows only positive habit entries
- **All Vices**: Shows only vice entries  
- **Specific Metric**: Shows entries for a selected metric
- **Visual Indicators**: Icons and colors for each filter type
- **Consistent UI**: Same filtering across History and Charts views

### **Smart Content Filtering**
- **Content Validation**: Only shows entries with meaningful content
- **Duplicate Prevention**: Prevents multiple empty entries for same day
- **Data Cleanup**: Automatic removal of empty/meaningless entries
- **Performance Optimization**: Efficient filtering and display

### **Filter Integration**
- **Calendar View**: Filter affects calendar display and search
- **Charts View**: All chart types respect selected filters
- **List View**: Recent entries list updates with filter changes
- **Real-time Updates**: Immediate visual feedback on filter changes

---

## 📝 Entry Management System

### **Editable Entry Cells**
- **Visual Design**: Clean card layout with rounded corners
- **Entry Information**: Date, status, metric name, and content
- **Status Icons**: Color-coded success/failure indicators
- **Edit Button**: Pencil icon to open editing interface
- **Content Display**: Shows details and motivations appropriately

### **Comprehensive Editing Interface**
- **Full-Screen Modal**: Clean editing experience
- **Contextual Fields**: Different fields for habits vs vices
- **Smart Labels**: Dynamic text based on habit type
- **Value Toggle**: Switch between done/skipped or avoided/did it
- **Details Editing**: Multi-line text input for habit details
- **Motivation Editing**: Multi-line text input for vice motivations
- **Data Persistence**: Immediate save to database

### **Data Storage Improvements**
- **Duplicate Prevention**: `getOrCreate` method ensures one entry per day
- **Content Validation**: `hasContent` property checks for meaningful data
- **Unified Management**: `updateOrCreate` method for consistent updates
- **Automatic Cleanup**: `cleanupEmptyEntries` removes meaningless data
- **Performance Optimization**: Fewer database queries and cleaner data
- **✅ Implemented**: All entry creation functions now use unified storage methods
- **✅ Implemented**: Automatic cleanup on app launch removes existing duplicates
- **✅ Implemented**: Consistent behavior across HomeView, MotivationView, and AddMetricView

---

## 💭 Motivation System

### **Personal Reasons Library**
- **Vice-Specific**: Only available for vices, not positive habits
- **Personal Reflections**: Users write their own reasons for avoiding vices
- **Emotional Connection**: More powerful than generic goal-setting
- **Historical Context**: Build a library of personal motivations over time

### **Dedicated Entry Point**
- **Motivation Tab**: Dedicated "+" button for adding motivations
- **Flexible Timing**: Add motivations anytime, not tied to daily logging
- **Separate from Logging**: Motivation entry doesn't affect daily toggle status
- **Clean Home Screen**: Daily logging interface stays focused and uncluttered

### **Social Media-Style Feed**
- **Instagram/Twitter Layout**: Familiar card-based interface
- **Visual Indicators**: Green checkmarks for successes, red X's for failures
- **Time Context**: "Monday • 3 days ago" style timestamps
- **Filtering**: View all motivations or filter by specific vice
- **Color Coding**: Green accent for successes, red accent for failures

### **Smart UI Design**
- **Clear Separation**: Daily toggle vs motivation entry are distinct actions
- **No Confusion**: Users can safely interact with vice rows
- **Focused Interface**: Home screen dedicated to daily logging only
- **Dedicated Space**: Motivation features have their own dedicated tab

---

## 📊 Visualization Features

### **Implemented Visualizations**
- 📈 **Line Charts**: Adherence trends over time
- 📊 **Bar Charts**: Completion rates per week/month
- 🟩 **Heatmap**: Calendar-style success/failure grid
- 🔥 **Streak Tracker**: Current and longest streaks
- 🎯 **Goal Progress**: Monthly/yearly completion bars

### **Smart Visual Indicators**
- Green checkmarks for positive habits
- Red X icons for vices
- Color-coded progress bars
- Contextual streak displays

---

## 🚀 Future Enhancements

### **Settings & Customization Features**
- 🎨 **Light/Dark Mode Toggle**: System theme preference
- 🖼 **Custom App Icons**: Multiple icon options for personalization
- 💝 **Donate Button**: Support development with in-app donations
- 📊 **Export Graphs**: Save charts as images (PNG/PDF)
- 📤 **Share App**: Native iOS sharing for app promotion
- 🔄 **Data Import**: Import data from other habit tracking apps
- 📱 **Backup & Restore**: iCloud backup with restore functionality

### **Phase 2 Features**
- ⏰ **Smart Notifications**: Context-aware reminders
- 🖼 **Home Screen Widgets**: Quick daily check-ins
- ⌚ **Apple Watch App**: Companion for quick logging
- ☁️ **iCloud Sync**: Cross-device data synchronization
- ✅ **Data Export**: JSON export for analysis (IMPLEMENTED)

### **Phase 3 Features**
- 🏆 **Achievement System**: Badges for milestones
- 📊 **Advanced Analytics**: Year-over-year comparisons
- 🎨 **Theme Customization**: Color schemes and visual themes
- 📈 **Predictive Analytics**: Success probability based on patterns

### **Advanced Features**
- 📱 **Shortcuts Integration**: Siri voice logging
- 🔔 **Smart Reminders**: ML-based optimal timing
- 👥 **Social Features**: Share progress (optional)
- 🔐 **Privacy Controls**: Granular data sharing permissions

---

## 🛠 Technical Implementation

### **Tech Stack**
- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Data persistence with migration support
- **Swift Charts**: Native data visualization
- **iOS 17+**: Required for SwiftData and latest features

### **Architecture**
- **MVVM Pattern**: Clean separation of concerns
- **SwiftData Models**: Automatic persistence management
- **Computed Properties**: Safe access to optional fields
- **Migration Support**: Backward compatibility for existing data

### **Key Technical Features**
- **Optional Habit Types**: Safe migration from existing data
- **Smart Calculations**: Context-aware progress tracking
- **Dynamic UI**: Text and behavior adapts to habit type
- **Advanced Filtering**: Consistent filtering system across all views
- **Entry Management**: Unified entry creation and editing system
- **Data Validation**: Content checking and duplicate prevention
- **Performance**: Efficient data queries and updates
- **Memory Management**: Automatic cleanup of empty entries
- **✅ Storage System**: Fully implemented unified storage with duplicate prevention
- **✅ Data Integrity**: Automatic cleanup and validation on app launch

---

## 🎨 User Experience

### **Intuitive Design**
- Clear visual distinction between habit types
- Contextual messaging throughout the app
- Consistent iconography and color coding
- Native iOS design patterns

### **Accessibility**
- VoiceOver support for all elements
- Dynamic Type support
- High contrast mode compatibility
- Clear visual hierarchy

### **Onboarding**
- Simple habit/vice creation flow
- Clear explanations of tracking differences
- Example suggestions for each type
- Progressive disclosure of features

---

## 📋 Development Status

### **✅ Completed**
- Core data models with habit types and details
- Smart tracking logic implementation
- All six main views (Home, History, Goals, Charts, Motivation, Settings)
- Habit details system with calendar integration
- Goal management system with vice-specific logic
- Motivation system with social media-style feed
- Calendar search and filtering by details
- **Advanced filtering system** (All Habits, All Vices, specific metrics)
- **Entries list view** with editable past entries
- **Comprehensive entry editing** with full details and motivations
- **✅ Improved data storage** with duplicate prevention
- **✅ Content validation** and automatic cleanup
- **✅ Unified storage system** across all views
- **✅ Automatic cleanup** on app launch
- **✅ Settings view** with data export and deletion
- **✅ JSON data export** functionality
- **✅ Delete all data** with confirmation
- Visual indicators and UI updates
- Migration support for existing data
- Comprehensive documentation

### **🔄 In Progress**
- Advanced chart visualizations
- Performance optimizations
- Accessibility improvements

### **📋 Planned**
- **Settings Features**: Light/dark mode, custom app icons, donate button, export graphs, share app
- **Notification system**: Smart reminders and context-aware alerts
- **Widget implementation**: Home screen widgets for quick logging
- **Apple Watch companion**: Watch app for on-the-go tracking
- **iCloud synchronization**: Cross-device data sync
- **Advanced customization**: Themes, colors, and visual personalization

---

## 🎯 Success Metrics

### **User Engagement**
- Daily active users
- Streak maintenance rates
- Goal completion percentages
- Feature adoption rates

### **Technical Performance**
- App launch time
- Data query performance
- Memory usage optimization
- Crash-free sessions

### **User Satisfaction**
- App Store ratings
- User feedback analysis
- Feature request patterns
- Retention rates

---

---

## 🎨 Unique Selling Points

### **Innovative Features**
- **Dual Habit System**: First app to properly handle both positive habits and vices
- **Smart Tracking Logic**: Automatically adjusts based on habit type
- **Habit Details System**: Optional subtitles for rich context tracking
- **Motivation System**: Personal reasons library for vice avoidance
- **Social Media Experience**: Instagram-style motivation browsing
- **Calendar Search**: Find specific activities across time
- **Advanced Filtering**: Comprehensive filtering across all views
- **Editable History**: Full editing capabilities for past entries
- **✅ Smart Data Storage**: Duplicate prevention and content validation
- **✅ Unified Storage System**: Consistent entry management across all views
- **Visual Clarity**: Clear distinction between habit types and actions
- **Emotional Connection**: Personal motivations are more powerful than generic goals

### **User Experience Advantages**
- **No Confusion**: Clear separation between daily logging and motivation entry
- **Rich Context**: Track not just "what" but "what specifically"
- **Searchable History**: Find specific books, exercises, or activities
- **Flexible Workflow**: Add motivations and details anytime
- **Historical Context**: Build a library of personal motivations over time
- **Contextual UI**: Interface adapts to what you're tracking
- **Familiar Patterns**: Social media-style feed feels natural and engaging
- **Comprehensive Filtering**: Easy navigation between different habit types
- **Editable Past**: Correct mistakes and update historical data
- **✅ Clean Data**: No duplicate or empty entries cluttering the interface
- **✅ Reliable Storage**: Consistent behavior prevents data corruption
- **Consistent Experience**: Same filtering and editing across all views

---

*This specification reflects the current implementation as of the latest development cycle, including the innovative dual habit/vice tracking system and motivation features that set this app apart from traditional habit trackers.*

#### My Ideas - Sandbox area


* Mini-Game inside of the social media section (track how much they scroll / add a fidget section)
* I want to add a de-stressor / fidget to take mind off vices
 * I want to revamp the social media motivations view and maybe put a small lite idle game there to desress while you read your motivations; 
 
 In settings, change what is considered the start of the week. I think now it is Sunday, some people prefer other days (Saturday/Monday being the next most common)


Known Issues:
* What would happen if someone set a goal of 31 days / monthly and a month doesnt have 31 days?
    * Fixed. 
* Time zones