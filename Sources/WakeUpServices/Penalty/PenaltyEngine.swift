import Foundation
import WakeUpDomain

public struct PenaltyEngine: PenaltyEngineProtocol, Sendable {
    public init() {}

    public func evaluateTrigger(session: AlarmSession, evaluatedAt: Date) -> PenaltyReason? {
        if session.snoozedAt != nil {
            return .snooze
        }

        if session.challengeResult != .passed && evaluatedAt >= session.timeoutAt {
            return .timeout
        }

        return nil
    }

    public func createSimulatedPenalty(eventInput: PenaltyEventInput) -> PenaltyEvent {
        PenaltyEvent(
            userId: eventInput.userId,
            alarmSessionId: eventInput.alarmSessionId,
            amount: eventInput.amount,
            recipientId: eventInput.recipientId,
            reason: eventInput.reason,
            status: .simulatedRecorded,
            createdAt: Date()
        )
    }
}
