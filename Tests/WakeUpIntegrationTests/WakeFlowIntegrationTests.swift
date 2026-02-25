import Foundation
import Testing
@testable import WakeUpDomain
@testable import WakeUpFeatures
@testable import WakeUpServices

@Test @MainActor
func snoozeCreatesPenaltyAndSchedulesRetry() async {
    let store = PrototypeStore()
    let scheduler = LocalAlarmScheduler()
    let engine = PenaltyEngine()

    let userId = UUID()
    let recipient = Recipient(userId: userId, label: "Friend", recipientType: .friend, transferHandle: "f://friend", isPresetCharity: false)
    await store.addRecipient(recipient)

    let alarm = AlarmRule(
        userId: userId,
        label: "Alarm",
        timeOfDay: TimeOfDay(hour: 6, minute: 45),
        repeatDays: [],
        penaltyAmount: 12,
        recipientId: recipient.id,
        wakeWindowSeconds: 120,
        retryPolicy: RetryPolicy(intervalMinutes: 5, maxRetries: 3)
    )
    try? await scheduler.schedule(alarm)

    let vm = WakeFlowViewModel(
        userId: userId,
        alarm: alarm,
        scheduledAt: Date(),
        store: store,
        penaltyEngineService: engine,
        scheduler: scheduler
    )

    await vm.start()
    await vm.snooze(now: Date())

    #expect(vm.penaltyEvent != nil)
    #expect(vm.session.retryCount == 1)

    let penalties = await store.listPenalties(for: userId)
    #expect(penalties.count == 1)
}

@Test @MainActor
func timeoutCreatesPenalty() async {
    let store = PrototypeStore()
    let scheduler = LocalAlarmScheduler()
    let engine = PenaltyEngine()
    let userId = UUID()

    let recipient = Recipient(userId: userId, label: "Charity", recipientType: .charity, transferHandle: "c://charity", isPresetCharity: false)
    await store.addRecipient(recipient)

    let alarm = AlarmRule(
        userId: userId,
        label: "Alarm",
        timeOfDay: TimeOfDay(hour: 7, minute: 0),
        repeatDays: [],
        penaltyAmount: 15,
        recipientId: recipient.id,
        wakeWindowSeconds: 120,
        retryPolicy: RetryPolicy(intervalMinutes: 5, maxRetries: 3)
    )

    let scheduledAt = Date().addingTimeInterval(-300)
    let vm = WakeFlowViewModel(
        userId: userId,
        alarm: alarm,
        scheduledAt: scheduledAt,
        store: store,
        penaltyEngineService: engine,
        scheduler: scheduler
    )

    await vm.start()
    await vm.tick(now: scheduledAt.addingTimeInterval(500))

    #expect(vm.penaltyEvent?.reason == .timeout)
}

@Test
func syncQueueFlushesOnlyWhenOnline() {
    var queue = InMemorySyncQueue()
    queue.enqueue(SyncEvent(type: "penalty", payload: "{}"))

    let offlineResult = queue.flushWhenOnline(isOnline: false)
    #expect(offlineResult.isEmpty)
    #expect(queue.pendingEvents.count == 1)

    let onlineResult = queue.flushWhenOnline(isOnline: true)
    #expect(onlineResult.count == 1)
    #expect(queue.pendingEvents.count == 0)
}
