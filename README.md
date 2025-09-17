# TrackBoth - Boolean Habit Tracker

A SwiftUI/SwiftData prototype for tracking positive habits and avoiding vices with visualizations and goal tracking.

## Features

✅ **Core Features**
- Custom habit and vice creation and management
- Daily yes/no logging with toggle interface
- Smart tracking: positive habits (days done) vs vices (days avoided)
- SwiftData persistence
- Visual progress tracking with Swift Charts

📱 **Views**
- **Home**: List of habits and vices with daily toggles and streak tracking
- **History**: Calendar view showing completion history
- **Goals**: Set and track monthly/yearly goals with progress bars
- **Charts**: Multiple visualization types (line, bar, heatmap) plus streak stats

## Tech Stack

- **SwiftUI** - Modern declarative UI framework
- **SwiftData** - Data persistence and model management
- **Swift Charts** - Data visualization
- **iOS 17+** - Required for SwiftData and latest SwiftUI features

## Getting Started

1. Open the project in Xcode 15+
2. Build and run on iOS 17+ simulator or device
3. Start by adding your first habit or vice from the Home tab
4. Toggle daily to build streaks (positive habits) or track clean days (vices)
5. Set goals and track progress over time

## Data Model

- **Metric**: Represents a habit or vice (name, type, creation date)
- **MetricEntry**: Daily log entries (date, boolean value)
- **Goal**: Targets for habits/vices (monthly/yearly, target count)

## Architecture

The app follows a simple MVVM pattern with SwiftData:
- Models define the data structure
- Views handle UI and user interaction
- SwiftData manages persistence automatically

## Future Enhancements

- Notifications and reminders
- Apple Watch companion
- iCloud sync
- Data export/import
- Achievement system
