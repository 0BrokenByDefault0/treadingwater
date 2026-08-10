import SwiftUI

struct TemplatesView: View {
    @EnvironmentObject var theme: Theme

    var body: some View {
        Sheet(serial: "004", kicker: "REFERENCE",
              title: "TEMPLATES",
              subtitle: "Finished reference beats, pulled apart. Leave one playing next to your DAW while you build your own.") {

            ForEach(Templates.all) { template in
                NavigationLink { TemplateDetailView(template: template) } label: {
                    TemplateCard(template: template)
                }
                .buttonStyle(.plain)
            }

            Ticker(text: "REFERENCE · NOT A RULE · STEAL THE SKELETON", repeats: 3)
        }
        .navigationBarHidden(true)
    }
}

struct TemplateCard: View {
    @EnvironmentObject var theme: Theme
    var template: GenreTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Caption("N°\(String.serial(Templates.all.firstIndex(where: { $0.id == template.id }).map { $0 + 1 } ?? 0, 3))")
                Rectangle().frame(height: 1).foregroundStyle(theme.rule.opacity(0.4))
                Caption("\(Int(template.bpm)) BPM")
                Caption(template.keyName, color: template.tint)
            }
            .padding(.horizontal, 10).padding(.top, 8)

            DisplayTitle(text: template.name, size: 34, color: template.tint)
                .padding(.horizontal, 10)

            Text(template.tagline)
                .font(TW.label(9)).tracking(1.3)
                .foregroundStyle(theme.fgMuted)
                .padding(.horizontal, 10)
                .padding(.top, 2)

            DrumGridPreview(beat: template.beat, tint: template.tint)
                .padding(.horizontal, 10)
                .padding(.top, 8)

            HStack(spacing: 8) {
                Text(template.feel)
                    .font(TW.body(12.5))
                    .foregroundStyle(theme.fg)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 4)
                Text("→").font(TW.wide(15, .black)).foregroundStyle(theme.fg)
            }
            .padding(10)

            SwatchStrip(colors: [template.tint, theme.fill, Ink.black, Ink.concreteLo, Ink.amber], height: 6)
        }
        .background(theme.panel)
        .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1.2))
    }
}

// MARK: - Detail

struct TemplateDetailView: View {
    @EnvironmentObject var theme: Theme
    @EnvironmentObject var audio: AudioEngine
    var template: GenreTemplate

    var body: some View {
        Sheet(serial: template.id.uppercased(),
              kicker: "\(Int(template.bpm)) BPM · \(template.keyName)",
              title: template.name,
              subtitle: template.tagline) {

            PatternPlayer(beat: template.beat, caption: template.feel, tint: template.tint)

            Panel(serial: "SPC", title: "SPEC") {
                HStack(spacing: 10) {
                    Readout(label: "TEMPO", value: "\(Int(template.bpm))", tint: template.tint)
                    Readout(label: "KEY", value: template.keyName)
                    Readout(label: "SCALE", value: template.scaleName)
                    Readout(label: "SWING", value: "\(Int(template.beat.swing * 100))%")
                }
            }

            listPanel("WHY IT WORKS", "WRK", template.makesItWork, template.tint)
            listPanel("SOUND PALETTE", "PAL", template.palette, Ink.clay)

            Panel(serial: "ARR", title: "ARRANGEMENT MAP") {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(template.structure) { s in
                        HStack(alignment: .top, spacing: 8) {
                            VStack(spacing: 1) {
                                Text(s.section)
                                    .font(TW.label(8.5)).tracking(0.8)
                                    .foregroundStyle(theme.bg)
                                Text(s.bars + " BARS")
                                    .font(TW.label(7))
                                    .foregroundStyle(theme.bg.opacity(0.8))
                            }
                            .frame(width: 84)
                            .padding(.vertical, 5)
                            .background(template.tint)

                            Text(s.whats)
                                .font(TW.body(13.5))
                                .foregroundStyle(theme.fg)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }

            listPanel("MIX NOTES", "MIX", template.mixNotes, Ink.plum)

            Panel(serial: "ERR", title: "WHAT GOES WRONG", tint: Ink.orange) {
                VStack(alignment: .leading, spacing: 9) {
                    ForEach(Array(template.mistakes.enumerated()), id: \.offset) { _, m in
                        HStack(alignment: .top, spacing: 8) {
                            Text("✕")
                                .font(TW.wide(11, .black))
                                .foregroundStyle(Ink.orange)
                            Text(m)
                                .font(TW.body(14))
                                .foregroundStyle(theme.fg)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }

            Ticker(text: "\(template.name) · \(Int(template.bpm)) BPM · \(template.keyName)",
                   repeats: 3, background: template.tint)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { audio.stop() }
    }

    private func listPanel(_ title: String, _ serial: String, _ items: [String], _ tint: Color) -> some View {
        Panel(serial: serial, title: title, tint: tint) {
            VStack(alignment: .leading, spacing: 9) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .top, spacing: 8) {
                        Rectangle()
                            .frame(width: 6, height: 6)
                            .foregroundStyle(tint)
                            .padding(.top, 5)
                        Text(item)
                            .font(TW.body(14))
                            .foregroundStyle(theme.fg)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}
