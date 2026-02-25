# Requirements Baseline

## Product Goal
Build a modern iOS alarm app that penalizes wake failures by creating simulated transfer events to selected recipients.

## Core Functional Requirements
1. User can sign in with Google or Apple.
2. User can set sleep target hours manually.
3. User can manage recipients (custom + preset charities).
4. User can create one-time or repeating alarms.
5. Alarm stores fixed per-alarm penalty amount and recipient.
6. App shows warning when remaining sleep time is below target.
7. Alarm wake flow requires slide-to-dismiss and challenge completion.
8. Challenge engine supports tap-sequence and reaction test.
9. Penalty event is triggered when user snoozes or times out.
10. Retry re-rings every 5 minutes up to 3 retries.
11. Penalty records are simulated only (no real transfer).
12. User can toggle theme pack + light/dark/auto mode.
13. Dynamic sky background reflects time-of-day segment.
14. App can operate wake flow offline and sync when online.

## Non-Functional Requirements
1. iOS 15+ baseline.
2. SwiftUI-first UI architecture.
3. Clean architecture with separable domain/services/features/UI layers.
4. Deterministic checks must run in CI for each branch.
5. Branch workflow: `main` + `dev` + `feature/*`.
