import SwiftUI

struct DrumLabView: View {
    @EnvironmentObject var theme: Theme
    @EnvironmentObject var store: Store
    @EnvironmentObject var audio: AudioEngine

    @State var brush: Brush = .accent
    @State var focusDrum: Drum? = nil
    @State var showPresets = false

    enum Brush: Double, CaseIterable, Identifiable {
        case accent = 1.0
        case mid = 0.62
        case ghost = 0.32
        case erase = 0.0

        var id: Double { rawValue }
        var label: String {
            switch self {
            case .accent: return "ACCENT"
            case .mid:    return "MID"
            case .ghost:  return "GHOST"
            case .erase:  return "ERASE"
            }
        }
        var tint: Color {
            switch self {
            case .accent: return Ink.orange
            case .mid:    return Ink.clay
            case .ghost:  return Ink.concreteLo
            case .erase:  return Ink.steel
            }
        }
    }

    var body: some View {
        Sheet(serial: "002-A", kicker: "HANDS ON", title: "DRUM LAB",
              subtitle: "Paint a pattern. Everything you hear is generated on the device.") {

            transport
            brushRail
            gridPanel
            if let focusDrum { rolePanel(focusDrum) }
            mixPanel
            recipes
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            store.ensureAllLanes()
            audio.load(store.drumSketch)
        }
        .onDisappear { audio.stop() }
        .sheet(isPresented: $showPresets) {
            PresetPickerView { beat in
                var next = beat
                next.melodies = []
                next.steps = 16
                // Truncate to a single bar so it drops straight into the lab grid.
                next.drums = beat.drums.map { track in
                    DrumTrack(drum: track.drum,
                              vel: Array(track.vel.prefix(16)),
                              mix: track.mix)
                }
                store.drumSketch = padded(next)
                audio.load(store.drumSketch)
                showPresets = false
            }
            .environmentObject(theme)
        }
    }

    // MARK: Transport

    private var transport: some View {
        Panel(serial: "TRN", title: "TRANSPORT", trailing: "16 STEPS") {
            VStack(spacing: 10) {
                HStack(spacing: 8) {
                    SquareButton(glyph: audio.isPlaying ? "■" : "▶",
                                 active: audio.isPlaying, size: 44) {
                        if audio.isPlaying {
                            audio.stop()
                        } else {
                            audio.load(store.drumSketch)
                            audio.play()
                        }
                    }
                    SquareButton(glyph: "◷", active: audio.metronome, tint: Ink.plum, size: 44) {
                        audio.metronome.toggle()
                    }
                    SquareButton(glyph: "⌫", size: 44) { clear() }
                    SquareButton(glyph: "⚙", size: 44) { showPresets = true }
                    Spacer(minLength: 0)
                    MeterBar(value: audio.level, segments: 10).frame(width: 62)
                }

                labelledSlider(title: "TEMPO", value: Int(store.drumSketch.bpm), unit: "BPM",
                               binding: Binding(
                                get: { store.drumSketch.bpm },
                                set: { store.drumSketch.bpm = $0; audio.bpm = $0 }),
                               range: 60...180)

                labelledSlider(title: "SWING", value: Int(store.drumSketch.swing * 100), unit: "%",
                               binding: Binding(
                                get: { store.drumSketch.swing },
                                set: { store.drumSketch.swing = $0; audio.swing = $0 }),
                               range: 0...0.6)
            }
        }
    }

