# TrackBoth

Quit vices. Build habits.

TrackBoth helps you quit what's hurting you and build what helps: a 10-second daily check-in, a tool for riding out urges, and progress a slip can't erase.

## Tabs

| Tab | What it's for |
|-----|----------------|
| **Today** | Check in, see days free, tick helper habits, open "I'm having an urge" |
| **Progress** | Saved, urges beaten, and a calendar per metric |
| **Settings** | Reminders, app lock, backup, and get help now |

1.0 is iPhone portrait. Screens are built so iPad and landscape can be added later without a redesign.

## Build and test

From `TrackBoth/` (the folder that contains `project.yml`):

```bash
xcodegen generate
```

```bash
xcodebuild build -project TrackBoth.xcodeproj -scheme TrackBothCI -destination 'platform=iOS Simulator,name=iPhone 17' CODE_SIGNING_ALLOWED=NO
```

```bash
xcodebuild test -project TrackBoth.xcodeproj -scheme TrackBoth -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:TrackBothTests CODE_SIGNING_ALLOWED=NO
```

```bash
xcodebuild test -project TrackBoth.xcodeproj -scheme TrackBoth -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:TrackBothUITests CODE_SIGNING_ALLOWED=NO
```

Requires Xcode 26. Do not hand-edit `TrackBoth.xcodeproj`.

## Layout

```
TrackBoth/TrackBoth/
├── App/            shell, router, lock gate
├── DesignSystem/   palette, type, components
├── Features/       Today, Check-in, Urge, Slip, Progress, Onboarding, Settings
├── Domain/         Foundation-only rules (inject now and calendar)
├── Data/           SwiftData models, RecoveryStore, backup
├── Services/       reminders, app lock, preferences
├── Support/        links, accessibility ids, debug surface
└── Resources/      assets, Info.plist, privacy manifest
```

The tree above is the target. During the overhaul, older folders remain until the cut phase removes them.

## Docs

| Doc | Purpose |
|-----|---------|
| [Specs/](Specs/) | Behavior contract |
| [docs/project-status.md](docs/project-status.md) | Where the app stands |
| [docs/feature-inventory.md](docs/feature-inventory.md) | What ships, what's cut |
| [ongoing/recovery-overhaul-plan.md](ongoing/recovery-overhaul-plan.md) | Approved implementation plan |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Project generation and tests |
