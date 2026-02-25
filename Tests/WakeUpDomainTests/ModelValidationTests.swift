import Testing
@testable import WakeUpDomain

@Test
func timeOfDayClampsInvalidValues() {
    let value = TimeOfDay(hour: 28, minute: -2)
    #expect(value.hour == 23)
    #expect(value.minute == 0)
}

@Test
func retryPolicyClampsValues() {
    let policy = RetryPolicy(intervalMinutes: 0, maxRetries: -1)
    #expect(policy.intervalMinutes == 1)
    #expect(policy.maxRetries == 0)
}

@Test
func alarmRuleEnforcesMinimumWakeWindow() {
    let alarm = AlarmRule(
        userId: UUID(),
        label: "Alarm",
        timeOfDay: TimeOfDay(hour: 6, minute: 30),
        repeatDays: [],
        penaltyAmount: 10,
        recipientId: UUID(),
        wakeWindowSeconds: 12
    )
    #expect(alarm.wakeWindowSeconds == 30)
}
