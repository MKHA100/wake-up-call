import Foundation
import WakeUpDomain
import WakeUpFeatures
import WakeUpServices

struct CheckFailure: Error, CustomStringConvertible {
    let message: String
    var description: String { message }
}

@main
struct WakeUpChecks {
    static func main() async {
        do {
            try runDomainChecks()
            try runServiceChecks()
            try await runIntegrationChecks()
            print("All WakeUp checks passed")
        } catch {
            fputs("WakeUp checks failed: \(error)\n", stderr)
            exit(1)
        }
    }

    private static func runDomainChecks() throws {
        let invalidTime = TimeOfDay(hour: 40, minute: -3)
        guard invalidTime.hour == 23 && invalidTime.minute == 0 else {
            throw CheckFailure(message: "TimeOfDay clamping failed")
        }

        let retry = RetryPolicy(intervalMinutes: 0, maxRetries: -2)
        guard retry.intervalMinutes == 1 && retry.maxRetries == 0 else {
            throw CheckFailure(message: "RetryPolicy clamping failed")
        }

        let alarm = AlarmRule(
            userId: UUID(),
            label: "Test",
            timeOfDay: TimeOfDay(hour: 6, minute: 0),
            repeatDays: [],
            penaltyAmount: 5,
            recipientId: UUID(),
            wakeWindowSeconds: 5
        )
        guard alarm.wakeWindowSeconds == 30 else {
            throw CheckFailure(message: "Alarm wake window minimum rule failed")
        }
    }

    private static func runServiceChecks() throws {
        var challenge = WakeChallengeEngine()
        challenge.startChallenge(type: .tapSequence)
        guard challenge.evaluate(.tapSequence([1, 3, 2, 4])) else {
            throw CheckFailure(message: "Tap sequence challenge expected pass")
        }

        challenge.startChallenge(type: .reactionTest)
        guard !challenge.evaluate(.reactionIntervals([1.0, 0.9, 1.1])) else {
            throw CheckFailure(message: "Reaction challenge expected fail")
        }

        let now = Date()
        let session = AlarmSession(
            alarmId: UUID(),
            scheduledAt: now,
            firedAt: now,
            challengeType: .tapSequence,
            challengeResult: .failed,
            timeoutAt: now.addingTimeInterval(-1),
            snoozedAt: now
        )
        let penalty = PenaltyEngine()
        guard penalty.evaluateTrigger(session: session, evaluatedAt: now) == .snooze else {
            throw CheckFailure(message: "Penalty trigger precedence failed")
        }
    }

    private static func runIntegrationChecks() async throws {
        let store = PrototypeStore()
        let scheduler = LocalAlarmScheduler()
        let penaltyEngine = PenaltyEngine()
        let userId = UUID()

        let recipient = Recipient(userId: userId, label: "Friend", recipientType: .friend, transferHandle: "friend://sam", isPresetCharity: false)
        await store.addRecipient(recipient)

        let alarm = AlarmRule(
            userId: userId,
            label: "Morning",
            timeOfDay: TimeOfDay(hour: 6, minute: 15),
            repeatDays: [.monday, .tuesday],
            penaltyAmount: 10,
            recipientId: recipient.id,
            wakeWindowSeconds: 120,
            retryPolicy: RetryPolicy(intervalMinutes: 5, maxRetries: 3)
        )

        try await scheduler.schedule(alarm)

        let wakeFlow = await MainActor.run {
            WakeFlowViewModel(
                userId: userId,
                alarm: alarm,
                scheduledAt: Date(),
                store: store,
                penaltyEngineService: penaltyEngine,
                scheduler: scheduler
            )
        }

        await wakeFlow.start()
        await wakeFlow.snooze(now: Date())

        let event = await MainActor.run { wakeFlow.penaltyEvent }
        guard event != nil else {
            throw CheckFailure(message: "Snooze should create penalty event")
        }

        let retryCount = await MainActor.run { wakeFlow.session.retryCount }
        guard retryCount == 1 else {
            throw CheckFailure(message: "Retry should increment after miss")
        }

        var queue = InMemorySyncQueue()
        queue.enqueue(SyncEvent(type: "penalty", payload: "{}"))
        let offline = queue.flushWhenOnline(isOnline: false)
        guard offline.isEmpty else {
            throw CheckFailure(message: "Offline sync flush should be empty")
        }
        let online = queue.flushWhenOnline(isOnline: true)
        guard online.count == 1 else {
            throw CheckFailure(message: "Online sync flush should return queued events")
        }
    }
}
