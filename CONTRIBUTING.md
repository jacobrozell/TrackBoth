# Contributing to TrackBoth

## Project generation

The Xcode project is generated from `TrackBoth/project.yml` via [XcodeGen](https://github.com/yonaskolb/XcodeGen). **Do not hand-edit** `TrackBoth.xcodeproj` — change `project.yml` or source folders, then regenerate:

```bash
cd TrackBoth
brew install xcodegen   # once
xcodegen generate
open TrackBoth.xcodeproj
```

## Schemes

| Scheme | Purpose |
|--------|---------|
| `TrackBoth` | Local dev — app, widget, run unit + UI tests |
| `TrackBothCI` | CI — builds app + both test targets (no test execution) |
| `TrackBothScreenshots` | App Store screenshots — seeds demo data, skips onboarding |

## App Store screenshots

1. Select the **TrackBothScreenshots** scheme in Xcode (or run with launch args `-skip_onboarding -screenshot_demo`).
2. Use iPhone 6.7" simulator (e.g. iPhone 16 Pro Max).
3. Capture Home (habits + vices visible), Goals, History, and Charts.

Regenerate the project after editing `project.yml`:

```bash
cd TrackBoth && xcodegen generate
```

## Running tests locally

```bash
cd TrackBoth

# Unit tests
xcodebuild test \
  -project TrackBoth.xcodeproj \
  -scheme TrackBoth \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:TrackBothTests

# UI tests (Phase 3+)
xcodebuild test \
  -project TrackBoth.xcodeproj \
  -scheme TrackBoth \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:TrackBothUITests
```

## CI

Pull requests run `.github/workflows/ci.yml` — XcodeGen + `TrackBothCI` build (app + test targets).

## Specs

Behavior changes require updating the matching spec in [`specs/`](../specs/) per [`specs/SpecGovernance.md`](../specs/SpecGovernance.md).

## Architecture (target)

- `Domain/` — pure logic, no SwiftUI/SwiftData
- `Features/` — MVVM screens
- `Data/` — repositories + SwiftData models
- See [`specs/ArchitectureSpec.md`](../specs/ArchitectureSpec.md)
