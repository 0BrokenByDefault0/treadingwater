import SwiftUI

// MARK: - Palette
//
// Pulled from the MORNE / ODEON typeface poster system: bone paper, dead-black
// ink, concrete greys, terracotta clay, and a single screaming orange used
// sparingly enough that it always means "look here".

enum Ink {
    static let black      = Color(hex: 0x14130F)
    static let blackSoft  = Color(hex: 0x1E1C18)

    static let bone       = Color(hex: 0xE9E3D6)
    static let boneDeep   = Color(hex: 0xDCD4C3)
    static let paper      = Color(hex: 0xF2EEE4)

    static let concrete   = Color(hex: 0xA5A29A)
    static let concreteHi = Color(hex: 0xB8B5AD)
    static let concreteLo = Color(hex: 0x86837B)

    static let clay       = Color(hex: 0xA97148)
    static let claySoft   = Color(hex: 0xC08A5E)

    static let orange     = Color(hex: 0xE9541B)
    static let amber      = Color(hex: 0xF2A81E)
    static let plum       = Color(hex: 0x6E6472)
    static let steel      = Color(hex: 0x55535B)

    /// The swatch strip that appears along the top of the reference sheets.
    static let swatches: [Color] = [black, steel, plum, concreteLo, clay, orange, amber]
}

// MARK: - Theme

/// Two committed looks: DAY (bone paper, black ink) and NIGHT (black ink,
/// bone type). Producers work in dark rooms; the poster language survives
/// the inversion because the reference sheets already invert their own panels.
final class Theme: ObservableObject {
    private static let key = "tw.night"

    @Published var night: Bool {
        didSet { UserDefaults.standard.set(night, forKey: Theme.key) }
    }

    init() {
        self.night = UserDefaults.standard.bool(forKey: Theme.key)
    }

    var bg: Color        { night ? Ink.black : Ink.bone }
    var bgDeep: Color    { night ? Color(hex: 0x0C0B09) : Ink.boneDeep }
    var panel: Color     { night ? Ink.blackSoft : Ink.paper }
    var fg: Color        { night ? Ink.bone : Ink.black }
    var fgMuted: Color   { night ? Ink.concreteLo : Ink.concreteLo }
    var rule: Color      { night ? Color(hex: 0x3A3833) : Ink.black.opacity(0.85) }
    var fill: Color      { night ? Color(hex: 0x2A2823) : Ink.concrete }
    var fillHi: Color    { night ? Color(hex: 0x3A3833) : Ink.concreteHi }

    var accent: Color    { Ink.orange }
    var accent2: Color   { Ink.clay }
    var accent3: Color   { Ink.amber }

    /// Text that sits on top of `accent`.
    var onAccent: Color  { Ink.bone }
}

// MARK: - Type
//
// No licensed font files ship with the app. SF Pro's *expanded* width axis at
// black weight gets remarkably close to the wide grotesque on the poster, and
// it stays legible at 9pt for the technical labels.

enum TW {
    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .black).width(.expanded)
    }
    static func heavy(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy).width(.expanded)
    }
    static func wide(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight).width(.expanded)
    }
    static func label(_ size: CGFloat = 10) -> Font {
        .system(size: size, weight: .semibold, design: .monospaced)
    }
    static func mono(_ size: CGFloat = 12, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
    static func body(_ size: CGFloat = 15.5) -> Font {
        .system(size: size, weight: .regular)
    }
    static func bodyBold(_ size: CGFloat = 15.5) -> Font {
        .system(size: size, weight: .semibold)
    }
}

// MARK: - Helpers

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue:  Double(hex & 0xFF) / 255.0,
            opacity: 1.0
        )
    }
}

extension String {
    /// Zero-padded serial, e.g. 7 -> "007".
    static func serial(_ n: Int, _ width: Int = 3) -> String {
        let s = String(n)
        if s.count >= width { return s }
        return String(repeating: "0", count: width - s.count) + s
    }
}
