import SwiftUI

// MARK: - Panel
//
// The core container of the whole app: a hard-ruled box with a header rail
// carrying a serial number on the left and a stencil title in the middle.

struct Panel<Content: View>: View {
    @EnvironmentObject var theme: Theme

    var serial: String? = nil
    var title: String? = nil
    var trailing: String? = nil
    var tint: Color? = nil
    var padded: Bool = true
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            if serial != nil || title != nil || trailing != nil {
                HStack(spacing: 8) {
                    if let serial {
                        Text(serial)
                            .font(TW.label(9))
                            .foregroundStyle(theme.bg)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(tint ?? theme.fg)
                    }
                    Rectangle().frame(height: 1).foregroundStyle(theme.rule.opacity(0.45))
                    if let title {
                        Text(title.uppercased())
                            .font(TW.label(9))
                            .tracking(1.6)
                            .foregroundStyle(theme.fg)
                            .fixedSize()
                    }
                    Rectangle().frame(height: 1).foregroundStyle(theme.rule.opacity(0.45))
                    if let trailing {
                        Text(trailing.uppercased())
                            .font(TW.label(9))
                            .tracking(1.0)
                            .foregroundStyle(theme.fgMuted)
                            .fixedSize()
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top, 8)
                .padding(.bottom, 6)
            }

            content
                .padding(padded ? 12 : 0)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(theme.panel)
        .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1.2))
    }
}

// MARK: - Display type

struct DisplayTitle: View {
    @EnvironmentObject var theme: Theme
    var text: String
    var size: CGFloat = 34
    var color: Color? = nil

    var body: some View {
        Text(text.uppercased())
            .font(TW.display(size))
            .tracking(-0.5)
            .foregroundStyle(color ?? theme.fg)
            .minimumScaleFactor(0.45)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// The tiny all-caps monospaced captions that label every region of the sheet.
struct Caption: View {
    @EnvironmentObject var theme: Theme
    var text: String
    var color: Color? = nil
    var size: CGFloat = 9

    init(_ text: String, color: Color? = nil, size: CGFloat = 9) {
        self.text = text; self.color = color; self.size = size
    }

    var body: some View {
        Text(text.uppercased())
            .font(TW.label(size))
            .tracking(1.4)
            .foregroundStyle(color ?? theme.fgMuted)
    }
}

// MARK: - Barcode

/// Deterministic pseudo-barcode generated from a seed string. Pure decoration,
/// but it is what makes the sheets read as instrumentation rather than a form.
struct Barcode: View {
    @EnvironmentObject var theme: Theme
    var seed: String
    var height: CGFloat = 26
    var color: Color? = nil

    private var widths: [CGFloat] {
        var h: UInt64 = 1469598103934665603
        for b in seed.utf8 { h = (h ^ UInt64(b)) &* 1099511628211 }
        var out: [CGFloat] = []
        for _ in 0..<46 {
            h = h &* 6364136223846793005 &+ 1442695040888963407
            out.append(CGFloat((h >> 33) % 4) + 1)
        }
        return out
    }

    var body: some View {
        HStack(alignment: .center, spacing: 1.4) {
            ForEach(Array(widths.enumerated()), id: \.offset) { _, w in
                Rectangle().frame(width: w)
            }
        }
        .frame(height: height)
        .foregroundStyle(color ?? theme.fg)
        .clipped()
    }
}

// MARK: - Swatch strip

struct SwatchStrip: View {
    var colors: [Color] = Ink.swatches
    var height: CGFloat = 10

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(colors.enumerated()), id: \.offset) { _, c in
                Rectangle().foregroundStyle(c)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Ticker

/// Repeating caption rail, like the "TWO ALTERNATIVE ALPHABETS" strips.
struct Ticker: View {
    @EnvironmentObject var theme: Theme
    var text: String
    var repeats: Int = 6
    var background: Color? = nil
    var foreground: Color? = nil

    var body: some View {
        HStack(spacing: 14) {
            ForEach(0..<repeats, id: \.self) { _ in
                Text(text.uppercased())
                    .font(TW.label(8))
                    .tracking(1.8)
                Text("✦").font(.system(size: 6))
            }
        }
        .foregroundStyle(foreground ?? theme.bg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(background ?? theme.fg)
        .clipped()
    }
}

// MARK: - Tag

struct Tag: View {
    @EnvironmentObject var theme: Theme
    var text: String
    var filled: Bool = false
    var tint: Color? = nil

    var body: some View {
        Text(text.uppercased())
            .font(TW.label(9))
            .tracking(1.1)
            .foregroundStyle(filled ? theme.bg : (tint ?? theme.fg))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(filled ? (tint ?? theme.fg) : Color.clear)
            .overlay(Rectangle().strokeBorder(tint ?? theme.rule, lineWidth: 1))
    }
}

// MARK: - Buttons

struct BlockButton: View {
    @EnvironmentObject var theme: Theme
    var title: String
    var subtitle: String? = nil
    var tint: Color? = nil
    var filled: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title.uppercased())
                        .font(TW.wide(13, .heavy))
                        .tracking(0.4)
                    if let subtitle {
                        Text(subtitle.uppercased())
                            .font(TW.label(8.5))
                            .tracking(1.2)
                            .opacity(0.75)
                    }
                }
                Spacer(minLength: 6)
                Text("→").font(TW.wide(15, .black))
            }
            .foregroundStyle(filled ? theme.onAccent : theme.fg)
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(filled ? (tint ?? theme.accent) : Color.clear)
            .overlay(Rectangle().strokeBorder(filled ? Color.clear : theme.rule, lineWidth: 1.2))
        }
        .buttonStyle(.plain)
    }
}

