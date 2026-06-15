# Tech Stack and Dependencies Specification

## 1. Purpose

Define the concrete technical stack for TrackBoth lean 1.0.0.

---

## 2. Core Stack

| Layer | Choice |
|-------|--------|
| Language | Swift 5.10+ |
| UI | SwiftUI |
| Persistence | SwiftData |
| Charts | Swift Charts (Apple framework) |
| Cloud backup | CloudKit via `iCloudBackupService` |
| Testing | XCTest (unit + UI); Swift Testing optional |
| Min deployment | iOS 17+ (SwiftData requirement) |

All core functionality uses Apple-native frameworks. **No required external SPM packages** for 1.0.

---

## 3. SPM Dependency Policy

### Required External Packages (1.0.0)
- **None**

### Approved Optional (tooling only)
- SwiftLint — CI/dev workflow
- XcodeGen — project generation (Phase 0)

Hard rule: do not add runtime packages unless there is a concrete gap not covered by Apple frameworks.

---

## 4. Out of Scope for 1.0

| Technology | Status |
|------------|--------|
| WidgetKit / App Groups | Post-1.0 (1.1) |
| watchOS / WatchConnectivity | Post-1.0 (1.2) |
| UserNotifications | Post-1.0 |
| App Intents / Shortcuts | Post-1.0 |
| Firebase / Crashlytics | Optional post-1.0; OSLog minimum for 1.0 |

---

## 5. Project Configuration

- Primary target: `TrackBoth`
- Widget extension: **excluded from Release scheme** for 1.0
- Bundle ID: `com.jacobrozell.TrackBoth`
- Versioning: `MARKETING_VERSION` + `CURRENT_PROJECT_VERSION` aligned across targets

---

## 6. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-14 |
| **Commit** | (current) |
| **Code** | `TrackBoth.xcodeproj/project.pbxproj` |
