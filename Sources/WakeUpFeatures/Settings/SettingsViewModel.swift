import Combine
import Foundation
import WakeUpDomain
import WakeUpServices

@MainActor
public final class SettingsViewModel: ObservableObject {
    @Published public var sleepTargetHours: Double
    @Published public var themePack: ThemePack
    @Published public var colorMode: ColorMode
    @Published public var biometricEnabled: Bool

    private let profileId: UUID
    private let store: PrototypeStore

    public init(profile: UserProfile, store: PrototypeStore) {
        self.profileId = profile.id
        self.store = store
        self.sleepTargetHours = profile.sleepTargetHours
        self.themePack = profile.themePack
        self.colorMode = profile.colorMode
        self.biometricEnabled = profile.biometricEnabled
    }

    public func persist() async {
        let profile = UserProfile(
            id: profileId,
            email: "user@wake-up.app",
            displayName: "Wake User",
            timezoneIdentifier: TimeZone.current.identifier,
            sleepTargetHours: sleepTargetHours,
            themePack: themePack,
            colorMode: colorMode,
            biometricEnabled: biometricEnabled
        )
        await store.upsertProfile(profile)
    }
}
