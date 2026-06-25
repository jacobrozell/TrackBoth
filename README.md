# TrackBoth — Habits & Vices

A SwiftUI/SwiftData app for tracking positive habits and avoiding vices in one daily log — streaks, goals, charts, and personal motivations in a single place.

**Status:** Pre-ship RC · v1.0.0 (build 3) · **Free** · **Branch:** `main`

Product behavior: [`specs/`](specs/) · Shipped features: [`docs/feature-inventory.md`](docs/feature-inventory.md) · Release gate: [`docs/release/1.0.0-ship-checklist.md`](docs/release/1.0.0-ship-checklist.md)

---

## What it does (1.0)

- **Track** — One-tap daily logging for habits and vices; hero streaks; goal progress on rows; milestone banners
- **History** — Calendar, entry list, edit past logs
- **Motivation** — Personal reasons to stay accountable (vice-focused)
- **Charts** — Line, bar, and heatmap progress views (Swift Charts)
- **Settings** — JSON export/import, themes, delete all data
- **Widget** — Home Screen widget extension (dev scheme `TrackBothWidget`)

Adaptive Track and History layouts ship device-specific UI for iPhone and iPad.

---

## Tech stack

| | |
|--|--|
| **UI** | SwiftUI + MVVM |
| **Persistence** | SwiftData (iOS 18+) |
| **Charts** | Swift Charts |
| **Project** | XcodeGen (`TrackBoth/project.yml`) |
| **Bundle** | `com.jacobrozell.trackboth` |

---

## Build & run

```bash
cd TrackBoth
brew install xcodegen   # once
xcodegen generate
open TrackBoth.xcodeproj
```

Select the **TrackBoth** scheme on an iPhone 17 simulator (or device) and press **⌘R**. Signing uses team `7JT2JB89AV`.

---

## Schemes

| Scheme | Use |
|--------|-----|
| `TrackBoth` | Local dev — app, widget, run unit + UI tests |
| `TrackBothCI` | CI — builds app + test targets |
| `TrackBothWidget` | Widget extension development |
| `TrackBothScreenshots` | App Store screenshots — seeds demo data, skips onboarding |

---

## Tests & CI

```bash
cd TrackBoth

# Unit tests
xcodebuild test \
  -project TrackBoth.xcodeproj \
  -scheme TrackBoth \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:TrackBothTests

# UI tests
xcodebuild test \
  -project TrackBoth.xcodeproj \
  -scheme TrackBoth \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:TrackBothUITests
```

Pull requests run `.github/workflows/ci.yml` — XcodeGen + `TrackBothCI` build.

---

## Architecture

```
Features/     SwiftUI + ViewModels (Track, History, Motivations, Charts, Settings)
Domain/       Pure logic — no SwiftUI/SwiftData imports
Data/         Repositories + SwiftData models
```

See [`specs/ArchitectureSpec.md`](specs/ArchitectureSpec.md) and [`CONTRIBUTING.md`](CONTRIBUTING.md).

---

## Documentation map

| Doc | Purpose |
|-----|---------|
| [`docs/project-status.md`](docs/project-status.md) | At-a-glance stage, version, focus |
| [`docs/release/progress-log.md`](docs/release/progress-log.md) | Lean 1.0 phase completion log |
| [`docs/release/1.0.0-ship-checklist.md`](docs/release/1.0.0-ship-checklist.md) | Pre-submit gate |
| [`docs/release/app-store-copy.md`](docs/release/app-store-copy.md) | Listing copy |
| [`docs/feature-inventory.md`](docs/feature-inventory.md) | What ships vs dev-only |
| [`Specs/ProductSurfaceSpec.md`](Specs/ProductSurfaceSpec.md) | Release gating matrix |
| [`FutureIdeas/ProductUXHandoff.md`](FutureIdeas/ProductUXHandoff.md) | Ship decisions + backlog |

---

## Legal (hosted)

GitHub Pages from `/docs` on branch `main`:

- [Privacy](https://jacobrozell.github.io/TrackBoth/privacy.html)
- [Support](https://jacobrozell.github.io/TrackBoth/support.html)
- [Accessibility](https://jacobrozell.github.io/TrackBoth/accessibility.html)
