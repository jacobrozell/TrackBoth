# Contributing to TrackBoth

## Project generation

The Xcode project is generated from `TrackBoth/project.yml` via [XcodeGen](https://github.com/yonaskolb/XcodeGen). **Do not hand-edit** `TrackBoth.xcodeproj`. Change `project.yml` or source folders, then regenerate:

```bash
cd TrackBoth
brew install xcodegen   # once
xcodegen generate
open TrackBoth.xcodeproj
```

## Schemes

| Scheme | Purpose |
|--------|---------|
| `TrackBoth` | Local dev — run the app and unit + UI tests |
| `TrackBothCI` | CI — builds the app and both test targets |
| `TrackBothScreenshots` | App Store screenshots — `-skip_onboarding -seed_demo -ui_testing` |

## Running tests locally

```bash
cd TrackBoth

xcodebuild test \
  -project TrackBoth.xcodeproj \
  -scheme TrackBoth \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:TrackBothTests \
  CODE_SIGNING_ALLOWED=NO

xcodebuild test \
  -project TrackBoth.xcodeproj \
  -scheme TrackBoth \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:TrackBothUITests \
  CODE_SIGNING_ALLOWED=NO
```

## Specs

Behavior changes require updating the matching spec in [`Specs/`](Specs/) in the same commit. See [`Specs/README.md`](Specs/README.md).

## Architecture

- `Domain/` — pure Foundation. Pass `now` and `calendar` in. Tests use `Calendar.testNY`.
- `Data/` — SwiftData models and `RecoveryStore`, the only place that writes.
- `Features/` — SwiftUI screens. Reads may use `@Query`. Writes go through the store.
- No new packages, analytics, or network calls.
