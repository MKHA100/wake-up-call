import Combine
import Foundation
import WakeUpDomain
import WakeUpServices

@MainActor
public final class OnboardingViewModel: ObservableObject {
    @Published public var sleepTargetHours: Double = 7.5
    @Published public var selectedThemePack: ThemePack = .midnight
    @Published public var selectedColorMode: ColorMode = .auto
    @Published public var biometricEnabled: Bool = false
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var errorMessage: String?

    private let dependencies: AppDependencies

    public init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    public func signInWithGoogle() async -> (AuthSession, UserProfile)? {
        await signIn(using: { try await dependencies.authService.signInWithGoogle() })
    }

    public func signInWithApple() async -> (AuthSession, UserProfile)? {
        await signIn(using: { try await dependencies.authService.signInWithApple() })
    }

    private func signIn(using operation: () async throws -> AuthSession) async -> (AuthSession, UserProfile)? {
        do {
            isLoading = true
            defer { isLoading = false }

            let session = try await operation()
            let profile = UserProfile(
                id: session.userId,
                email: session.email,
                displayName: session.displayName,
                timezoneIdentifier: TimeZone.current.identifier,
                sleepTargetHours: sleepTargetHours,
                themePack: selectedThemePack,
                colorMode: selectedColorMode,
                biometricEnabled: biometricEnabled
            )
            await dependencies.store.upsertProfile(profile)
            return (session, profile)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
