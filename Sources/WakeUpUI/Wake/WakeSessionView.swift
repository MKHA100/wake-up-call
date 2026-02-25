import SwiftUI
import WakeUpDomain
import WakeUpFeatures

public struct WakeSessionView: View {
    @ObservedObject private var viewModel: WakeFlowViewModel
    private let onDone: () -> Void

    @State private var sliderOffset: CGFloat = 0
    @State private var tapSequenceInput: [Int] = []

    public init(viewModel: WakeFlowViewModel, onDone: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onDone = onDone
    }

    public var body: some View {
        ZStack {
            DynamicSkyBackgroundView()

            VStack(spacing: 20) {
                Text("Wake Challenge")
                    .font(WakeUpDesign.titleFont())
                    .foregroundStyle(.white)

                Text("Time left: \(viewModel.secondsRemaining)s")
                    .foregroundStyle(.white.opacity(0.9))

                slider

                challenge

                Button("Snooze") {
                    Task {
                        await viewModel.snooze()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)

                if let message = viewModel.encouragementMessage {
                    Text(message)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                if viewModel.penaltyEvent != nil {
                    Text("Penalty recorded. Re-ring scheduled.")
                        .foregroundStyle(.yellow)
                }

                Button("Done") { onDone() }
                    .buttonStyle(.bordered)
            }
            .padding(24)
        }
        .task {
            await viewModel.start()
        }
    }

    private var slider: some View {
        VStack(spacing: 10) {
            Text("Slide up to dismiss")
                .foregroundStyle(.white.opacity(0.85))

            Circle()
                .fill(Color.white.opacity(0.85))
                .frame(width: 84, height: 84)
                .overlay(Image(systemName: "chevron.up").font(.title).foregroundStyle(.black))
                .offset(y: sliderOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            sliderOffset = min(0, value.translation.height)
                        }
                        .onEnded { _ in
                            if sliderOffset < -45 {
                                Task {
                                    await viewModel.slideToDismiss()
                                }
                            }
                            withAnimation(.spring()) {
                                sliderOffset = 0
                            }
                        }
                )
        }
    }

    @ViewBuilder
    private var challenge: some View {
        VStack(spacing: 12) {
            Text("Challenge")
                .foregroundStyle(.white)

            Button("Tap 1") { tapSequenceInput.append(1) }
            Button("Tap 2") { tapSequenceInput.append(2) }
            Button("Tap 3") { tapSequenceInput.append(3) }
            Button("Tap 4") { tapSequenceInput.append(4) }

            Button("Submit Tap Sequence") {
                Task {
                    await viewModel.submitChallenge(.tapSequence(tapSequenceInput))
                    tapSequenceInput = []
                }
            }
            .buttonStyle(.borderedProminent)

            HStack {
                Button("Reaction: Fast") {
                    Task {
                        await viewModel.submitChallenge(.reactionIntervals([0.42, 0.38, 0.51]))
                    }
                }
                .buttonStyle(.bordered)

                Button("Reaction: Slow") {
                    Task {
                        await viewModel.submitChallenge(.reactionIntervals([0.9, 0.8, 1.1]))
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
