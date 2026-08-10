import SwiftUI

enum TWTab: String, CaseIterable, Identifiable {
    case path = "PATH"
    case lab = "LAB"
    case decode = "DECODE"
    case refs = "REF"
    case stuck = "STUCK"

    var id: String { rawValue }

    var serial: String {
        switch self {
        case .path:   return "001"
        case .lab:    return "002"
        case .decode: return "003"
        case .refs:   return "004"
        case .stuck:  return "005"
        }
    }

    var glyph: String {
        switch self {
        case .path:   return "▚"
        case .lab:    return "▦"
        case .decode: return "◆"
        case .refs:   return "▤"
        case .stuck:  return "!"
        }
    }
}

struct RootView: View {
    @EnvironmentObject var theme: Theme
    @EnvironmentObject var audio: AudioEngine
    @State var tab: TWTab = .path

    var body: some View {
        ZStack(alignment: .bottom) {
            theme.bg.ignoresSafeArea()

            Group {
                switch tab {
                case .path:   NavigationStack { PathView() }
                case .lab:    NavigationStack { LabHomeView() }
                case .decode: NavigationStack { DecodeView() }
                case .refs:   NavigationStack { TemplatesView() }
                case .stuck:  NavigationStack { StuckView() }
                }
            }

            VStack(spacing: 0) {
                if audio.isPlaying {
                    MiniTransport()
                }
                TabRail(tab: $tab)
            }
        }
    }
}

// MARK: - Tab rail

private struct TabRail: View {
    @EnvironmentObject var theme: Theme
    @Binding var tab: TWTab

    var body: some View {
        VStack(spacing: 0) {
            HardRule(weight: 1.4)
            HStack(spacing: 0) {
                ForEach(TWTab.allCases) { t in
                    Button {
                        tab = t
                    } label: {
                        VStack(spacing: 3) {
                            Text(t.glyph)
                                .font(.system(size: 13, weight: .black))
                            Text(t.rawValue)
                                .font(TW.label(8.5))
                                .tracking(1.0)
                        }
                        .foregroundStyle(tab == t ? theme.bg : theme.fg)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 9)
                        .padding(.bottom, 4)
                        .background(tab == t ? theme.accent : theme.panel)
                        .overlay(alignment: .trailing) {
                            Rectangle().frame(width: 1).foregroundStyle(theme.rule.opacity(0.4))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .background(theme.panel)
    }
}

// MARK: - Mini transport
//
// Follows you across every screen so a loop keeps playing while you read.

private struct MiniTransport: View {
    @EnvironmentObject var theme: Theme
    @EnvironmentObject var audio: AudioEngine

    var body: some View {
        HStack(spacing: 10) {
            Button { audio.stop() } label: {
                Text("■")
                    .font(TW.wide(13, .black))
                    .foregroundStyle(theme.bg)
                    .frame(width: 28, height: 24)
                    .background(theme.accent)
            }
            .buttonStyle(.plain)

            Caption("PLAYING", color: theme.fg)

            Text("\(Int(audio.bpm)) BPM")
                .font(TW.mono(10, .semibold))
                .foregroundStyle(theme.fgMuted)

            Spacer(minLength: 4)

            MeterBar(value: audio.level, segments: 14)
                .frame(width: 80)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(theme.panel)
        .overlay(alignment: .top) { HardRule() }
    }
}
