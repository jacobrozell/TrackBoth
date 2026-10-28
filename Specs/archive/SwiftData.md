# SwiftData Persistence Specification

## 1. Purpose

Define SwiftData container bootstrap, schema composition, and migration policy for TrackBoth.

Complements [`DataSchemaSpec.md`](DataSchemaSpec.md) (entity invariants).

**Pre-release baseline:** [`docs/release/1.0.0-schema-baseline.md`](../docs/release/1.0.0-schema-baseline.md) — locked schema for unreleased 1.0.0; no production migration yet.

---

## 2. Schema (Lean 1.0)

Registered models via `TrackBothSchemaV1`:

- `Metric` (includes `costPerUnit` for vice savings)
- `MetricEntry`
- `Goal`

---

## 3. Container Bootstrap

```
TrackBothApp
  └─ BootstrapStoreRecovery.makeContainer()
       ├─ local-only persistent (default)
       └─ in-memory fallback + MigrationRecoveryView banner
```

Never `fatalError` on store failure — fallback ladder per [`MigrationRecoverySpec.md`](MigrationRecoverySpec.md).

---

## 4. Migration Policy

**Pre-1.0.0:** TrackBoth has no App Store users. `TrackBothMigrationPlan` has empty stages. Launch-time `MigrationUtils` only backfills dev-era state (legacy cost UserDefaults, logged-status promotion). See [`docs/release/1.0.0-schema-baseline.md`](../docs/release/1.0.0-schema-baseline.md).

**Post-1.0.0:** Every breaking persisted change requires a new `VersionedSchema` and migration stages.

| Change type | Policy |
|-------------|--------|
| Add optional field with default | Lightweight migration (SwiftData automatic) |
| Rename / delete field | Versioned schema + migration plan |
| Semantic change (e.g. `hasBeenLogged` on Metric) | Migration script + `MigrationUtils` |
| Legacy UserDefaults `MetricCostStore` | One-time backfill to `Metric.costPerUnit` |

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
- `BootstrapStoreRecoveryTests` — container creation + fallback modes
- Migration idempotency tests
- Cascade delete tests

---

## 7. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-15 |
| **Commit** | (current) |
| **Code** | `TrackBothApp.swift`, `BootstrapStoreRecovery.swift`, `TrackBothSchema.swift`, `Models/*.swift`, `MigrationUtils.swift` |
