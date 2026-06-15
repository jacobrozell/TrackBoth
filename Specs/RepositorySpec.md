# Repository Specification

## 1. Purpose

Define data access protocols between features and SwiftData. Enables unit tests with in-memory doubles.

---

## 2. Protocols (target — Phase 2)

```swift
protocol MetricRepository {
    func fetchAll() throws -> [Metric]
    func save(_ metric: Metric) throws
    func delete(_ metric: Metric, entries: [MetricEntry]) throws
}

protocol EntryRepository {
    func fetch(for metricID: UUID) throws -> [MetricEntry]
    func entry(for metricID: UUID, on date: Date) throws -> MetricEntry?
    func save(_ entry: MetricEntry) throws
    func delete(_ entry: MetricEntry) throws
}

protocol GoalRepository {
    func fetch(for metric: Metric) throws -> [Goal]
    func save(_ goal: Goal) throws
    func delete(_ goal: Goal) throws
}
```

---

## 3. Implementation Rules

- SwiftData implementations live in `Data/Repositories/`.
- ViewModels receive repositories via init (or environment wrapper post-bootstrap).
- Views never call `modelContext` directly — only ViewModels and repositories.
- **Lean 1.0 pragmatism:** Existing `@Query` in views is acceptable short-term; new code uses repositories.

---

## 4. Testing

- In-memory `ModelContainer` backing each repository
- Contract tests: CRUD, cascade delete, one-entry-per-day

---

## 5. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-14 |
| **Commit** | (not implemented) |
| **Code** | Target: `Data/Repositories/` |
