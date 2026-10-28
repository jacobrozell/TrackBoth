# Logging Specification

## 1. Purpose

Define structured logging for TrackBoth — replacing ad-hoc `print()` and noisy enum logging.

---

## 2. Lean 1.0 Scope

### In scope
- Protocol-based `AppLogger` with categories: `general`, `data`, `ui`, `network`, `business`
- **Release:** OSLog only
- **DEBUG:** verbose logging permitted
- SwiftLint rule: no `print()` in app target

### Out of scope (1.0)
- Firebase Crashlytics
- Remote log shipping

---

## 3. API (target)

Mirror Dart Buddy pattern:

```swift
protocol AppLogger {
    func debug(_ message: String, category: LogCategory)
    func info(_ message: String, category: LogCategory)
    func warn(_ message: String, category: LogCategory)
    func error(_ message: String, category: LogCategory)
}
```

Migrate from existing `Logger.swift` singleton.

---

## 4. Rules

- No logging in computed properties called frequently (e.g. `HabitType.displayName`).
- User actions: `logUserAction(_:details:)` at info level.
- Data mutations: debug level with metric ID, not full PII.
- Never log motivation text contents in Release.

---

## 5. Testing

- Logger does not crash on any level
- Redaction policy tests (when motivation logging is added)

---

## 6. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-14 |
| **Commit** | (current) |
| **Code** | `Utils/Services/Logger.swift` |
