import SwiftUI

/// A read-only, playable snapshot of a Beat. Used inside lessons and templates
/// so an example can be heard the moment it's read about.
struct PatternPlayer: View {
    @EnvironmentObject var theme: Theme
    @EnvironmentObject var audio: AudioEngine

    var beat: Beat
    var caption: String? = nil
    var tint: Color? = nil

    @State var loadedID: UUID? = nil

    private var isThisPlaying: Bool {
        audio.isPlaying && loadedID == beat.id
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Button(action: toggle) {
                    Text(isThisPlaying ? "■" : "▶")
                        .font(TW.wide(14, .black))
                        .foregroundStyle(theme.bg)
                        .frame(width: 40, height: 34)
                        .background(isThisPlaying ? theme.fg : (tint ?? theme.accent))
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 1) {
                    Text(beat.name)
                        .font(TW.wide(11, .heavy)).tracking(0.6)
                        .foregroundStyle(theme.fg)
                    Caption("\(Int(beat.bpm)) BPM · \(beat.bars) BAR\(beat.bars > 1 ? "S" : "")\(beat.swing > 0 ? " · SWING \(Int(beat.swing * 100))%" : "")")
                }
                Spacer(minLength: 0)
            }

            if !beat.drums.isEmpty {
                DrumGridPreview(beat: beat, tint: tint)
            }
            if !beat.melodies.isEmpty {
                RollPreview(beat: beat, tint: tint)
            }
            if let caption {
                Text(caption)
                    .font(TW.body(13))
                    .foregroundStyle(theme.fgMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(10)
        .background(theme.panel)
        .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1.2))
        .onChange(of: audio.isPlaying) { _, playing in
            if !playing { loadedID = nil }
        }
    }

    private func toggle() {
        if isThisPlaying {
            audio.stop()
            loadedID = nil
        } else {
            audio.load(beat)
            loadedID = beat.id
            audio.play()
        }
    }
}

// MARK: - Drum grid preview

struct DrumGridPreview: View {
    @EnvironmentObject var theme: Theme
    @EnvironmentObject var audio: AudioEngine

    var beat: Beat
    var tint: Color? = nil

    private var activeTracks: [DrumTrack] {
        beat.drums.filter { $0.vel.contains { $0 > 0 } }
    }

    var body: some View {
        VStack(spacing: 2) {
            ForEach(activeTracks) { track in
                HStack(spacing: 2) {
                    Text(track.drum.short)
                        .font(TW.label(7.5)).tracking(0.6)
                        .foregroundStyle(theme.fgMuted)
                        .frame(width: 26, alignment: .leading)

                    GeometryReader { geo in
                        let count = max(1, beat.steps)
                        let w = (geo.size.width - CGFloat(count - 1) * 1.5) / CGFloat(count)
                        HStack(spacing: 1.5) {
                            ForEach(0..<count, id: \.self) { step in
                                let v = track.velocity(at: step)
                                Rectangle()
                                    .foregroundStyle(color(for: v, track: track, step: step))
                                    .frame(width: max(2, w))
                            }
                        }
                    }
                    .frame(height: 11)
                }
            }
        }
    }

    private func color(for v: Double, track: DrumTrack, step: Int) -> Color {
        if audio.playhead == step && audio.isPlaying {
            return theme.fg
        }
        if v <= 0 {
            return (step % 4 == 0) ? theme.fill.opacity(0.55) : theme.fill.opacity(0.25)
        }
        return (tint ?? track.drum.tint).opacity(0.35 + 0.65 * v)
    }
}

// MARK: - Piano roll preview

struct RollPreview: View {
    @EnvironmentObject var theme: Theme
    var beat: Beat
    var tint: Color? = nil

    private var allNotes: [(Int, Note)] {
        beat.melodies.enumerated().flatMap { idx, track in
            track.notes.map { (idx, $0) }
        }
    }

    private var range: ClosedRange<Int> {
        let pitches = allNotes.map { $0.1.pitch }
        guard let lo = pitches.min(), let hi = pitches.max() else { return 48...72 }
        return (lo - 1)...(hi + 1)
    }

    var body: some View {
        GeometryReader { geo in
            let steps = max(1, beat.steps)
            let span = max(1, range.upperBound - range.lowerBound + 1)
            let stepW = geo.size.width / CGFloat(steps)
            let rowH = geo.size.height / CGFloat(span)

            ZStack(alignment: .topLeading) {
                Rectangle().foregroundStyle(theme.fill.opacity(0.22))

                // Bar lines every 16 steps.
                ForEach(0..<max(1, steps / 4), id: \.self) { i in
                    Rectangle()
                        .foregroundStyle(theme.rule.opacity(i % 4 == 0 ? 0.35 : 0.15))
                        .frame(width: 1)
                        .offset(x: CGFloat(i * 4) * stepW)
                }

                ForEach(Array(allNotes.enumerated()), id: \.offset) { _, item in
                    let (trackIdx, note) = item
                    Rectangle()
                        .foregroundStyle(noteColor(trackIdx))
                        .frame(width: max(2, CGFloat(note.length) * stepW - 1),
                               height: max(2, rowH - 1))
                        .offset(x: CGFloat(note.start) * stepW,
                                y: CGFloat(range.upperBound - note.pitch) * rowH)
                }
            }
        }
        .frame(height: 62)
    }

    private func noteColor(_ trackIndex: Int) -> Color {
        if let tint { return tint }
        let palette = [Ink.orange, Ink.plum, Ink.clay, Ink.amber]
        return palette[trackIndex % palette.count]
    }
}
