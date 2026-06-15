# Data Schema Specification

## 1. Purpose

Define canonical persisted entities, relationships, and invariants.

Authoritative field lists live here. Feature specs link back — do not duplicate full schemas.

---

## 2. Canonical Entities

### Metric

| Field | Type | Notes |
|-------|------|-------|
| `id` | UUID | Primary key |
| `name` | String | Display name |
| `createdAt` | Date | Creation timestamp |
| `habitType` | HabitType | `.positive` or `.vice` |
| `primaryMotivation` | String? | Set at creation for vices |
| `goals` | [Goal]? | Cascade relationship |
| `hasBeenLogged` | Bool | **Target:** user has ever logged this metric (default `false`) |

> **Implementation note:** `hasBeenLogged` is specified on `Metric` per [`TrackingSemanticsSpec.md`](TrackingSemanticsSpec.md). Current code partially implements on `MetricEntry` — migrate in Phase 1.

### MetricEntry

| Field | Type | Notes |
|-------|------|-------|
| `id` | UUID | Primary key |
| `metricID` | UUID | FK to Metric |
| `date` | Date | Start of day |
| `value` | Bool | See TrackingSemantics |
| `motivation` | String? | Daily motivation text |
| `starred` | Bool? | Primary motivation flag |
| `details` | String? | Habit detail subtitle |
| `quantity` | Int? | Quantity tracking |
| `unit` | String? | e.g. "minutes", "times" |

**Uniqueness invariant:** At most one entry per `(metricID, calendar day)`.

### Goal

| Field | Type | Notes |
|-------|------|-------|
| `id` | UUID | Primary key |
| `goalType` | GoalType | `.boolean` or `.quantity` |
| `period` | GoalPeriod | `.weekly`, `.monthly`, `.yearly` |
| `target` | Int | Target count |
| `quantityGoalType` | QuantityGoalType? | For quantity goals |
| `defaultUnit` | String? | Default unit for quantity |
| `maxDailyQuantity` | Int? | Vice max daily |
| `metric` | Metric? | Parent metric |

---

## 3. Enums

See `Models/Enums.swift`:

- `HabitType`: positive, vice
- `GoalPeriod`: weekly, monthly, yearly (no bi-weekly in 1.0)
- `GoalType`: boolean, quantity
- `QuantityGoalType`: maxDaily, avgDaily, totalPeriod

---

## 4. Invariants

1. One entry per metric per calendar day.
2. Deleting a metric deletes its goals (cascade) and all entries (explicit delete in ViewModel).
3. `hasBeenLogged == false` → streak display hidden; streak count = 0.
4. Empty entries (no content) are cleaned up on launch via `MetricEntry.cleanupEmptyEntries`.
5. `hasContent` requires: `value` meaningful for type, non-empty details/motivation, or quantity > 0.

---

## 5. Deletion and Retention

- **Delete metric:** Removes metric, goals, and all entries.
- **Delete all data:** See [`DeleteAllDataSpec.md`](DeleteAllDataSpec.md).
- **iCloud backup:** JSON snapshot; not live sync. See [`ExportImportSpec.md`](ExportImportSpec.md).

---

## 6. Testing

- Invariant validator tests per entity
- One-entry-per-day enforcement
- Cascade delete tests
- `hasBeenLogged` / streak boundary tests

---

## 7. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-14 |
| **Commit** | (current) |
| **Code** | `Models/Metric.swift`, `MetricEntry.swift`, `Goal.swift` |
