import Foundation

public enum ThemePack: String, Codable, CaseIterable, Sendable {
    case aurora
    case midnight
    case sunrise
    case minimal
}

public enum ColorMode: String, Codable, CaseIterable, Sendable {
    case light
    case dark
    case auto
}

public enum RecipientType: String, Codable, CaseIterable, Sendable {
    case friend
    case family
    case enemy
    case charity
}

public enum ChallengeType: String, Codable, CaseIterable, Sendable {
    case tapSequence
    case reactionTest
}

public enum ChallengeResult: String, Codable, Sendable {
    case notStarted
    case inProgress
    case passed
    case failed
}

public enum PenaltyReason: String, Codable, Sendable {
    case snooze
    case timeout
}

public enum PenaltyStatus: String, Codable, Sendable {
    case simulatedRecorded
}

public enum DaySegment: String, Codable, Sendable {
    case night
    case dawn
    case day
    case dusk
}

public enum RepeatDay: Int, Codable, CaseIterable, Sendable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
}

public struct TimeOfDay: Codable, Hashable, Sendable {
    public var hour: Int
    public var minute: Int

    public init(hour: Int, minute: Int) {
        self.hour = max(0, min(23, hour))
        self.minute = max(0, min(59, minute))
    }
}

public struct RetryPolicy: Codable, Hashable, Sendable {
    public var intervalMinutes: Int
    public var maxRetries: Int

    public init(intervalMinutes: Int = 5, maxRetries: Int = 3) {
        self.intervalMinutes = max(1, intervalMinutes)
        self.maxRetries = max(0, maxRetries)
    }
}

public struct UserProfile: Codable, Sendable {
    public var id: UUID
    public var email: String
    public var displayName: String
    public var timezoneIdentifier: String
    public var sleepTargetHours: Double
    public var themePack: ThemePack
    public var colorMode: ColorMode
    public var biometricEnabled: Bool

    public init(
        id: UUID = UUID(),
        email: String,
        displayName: String,
        timezoneIdentifier: String,
        sleepTargetHours: Double,
        themePack: ThemePack,
        colorMode: ColorMode,
        biometricEnabled: Bool
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.timezoneIdentifier = timezoneIdentifier
        self.sleepTargetHours = sleepTargetHours
        self.themePack = themePack
        self.colorMode = colorMode
        self.biometricEnabled = biometricEnabled
    }
}

public struct Recipient: Codable, Sendable {
    public var id: UUID
    public var userId: UUID
    public var label: String
    public var recipientType: RecipientType
    public var transferHandle: String
    public var isPresetCharity: Bool

    public init(
        id: UUID = UUID(),
        userId: UUID,
        label: String,
        recipientType: RecipientType,
        transferHandle: String,
        isPresetCharity: Bool
    ) {
        self.id = id
        self.userId = userId
        self.label = label
        self.recipientType = recipientType
        self.transferHandle = transferHandle
        self.isPresetCharity = isPresetCharity
    }
}

public struct AlarmRule: Codable, Sendable {
    public var id: UUID
    public var userId: UUID
    public var label: String
    public var timeOfDay: TimeOfDay
    public var repeatDays: Set<RepeatDay>
    public var penaltyAmount: Decimal
    public var currency: String
    public var recipientId: UUID
    public var wakeWindowSeconds: Int
    public var retryPolicy: RetryPolicy
    public var enabled: Bool

    public init(
        id: UUID = UUID(),
        userId: UUID,
        label: String,
        timeOfDay: TimeOfDay,
        repeatDays: Set<RepeatDay>,
        penaltyAmount: Decimal,
        currency: String = "USD",
        recipientId: UUID,
        wakeWindowSeconds: Int = 120,
        retryPolicy: RetryPolicy = RetryPolicy(),
        enabled: Bool = true
    ) {
        self.id = id
        self.userId = userId
        self.label = label
        self.timeOfDay = timeOfDay
        self.repeatDays = repeatDays
        self.penaltyAmount = penaltyAmount
        self.currency = currency
        self.recipientId = recipientId
        self.wakeWindowSeconds = max(30, wakeWindowSeconds)
        self.retryPolicy = retryPolicy
        self.enabled = enabled
    }
}

