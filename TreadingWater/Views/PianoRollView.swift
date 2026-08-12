import SwiftUI

struct PianoRollView: View {
    @EnvironmentObject var theme: Theme
    @EnvironmentObject var store: Store
    @EnvironmentObject var audio: AudioEngine

    @State var root: Int = 9          // pitch class, 9 = A
    @State var scaleIndex: Int = 0    // Scale.all
    @State var scaleLock = true
    @State var basePitch: Int = 57    // bottom row, A3
    @State var noteLength: Int = 2
    @State var chordMode = false
    @State var chordIndex: Int = 0
    @State var timbre: TrackTimbre = .keys
    @State var drumsOn = true

    let rows = 15

    private var scale: Scale { Scale.all[min(scaleIndex, Scale.all.count - 1)] }
    private var chord: ChordShape { ChordShape.all[min(chordIndex, ChordShape.all.count - 1)] }

    private var pitches: [Int] {
        Array((basePitch..<(basePitch + rows)).reversed())
    }

    var body: some View {
        Sheet(serial: "002-B", kicker: "HANDS ON", title: "PIANO ROLL",
              subtitle: "Turn scale lock on and you physically cannot place a wrong note.") {

            transport
            scalePanel
            rollPanel
            toolPanel
            guidance
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { audio.load(playableBeat) }
        .onDisappear { audio.stop() }
    }

    // MARK: Playable

    private var playableBeat: Beat {
        var beat = store.rollSketch
        beat.steps = 16
        if !drumsOn {
            beat.drums = []
        }
        if beat.melodies.isEmpty {
            beat.melodies = [MelodyTrack("LEAD", timbre, [])]
        } else {
            beat.melodies[0].timbre = timbre
        }
        return beat
    }

    private func refresh() {
        audio.upload(playableBeat)
    }

    // MARK: Transport

    private var transport: some View {
        Panel(serial: "TRN", title: "TRANSPORT") {
            HStack(spacing: 8) {
                SquareButton(glyph: audio.isPlaying ? "■" : "▶",
                             active: audio.isPlaying, size: 44) {
                    if audio.isPlaying {
                        audio.stop()
                    } else {
                        audio.load(playableBeat)
                        audio.play()
                    }
                }
                SquareButton(glyph: "♪", active: drumsOn, tint: Ink.clay, size: 44) {
                    drumsOn.toggle()
                    refresh()
                }
                SquareButton(glyph: "⌫", size: 44) {
                    store.rollSketch.melodies = [MelodyTrack("LEAD", timbre, [])]
                    refresh()
                }
                Spacer(minLength: 0)
                VStack(alignment: .trailing, spacing: 2) {
                    Caption("TEMPO")
                    Text("\(Int(store.rollSketch.bpm)) BPM")
                        .font(TW.mono(11, .bold))
                        .foregroundStyle(theme.fg)
                }
            }
        }
    }

    // MARK: Scale

    private var scalePanel: some View {
        Panel(serial: "KEY", title: "KEY & SCALE",
              trailing: scaleLock ? "LOCK ON" : "LOCK OFF",
              tint: scaleLock ? Ink.orange : Ink.steel) {
            VStack(alignment: .leading, spacing: 9) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(0..<12, id: \.self) { pc in
                            Button { root = pc } label: {
                                Text(Theory.noteNames[pc])
                                    .font(TW.label(9.5))
                                    .foregroundStyle(root == pc ? theme.bg : theme.fg)
                                    .frame(width: 30, height: 28)
                                    .background(root == pc ? theme.accent : Color.clear)
                                    .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(Array(Scale.all.enumerated()), id: \.offset) { i, s in
                            Button { scaleIndex = i } label: {
                                Tag(text: s.name, filled: scaleIndex == i, tint: Ink.clay)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Text(scale.mood)
                    .font(TW.body(13))
                    .foregroundStyle(theme.fgMuted)
                    .fixedSize(horizontal: false, vertical: true)

                Button { scaleLock.toggle() } label: {
                    HStack {
                        Text(scaleLock ? "SCALE LOCK: ON" : "SCALE LOCK: OFF")
                            .font(TW.label(9.5)).tracking(1.2)
                        Spacer()
                        Text(scaleLock ? "✓" : "—").font(TW.wide(12, .black))
                    }
                    .foregroundStyle(scaleLock ? theme.onAccent : theme.fg)
                    .padding(.horizontal, 10).padding(.vertical, 9)
                    .background(scaleLock ? theme.accent : Color.clear)
                    .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1.2))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: Roll

    private var rollPanel: some View {
        Panel(serial: "ROL", title: "ROLL", trailing: "1 BAR / 16TH", padded: false) {
            VStack(spacing: 6) {
                StepRuler(steps: 16, playhead: audio.isPlaying ? audio.playhead : -1)
                    .padding(.horizontal, 10)

                HStack(alignment: .top, spacing: 6) {
                    keyboardColumn
                    rollGrid
                }
                .padding(.horizontal, 10)

                HStack(spacing: 6) {
                    Button { basePitch = max(24, basePitch - 12) } label: {
                        Text("OCT −").font(TW.label(9))
                            .foregroundStyle(theme.fg)
                            .frame(maxWidth: .infinity).padding(.vertical, 8)
                            .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    Text(Theory.fullName(for: basePitch) + " → " + Theory.fullName(for: basePitch + rows - 1))
                        .font(TW.mono(10))
                        .foregroundStyle(theme.fgMuted)
                    Button { basePitch = min(96, basePitch + 12) } label: {
                        Text("OCT +").font(TW.label(9))
                            .foregroundStyle(theme.fg)
                            .frame(maxWidth: .infinity).padding(.vertical, 8)
                            .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            }
        }
    }

    private var keyboardColumn: some View {
        VStack(spacing: 1) {
            ForEach(pitches, id: \.self) { pitch in
                let inScale = scale.contains(pitch, root: root)
                HStack(spacing: 0) {
                    Text(Theory.name(for: pitch))
                        .font(TW.label(7.5))
                        .foregroundStyle(Theory.isBlackKey(pitch) ? theme.bg : theme.fg)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 3)
                }
                .frame(width: 34, height: 20)
                .background(Theory.isBlackKey(pitch) ? theme.fg : theme.panel)
                .overlay(alignment: .trailing) {
                    Rectangle()
                        .frame(width: 3)
                        .foregroundStyle(inScale ? theme.accent.opacity(0.8) : Color.clear)
                }
                .overlay(Rectangle().strokeBorder(theme.rule.opacity(0.3), lineWidth: 0.5))
            }
        }
    }

    private var rollGrid: some View {
        GeometryReader { geo in
            let cols = 16
            let gap: CGFloat = 1
            let cellW = (geo.size.width - CGFloat(cols - 1) * gap) / CGFloat(cols)
            let rowH: CGFloat = 21

            ZStack(alignment: .topLeading) {
                VStack(spacing: gap) {
                    ForEach(Array(pitches.enumerated()), id: \.element) { _, pitch in
                        let inScale = scale.contains(pitch, root: root)
                        HStack(spacing: gap) {
                            ForEach(0..<cols, id: \.self) { step in
                                Rectangle()
                                    .foregroundStyle(cellColor(pitch: pitch, step: step, inScale: inScale))
                                    .frame(width: max(4, cellW), height: rowH - gap)
                                    .overlay(
                                        Rectangle().strokeBorder(
                                            theme.rule.opacity(step % 4 == 0 ? 0.35 : 0.12),
                                            lineWidth: 1)
                                    )
                            }
                        }
                    }
                }

                // Notes drawn on top so their full length reads clearly.
                ForEach(noteList) { note in
                    if let rowIndex = pitches.firstIndex(of: note.pitch) {
                        Rectangle()
                            .foregroundStyle(theme.accent)
                            .frame(width: max(4, CGFloat(note.length) * (cellW + gap) - gap),
                                   height: rowH - gap)
                            .overlay(Rectangle().strokeBorder(theme.fg, lineWidth: 1))
                            .offset(x: CGFloat(note.start) * (cellW + gap),
                                    y: CGFloat(rowIndex) * rowH)
                            .allowsHitTesting(false)
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        tap(at: value.location, cellW: cellW, gap: gap, rowH: rowH, cols: cols)
                    }
            )
        }
        .frame(height: CGFloat(rows) * 21)
    }

    private var noteList: [Note] {
        store.rollSketch.melodies.first?.notes ?? []
    }

    private func cellColor(pitch: Int, step: Int, inScale: Bool) -> Color {
        if step == audio.playhead && audio.isPlaying {
            return theme.fill.opacity(0.75)
        }
        if scaleLock && !inScale {
            return theme.fill.opacity(theme.night ? 0.5 : 0.55)
        }
        if pitch % 12 == root {
            return theme.accent.opacity(0.16)
        }
        return (step % 4 == 0) ? theme.fill.opacity(0.28) : theme.fill.opacity(0.12)
    }

    // MARK: Editing

    private func tap(at point: CGPoint, cellW: CGFloat, gap: CGFloat, rowH: CGFloat, cols: Int) {
        let rowIndex = Int(point.y / rowH)
        let step = Int(point.x / (cellW + gap))
        guard rowIndex >= 0, rowIndex < pitches.count, step >= 0, step < cols else { return }

        let pitch = pitches[rowIndex]
        if scaleLock && !scale.contains(pitch, root: root) { return }

        if store.rollSketch.melodies.isEmpty {
            store.rollSketch.melodies = [MelodyTrack("LEAD", timbre, [])]
        }
        var notes = store.rollSketch.melodies[0].notes

        // Tapping an existing note removes it (and its chord siblings).
        if let hit = notes.first(where: {
            $0.pitch == pitch && step >= $0.start && step < $0.start + $0.length
        }) {
            if chordMode {
                // Chord mode places whole chords, so it removes whole chords.
                notes.removeAll { $0.start == hit.start }
            } else {
                notes.removeAll { $0.id == hit.id }
            }
        } else {
            let newPitches = chordMode ? chordPitches(from: pitch) : [pitch]
            for p in newPitches {
                guard p >= basePitch - 24, p <= basePitch + 36 else { continue }
                notes.removeAll { $0.pitch == p && $0.start == step }
                notes.append(Note(p, step, min(noteLength, cols - step)))
            }
            audio.audition(pitch: pitch, timbre: timbre)
        }

        store.rollSketch.melodies[0].notes = notes
        store.rollSketch.melodies[0].timbre = timbre
        refresh()
    }

    /// Chord tones snapped into the current scale so stamps never go sour.
    private func chordPitches(from rootPitch: Int) -> [Int] {
        guard chordMode else { return [rootPitch] }
        return chord.intervals.map { rootPitch + $0 }
    }

    // MARK: Tools

    private var toolPanel: some View {
        Panel(serial: "TLS", title: "TOOLS") {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Caption("SOUND")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(TrackTimbre.allCases) { t in
                                Button {
                                    timbre = t
                                    if !store.rollSketch.melodies.isEmpty {
                                        store.rollSketch.melodies[0].timbre = t
                                        store.rollSketch.melodies[0].mix = t.defaultMix
                                    }
                                    refresh()
                                    audio.audition(pitch: t.isLowEnd ? 40 : 64, timbre: t)
                                } label: {
                                    Text(t.name)
                                        .font(TW.label(8.5))
                                        .foregroundStyle(timbre == t ? theme.bg : theme.fg)
                                        .frame(width: 54)
                                        .padding(.vertical, 8)
                                        .background(timbre == t ? Ink.plum : Color.clear)
                                        .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    Text(timbre.blurb)
                        .font(TW.body(12.5))
                        .foregroundStyle(theme.fgMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Caption("NOTE LENGTH")
                    HStack(spacing: 4) {
                        ForEach([1, 2, 4, 8, 16], id: \.self) { len in
                            Button { noteLength = len } label: {
                                Text(lengthLabel(len))
                                    .font(TW.label(8.5))
                                    .foregroundStyle(noteLength == len ? theme.bg : theme.fg)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 7)
                                    .background(noteLength == len ? theme.accent2 : Color.clear)
                                    .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Caption("CHORD STAMP")
                        Spacer()
                        Button { chordMode.toggle() } label: {
                            Text(chordMode ? "ON" : "OFF")
                                .font(TW.label(9))
                                .foregroundStyle(chordMode ? theme.bg : theme.fg)
                                .padding(.horizontal, 9).padding(.vertical, 4)
                                .background(chordMode ? Ink.amber : Color.clear)
                                .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                    if chordMode {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                ForEach(Array(ChordShape.all.enumerated()), id: \.offset) { i, shape in
                                    Button { chordIndex = i } label: {
                                        Tag(text: shape.name, filled: chordIndex == i, tint: Ink.amber)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        Text(chord.use)
                            .font(TW.body(12.5))
                            .foregroundStyle(theme.fgMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private func lengthLabel(_ steps: Int) -> String {
        switch steps {
        case 1:  return "1/16"
        case 2:  return "1/8"
        case 4:  return "1/4"
        case 8:  return "1/2"
        default: return "BAR"
        }
    }

    // MARK: Guidance

    private var guidance: some View {
        Panel(serial: "RCP", title: "TRY THIS") {
            VStack(alignment: .leading, spacing: 9) {
                item("A MELODY IN 60 SECONDS",
                     "Scale lock on, MIN PENT selected. Place four notes in the first half of the bar. Leave the second half empty. That's a phrase.")
                item("MAKE IT A HOOK",
                     "Repeat those four notes in the second half and change only the last one.")
                item("CHORDS",
                     "Chord stamp on, MIN selected, note length 1/4. Place one chord per beat and listen to the progression.")
                item("A BASSLINE",
                     "Switch the sound to BASS, drop two octaves, and place a long note wherever the kick lands.")
                item("HEAR SCALE LOCK WORK",
                     "Turn lock off and tap a greyed row. That's the note the lock was protecting you from.")
            }
        }
    }

    private func item(_ title: String, _ body: String) -> some View {
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
}
