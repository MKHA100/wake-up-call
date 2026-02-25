import Foundation
import WakeUpDomain

public protocol WeatherOverlayProvider: Sendable {
    func cloudIntensity(at date: Date, location: GeoLocation?) -> Double
}

public struct NoOpWeatherOverlayProvider: WeatherOverlayProvider {
    public init() {}
    public func cloudIntensity(at date: Date, location: GeoLocation?) -> Double { 0.0 }
}

public struct LocalSkySceneProvider: SkySceneProviderProtocol, Sendable {
    private let weatherProvider: WeatherOverlayProvider

    public init(weatherProvider: WeatherOverlayProvider = NoOpWeatherOverlayProvider()) {
        self.weatherProvider = weatherProvider
    }

    public func currentSkyState(date: Date, location: GeoLocation?) -> SkyState {
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        let normalizedDayProgress = (Double(hour) + Double(minute) / 60.0) / 24.0

        let segment: DaySegment
        switch hour {
        case 0..<5, 21..<24:
            segment = .night
        case 5..<8:
            segment = .dawn
        case 8..<18:
            segment = .day
        default:
            segment = .dusk
        }

        let sunY = max(0.0, sin(normalizedDayProgress * .pi))
        let moonY = max(0.0, sin((normalizedDayProgress + 0.5) * .pi))

        let moon = (segment == .night || segment == .dawn || segment == .dusk)
            ? CelestialBodyState(name: "moon", x: 0.2 + normalizedDayProgress * 0.6, y: moonY, opacity: 0.85)
            : nil

        let sun = (segment == .day || segment == .dawn || segment == .dusk)
            ? CelestialBodyState(name: "sun", x: 0.1 + normalizedDayProgress * 0.8, y: sunY, opacity: 0.9)
            : nil

        let planetJupiter = CelestialBodyState(name: "jupiter", x: 0.72, y: 0.68, opacity: segment == .night ? 0.8 : 0.25)

        return SkyState(
            segment: segment,
            starsVisible: segment == .night || segment == .dawn,
            moon: moon,
            sun: sun,
            planets: [planetJupiter]
        )
    }

    public func animatedLayers(for skyState: SkyState) -> [SkyLayer] {
        let cloudIntensity = weatherProvider.cloudIntensity(at: Date(), location: nil)
        return [
            SkyLayer(id: "gradient", kind: "gradient", intensity: 1.0),
            SkyLayer(id: "stars", kind: "stars", intensity: skyState.starsVisible ? 1.0 - cloudIntensity : 0.0),
            SkyLayer(id: "shooting-stars", kind: "shooting-stars", intensity: skyState.segment == .night ? 0.6 : 0.1),
            SkyLayer(id: "clouds", kind: "clouds", intensity: cloudIntensity)
        ]
    }
}
