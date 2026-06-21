# TrackBoth — Habits & Vices

A SwiftUI/SwiftData app for tracking positive habits and avoiding vices in one daily log.

**Stage:** Pre-ship RC · v1.0.0 (build 3) · **Free**

## Features (1.0)

- **Track** — One-tap daily logging; habits + vices; hero streaks; goal progress on rows; milestone banners
- **History** — Calendar, entry list, edit past logs
- **Motivation** — Personal reasons to stay accountable (vice-focused)
- **Charts** — Line, bar, heatmap progress views
- **Settings** — JSON export/import, themes, delete all data

## Tech Stack

- SwiftUI + SwiftData (iOS 18+)
- Swift Charts
- XcodeGen

## Getting Started

```bash
cd TrackBoth/TrackBoth
xcodegen generate
open TrackBoth.xcodeproj
```

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for schemes, tests, and CI.

## Documentation

| Doc | Purpose |
|-----|---------|
| [`docs/release/1.0.0-ship-checklist.md`](docs/release/1.0.0-ship-checklist.md) | Pre-submit gate |
| [`docs/release/app-store-copy.md`](docs/release/app-store-copy.md) | Listing copy |
| [`docs/feature-inventory.md`](docs/feature-inventory.md) | What ships vs dev-only |
| [`FutureIdeas/ProductUXHandoff.md`](FutureIdeas/ProductUXHandoff.md) | Ship decisions + backlog |
| [`Specs/ProductSurfaceSpec.md`](Specs/ProductSurfaceSpec.md) | Release gating matrix |

## Schemes

| Scheme | Use |
|--------|-----|
| `TrackBoth` | Run + test (Release archive) |
| `TrackBothWidget` | Widget extension development |
| `TrackBothScreenshots` | Screenshot demo data |
