import SwiftUI

public struct MD3ColorScheme {
    public let primary: Color
    public let onPrimary: Color
    public let primaryContainer: Color
    public let onPrimaryContainer: Color

    public let secondary: Color
    public let onSecondary: Color
    public let secondaryContainer: Color
    public let onSecondaryContainer: Color

    public let background: Color
    public let onBackground: Color
    public let surface: Color
    public let onSurface: Color
    public let surfaceVariant: Color
    public let onSurfaceVariant: Color
    public let outline: Color

    // Light mode
    public static let light = MD3ColorScheme(
        primary: Color(hex: 0x6750A4),
        onPrimary: Color(hex: 0xFFFFFF),
        primaryContainer: Color(hex: 0xEADDFF),
        onPrimaryContainer: Color(hex: 0x21005D),
        secondary: Color(hex: 0x625B71),
        onSecondary: Color(hex: 0xFFFFFF),
        secondaryContainer: Color(hex: 0xE8DEF8),
        onSecondaryContainer: Color(hex: 0x1D192B),
        background: Color(hex: 0xFFFBFE),
        onBackground: Color(hex: 0x1C1B1F),
        surface: Color(hex: 0xFFFBFE),
        onSurface: Color(hex: 0x1C1B1F),
        surfaceVariant: Color(hex: 0xE7E0EC),
        onSurfaceVariant: Color(hex: 0x49454F),
        outline: Color(hex: 0x79747E)
    )

    // Dark mode
    public static let dark = MD3ColorScheme(
        primary: Color(hex: 0xD0BCFF),
        onPrimary: Color(hex: 0x381E72),
        primaryContainer: Color(hex: 0x4F378B),
        onPrimaryContainer: Color(hex: 0xEADDFF),
        secondary: Color(hex: 0xCCC2DC),
        onSecondary: Color(hex: 0x332D41),
        secondaryContainer: Color(hex: 0x4A4458),
        onSecondaryContainer: Color(hex: 0xE8DEF8),
        background: Color(hex: 0x1C1B1F),
        onBackground: Color(hex: 0xE6E1E5),
        surface: Color(hex: 0x1C1B1F),
        onSurface: Color(hex: 0xE6E1E5),
        surfaceVariant: Color(hex: 0x49454F),
        onSurfaceVariant: Color(hex: 0xCAC4D0),
        outline: Color(hex: 0x938F99)
    )
}

public extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

public struct MD3ThemeKey: EnvironmentKey {
    public static let defaultValue: MD3ColorScheme = .light
}

public extension EnvironmentValues {
    var md3Theme: MD3ColorScheme {
        get { self[MD3ThemeKey.self] }
        set { self[MD3ThemeKey.self] = newValue }
    }
}