    private func labelledSlider(title: String, value: Int, unit: String,
                                binding: Binding<Double>,
                                range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Caption(title)
                Spacer()
                Text("\(value) \(unit)")
                    .font(TW.mono(11, .bold))
                    .foregroundStyle(theme.fg)
            }
            Slider(value: binding, in: range)
                .tint(theme.accent)
        }
    }

    // MARK: Brush

    private var brushRail: some View {
        Panel(serial: "VEL", title: "BRUSH", trailing: "TAP OR DRAG THE GRID") {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    ForEach(Brush.allCases) { b in
                        Button { brush = b } label: {
                            Text(b.label)
                                .font(TW.label(8.5)).tracking(0.9)
                                .foregroundStyle(brush == b ? theme.bg : theme.fg)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(brush == b ? b.tint : Color.clear)
                                .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
                Text(brushHint)
                    .font(TW.body(12.5))
                    .foregroundStyle(theme.fgMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var brushHint: String {
        switch brush {
        case .accent: return "Full-strength hits. Use these on the four downbeats — steps 1, 5, 9 and 13."
        case .mid:    return "Around 60%. The in-between hats that keep a pattern moving without shouting."
        case .ghost:  return "Around 30%. Ghost snares and quiet hats. Barely audible, entirely responsible for the groove."
        case .erase:  return "Removes hits. Subtraction fixes more patterns than addition."
        }
    }

    // MARK: Grid

    private var gridPanel: some View {
        Panel(serial: "GRD", title: "PATTERN", trailing: "1 BAR / 16TH NOTES", padded: false) {
            VStack(spacing: 6) {
                StepRuler(steps: 16, playhead: audio.isPlaying ? audio.playhead : -1)
                    .padding(.horizontal, 10)

                HStack(alignment: .top, spacing: 6) {
                    VStack(spacing: 2) {
                        ForEach(Drum.allCases) { drum in
                            Button {
                                focusDrum = (focusDrum == drum) ? nil : drum
                                audio.audition(drum)
                            } label: {
                                HStack(spacing: 3) {
                                    Rectangle()
                                        .frame(width: 3)
                                        .foregroundStyle(drum.tint)
                                    Text(drum.short)
                                        .font(TW.label(8))
                                        .foregroundStyle(theme.fg)
                                    Spacer(minLength: 0)
                                }
                                .frame(width: 42, height: 26)
                                .background(focusDrum == drum ? drum.tint.opacity(0.25) : Color.clear)
                                .overlay(Rectangle().strokeBorder(theme.rule.opacity(0.35), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    StepGrid(beat: $store.drumSketch,
                             playhead: audio.isPlaying ? audio.playhead : -1,
                             brushValue: brush.rawValue,
                             onEdit: { audio.upload(store.drumSketch) },
                             onPaintSound: { drum in
                                 if brush != .erase && !audio.isPlaying {
                                     audio.audition(drum, vel: brush.rawValue)
                                 }
                             })
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            }
        }
    }

    private func rolePanel(_ drum: Drum) -> some View {
        Panel(serial: "SND", title: "\(drum.name) — SOUND DESIGN", tint: drum.tint) {
            VStack(alignment: .leading, spacing: 10) {
                Text(drum.role)
                    .font(TW.body(14))
                    .foregroundStyle(theme.fg)
                    .fixedSize(horizontal: false, vertical: true)

                knob("TUNE", laneBinding(drum, \.tune), -12...12, format: { "\(Int($0)) ST" })
                knob("TONE", laneBinding(drum, \.tone), 0...1, format: pct)
                knob("DECAY", laneBinding(drum, \.decay), 0...1, format: pct)
                knob("DRIVE", laneBinding(drum, \.drive), 0...1, format: pct)
                knob("REVERB", laneBinding(drum, \.reverb), 0...0.6, format: pct)
                knob("PAN", laneBinding(drum, \.pan), -1...1, format: panLabel)
                knob("LEVEL", laneBinding(drum, \.gain), 0...1.4, format: pct)

                Button { audio.audition(drum) } label: {
                    Text("AUDITION")
                        .font(TW.label(9)).tracking(1.2)
                        .foregroundStyle(theme.bg)
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(drum.tint)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: Mix

    private var mixPanel: some View {
        Panel(serial: "MIX", title: "BUS & MASTER", trailing: "STAGE 05") {
            VStack(alignment: .leading, spacing: 10) {
                Text("These are the same controls the MIXING stage describes. Move one while the loop plays and you'll hear exactly what the lesson means.")
                    .font(TW.body(12.5))
                    .foregroundStyle(theme.fgMuted)
                    .fixedSize(horizontal: false, vertical: true)

                knob("SIDECHAIN", mixBinding(\.sidechain), 0...1, format: pct)
                knob("SC RELEASE", mixBinding(\.sidechainRelease), 0.04...0.4,
                     format: { "\(Int($0 * 1000)) MS" })
                knob("DRUM DRIVE", mixBinding(\.drumDrive), 0...1, format: pct)
                knob("DRUM GLUE", mixBinding(\.drumGlue), 0...1, format: pct)
                knob("REVERB SIZE", mixBinding(\.reverbSize), 0...1, format: pct)
                knob("REVERB DAMP", mixBinding(\.reverbDamp), 0...1, format: pct)
                knob("WIDTH", mixBinding(\.width), 0...1, format: pct)
                knob("HUMANIZE", mixBinding(\.humanize), 0...1, format: pct)
                knob("MASTER DRIVE", mixBinding(\.masterDrive), 0...0.6, format: pct)

                HStack(spacing: 8) {
                    Caption("GAIN REDUCTION")
                    MeterBar(value: min(1, audio.gainReduction / 8.0), segments: 16, tint: Ink.amber)
                    Text("\(String(format: "%.1f", audio.gainReduction)) dB")
                        .font(TW.mono(10, .bold))
                        .foregroundStyle(theme.fgMuted)
                }
            }
        }
    }

    // MARK: Control helpers

    private func knob(_ label: String, _ binding: Binding<Double>,
                      _ range: ClosedRange<Double>,
                      format: @escaping (Double) -> String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Caption(label)
                Spacer()
                Text(format(binding.wrappedValue))
                    .font(TW.mono(10, .bold))
                    .foregroundStyle(theme.fg)
            }
            Slider(value: binding, in: range).tint(theme.accent)
        }
    }

    private func pct(_ v: Double) -> String { "\(Int(v * 100))%" }

    private func panLabel(_ v: Double) -> String {
        if abs(v) < 0.03 { return "C" }
        return "\(v < 0 ? "L" : "R")\(Int(abs(v) * 100))"
    }

    private func mixBinding(_ path: WritableKeyPath<MixSettings, Double>) -> Binding<Double> {
        Binding(
            get: { store.drumSketch.mix[keyPath: path] },
            set: {
                store.drumSketch.mix[keyPath: path] = $0
                audio.upload(store.drumSketch)
            }
        )
    }

    private func laneBinding(_ drum: Drum,
                             _ path: WritableKeyPath<TrackMix, Double>) -> Binding<Double> {
        Binding(
            get: {
                store.drumSketch.drums.first { $0.drum == drum }?.mix[keyPath: path]
                    ?? drum.defaultMix[keyPath: path]
            },
            set: { newValue in
                guard let i = store.drumSketch.drums.firstIndex(where: { $0.drum == drum })
                else { return }
                store.drumSketch.drums[i].mix[keyPath: path] = newValue
                audio.upload(store.drumSketch)
            }
        )
    }

    // MARK: Recipes

    private var recipes: some View {
        Panel(serial: "RCP", title: "TRY THIS") {
            VStack(alignment: .leading, spacing: 9) {
                recipe("THE SKELETON", "Kick on 1. Snare on 5 and 13. Nothing else. Play it — that's already a beat.")
                recipe("ADD THE CLOCK", "Mid hats on every other step. Now it has speed.")
                recipe("MAKE IT HUMAN", "Accent steps 1, 5, 9, 13. Ghost everything in between. Same notes, alive.")
                recipe("ONE OPEN HAT", "Put an open hat on step 15. The bar suddenly breathes into the next one.")
                recipe("MOVE THE SECOND KICK", "Try step 11, then 8, then 4. Each one is a different genre.")
            }
        }
    }

    private func recipe(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(TW.wide(11, .heavy)).tracking(0.6)
                .foregroundStyle(theme.accent)
            Text(body)
                .font(TW.body(13.5))
                .foregroundStyle(theme.fg)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Helpers

    private func clear() {
        var beat = store.drumSketch
        for i in beat.drums.indices {
            beat.drums[i].vel = Array(repeating: 0, count: beat.steps)
        }
        store.drumSketch = beat
        audio.upload(beat)
    }

    /// Guarantees every lane exists and is exactly `steps` long.
    private func padded(_ beat: Beat) -> Beat {
        var out = beat
        for drum in Drum.allCases where !out.drums.contains(where: { $0.drum == drum }) {
            out.drums.append(DrumTrack(drum: drum, vel: [], mix: drum.defaultMix))
        }
        for i in out.drums.indices {
            var v = out.drums[i].vel
            if v.count < out.steps {
                v.append(contentsOf: Array(repeating: 0, count: out.steps - v.count))
            } else if v.count > out.steps {
                v = Array(v.prefix(out.steps))
            }
            out.drums[i].vel = v
        }
        out.drums.sort { $0.drum.rawValue < $1.drum.rawValue }
        return out
    }
}

// MARK: - Step ruler

struct StepRuler: View {
    @EnvironmentObject var theme: Theme
    var steps: Int
    var playhead: Int

    var body: some View {
        HStack(spacing: 6) {
            Color.clear.frame(width: 42, height: 1)
            GeometryReader { geo in
                let gap: CGFloat = 2
                let w = (geo.size.width - CGFloat(steps - 1) * gap) / CGFloat(steps)
                HStack(spacing: gap) {
                    ForEach(0..<steps, id: \.self) { i in
                        Text(i % 4 == 0 ? "\(i / 4 + 1)" : "·")
                            .font(TW.label(i % 4 == 0 ? 9 : 7))
                            .foregroundStyle(i == playhead ? theme.accent : theme.fgMuted)
                            .frame(width: w)
                    }
                }
            }
            .frame(height: 12)
        }
    }
}

// MARK: - Editable step grid

struct StepGrid: View {
    @EnvironmentObject var theme: Theme
    @Binding var beat: Beat
    var playhead: Int
    var brushValue: Double
    var onEdit: () -> Void
    var onPaintSound: (Drum) -> Void

    let rowH: CGFloat = 26
    let gap: CGFloat = 2

    @State var lastCell: String = ""

    private var lanes: [Drum] { Drum.allCases }

    var body: some View {
        GeometryReader { geo in
            let cols = max(1, beat.steps)
            let cellW = (geo.size.width - CGFloat(cols - 1) * gap) / CGFloat(cols)

            VStack(spacing: gap) {
                ForEach(Array(lanes.enumerated()), id: \.element.id) { _, drum in
                    HStack(spacing: gap) {
                        ForEach(0..<cols, id: \.self) { step in
                            let v = velocity(drum, step)
                            Rectangle()
                                .foregroundStyle(fill(drum: drum, step: step, v: v))
                                .frame(width: max(4, cellW), height: rowH)
                                .overlay(
                                    Rectangle()
                                        .strokeBorder(theme.rule.opacity(step % 4 == 0 ? 0.45 : 0.15),
                                                      lineWidth: 1)
                                )
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        paint(at: value.location, cellW: cellW, cols: cols)
                    }
                    .onEnded { _ in lastCell = "" }
            )
        }
        .frame(height: CGFloat(lanes.count) * rowH + CGFloat(lanes.count - 1) * gap)
    }

    private func velocity(_ drum: Drum, _ step: Int) -> Double {
        guard let track = beat.drums.first(where: { $0.drum == drum }) else { return 0 }
        return track.velocity(at: step)
    }

    private func fill(drum: Drum, step: Int, v: Double) -> Color {
        if step == playhead {
            return v > 0 ? drum.tint : theme.fill.opacity(0.65)
        }
        if v <= 0 {
            return (step % 4 == 0) ? theme.fill.opacity(0.42) : theme.fill.opacity(0.18)
        }
        return drum.tint.opacity(0.3 + 0.7 * v)
    }

    private func paint(at point: CGPoint, cellW: CGFloat, cols: Int) {
        let row = Int(point.y / (rowH + gap))
        let col = Int(point.x / (cellW + gap))
        guard row >= 0, row < lanes.count, col >= 0, col < cols else { return }

        let key = "\(row):\(col)"
        guard key != lastCell else { return }
        lastCell = key

        let drum = lanes[row]
        guard let index = beat.drums.firstIndex(where: { $0.drum == drum }) else { return }
        var vel = beat.drums[index].vel
        if vel.count < cols {
            vel.append(contentsOf: Array(repeating: 0, count: cols - vel.count))
        }
        vel[col] = brushValue
        beat.drums[index].vel = vel

        onEdit()
        if brushValue > 0 { onPaintSound(drum) }
    }
}

// MARK: - Preset picker

struct PresetPickerView: View {
    @EnvironmentObject var theme: Theme
    @Environment(\.dismiss) var dismiss
    var onPick: (Beat) -> Void

    private var options: [(String, String, Beat)] {
        var out: [(String, String, Beat)] = [
            ("SKELETON", "Kick and snare only. The starting point for everything.", DemoBeats.threeJobs),
            ("SHAPED HATS", "Accents and ghosts. Hear what velocity does.", DemoBeats.velocityShaped)
        ]
        // Genre kits bring their tuning, drive and bus settings with them, so
        // loading one is a lesson in sound design as much as in patterns.
        for t in Templates.all {
            out.append(("\(t.name) KIT",
                        "\(Int(t.bpm)) BPM · \(t.tagline.lowercased())",
                        t.beat))
        }
        return out
    }

    var body: some View {
        ZStack(alignment: .top) {
            theme.bg.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 12) {
                    DisplayTitle(text: "LOAD PATTERN", size: 28)
                    Text("These replace the grid. Your current pattern will be lost.")
                        .font(TW.body(13))
                        .foregroundStyle(theme.fgMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                        Button { onPick(option.2) } label: {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(option.0)
                                    .font(TW.wide(15, .black))
                                    .foregroundStyle(theme.fg)
                                Text(option.1)
                                    .font(TW.body(13))
                                    .foregroundStyle(theme.fgMuted)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(11)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(theme.panel)
                            .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1.2))
                        }
                        .buttonStyle(.plain)
                    }

                    Button { dismiss() } label: {
                        Text("CANCEL")
                            .font(TW.label(10)).tracking(1.4)
                            .foregroundStyle(theme.fg)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1.2))
                    }
                    .buttonStyle(.plain)
                }
                .padding(14)
            }
        }
    }
}
