# Service Interfaces

## AuthServiceProtocol
- `signInWithGoogle() async throws -> AuthSession`
- `signInWithApple() async throws -> AuthSession`
- `signOut() async throws`

## AlarmSchedulerProtocol
- `schedule(_ rule: AlarmRule) async throws`
- `cancel(alarmId: UUID) async throws`
- `reschedule(alarmId: UUID) async throws`

## WakeChallengeEngineProtocol
- `startChallenge(type: ChallengeType)`
- `evaluate(_ input: ChallengeInput) -> Bool`
- `isPassed: Bool`

## PenaltyEngineProtocol
- `evaluateTrigger(session: AlarmSession, evaluatedAt: Date) -> PenaltyReason?`
- `createSimulatedPenalty(eventInput: PenaltyEventInput) -> PenaltyEvent`

## SkySceneProviderProtocol
- `currentSkyState(date: Date, location: GeoLocation?) -> SkyState`
- `animatedLayers(for skyState: SkyState) -> [SkyLayer]`

## SyncQueueProtocol
- `enqueue(_ event: SyncEvent)`
- `flushWhenOnline(isOnline: Bool) -> [SyncEvent]`
