import Foundation
import WakeUpDomain

public struct WakeChallengeEngine: WakeChallengeEngineProtocol, Sendable {
    private enum InternalState: Sendable {
        case idle
        case tapSequence(expected: [Int])
        case reaction(maxAverage: TimeInterval)
    }

    private var state: InternalState = .idle
    public private(set) var isPassed: Bool = false

    public init() {}

    public mutating func startChallenge(type: ChallengeType) {
        isPassed = false
        switch type {
        case .tapSequence:
            // Deterministic pattern for predictable tests; can be randomized in app runtime.
            state = .tapSequence(expected: [1, 3, 2, 4])
        case .reactionTest:
            state = .reaction(maxAverage: 0.6)
        }
    }

    public mutating func evaluate(_ input: ChallengeInput) -> Bool {
        switch (state, input) {
        case let (.tapSequence(expected), .tapSequence(actual)):
            isPassed = actual == expected
        case let (.reaction(maxAverage), .reactionIntervals(intervals)):
            guard !intervals.isEmpty else {
                isPassed = false
                return false
            }
            let average = intervals.reduce(0, +) / Double(intervals.count)
            isPassed = average <= maxAverage
        default:
            isPassed = false
        }

        return isPassed
    }
}
