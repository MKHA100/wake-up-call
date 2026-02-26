import Foundation

@MainActor
public protocol HapticServiceProtocol {
    func success()
    func warning()
    func selection()
}

@MainActor
public struct NoOpHapticService: HapticServiceProtocol {
    public init() {}
    public func success() {}
    public func warning() {}
    public func selection() {}
}

#if canImport(UIKit)
import UIKit

@MainActor
public final class UIKitHapticService: HapticServiceProtocol {
    private let notificationGenerator: UINotificationFeedbackGenerator
    private let selectionGenerator: UISelectionFeedbackGenerator

    public init() {
        notificationGenerator = UINotificationFeedbackGenerator()
        selectionGenerator = UISelectionFeedbackGenerator()
    }

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
