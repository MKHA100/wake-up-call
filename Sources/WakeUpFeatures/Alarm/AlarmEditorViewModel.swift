import Combine
import Foundation
import WakeUpDomain
import WakeUpServices

@MainActor
public final class AlarmEditorViewModel: ObservableObject {
    @Published public var alarmLabel: String = "Morning Alarm"
    @Published public var selectedDate: Date
    @Published public var repeatDays: Set<RepeatDay> = []
    @Published public var selectedRecipientId: UUID?
    @Published public var penaltyAmount: Decimal = 10
    @Published public var currency: String = "USD"
    @Published public var wakeWindowSeconds: Int = 120
    @Published public var showPenaltyConsent: Bool = false
    @Published public private(set) var sleepWarning: SleepWarning?

    private let userId: UUID
    private let sleepTargetHours: Double
    private let store: PrototypeStore
    private let scheduler: LocalAlarmScheduler
    private let sleepWarningService: SleepWarningService

    public init(
        userId: UUID,
        sleepTargetHours: Double,
        store: PrototypeStore,
        scheduler: LocalAlarmScheduler,
        sleepWarningService: SleepWarningService
    ) {
        self.userId = userId
        self.sleepTargetHours = sleepTargetHours
        self.store = store
        self.scheduler = scheduler
        self.sleepWarningService = sleepWarningService

        var calendar = Calendar.current
        calendar.timeZone = .current
        selectedDate = calendar.date(bySettingHour: 6, minute: 30, second: 0, of: Date()) ?? Date()
    }

    public func refreshSleepWarning(now: Date = Date()) {
        let rule = draftRule(recipientId: selectedRecipientId ?? UUID())
        sleepWarning = sleepWarningService.warningIfNeeded(alarm: rule, now: now, targetHours: sleepTargetHours)
    }

    public func loadRecipients() async -> [Recipient] {
        await store.listRecipients(for: userId)
    }

    public func createAlarm(consentVersion: String = "v1") async throws -> AlarmRule {
        guard let recipientId = selectedRecipientId else {
            throw AlarmEditorError.recipientRequired
        }

        let rule = draftRule(recipientId: recipientId)
        await store.addAlarm(rule)
        try await scheduler.schedule(rule)
        await store.addConsent(ConsentRecord(userId: userId, alarmId: rule.id, termsVersion: consentVersion))
        return rule
    }

    private func draftRule(recipientId: UUID) -> AlarmRule {
        let components = Calendar.current.dateComponents([.hour, .minute], from: selectedDate)
        return AlarmRule(
            userId: userId,
            label: alarmLabel,
            timeOfDay: TimeOfDay(hour: components.hour ?? 6, minute: components.minute ?? 30),
            repeatDays: repeatDays,
            penaltyAmount: penaltyAmount,
            currency: currency,
            recipientId: recipientId,
            wakeWindowSeconds: wakeWindowSeconds,
            retryPolicy: RetryPolicy(intervalMinutes: 5, maxRetries: 3),
            enabled: true
        )
    }
}

public enum AlarmEditorError: Error {
    case recipientRequired
}
