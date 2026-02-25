# Data Contracts

## UserProfile
- `id: UUID`
- `email: String`
- `displayName: String`
- `timezoneIdentifier: String`
- `sleepTargetHours: Double`
- `themePack: ThemePack`
- `colorMode: ColorMode`
- `biometricEnabled: Bool`

## Recipient
- `id: UUID`
- `userId: UUID`
- `label: String`
- `recipientType: friend | family | enemy | charity`
- `transferHandle: String`
- `isPresetCharity: Bool`

## AlarmRule
- `id: UUID`
- `userId: UUID`
- `label: String`
- `timeOfDay: { hour, minute }`
- `repeatDays: Set<RepeatDay>`
- `penaltyAmount: Decimal`
- `currency: String`
- `recipientId: UUID`
- `wakeWindowSeconds: Int`
- `retryPolicy: { intervalMinutes, maxRetries }`
- `enabled: Bool`

## AlarmSession
- `id: UUID`
- `alarmId: UUID`
- `scheduledAt: Date`
- `firedAt: Date?`
- `dismissedAt: Date?`
- `challengeType: tapSequence | reactionTest`
- `challengeResult: notStarted | inProgress | passed | failed`
- `timeoutAt: Date`
- `retryCount: Int`
- `snoozedAt: Date?`

## PenaltyEvent
- `id: UUID`
- `userId: UUID`
- `alarmSessionId: UUID`
- `amount: Decimal`
- `recipientId: UUID`
- `reason: snooze | timeout`
- `status: simulatedRecorded`
- `createdAt: Date`

## ConsentRecord
- `id: UUID`
- `userId: UUID`
- `alarmId: UUID`
- `acceptedAt: Date`
- `termsVersion: String`
