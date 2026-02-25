import Foundation
import WakeUpDomain

public enum AuthError: Error {
    case userCancelled
}

public final class MockAuthService: AuthServiceProtocol, @unchecked Sendable {
    private let seedEmail: String
    private let seedName: String

    public init(seedEmail: String = "user@wake-up.app", seedName: String = "Wake User") {
        self.seedEmail = seedEmail
        self.seedName = seedName
    }

    public func signInWithGoogle() async throws -> AuthSession {
        AuthSession(userId: UUID(), email: seedEmail, displayName: seedName, provider: "google")
    }

    public func signInWithApple() async throws -> AuthSession {
        AuthSession(userId: UUID(), email: seedEmail, displayName: seedName, provider: "apple")
    }

    public func signOut() async throws {}
}
