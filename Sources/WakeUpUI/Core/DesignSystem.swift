import SwiftUI
import WakeUpDomain

public enum WakeUpDesign {
    public static let cornerRadius: CGFloat = 22
    public static let spacing: CGFloat = 16
    public static let largeSpacing: CGFloat = 28

    public static func titleFont() -> Font {
        .custom("AvenirNext-Bold", size: 32)
    }

    public static func subtitleFont() -> Font {
        .custom("AvenirNext-Medium", size: 17)
    }

    public static func cardBackground(for mode: ColorMode) -> Color {
        switch mode {
        case .light:
            return Color.white.opacity(0.75)
        case .dark:
            return Color.black.opacity(0.45)
        case .auto:
            return Color.white.opacity(0.22)
        }
    }

    public static func gradient(for segment: DaySegment) -> LinearGradient {
        switch segment {
        case .night:
            return LinearGradient(colors: [Color(red: 0.01, green: 0.03, blue: 0.13), Color(red: 0.05, green: 0.08, blue: 0.24)], startPoint: .top, endPoint: .bottom)
        case .dawn:
            return LinearGradient(colors: [Color(red: 0.04, green: 0.08, blue: 0.2), Color(red: 0.9, green: 0.65, blue: 0.35)], startPoint: .top, endPoint: .bottom)
        case .day:
            return LinearGradient(colors: [Color(red: 0.33, green: 0.68, blue: 0.95), Color(red: 0.95, green: 0.96, blue: 0.99)], startPoint: .top, endPoint: .bottom)
        case .dusk:
            return LinearGradient(colors: [Color(red: 0.16, green: 0.14, blue: 0.32), Color(red: 0.95, green: 0.54, blue: 0.32)], startPoint: .top, endPoint: .bottom)
        }
    }
}
