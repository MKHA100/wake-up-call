import Foundation

public protocol HapticServiceProtocol {
    func success()
    func warning()
    func selection()
}

public struct NoOpHapticService: HapticServiceProtocol {
    public init() {}
    public func success() {}
    public func warning() {}
    public func selection() {}
}

#if canImport(UIKit)
import UIKit

public final class UIKitHapticService: HapticServiceProtocol {
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    public init() {}

    public func success() {
        notificationGenerator.notificationOccurred(.success)
    }

    public func warning() {
        notificationGenerator.notificationOccurred(.warning)
    }

    public func selection() {
        selectionGenerator.selectionChanged()
    }
}
#endif
