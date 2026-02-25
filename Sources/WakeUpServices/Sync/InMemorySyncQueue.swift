import Foundation
import WakeUpDomain

public struct InMemorySyncQueue: SyncQueueProtocol, Sendable {
    public private(set) var pendingEvents: [SyncEvent] = []

    public init() {}

    public mutating func enqueue(_ event: SyncEvent) {
        pendingEvents.append(event)
    }

    public mutating func flushWhenOnline(isOnline: Bool) -> [SyncEvent] {
        guard isOnline else { return [] }
        let flushed = pendingEvents
        pendingEvents.removeAll(keepingCapacity: true)
        return flushed
    }
}
