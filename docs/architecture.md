# Architecture

## Layering
1. `WakeUpDomain`
- Business entities and protocol contracts.
- No framework coupling.

2. `WakeUpServices`
- Alarm scheduling calculator + in-memory scheduler.
- Wake challenge engine.
- Penalty evaluation and event creation.
- Sky scene state provider.
- Offline sync queue.
- Prototype in-memory store.

3. `WakeUpFeatures`
- App state routing.
- Onboarding/auth orchestration.
- Alarm editor/list state.
- Wake flow orchestration.
- Penalty ledger read model.

4. `WakeUpUI`
- SwiftUI screens and reusable visual components.
- Dynamic sky background rendering.
- Haptic service adapter.

## Data Flow
1. UI actions call feature view models.
2. View models call services/store actors.
3. Services compute triggers/challenge/penalty outcomes.
4. Store persists in-memory prototype state.
5. Sync queue buffers outbound events for online flush.

## Backend Mapping (Planned Firebase)
- Auth providers: Google + Apple.
- Firestore collections: users, recipients, alarms, sessions, penalties, consents.
- Cloud Functions: wake session record, penalty evaluation, ledger append, alarm sync.

## Security and Consent
- Per-alarm consent record is created before activation.
- Biometric preference is modeled for settings lock integration.
- Ledger records are append-only at API layer (to be enforced by backend rules).
