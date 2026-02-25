import Foundation
import Testing
@testable import WakeUpDomain
@testable import WakeUpServices

@Test
func nextTriggerDateForRepeatingAlarm() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!

    let formatter = ISO8601DateFormatter()
    let now = formatter.date(from: "2026-02-25T22:00:00Z")!

    let alarm = AlarmRule(
        userId: UUID(),
        label: "Weekday",
        timeOfDay: TimeOfDay(hour: 6, minute: 30),
        repeatDays: [.thursday],
        penaltyAmount: 5,
        recipientId: UUID()
    )

    let trigger = AlarmScheduleCalculator.nextTriggerDate(for: alarm, from: now, calendar: calendar)
    #expect(trigger != nil)
    if let trigger {
        #expect(calendar.component(.weekday, from: trigger) == RepeatDay.thursday.rawValue)
    }
}

@Test
func sleepWarningWhenRemainingHoursBelowTarget() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!

    let now = ISO8601DateFormatter().date(from: "2026-02-25T23:30:00Z")!
    let alarm = AlarmRule(
        userId: UUID(),
        label: "Soon",
        timeOfDay: TimeOfDay(hour: 2, minute: 0),
        repeatDays: [],
        penaltyAmount: 4,
        recipientId: UUID()
    )

    let service = SleepWarningService(calendar: calendar)
    let warning = service.warningIfNeeded(alarm: alarm, now: now, targetHours: 5.0)
    #expect(warning != nil)
    #expect((warning?.remainingHours ?? 6) < 5.0)
}

@Test
func tapSequenceChallengePassesWithExpectedPattern() {
    var engine = WakeChallengeEngine()
    engine.startChallenge(type: .tapSequence)

    let result = engine.evaluate(.tapSequence([1, 3, 2, 4]))
    #expect(result)
    #expect(engine.isPassed)
}

@Test
func reactionChallengeFailsForSlowResponses() {
    var engine = WakeChallengeEngine()
    engine.startChallenge(type: .reactionTest)

    let result = engine.evaluate(.reactionIntervals([0.9, 0.8, 1.0]))
    #expect(!result)
    #expect(!engine.isPassed)
}

@Test
func penaltyEnginePrefersSnoozeOverTimeout() {
    let now = Date()
    let session = AlarmSession(
        alarmId: UUID(),
        scheduledAt: now,
        firedAt: now,
        challengeType: .tapSequence,
        challengeResult: .failed,
        timeoutAt: now.addingTimeInterval(-10),
        snoozedAt: now
    )

    let engine = PenaltyEngine()
    #expect(engine.evaluateTrigger(session: session, evaluatedAt: now) == .snooze)
}

@Test
func retryDateStopsAtMaxRetryCount() {
    let now = Date()
    let policy = RetryPolicy(intervalMinutes: 5, maxRetries: 3)

    let allowed = AlarmScheduleCalculator.nextRetryDate(after: now, retryPolicy: policy, currentRetryCount: 2)
    let blocked = AlarmScheduleCalculator.nextRetryDate(after: now, retryPolicy: policy, currentRetryCount: 3)

    #expect(allowed != nil)
    #expect(blocked == nil)
}
