import SwiftUI
import WakeUpDomain
import WakeUpFeatures

public struct OnboardingView: View {
    @ObservedObject private var viewModel: OnboardingViewModel
    private let onAuthenticated: (AuthSession, UserProfile) -> Void

    public init(viewModel: OnboardingViewModel, onAuthenticated: @escaping (AuthSession, UserProfile) -> Void) {
        self.viewModel = viewModel
        self.onAuthenticated = onAuthenticated
    }

    public var body: some View {
        ZStack {
            DynamicSkyBackgroundView()

            VStack(spacing: WakeUpDesign.largeSpacing) {
                VStack(spacing: 8) {
                    Text("Wake Up Call")
                        .font(WakeUpDesign.titleFont())
                        .foregroundStyle(.white)
                    Text("Beat snooze. Keep your money.")
                        .font(WakeUpDesign.subtitleFont())
                        .foregroundStyle(.white.opacity(0.85))
                }

                VStack(spacing: WakeUpDesign.spacing) {
                    HStack {
                        Text("Target Sleep")
                        Spacer()
                        Text("\(viewModel.sleepTargetHours, specifier: "%.1f") h")
                    }
                    .foregroundStyle(.white)

                    Slider(value: $viewModel.sleepTargetHours, in: 5...10, step: 0.5)
                        .tint(.yellow)

                    Picker("Theme", selection: $viewModel.selectedThemePack) {
                        ForEach(ThemePack.allCases, id: \.self) { theme in
                            Text(theme.rawValue.capitalized).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)

                    Picker("Mode", selection: $viewModel.selectedColorMode) {
                        ForEach(ColorMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue.capitalized).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    Toggle("Protect sensitive settings with biometrics", isOn: $viewModel.biometricEnabled)
                        .foregroundStyle(.white)

                    Button("Continue with Google") {
                        Task {
                            if let auth = await viewModel.signInWithGoogle() {
                                onAuthenticated(auth.0, auth.1)
                            }
                        }
                    }
                    .buttonStyle(WakePrimaryButtonStyle())

                    Button("Continue with Apple") {
                        Task {
                            if let auth = await viewModel.signInWithApple() {
                                onAuthenticated(auth.0, auth.1)
                            }
                        }
                    }
                    .buttonStyle(WakeSecondaryButtonStyle())
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: WakeUpDesign.cornerRadius))
                .padding(.horizontal, 20)
            }
            .padding(.top, 20)
        }
    }
}

private struct WakePrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("AvenirNext-DemiBold", size: 18))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.yellow)
            .foregroundStyle(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

private struct WakeSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("AvenirNext-DemiBold", size: 18))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.18))
            .foregroundStyle(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}
