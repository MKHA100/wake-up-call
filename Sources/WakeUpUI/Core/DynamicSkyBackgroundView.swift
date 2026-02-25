import SwiftUI
import WakeUpDomain
import WakeUpServices

public struct DynamicSkyBackgroundView: View {
    private let provider: any SkySceneProviderProtocol
    private let location: GeoLocation?

    public init(provider: any SkySceneProviderProtocol = LocalSkySceneProvider(), location: GeoLocation? = nil) {
        self.provider = provider
        self.location = location
    }

    public var body: some View {
        TimelineView(.animation(minimumInterval: 1.0)) { timeline in
            let sky = provider.currentSkyState(date: timeline.date, location: location)
            ZStack {
                WakeUpDesign.gradient(for: sky.segment)
                    .ignoresSafeArea()

                if sky.starsVisible {
                    StarFieldView(date: timeline.date)
                }

                CelestialBodyView(bodyState: sky.moon, color: .white)
                CelestialBodyView(bodyState: sky.sun, color: .yellow)

                ForEach(sky.planets, id: \.name) { planet in
                    CelestialBodyView(bodyState: planet, color: .orange.opacity(0.8))
                }

                if sky.segment == .dawn || sky.segment == .dusk {
                    MorningHorizonGlow()
                }
            }
            .animation(.easeInOut(duration: 0.8), value: sky.segment)
        }
    }
}

private struct CelestialBodyView: View {
    let bodyState: CelestialBodyState?
    let color: Color

    var body: some View {
        GeometryReader { geo in
            if let bodyState {
                Circle()
                    .fill(color.opacity(bodyState.opacity))
                    .frame(width: 28, height: 28)
                    .blur(radius: 0.3)
                    .position(
                        x: geo.size.width * bodyState.x,
                        y: geo.size.height * (1 - max(0.0, min(1.0, bodyState.y)))
                    )
            }
        }
        .ignoresSafeArea()
    }
}

private struct MorningHorizonGlow: View {
    var body: some View {
        LinearGradient(
            colors: [Color.yellow.opacity(0.45), Color.white.opacity(0.05), .clear],
            startPoint: .bottom,
            endPoint: .top
        )
        .frame(maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
    }
}

private struct StarFieldView: View {
    let date: Date

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let second = Calendar.current.component(.second, from: date)
                for index in 0..<120 {
                    let xSeed = Double((index * 37) % 100) / 100.0
                    let ySeed = Double((index * 53) % 100) / 100.0
                    let twinkle = 0.35 + 0.65 * abs(sin(Double(second + index) * 0.2))
                    let rect = CGRect(
                        x: size.width * xSeed,
                        y: size.height * ySeed,
                        width: 2.2,
                        height: 2.2
                    )
                    context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(twinkle)))
                }
            }
        }
        .ignoresSafeArea()
    }
}
