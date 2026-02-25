import SwiftUI
import WakeUpDomain
import WakeUpFeatures

public struct RootPrototypeView: View {
    @StateObject private var appState: AppState

    public init(appState: AppState = AppState()) {
        _appState = StateObject(wrappedValue: appState)
    }

    public var body: some View {
        switch appState.route {
        case .onboarding:
            OnboardingView(
                viewModel: OnboardingViewModel(dependencies: appState.dependencies)
            ) { session, profile in
                appState.didAuthenticate(session, profile: profile)
            }
        case .dashboard:
            if let profile = appState.profile {
                DashboardContainerView(appState: appState, profile: profile)
            }
        case let .wakeSession(session):
            if let profile = appState.profile,
               let alarm = findAlarm(profile: profile, alarmId: session.alarmId) {
                WakeSessionContainerView(appState: appState, profile: profile, alarm: alarm)
            }
        }
    }

    private func findAlarm(profile: UserProfile, alarmId: UUID) -> AlarmRule? {
        // The wake route is simulated from dashboard in this prototype and always has an in-memory alarm.
        // Returning a synthesized alarm keeps the route robust if the backing list refresh lags.
        AlarmRule(
            id: alarmId,
            userId: profile.id,
            label: "Wake Alarm",
            timeOfDay: TimeOfDay(hour: 6, minute: 30),
            repeatDays: [.monday, .tuesday, .wednesday, .thursday, .friday],
            penaltyAmount: 10,
            currency: "USD",
            recipientId: UUID(),
            wakeWindowSeconds: 120,
            retryPolicy: RetryPolicy(intervalMinutes: 5, maxRetries: 3),
            enabled: true
        )
    }
}

private struct DashboardContainerView: View {
    @ObservedObject var appState: AppState
    let profile: UserProfile

    @StateObject private var alarmVM: AlarmListViewModel
    @StateObject private var ledgerVM: PenaltyLedgerViewModel

    init(appState: AppState, profile: UserProfile) {
        self.appState = appState
        self.profile = profile
        _alarmVM = StateObject(wrappedValue: AlarmListViewModel(userId: profile.id, store: appState.dependencies.store))
        _ledgerVM = StateObject(wrappedValue: PenaltyLedgerViewModel(userId: profile.id, store: appState.dependencies.store))
    }

    var body: some View {
        AlarmDashboardView(
            alarmsViewModel: alarmVM,
            ledgerViewModel: ledgerVM,
            createEditor: {
                AlarmEditorViewModel(
                    userId: profile.id,
                    sleepTargetHours: profile.sleepTargetHours,
                    store: appState.dependencies.store,
                    scheduler: appState.dependencies.scheduler,
                    sleepWarningService: appState.dependencies.sleepWarningService
                )
            },
            onStartWakeSession: { alarm in
                let session = AlarmSession(
                    alarmId: alarm.id,
                    scheduledAt: Date(),
                    firedAt: Date(),
                    challengeType: .tapSequence,
                    timeoutAt: Date().addingTimeInterval(TimeInterval(alarm.wakeWindowSeconds))
                )
                appState.beginWakeSession(session)
            }
        )
    }
}

private struct WakeSessionContainerView: View {
    @ObservedObject var appState: AppState
    let profile: UserProfile
    let alarm: AlarmRule

    @StateObject private var wakeVM: WakeFlowViewModel

    init(appState: AppState, profile: UserProfile, alarm: AlarmRule) {
        self.appState = appState
        self.profile = profile
        self.alarm = alarm
        _wakeVM = StateObject(
            wrappedValue: WakeFlowViewModel(
                userId: profile.id,
                alarm: alarm,
                scheduledAt: Date(),
                store: appState.dependencies.store,
                penaltyEngineService: appState.dependencies.penaltyEngine,
                scheduler: appState.dependencies.scheduler
            )
        )
    }

    var body: some View {
        WakeSessionView(viewModel: wakeVM) {
            appState.endWakeSession()
        }
        .task {
            await wakeVM.tick()
        }
    }
}
