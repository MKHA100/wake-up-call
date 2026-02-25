import Combine
import Foundation
import WakeUpDomain
import WakeUpServices

@MainActor
public final class AppState: ObservableObject {
    public enum Route {
        case onboarding
        case dashboard
        case wakeSession(AlarmSession)
    }

    @Published public private(set) var route: Route = .onboarding
    @Published public private(set) var authSession: AuthSession?
    @Published public private(set) var profile: UserProfile?

    public let dependencies: AppDependencies

    public init(dependencies: AppDependencies = .prototype()) {
        self.dependencies = dependencies
    }

    public func didAuthenticate(_ session: AuthSession, profile: UserProfile) {
        self.authSession = session
        self.profile = profile
        self.route = .dashboard
    }

    public func beginWakeSession(_ session: AlarmSession) {
        route = .wakeSession(session)
    }

    public func endWakeSession() {
        route = .dashboard
    }
}

public struct AppDependencies: Sendable {
    public let authService: any AuthServiceProtocol
    public let scheduler: LocalAlarmScheduler
    public let store: PrototypeStore
    public let penaltyEngine: PenaltyEngine
    public let sleepWarningService: SleepWarningService
    public let skyProvider: any SkySceneProviderProtocol

    public init(
        authService: any AuthServiceProtocol,
        scheduler: LocalAlarmScheduler,
        store: PrototypeStore,
        penaltyEngine: PenaltyEngine,
        sleepWarningService: SleepWarningService,
        skyProvider: any SkySceneProviderProtocol
    ) {
        self.authService = authService
        self.scheduler = scheduler
        self.store = store
        self.penaltyEngine = penaltyEngine
        self.sleepWarningService = sleepWarningService
        self.skyProvider = skyProvider
    }

    public static func prototype() -> AppDependencies {
        AppDependencies(
            authService: MockAuthService(),
            scheduler: LocalAlarmScheduler(),
            store: PrototypeStore(),
            penaltyEngine: PenaltyEngine(),
            sleepWarningService: SleepWarningService(),
            skyProvider: LocalSkySceneProvider()
        )
    }
}
