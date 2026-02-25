# Wake Up Call (iOS Prototype)

Wake Up Call is an iOS-first prototype that combines alarm accountability with a simulated penalty ledger.

## Implemented Prototype Scope
- Alarm domain model for one-time and repeating alarms.
- Wake flow model with slide-to-dismiss + challenge gating.
- Penalty trigger logic (`snooze OR timeout miss`).
- Simulated transfer ledger entries (no real payments).
- Google/Apple auth service interfaces with mock implementation.
- Dynamic sky view scaffolding with day/night transitions.
- Offline sync queue model and deterministic automated checks.

## Repository Workflow
- Integration branch: `dev`
- Feature branches: `feature/*`
- No direct work to `main`
- Meaningful commit messages required

## Build and Checks
This environment does not expose XCTest/Swift Testing modules, so deterministic check automation is included as an executable target.

```bash
HOME="$PWD/.home" \
SWIFTPM_MODULECACHE_OVERRIDE="$PWD/.build/ModuleCache.noindex" \
CLANG_MODULE_CACHE_PATH="$PWD/.build/ModuleCache.noindex" \
swift build --disable-sandbox
```

```bash
HOME="$PWD/.home" \
SWIFTPM_MODULECACHE_OVERRIDE="$PWD/.build/ModuleCache.noindex" \
CLANG_MODULE_CACHE_PATH="$PWD/.build/ModuleCache.noindex" \
swift run --disable-sandbox WakeUpChecks
```

## Project Layout
- `Sources/WakeUpDomain`: core entities and protocols.
- `Sources/WakeUpServices`: scheduling, challenges, penalties, sky provider, storage, sync queue.
- `Sources/WakeUpFeatures`: MVVM state and feature orchestration.
- `Sources/WakeUpUI`: SwiftUI screens, design system, dynamic sky background.
- `Sources/WakeUpPrototypeCLI`: CLI smoke bootstrap.
- `Sources/WakeUpChecks`: deterministic automated verification runner.
- `docs/`: requirements, architecture, ADRs, contracts, checklists.