/// Small square hard-edged control used across the labs (transport, toggles).
struct SquareButton: View {
    @EnvironmentObject var theme: Theme
    var glyph: String
    var active: Bool = false
    var tint: Color? = nil
    var size: CGFloat = 40
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(glyph)
                .font(TW.wide(14, .black))
                .foregroundStyle(active ? theme.bg : theme.fg)
                .frame(width: size, height: size)
                .background(active ? (tint ?? theme.accent) : theme.panel)
                .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1.2))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Meters & readouts

struct Readout: View {
    @EnvironmentObject var theme: Theme
    var label: String
    var value: String
    var tint: Color? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Caption(label)
            Text(value.uppercased())
                .font(TW.wide(15, .heavy))
                .foregroundStyle(tint ?? theme.fg)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MeterBar: View {
    @EnvironmentObject var theme: Theme
    var value: Double          // 0...1
    var segments: Int = 24
    var tint: Color? = nil

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<segments, id: \.self) { i in
                Rectangle()
                    .foregroundStyle(
                        Double(i) / Double(segments) < value
                            ? (tint ?? theme.accent)
                            : theme.fill.opacity(0.5)
                    )
            }
        }
        .frame(height: 8)
    }
}

// MARK: - Rules & marks

struct HardRule: View {
    @EnvironmentObject var theme: Theme
    var weight: CGFloat = 1.2
    var body: some View {
        Rectangle().frame(height: weight).foregroundStyle(theme.rule)
    }
}

/// The little register marks in the corners of the poster panels.
struct CornerTicks<Content: View>: View {
    @EnvironmentObject var theme: Theme
    @ViewBuilder var content: Content

    var body: some View {
        content.overlay(alignment: .topLeading) { tick }
            .overlay(alignment: .topTrailing) { tick }
            .overlay(alignment: .bottomLeading) { tick }
            .overlay(alignment: .bottomTrailing) { tick }
    }

    private var tick: some View {
        Text("+")
            .font(TW.mono(10, .bold))
            .foregroundStyle(theme.fgMuted)
            .padding(3)
    }
}

// MARK: - Layout helper

/// Standard screen scaffold: bone ground, swatch strip, scrolling sheet.
struct Sheet<Content: View>: View {
    @EnvironmentObject var theme: Theme
    var serial: String
    var kicker: String
    var title: String
    var subtitle: String? = nil
    @ViewBuilder var content: Content

    var body: some View {
        ZStack(alignment: .top) {
            theme.bg.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    VStack(spacing: 6) {
                        HStack {
                            Caption("N°\(serial)")
                            Rectangle().frame(height: 1).foregroundStyle(theme.rule.opacity(0.4))
                            Caption(kicker)
                        }
                        DisplayTitle(text: title, size: 36)
                        if let subtitle {
                            Text(subtitle)
                                .font(TW.body(14))
                                .foregroundStyle(theme.fgMuted)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        SwatchStrip()
                    }
                    content
                }
                .padding(.horizontal, 14)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
        }
    }
}
