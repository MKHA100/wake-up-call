import Foundation
import WakeUpDomain
import WakeUpFeatures
import WakeUpServices

@main
struct WakeUpPrototypeCLI {
    static func main() async {
        let dependencies = AppDependencies.prototype()
        let auth = try? await dependencies.authService.signInWithGoogle()

        guard let auth else {
            print("Auth failed")
            return
        }

        let profile = UserProfile(
            id: auth.userId,
            email: auth.email,
            displayName: auth.displayName,
            timezoneIdentifier: TimeZone.current.identifier,
            sleepTargetHours: 7.5,
            themePack: .midnight,
            colorMode: .auto,
            biometricEnabled: false
        )
        await dependencies.store.upsertProfile(profile)

        let recipient = Recipient(
            userId: profile.id,
            label: "Best Friend",
            recipientType: .friend,
            transferHandle: "friend://alex",
            isPresetCharity: false
        )
        await dependencies.store.addRecipient(recipient)

        let alarm = AlarmRule(
            userId: profile.id,
            label: "Weekday Alarm",
            timeOfDay: TimeOfDay(hour: 6, minute: 30),
            repeatDays: [.monday, .tuesday, .wednesday, .thursday, .friday],
            penaltyAmount: 10,
            recipientId: recipient.id,
            wakeWindowSeconds: 120,
            retryPolicy: RetryPolicy(intervalMinutes: 5, maxRetries: 3)
        )
        await dependencies.store.addAlarm(alarm)
        try? await dependencies.scheduler.schedule(alarm)

        print("Wake Up Call prototype initialized for \(profile.displayName).")
    }
}
