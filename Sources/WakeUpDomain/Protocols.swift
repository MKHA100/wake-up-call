import Foundation

public protocol AuthServiceProtocol: Sendable {
    func signInWithGoogle() async throws -> AuthSession
    func signInWithApple() async throws -> AuthSession
    func signOut() async throws
}

public protocol AlarmSchedulerProtocol: Sendable {
    func schedule(_ rule: AlarmRule) async throws
    func cancel(alarmId: UUID) async throws
    func reschedule(alarmId: UUID) async throws
}

public protocol WakeChallengeEngineProtocol: Sendable {
    mutating func startChallenge(type: ChallengeType)
    mutating func evaluate(_ input: ChallengeInput) -> Bool
    var isPassed: Bool { get }
}

public struct PenaltyEventInput: Sendable {
    public var userId: UUID
    public var alarmSessionId: UUID
    public var amount: Decimal
    public var recipientId: UUID
    public var reason: PenaltyReason

    public init(userId: UUID, alarmSessionId: UUID, amount: Decimal, recipientId: UUID, reason: PenaltyReason) {
        self.userId = userId
        self.alarmSessionId = alarmSessionId
        self.amount = amount
        self.recipientId = recipientId
        self.reason = reason
    }
}

public protocol PenaltyEngineProtocol: Sendable {
    func evaluateTrigger(session: AlarmSession, evaluatedAt: Date) -> PenaltyReason?
    func createSimulatedPenalty(eventInput: PenaltyEventInput) -> PenaltyEvent
}

public protocol SkySceneProviderProtocol: Sendable {
    func currentSkyState(date: Date, location: GeoLocation?) -> SkyState
    func animatedLayers(for skyState: SkyState) -> [SkyLayer]
}

public protocol SyncQueueProtocol: Sendable {
    mutating func enqueue(_ event: SyncEvent)
    mutating func flushWhenOnline(isOnline: Bool) -> [SyncEvent]
}
