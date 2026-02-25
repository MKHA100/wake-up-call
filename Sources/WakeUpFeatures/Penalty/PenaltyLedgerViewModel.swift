import Combine
import Foundation
import WakeUpDomain
import WakeUpServices

@MainActor
public final class PenaltyLedgerViewModel: ObservableObject {
    @Published public private(set) var events: [PenaltyEvent] = []

    private let userId: UUID
    private let store: PrototypeStore

    public init(userId: UUID, store: PrototypeStore) {
        self.userId = userId
        self.store = store
    }

    public func refresh() async {
        events = await store.listPenalties(for: userId)
    }
}
