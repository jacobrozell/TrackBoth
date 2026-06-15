# Spec Governance

## 1. Purpose

Prevent spec drift, duplication conflicts, and ambiguous ownership so implementation agents have one clear source of truth.

---

## 2. Source-of-Truth Map

| Topic | Authoritative spec |
|-------|-------------------|
| Persistence models and migration policy | `specs/SwiftData.md`, `specs/DataSchemaSpec.md` |
| Architecture boundaries | `specs/ArchitectureSpec.md` |
| Runtime dependencies | `specs/TechStackSpec.md` |
| Habit/vice boolean rules, streaks, logged status | `specs/TrackingSemanticsSpec.md` |
| Logging | `specs/LoggingSpec.md` |
| Accessibility | `specs/AccessibilitySpec.md` |
| Lean 1.0 scope gating | `specs/ProductSurfaceSpec.md` |
| Feature UX and behavior | Feature specs in [`specs/README.md`](README.md) |
| Migration recovery UX | `specs/MigrationRecoverySpec.md` |
| Test policy | `specs/TestPlanSpec.md` |
| JSON export/import | `specs/ExportImportSpec.md` |
| Delete all data | `specs/DeleteAllDataSpec.md` |

If two specs disagree, the authoritative spec above wins.

---

## 3. Duplication Rules

- Do not duplicate full persistence field lists across multiple specs.
- Feature specs may include conceptual data snippets only with explicit link back to `DataSchemaSpec.md`.
- Prefer references over restating large sections.

### 3.1 Repo-level documentation (non-spec)

| Doc | Owns | Do not copy into |
|-----|------|------------------|
| `README.md` | Repo entry, build steps | Feature specs |
| `docs/release/lean-1.0-master-plan.md` | Phased release plan, timeline | Feature specs (link only) |
| `docs/feature-inventory.md` | Shipped / partial / planned register | Feature specs (behavior) |
| `TODOs/` | Legacy task lists | Superseded by specs + master plan for 1.0 |
| `Specs/` (legacy) | Historical drafts | Do not edit — migrate to `specs/` |

---

## 4. Change Management Rules

- **Schema field change** → update `SwiftData.md`, `DataSchemaSpec.md`, impacted feature specs.
- **Architecture boundary change** → update `ArchitectureSpec.md`, `RepositorySpec.md` if contracts affected.
- **Boolean/streak/logged-status change** → update `TrackingSemanticsSpec.md` and all feature specs that reference completion.
- **Lean 1.0 scope change** → update `ProductSurfaceSpec.md`, `docs/feature-inventory.md`, master plan.
- **User-visible feature behavior change** → update matching feature spec Verification block.

---

## 5. Pull Request Rules

1. **Behavior change** → update the authoritative feature spec.
2. **New screen or tab** → add row to `SpecGovernance.md` §6 and feature spec.
3. **Schema change** → `SwiftData.md` + `DataSchemaSpec.md` (no full field dumps in feature specs).
4. **Shipped / partial / planned status change** → `docs/feature-inventory.md` in same PR.
5. **Tracking semantics change** → `TrackingSemanticsSpec.md` + unit tests in same PR.

---

## 6. Feature Spec Coverage Checklist

Audit after major releases. Bump **Last verified** and **Commit** when behavior changes.

| Feature area | Spec | Primary code paths |
|--------------|------|-------------------|
| App shell | `AppShellSpec.md` | `TrackBothApp.swift`, `ContentView.swift` |
| Home | `HomeSpec.md` | `HomeView.swift`, `HomeViewModel.swift`, `CompactMetricRow.swift`, `LoggingSheet.swift` |
| Goals | `GoalsSpec.md` | `GoalsView.swift`, `GoalsViewModel.swift`, `GoalUtils.swift` |
| History | `HistorySpec.md` | `HistoryView.swift`, `HistoryViewModel.swift` |
| Charts | `ChartsSpec.md` | `ChartsView.swift`, `ChartsViewModel.swift` |
| Motivations | `MotivationsSpec.md` | `MotivationsView.swift`, `MotivationViewModel.swift` |
| Settings | `SettingsSpec.md` | `SettingsView.swift`, `SettingsViewModel.swift` |
| Onboarding | `OnboardingSpec.md` | `OnboardingView.swift` |
| Tracking semantics | `TrackingSemanticsSpec.md` | `Domain/Tracking/`, `StreakUtils.swift` |
| Data export | `ExportImportSpec.md` | `SettingsView.swift`, `iCloudBackupService.swift` |
| Delete all data | `DeleteAllDataSpec.md` | `SettingsView.swift`, `DemoDataGenerator.swift` |
| Migration recovery | `MigrationRecoverySpec.md` | `TrackBothApp.swift`, `MigrationUtils.swift` |
| Product surface | `ProductSurfaceSpec.md` | `Support/Release/ProductSurface.swift` |

---

## 7. Verification Block (required on feature specs)

Every feature spec ends with:

```markdown
## N. Verification
| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | YYYY-MM-DD |
| **Commit** | `abc1234` |
| **Code** | `PrimaryFile.swift`, … |
```

**Estimated release** = target App Store semver when users first get the feature. Post-1.0 specs use `1.1`, `1.2`, etc.

---

## 8. Agent Safety Checklist

Before implementation:

1. Confirm no conflict with authoritative specs.
2. If conflict exists, resolve spec first.
3. Document assumptions in PR notes when spec is silent.
4. After implementation, update feature spec Verification block, §6 row, and `docs/feature-inventory.md` when ship status changes.
