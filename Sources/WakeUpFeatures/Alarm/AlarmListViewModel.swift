import Combine
import Foundation
import WakeUpDomain
import WakeUpServices

@MainActor
public final class AlarmListViewModel: ObservableObject {
    @Published public private(set) var alarms: [AlarmRule] = []

    private let userId: UUID
    private let store: PrototypeStore

    public init(userId: UUID, store: PrototypeStore) {
        self.userId = userId
        self.store = store
    }

    public func refresh() async {
        alarms = await store.listAlarms(for: userId)
    }
}