public struct AlarmSession: Codable, Sendable {
    public var id: UUID
    public var alarmId: UUID
    public var scheduledAt: Date
    public var firedAt: Date?
    public var dismissedAt: Date?
    public var challengeType: ChallengeType
    public var challengeResult: ChallengeResult
    public var timeoutAt: Date
    public var retryCount: Int
    public var snoozedAt: Date?

    public init(
        id: UUID = UUID(),
        alarmId: UUID,
        scheduledAt: Date,
        firedAt: Date? = nil,
        dismissedAt: Date? = nil,
        challengeType: ChallengeType,
        challengeResult: ChallengeResult = .notStarted,
        timeoutAt: Date,
        retryCount: Int = 0,
        snoozedAt: Date? = nil
    ) {
        self.id = id
        self.alarmId = alarmId
        self.scheduledAt = scheduledAt
        self.firedAt = firedAt
        self.dismissedAt = dismissedAt
        self.challengeType = challengeType
        self.challengeResult = challengeResult
        self.timeoutAt = timeoutAt
        self.retryCount = retryCount
        self.snoozedAt = snoozedAt
    }
}

public struct PenaltyEvent: Codable, Sendable {
    public var id: UUID
    public var userId: UUID
    public var alarmSessionId: UUID
    public var amount: Decimal
    public var recipientId: UUID
    public var reason: PenaltyReason
    public var status: PenaltyStatus
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        userId: UUID,
        alarmSessionId: UUID,
        amount: Decimal,
        recipientId: UUID,
        reason: PenaltyReason,
        status: PenaltyStatus = .simulatedRecorded,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.alarmSessionId = alarmSessionId
        self.amount = amount
        self.recipientId = recipientId
        self.reason = reason
        self.status = status
        self.createdAt = createdAt
    }
}

public struct ConsentRecord: Codable, Sendable {
    public var id: UUID
    public var userId: UUID
    public var alarmId: UUID
    public var acceptedAt: Date
    public var termsVersion: String

    public init(
        id: UUID = UUID(),
        userId: UUID,
        alarmId: UUID,
        acceptedAt: Date = Date(),
        termsVersion: String
    ) {
        self.id = id
        self.userId = userId
        self.alarmId = alarmId
        self.acceptedAt = acceptedAt
        self.termsVersion = termsVersion
    }
}

public struct AuthSession: Codable, Sendable {
    public var userId: UUID
    public var email: String
    public var displayName: String
    public var provider: String

    public init(userId: UUID, email: String, displayName: String, provider: String) {
        self.userId = userId
        self.email = email
        self.displayName = displayName
        self.provider = provider
    }
}

public struct GeoLocation: Codable, Hashable, Sendable {
    public var latitude: Double
    public var longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public struct CelestialBodyState: Codable, Sendable {
    public var name: String
    public var x: Double
    public var y: Double
    public var opacity: Double

    public init(name: String, x: Double, y: Double, opacity: Double) {
        self.name = name
        self.x = x
        self.y = y
        self.opacity = opacity
    }
}

public struct SkyState: Codable, Sendable {
    public var segment: DaySegment
    public var starsVisible: Bool
    public var moon: CelestialBodyState?
    public var sun: CelestialBodyState?
    public var planets: [CelestialBodyState]

    public init(
        segment: DaySegment,
        starsVisible: Bool,
        moon: CelestialBodyState?,
        sun: CelestialBodyState?,
        planets: [CelestialBodyState]
    ) {
        self.segment = segment
        self.starsVisible = starsVisible
        self.moon = moon
        self.sun = sun
        self.planets = planets
    }
}

public struct SkyLayer: Codable, Sendable {
    public var id: String
    public var kind: String
    public var intensity: Double

    public init(id: String, kind: String, intensity: Double) {
        self.id = id
        self.kind = kind
        self.intensity = intensity
    }
}

public enum ChallengeInput: Sendable {
    case tapSequence([Int])
    case reactionIntervals([TimeInterval])
}

public struct SleepWarning: Equatable, Sendable {
    public var remainingHours: Double
    public var targetHours: Double

    public init(remainingHours: Double, targetHours: Double) {
        self.remainingHours = remainingHours
        self.targetHours = targetHours
    }
}

public struct SyncEvent: Codable, Sendable {
    public var id: UUID
    public var type: String
    public var payload: String
    public var createdAt: Date

    public init(id: UUID = UUID(), type: String, payload: String, createdAt: Date = Date()) {
        self.id = id
        self.type = type
        self.payload = payload
        self.createdAt = createdAt
    }
}
