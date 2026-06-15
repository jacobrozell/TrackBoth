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

1. Install [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`
2. Generate the Xcode project and open it:

```bash
cd LifeMetrics
xcodegen generate
open TrackBoth.xcodeproj
```

3. Build and run on iOS 18+ simulator or device
4. See [`CONTRIBUTING.md`](CONTRIBUTING.md) for schemes, tests, and CI

## Data Model

- **Metric**: Represents a habit or vice (name, type, creation date)
- **MetricEntry**: Daily log entries (date, boolean value)
- **Goal**: Targets for habits/vices (monthly/yearly, target count)

## Architecture

The app follows a simple MVVM pattern with SwiftData:
- Models define the data structure
- Views handle UI and user interaction
- SwiftData manages persistence automatically

## Documentation

- **Specs (authoritative):** [`specs/README.md`](specs/README.md)
- **Lean 1.0 plan:** [`docs/release/lean-1.0-master-plan.md`](docs/release/lean-1.0-master-plan.md)
- **Feature inventory:** [`docs/feature-inventory.md`](docs/feature-inventory.md)

Legacy drafts in `Specs/` (capital S) are deprecated — see [`Specs/README.md`](Specs/README.md).

## Future Enhancements (post-1.0)

See [`specs/planned/README.md`](specs/planned/README.md) — widgets, watch, notifications, achievements, etc.
