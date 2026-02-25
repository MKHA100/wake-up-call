import Foundation
import WakeUpDomain

public actor PrototypeStore {
    public private(set) var profiles: [UUID: UserProfile] = [:]
    public private(set) var recipients: [UUID: Recipient]
    public private(set) var alarms: [UUID: AlarmRule] = [:]
    public private(set) var sessions: [UUID: AlarmSession] = [:]
    public private(set) var penalties: [UUID: PenaltyEvent] = [:]
    public private(set) var consents: [UUID: ConsentRecord] = [:]

    public init() {
        recipients = Self.presetCharities()
    }

    public func upsertProfile(_ profile: UserProfile) {
        profiles[profile.id] = profile
    }

    public func addRecipient(_ recipient: Recipient) {
        recipients[recipient.id] = recipient
    }

    public func addAlarm(_ alarm: AlarmRule) {
        alarms[alarm.id] = alarm
    }

    public func updateAlarm(_ alarm: AlarmRule) {
        alarms[alarm.id] = alarm
    }

    public func addSession(_ session: AlarmSession) {
        sessions[session.id] = session
    }

    public func updateSession(_ session: AlarmSession) {
        sessions[session.id] = session
    }

    public func addPenalty(_ event: PenaltyEvent) {
        penalties[event.id] = event
    }

    public func addConsent(_ consent: ConsentRecord) {
        consents[consent.id] = consent
    }

    public func listRecipients(for userId: UUID) -> [Recipient] {
        recipients.values
            .filter { $0.userId == userId || $0.isPresetCharity }
            .sorted { $0.label < $1.label }
    }

    public func listAlarms(for userId: UUID) -> [AlarmRule] {
        alarms.values
            .filter { $0.userId == userId }
            .sorted { lhs, rhs in
                if lhs.timeOfDay.hour == rhs.timeOfDay.hour {
                    return lhs.timeOfDay.minute < rhs.timeOfDay.minute
                }
                return lhs.timeOfDay.hour < rhs.timeOfDay.hour
            }
    }

    public func listPenalties(for userId: UUID) -> [PenaltyEvent] {
        penalties.values
            .filter { $0.userId == userId }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private static func presetCharities() -> [UUID: Recipient] {
        let systemUser = UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID()
        let preset = [
            Recipient(userId: systemUser, label: "UNICEF", recipientType: .charity, transferHandle: "charity://unicef", isPresetCharity: true),
            Recipient(userId: systemUser, label: "Red Cross", recipientType: .charity, transferHandle: "charity://red-cross", isPresetCharity: true),
            Recipient(userId: systemUser, label: "WWF", recipientType: .charity, transferHandle: "charity://wwf", isPresetCharity: true)
        ]

        var mapped: [UUID: Recipient] = [:]
        for recipient in preset {
            mapped[recipient.id] = recipient
        }
        return mapped
    }
}
