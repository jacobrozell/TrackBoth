# SwiftData Persistence Specification

## 1. Purpose

Define SwiftData container bootstrap, schema composition, and migration policy for TrackBoth.

Complements [`DataSchemaSpec.md`](DataSchemaSpec.md) (entity invariants).

---

## 2. Schema (Lean 1.0)

Registered models in `TrackBothApp.sharedModelContainer`:

- `Metric`
- `MetricEntry`
- `Goal`

No versioning enum yet — lean 1.0 uses implicit schema. **Before App Store:** introduce `VersionedSchema` if any field changes ship to existing users.

---

## 3. Container Bootstrap

```
TrackBothApp
  └─ ModelContainer(for: Metric.self, MetricEntry.self, Goal.self)
       ├─ success → ContentView
       └─ failure → in-memory fallback (warn) → fatalError if that fails
```

**Target (Phase 4):** Replace fatalError path with `MigrationRecoveryView` per [`MigrationRecoverySpec.md`](MigrationRecoverySpec.md).

---

## 4. Migration Policy

| Change type | Policy |
|-------------|--------|
| Add optional field with default | Lightweight migration (SwiftData automatic) |
| Rename / delete field | Versioned schema + migration plan |
| Semantic change (e.g. `hasBeenLogged` on Metric) | Migration script + `MigrationUtils` |

On every launch (required):

```swift
MigrationUtils.runMigrationIfNeeded(in: modelContext)
```

---

## 5. Relationship Rules

- `Metric` → `Goal` (cascade delete)
- `MetricEntry` references `Metric` by `metricID` (UUID, not `@Relationship`)
- Deleting a `Metric` must delete all `MetricEntry` rows for that `metricID`

---

## 6. Testing

- In-memory `ModelContainer` for unit/integration tests
- Migration idempotency tests
- Cascade delete tests

---

## 7. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-14 |
| **Commit** | (current) |
| **Code** | `TrackBothApp.swift`, `Models/*.swift`, `MigrationUtils.swift` |
