import SwiftUI

struct LabHomeView: View {
    @EnvironmentObject var theme: Theme
    @EnvironmentObject var audio: AudioEngine

    var body: some View {
        Sheet(serial: "002", kicker: "INTERACTIVE",
              title: "LABS",
              subtitle: "Two sandboxes with a real synth engine underneath. Nothing here needs an internet connection or a sample pack.") {

            NavigationLink { DrumLabView() } label: {
                LabCard(title: "DRUM LAB",
                        serial: "002-A",
                        blurb: "A nine-lane, sixteen-step grid. Paint hits at three velocities, set the swing, and hear what each choice does to the groove.",
                        bullets: ["Velocity brushes — accent, mid, ghost",
                                  "Swing from dead straight to full shuffle",
                                  "Load a genre skeleton and take it apart"],
                        tint: Ink.orange)
            }
            .buttonStyle(.plain)

            NavigationLink { PianoRollView() } label: {
                LabCard(title: "PIANO ROLL",
                        serial: "002-B",
                        blurb: "Fifteen rows of pitch against the same sixteen steps. Scale lock greys out every note that would sound wrong.",
                        bullets: ["Seven scales with plain-English moods",
                                  "Chord stamp — triads, 7ths and sus shapes",
                                  "Six synth voices from sub to bell"],
                        tint: Ink.plum)
            }
            .buttonStyle(.plain)

            Panel(serial: "SND", title: "ABOUT THE SOUND") {
                VStack(alignment: .leading, spacing: 9) {
                    Text("Every drum and note here is synthesised in real time on your phone — no samples are bundled, so the app stays small and works with no connection.")
                        .font(TW.body(14))
                        .foregroundStyle(theme.fg)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("It is not a beeping toy sequencer. Kicks have separate click, body and sub layers with two pitch envelopes. Hats and cymbals are six square oscillators at inharmonic ratios, the way an 808 builds metal. Claps are four bursts a few milliseconds apart. Underneath that sits a real mixer: a drum bus with saturation and glue compression, kick-triggered sidechain ducking, an eight-comb reverb and a tempo-synced ping-pong delay on sends, stereo width, and a glued and limited master.")
                        .font(TW.body(14))
                        .foregroundStyle(theme.fg)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("That's why the genre templates sound like records rather than sketches — and why the MIX panel in the Drum Lab is worth playing with while a loop runs.")
                        .font(TW.body(13))
                        .foregroundStyle(theme.fgMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Panel(serial: "OUT", title: "OUTPUT") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Caption("MASTER")
                        Spacer()
                        Text("\(Int(audio.masterVolume * 100))%")
                            .font(TW.mono(11, .bold))
                            .foregroundStyle(theme.fg)
                    }
                    Slider(value: $audio.masterVolume, in: 0...1).tint(theme.accent)
                    Text("The app mixes with other audio rather than interrupting it, so you can leave a reference loop running next to your DAW.")
                        .font(TW.body(12.5))
                        .foregroundStyle(theme.fgMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

private struct LabCard: View {
    @EnvironmentObject var theme: Theme
    var title: String
    var serial: String
    var blurb: String
    var bullets: [String]
    var tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Text(serial)
                    .font(TW.label(9))
                    .foregroundStyle(theme.bg)
                    .padding(.horizontal, 5).padding(.vertical, 2)
                    .background(tint)
                Rectangle().frame(height: 1).foregroundStyle(theme.rule.opacity(0.4))
                Text("→").font(TW.wide(14, .black)).foregroundStyle(theme.fg)
            }
            .padding(.horizontal, 10).padding(.top, 8).padding(.bottom, 6)

            DisplayTitle(text: title, size: 30)
                .padding(.horizontal, 10)

            Text(blurb)
                .font(TW.body(13.5))
                .foregroundStyle(theme.fgMuted)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 10)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(bullets.enumerated()), id: \.offset) { _, b in
                    HStack(alignment: .top, spacing: 6) {
                        Rectangle().frame(width: 5, height: 5).foregroundStyle(tint).padding(.top, 5)
                        Text(b)
                            .font(TW.mono(11.5))
                            .foregroundStyle(theme.fg)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            .padding(10)

            SwatchStrip(colors: [tint, theme.fill, Ink.black, Ink.clay, Ink.amber], height: 6)
        }
        .background(theme.panel)
        .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1.2))
    }
}
