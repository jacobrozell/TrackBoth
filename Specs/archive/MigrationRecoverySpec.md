# Migration Recovery Specification

## 1. Purpose

Define user-facing behavior when SwiftData container bootstrap or migration fails at launch.

Schema policy: [`SwiftData.md`](SwiftData.md). Shell routing: [`AppShellSpec.md`](AppShellSpec.md).

---

## 2. Lean 1.0 Scope

### In scope
- Full-screen recovery UI blocking tabs until bootstrap succeeds
- **Retry** — re-run container creation
- **Export diagnostics** — share error description + app version
- **Reset local data** — destructive wipe + fresh container (same end state as Settings delete)
- Never silent data wipe on first failure

### Out of scope (1.0)
- Partial field-level repair
- Automatic iCloud restore on failure

---

## 3. Bootstrap Flow (target)

```
TrackBothApp
  └─ bootstrap()
       ├─ .ready(container) → ContentView
       └─ .recovery(context) → MigrationRecoveryView
```

**Current state:** Falls back to in-memory container, then `fatalError`. Replace with recovery UI in Phase 4.

---

## 4. UI Specification

| Control | Role |
|---------|------|
| Title | "Couldn't load your data" |
| Message | Plain-language explanation |
| Retry | Re-attempt container open |
| Export | Share diagnostic text |
| Reset | Destructive — wipe local store |

No tab bar until recovery succeeds.

---

## 5. Data Safety

- Reset requires explicit confirmation
- Retry does not delete store
- Post-reset: empty app, onboarding may show

Related: [`DeleteAllDataSpec.md`](DeleteAllDataSpec.md)

---

## 6. Testing

- Simulated container failure → recovery UI appears
- Retry success path
- Reset converges with Settings delete all

---

## 7. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-14 |
| **Commit** | (not implemented) |
| **Code** | `TrackBothApp.swift`, `MigrationUtils.swift` |
