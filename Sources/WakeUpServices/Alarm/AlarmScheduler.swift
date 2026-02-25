import Foundation
import WakeUpDomain

public enum AlarmSchedulerError: Error {
    case alarmNotFound
}

public actor LocalAlarmScheduler: AlarmSchedulerProtocol {
    private var rules: [UUID: AlarmRule] = [:]
    private let calendar: Calendar

    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    public func schedule(_ rule: AlarmRule) async throws {
        rules[rule.id] = rule
    }

    public func cancel(alarmId: UUID) async throws {
        rules.removeValue(forKey: alarmId)
    }

    public func reschedule(alarmId: UUID) async throws {
        guard let existing = rules[alarmId] else { throw AlarmSchedulerError.alarmNotFound }
        rules[alarmId] = existing
    }

    public func nextTriggerDate(for rule: AlarmRule, from now: Date = Date()) -> Date? {
        AlarmScheduleCalculator.nextTriggerDate(for: rule, from: now, calendar: calendar)
    }

    public func allRules() -> [AlarmRule] {
        Array(rules.values)
    }
}

public enum AlarmScheduleCalculator {
    public static func nextTriggerDate(for rule: AlarmRule, from now: Date, calendar: Calendar = .current) -> Date? {
        if rule.repeatDays.isEmpty {
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.hour = rule.timeOfDay.hour
            components.minute = rule.timeOfDay.minute
            components.second = 0
            guard let candidate = calendar.date(from: components) else { return nil }
            if candidate > now {
                return candidate
            }
            return calendar.date(byAdding: .day, value: 1, to: candidate)
        }

        for offset in 0...7 {
            guard let date = calendar.date(byAdding: .day, value: offset, to: now) else { continue }
            let weekday = calendar.component(.weekday, from: date)
            guard let repeatDay = RepeatDay(rawValue: weekday), rule.repeatDays.contains(repeatDay) else {
                continue
            }

            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.hour = rule.timeOfDay.hour
            components.minute = rule.timeOfDay.minute
            components.second = 0

            if let candidate = calendar.date(from: components), candidate > now {
                return candidate
            }
        }

        return nil
    }

    public static func nextRetryDate(after date: Date, retryPolicy: RetryPolicy, currentRetryCount: Int, calendar: Calendar = .current) -> Date? {
        guard currentRetryCount < retryPolicy.maxRetries else { return nil }
        return calendar.date(byAdding: .minute, value: retryPolicy.intervalMinutes, to: date)
    }
}
