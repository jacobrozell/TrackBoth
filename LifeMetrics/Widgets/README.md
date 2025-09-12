# 🏠 QuickLog Home Screen Widgets

## Overview
QuickLog widgets provide quick access to habit tracking directly from the home screen, allowing users to log habits and view progress without opening the app.

## Widget Types

### 📊 Small Widget (2x2)
- **Purpose**: Quick progress overview
- **Content**: Today's completion count (e.g., "3/5 completed")
- **Interactions**: Tap to open app

### ⚡ Medium Widget (4x2)
- **Purpose**: Quick logging and progress
- **Content**: 
  - Progress bar showing today's completion
  - List of top 3 habits with toggle buttons
- **Interactions**: 
  - Tap habit buttons to log directly
  - Tap progress area to open app

### 📈 Large Widget (4x4)
- **Purpose**: Comprehensive dashboard
- **Content**:
  - Progress summary with stats
  - Complete habits list with streaks
  - Goal progress indicators
- **Interactions**:
  - Tap habits to log directly
  - Tap stats to open specific app sections

## Technical Implementation

### App Groups Setup
1. Add App Groups capability to main app target
2. Add App Groups capability to widget extension target
3. Use shared container: `group.com.quicklog.app`

### Data Sharing
- **UserDefaults**: Shared container for widget data
- **JSON Serialization**: Convert SwiftData models to JSON
- **Real-time Updates**: WidgetCenter.shared.reloadAllTimelines()

### Interactive Features (iOS 17+)
- **App Intents**: Direct habit logging from widget
- **Deep Links**: Open specific app sections
- **Button Actions**: Toggle habits without opening app

## Widget Data Models

### WidgetMetric
```swift
struct WidgetMetric {
    let id: String
    let name: String
    let habitType: String
    let isCompletedToday: Bool
    let streak: Int
}
```

### WidgetEntry
```swift
struct WidgetEntry {
    let metricID: String
    let value: Bool
    let quantity: Int?
    let unit: String?
}
```

## Setup Instructions

### 1. Create Widget Extension Target
1. File → New → Target
2. Select "Widget Extension"
3. Name: "QuickLogWidget"
4. Include Configuration Intent: No

### 2. Add App Groups
1. Select main app target
2. Signing & Capabilities → + Capability → App Groups
3. Add group: `group.com.quicklog.app`
4. Repeat for widget extension target

### 3. Configure Info.plist
- Add widget configuration to Info.plist
- Set supported families: small, medium, large
- Configure display name and description

### 4. Implement Data Sharing
- Use WidgetDataManager for data synchronization
- Update widget data when app data changes
- Handle widget timeline updates

## Widget Lifecycle

### Timeline Updates
- **Frequency**: Every 15 minutes
- **Triggers**: App data changes, user interactions
- **Policy**: .after(nextUpdate)

### Data Loading
- **Source**: Shared App Groups container
- **Format**: JSON serialized data
- **Fallback**: Placeholder data for previews

### Performance
- **Memory**: Limited to 16MB
- **CPU**: Background processing only
- **Network**: Minimal data usage

## User Experience

### Design Principles
- **Glanceable**: Information at a glance
- **Actionable**: Direct interactions where possible
- **Consistent**: Matches app design language
- **Responsive**: Adapts to different sizes

### Accessibility
- **VoiceOver**: Full accessibility support
- **Dynamic Type**: Respects user font size
- **High Contrast**: Supports accessibility settings

## Future Enhancements

### Planned Features
- **Customizable Widgets**: User-selectable habits
- **Smart Suggestions**: AI-powered habit recommendations
- **Complications**: Apple Watch support
- **Live Activities**: Real-time progress updates

### Advanced Interactions
- **Swipe Gestures**: Quick actions
- **Long Press**: Context menus
- **Haptic Feedback**: Tactile responses

## Troubleshooting

### Common Issues
1. **Widget not updating**: Check App Groups configuration
2. **Data not syncing**: Verify shared container access
3. **Interactions not working**: Check App Intents setup
4. **Performance issues**: Optimize data serialization

### Debug Tips
- Use WidgetKit simulator for testing
- Check console logs for errors
- Verify data format compatibility
- Test on different device sizes

## Resources

### Apple Documentation
- [WidgetKit Framework](https://developer.apple.com/documentation/widgetkit)
- [App Intents Framework](https://developer.apple.com/documentation/appintents)
- [App Groups](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups)

### Design Guidelines
- [Human Interface Guidelines - Widgets](https://developer.apple.com/design/human-interface-guidelines/widgets)
- [Widget Design Best Practices](https://developer.apple.com/design/human-interface-guidelines/widgets/overview)
