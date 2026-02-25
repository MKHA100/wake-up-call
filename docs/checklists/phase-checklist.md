# Phase Checklist

## Phase 0: Repo and Process
- [x] Package scaffold established.
- [x] Branch strategy documented (`main`, `dev`, `feature/*`).
- [x] CI workflow added.

## Phase 1: Docs and Contracts
- [x] Requirements baseline.
- [x] Architecture doc.
- [x] ADR set.
- [x] Data contracts.

## Phase 2: App Skeleton and Design System
- [x] Domain/service/feature/UI modules.
- [x] Design tokens and dynamic background view.

## Phase 3: Auth and Profile
- [x] Auth service protocol and mock implementation.
- [x] Onboarding view model and UI.

## Phase 4: Alarm Domain and Scheduler
- [x] Alarm model and scheduler utility.
- [x] Sleep warning evaluator.
- [x] Alarm editor/list view models and UI.

## Phase 5: Wake Flow and Challenge Engine
- [x] Wake flow view model.
- [x] Slide-to-dismiss + challenge UI.

## Phase 6: Penalty and Retry
- [x] Penalty trigger engine.
- [x] Ledger model + view model.
- [x] Retry scheduling logic.

## Phase 7: Sky Engine
- [x] Local sky-state provider.
- [x] Animated sky background rendering.

## Phase 8: Hardening and QA
- [x] Build validation (`swift build --disable-sandbox`).
- [x] Deterministic check executable (`WakeUpChecks`).
- [ ] Firebase runtime integration wiring.
- [ ] Real iOS notification scheduling and entitlement setup.
- [ ] TestFlight packaging (requires full Xcode environment).
