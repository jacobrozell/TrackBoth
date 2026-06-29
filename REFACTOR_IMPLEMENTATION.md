# Refactor — Implementation Status

Companion to `REFACTOR_PLAN.md`. Tracks what has been applied to the code and what remains.

## Important environment constraint

The project references every source file explicitly in `TrackBoth.xcodeproj/project.pbxproj` (it does **not** use Xcode 16 synchronized folders). That means **adding, moving, or deleting files must go through Xcode** — editing the `.pbxproj` by hand without a compiler to catch mistakes risks a project that won't open. The work below is therefore split into:

- **Applied (build-safe):** in-file code changes only. No files added/moved/deleted, so the project is unchanged structurally and still builds.
- **Pending (do in Xcode):** anything that changes file membership or the folder tree.

Also: this work was prepared in a Linux environment with no iOS SDK, so changes were reviewed structurally, not compiled. **Build + run the test suite in Xcode after pulling.**

---

## Applied — Phase 1 keystone (the data boundary)

Highest-leverage change from the plan: give persistence a single, testable seam.

1. **`Domain/Data/EntryStore.swift`** — added `protocol EntryRepository`; `EntryStore` now conforms. Added `entry(for:on:)` and `getOrCreate(for:on:)`, moving the get-or-create persistence logic out of the `MetricEntry` model and into the store (the store now fetches the day's entry from the database rather than relying on a pre-fetched array).
2. **`Domain/Data/MetricStore.swift`** — added `protocol MetricRepository`; `MetricStore` now conforms.
3. **`ViewModels/HomeViewModel.swift`** — `updateMetricEntry(...)` now routes through `EntryStore.getOrCreate`, with a fallback to the legacy `MetricEntry.getOrCreate` so behavior is unchanged if a fetch ever fails.

All three are additive/internal — nothing existing was removed, so the build is preserved. The legacy `MetricEntry.getOrCreate` static helper is intentionally left in place for now because archived files still call it; it gets deleted in Phase 0 (see below).

## Prepared but NOT yet in the build

- **`Tests/Unit/Fakes/InMemoryRepositories.swift`** — `InMemoryEntryRepository` and `InMemoryMetricRepository` for fast view-model tests. The file is on disk but is **not a member of any target**, so it does nothing until added. To activate: in Xcode, select the file → File Inspector → Target Membership → check **TrackBothTests**. Then view models can be tested against fakes instead of a live `ModelContext`.

---

## Pending — Xcode-side steps, in order

### Phase 0 — Cut dead weight (do this first; it removes code you'd otherwise migrate)
1. In Xcode, delete the **`Archive/`** group (Watch app + `UnifiedMetricRowView`, ~1,550 LOC) → *Move to Trash*.
2. After Archive is gone, delete the now-unused legacy helpers `MetricEntry.getOrCreate` / `updateOrCreate` from `Models/MetricEntry.swift` (the repository replaces them) and remove the fallback branch in `HomeViewModel.updateMetricEntry`.
3. Delete the `Tabs/HomeView.swift` shim (it only returns `TrackScreen()`; `ContentView` already calls `TrackScreen` directly).
4. Remove `tmp/`, `TODOs/`, `FutureIdeas/`, `ongoing/` from the compiled target (keep in repo root if useful, but not in the app group).

### Phase 1 finish
5. Add `Tests/Unit/Fakes/InMemoryRepositories.swift` to the **TrackBothTests** target (above).
6. Add a `GoalStore` + `GoalRepository` mirroring the other two (goals persistence currently lives in views/`GoalsViewModel`).
7. Sweep the ~17 views using `@Query` / `modelContext.insert|delete` directly and route them through the repositories via their feature view model.

### Phase 2 — Composition root & DI
8. Add `App/AppContainer.swift` (builds the `ModelContainer` + repositories, injects via `@Environment`).
9. Convert `ThemeManager` from `.shared` singleton to a container-owned, environment-injected instance.
10. Add `App/AppRouter.swift` (`@Observable`) and replace the `AppEvent`/`NotificationCenter` plumbing in `ContentView` — including the `DispatchQueue.asyncAfter(0.35)` add-metric hack — with synchronous router state.

### Phase 3 — Feature migration (one tab at a time: Settings → History → Goals → Motivation → Insights)
11. For each, create `Features/<Name>/{Screen, <Name>ViewModel, Components/, Layouts/}`, move the view out of `Tabs/`, remove direct data access, and split the god files (`SettingsView` 555 LOC, `AddGoalView` 504, `QuantityInputSheet` 454) into focused subviews. Track is already the reference pattern.

### Phases 4–6
Design-system consolidation, lint/CI boundary enforcement, then optional SPM local packages — as described in `REFACTOR_PLAN.md`.

---

## Verification checklist (run in Xcode after each step)
- [ ] Project builds (all targets: app, widget, tests).
- [ ] `TrackBothTests` passes — especially `EntryStoreTests`, `HomeViewModelTests`.
- [ ] Add/toggle/log a metric still persists across relaunch.
- [ ] Widget still updates after logging.
