import Foundation
import WakeUpDomain

public struct SleepWarningService: Sendable {
    private let calendar: Calendar

    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    public func warningIfNeeded(alarm: AlarmRule, now: Date, targetHours: Double) -> SleepWarning? {
        guard let trigger = AlarmScheduleCalculator.nextTriggerDate(for: alarm, from: now, calendar: calendar) else {
            return nil
        }

        let remaining = trigger.timeIntervalSince(now) / 3600
        guard remaining < targetHours else { return nil }
        return SleepWarning(remainingHours: remaining, targetHours: targetHours)
    }
}
