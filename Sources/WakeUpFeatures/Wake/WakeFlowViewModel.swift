import Combine
import Foundation
import WakeUpDomain
import WakeUpServices

@MainActor
public final class WakeFlowViewModel: ObservableObject {
    @Published public private(set) var session: AlarmSession
    @Published public private(set) var secondsRemaining: Int
    @Published public private(set) var penaltyEvent: PenaltyEvent?
    @Published public private(set) var encouragementMessage: String?

    private var challengeEngine: WakeChallengeEngine
    private let userId: UUID
    private let alarm: AlarmRule
    private let store: PrototypeStore
    private let penaltyEngineService: PenaltyEngine
    private let scheduler: LocalAlarmScheduler

    public init(
        userId: UUID,
        alarm: AlarmRule,
        scheduledAt: Date,
        store: PrototypeStore,
        penaltyEngineService: PenaltyEngine,
        scheduler: LocalAlarmScheduler
    ) {
        let challengeType: ChallengeType = Int.random(in: 0...1) == 0 ? .tapSequence : .reactionTest
        let timeoutAt = scheduledAt.addingTimeInterval(TimeInterval(alarm.wakeWindowSeconds))
        self.session = AlarmSession(alarmId: alarm.id, scheduledAt: scheduledAt, firedAt: Date(), challengeType: challengeType, timeoutAt: timeoutAt)
        self.secondsRemaining = alarm.wakeWindowSeconds
        self.challengeEngine = WakeChallengeEngine()
        self.userId = userId
        self.alarm = alarm
        self.store = store
        self.penaltyEngineService = penaltyEngineService
        self.scheduler = scheduler

        challengeEngine.startChallenge(type: challengeType)
    }

    public func start() async {
        await store.addSession(session)
    }

    public func slideToDismiss(now: Date = Date()) async {
        session.dismissedAt = now
        session.challengeResult = .inProgress
        await store.updateSession(session)
    }

    public func submitChallenge(_ input: ChallengeInput, now: Date = Date()) async {
        let passed = challengeEngine.evaluate(input)
        session.challengeResult = passed ? .passed : .failed
        secondsRemaining = max(0, Int(session.timeoutAt.timeIntervalSince(now)))
        if passed {
            encouragementMessage = "Alright mate, you are up and ready to go. Let's make the most of the day!"
        }
        await store.updateSession(session)
    }

    public func snooze(now: Date = Date()) async {
        session.snoozedAt = now
        await evaluatePenaltyAndScheduleRetry(now: now)
    }

    public func tick(now: Date = Date()) async {
        secondsRemaining = max(0, Int(session.timeoutAt.timeIntervalSince(now)))
        if session.challengeResult != .passed, now >= session.timeoutAt {
            await evaluatePenaltyAndScheduleRetry(now: now)
        }
    }

    private func evaluatePenaltyAndScheduleRetry(now: Date) async {
        guard penaltyEvent == nil else { return }

        guard let reason = penaltyEngineService.evaluateTrigger(session: session, evaluatedAt: now) else {
            return
        }

        let event = penaltyEngineService.createSimulatedPenalty(
            eventInput: PenaltyEventInput(
                userId: userId,
                alarmSessionId: session.id,
                amount: alarm.penaltyAmount,
                recipientId: alarm.recipientId,
                reason: reason
            )
        )
        penaltyEvent = event
        await store.addPenalty(event)

        if let retry = AlarmScheduleCalculator.nextRetryDate(
            after: now,
            retryPolicy: alarm.retryPolicy,
            currentRetryCount: session.retryCount
        ) {
            session.retryCount += 1
            session.scheduledAt = retry
            session.timeoutAt = retry.addingTimeInterval(TimeInterval(alarm.wakeWindowSeconds))
            session.challengeResult = .notStarted
            session.snoozedAt = nil
            challengeEngine.startChallenge(type: session.challengeType)
            _ = try? await scheduler.reschedule(alarmId: alarm.id)
            await store.updateSession(session)
        }
    }
}
