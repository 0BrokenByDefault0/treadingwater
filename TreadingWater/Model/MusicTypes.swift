import Foundation
import SwiftUI

// MARK: - Per-track character
//
// The reason a boom-bap kick and a trap kick are different instruments rather
// than the same beep at two volumes.

struct TrackMix: Codable, Equatable {
    var gain: Double = 1.0
    var pan: Double = 0.0        // -1 ... 1
    var tune: Double = 0.0       // semitones (drums)
    var tone: Double = 0.5       // 0 dark ... 1 bright
    var decay: Double = 0.5      // 0 tight ... 1 long
    var drive: Double = 0.25
    var reverb: Double = 0.0     // send amount
    var delay: Double = 0.0      // send amount
    var timing: Double = 0.0     // -1 early ... 1 late (±12 ms)
    var cutoff: Double = 1.0     // filter scaling (melodic)
    var glide: Double = 0.0      // portamento seconds (melodic)
}

// MARK: - Master / bus settings

enum DelaySync: Int, Codable, CaseIterable, Identifiable {
    case sixteenth = 0, eighth, dottedEighth, quarter, dottedQuarter

    var id: Int { rawValue }
    var beats: Double {
        switch self {
        case .sixteenth:     return 0.25
        case .eighth:        return 0.5
        case .dottedEighth:  return 0.75
        case .quarter:       return 1.0
        case .dottedQuarter: return 1.5
        }
    }
    var name: String {
        switch self {
        case .sixteenth:     return "1/16"
        case .eighth:        return "1/8"
        case .dottedEighth:  return "1/8D"
        case .quarter:       return "1/4"
        case .dottedQuarter: return "1/4D"
        }
    }
}

struct MixSettings: Codable, Equatable {
    var reverbSize: Double = 0.62
    var reverbDamp: Double = 0.5
    var reverbPreDelay: Double = 0.022
    var delaySync: DelaySync = .dottedEighth
    var delayFeedback: Double = 0.32
    var delayPingPong: Bool = true
    /// How hard the bass and music buses duck under the kick.
    var sidechain: Double = 0.0
    var sidechainRelease: Double = 0.16
    var drumDrive: Double = 0.20
    var drumGlue: Double = 0.35
    var masterDrive: Double = 0.12
    var masterGlue: Double = 0.45
    var width: Double = 0.30
    /// Timing and velocity jitter applied to every sequenced hit.
    var humanize: Double = 0.15
    var chorus: Double = 0.0

    static let neutral = MixSettings()
}

// MARK: - Drums

enum Drum: Int, CaseIterable, Identifiable, Codable {
    case kick = 0, snare, clap, closedHat, openHat, rim, tom, perc, crash

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .kick:      return "KICK"
        case .snare:     return "SNARE"
        case .clap:      return "CLAP"
        case .closedHat: return "CL HAT"
        case .openHat:   return "OP HAT"
        case .rim:       return "RIM"
        case .tom:       return "TOM"
        case .perc:      return "PERC"
        case .crash:     return "CRASH"
        }
    }

    var short: String {
        switch self {
        case .kick:      return "KCK"
        case .snare:     return "SNR"
        case .clap:      return "CLP"
        case .closedHat: return "CH"
        case .openHat:   return "OH"
        case .rim:       return "RIM"
        case .tom:       return "TOM"
        case .perc:      return "PRC"
        case .crash:     return "CRS"
        }
    }

    /// What this piece is actually *for* in an arrangement — shown in the lab
    /// so you learn the role, not just the sound.
    var role: String {
        switch self {
        case .kick:      return "The floor. Sets the pulse and owns everything under 100 Hz."
        case .snare:     return "The answer to the kick. Usually lands on 2 and 4 and defines the backbeat."
        case .clap:      return "A wider, brighter backbeat. Layer it with the snare or use it instead."
        case .closedHat: return "The clock. Subdivides the bar so the listener can feel the speed."
        case .openHat:   return "Air and lift. One per bar in the right spot does more than sixteen."
        case .rim:       return "A dry, quiet backbeat for verses and low-energy sections."
        case .tom:       return "Fills and movement. Pitch it down for weight, up for urgency."
        case .perc:      return "Personality. Shakers, blips and rides that make a loop yours."
        case .crash:     return "A marker. Put it on the downbeat where a new section begins."
        }
    }

    var tint: Color {
        switch self {
        case .kick:      return Ink.orange
        case .snare:     return Ink.clay
        case .clap:      return Ink.claySoft
        case .closedHat: return Ink.steel
        case .openHat:   return Ink.plum
        case .rim:       return Ink.concreteLo
        case .tom:       return Ink.amber
        case .perc:      return Ink.plum
        case .crash:     return Ink.steel
        }
    }

    var voiceKind: DrumVoiceKind { DrumVoiceKind(rawValue: rawValue) ?? .kick }

    /// Sensible starting character per piece, before a template customises it.
    var defaultMix: TrackMix {
        var m = TrackMix()
        switch self {
        case .kick:      m.gain = 1.0;  m.drive = 0.35; m.decay = 0.45
        case .snare:     m.gain = 0.80; m.drive = 0.25; m.reverb = 0.10
        case .clap:      m.gain = 0.72; m.pan = 0.05;   m.reverb = 0.14
        case .closedHat: m.gain = 0.44; m.pan = 0.18;   m.decay = 0.30; m.drive = 0.05
        case .openHat:   m.gain = 0.40; m.pan = -0.14;  m.decay = 0.45; m.drive = 0.05
        case .rim:       m.gain = 0.52; m.pan = -0.22;  m.reverb = 0.08
        case .tom:       m.gain = 0.66; m.pan = 0.24
        case .perc:      m.gain = 0.50; m.pan = -0.28;  m.reverb = 0.12
        case .crash:     m.gain = 0.46; m.pan = 0.12;   m.reverb = 0.22; m.decay = 0.7
        }
        return m
    }
}

struct DrumTrack: Identifiable, Codable, Equatable {
    var drum: Drum
    /// One velocity per step. 0 means the step is off.
    var vel: [Double]
    var muted: Bool = false
    var mix: TrackMix

    var id: Int { drum.rawValue }

    /// Compact authoring format: "x" full, "o" medium, "." ghost, "-" off.
    init(_ drum: Drum, _ pattern: String, gain: Double? = nil) {
        self.drum = drum
        self.vel = pattern.compactMap { ch in
            switch ch {
            case "x", "X": return 1.0
            case "o", "O": return 0.66
            case ".":      return 0.34
            case "-", " ": return 0.0
            default:       return nil
            }
        }
        var m = drum.defaultMix
        if let gain { m.gain *= gain }
        self.mix = m
    }

    init(drum: Drum, vel: [Double], muted: Bool = false, mix: TrackMix? = nil) {
        self.drum = drum
        self.vel = vel
        self.muted = muted
        self.mix = mix ?? drum.defaultMix
    }

    func velocity(at step: Int) -> Double {
        guard step >= 0 && step < vel.count else { return 0 }
        return vel[step]
    }

    /// Chainable customisation, so template definitions stay readable.
    func character(gain: Double? = nil, pan: Double? = nil, tune: Double? = nil,
                   tone: Double? = nil, decay: Double? = nil, drive: Double? = nil,
                   reverb: Double? = nil, delay: Double? = nil,
                   timing: Double? = nil) -> DrumTrack {
        var copy = self
        if let gain { copy.mix.gain = gain }
        if let pan { copy.mix.pan = pan }
        if let tune { copy.mix.tune = tune }
        if let tone { copy.mix.tone = tone }
        if let decay { copy.mix.decay = decay }
        if let drive { copy.mix.drive = drive }
        if let reverb { copy.mix.reverb = reverb }
        if let delay { copy.mix.delay = delay }
        if let timing { copy.mix.timing = timing }
        return copy
    }
}

// MARK: - Melody

struct Note: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var pitch: Int          // MIDI note number
    var start: Int          // step index
    var length: Int         // in steps
    var vel: Double = 0.8

    init(_ pitch: Int, _ start: Int, _ length: Int = 4, vel: Double = 0.8) {
        self.pitch = pitch; self.start = start; self.length = length; self.vel = vel
    }
}

enum TrackTimbre: Int, CaseIterable, Identifiable, Codable {
    case sub = 0, bass808, bass, reese, keys, pad, pluck, lead, bell, organ

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .sub:     return "SUB"
        case .bass808: return "808"
        case .bass:    return "BASS"
        case .reese:   return "REESE"
        case .keys:    return "KEYS"
        case .pad:     return "PAD"
        case .pluck:   return "PLUCK"
        case .lead:    return "LEAD"
        case .bell:    return "BELL"
        case .organ:   return "ORGAN"
        }
    }

    var blurb: String {
        switch self {
        case .sub:     return "A clean sine. Felt, not heard — layer something above it."
        case .bass808: return "Long, driven, glides between notes. Kick and bassline in one."
        case .bass:    return "Punchy filtered synth bass with a sub underneath."
        case .reese:   return "Detuned saws beating against each other. Drum & bass."
        case .keys:    return "FM electric piano. Bright on the attack, mellow as it rings."
        case .pad:     return "Seven detuned saws, slow attack. Fills space behind everything."
        case .pluck:   return "Fast filter envelope. Short, bright, rhythmic."
        case .lead:    return "Supersaw. Wide and forward — keep it above the chords."
        case .bell:    return "FM bell. Cuts through anything. Use sparingly."
        case .organ:   return "Additive drawbars. Warm, retro, sits well under vocals."
        }
    }

    /// True for anything that belongs on the bass bus rather than the music bus.
    var isLowEnd: Bool {
        switch self {
        case .sub, .bass808, .bass, .reese: return true
        default: return false
        }
    }

    var timbre: Timbre { Timbre(rawValue: rawValue) ?? .keys }

    var defaultMix: TrackMix {
        var m = TrackMix()
        switch self {
        case .sub:     m.gain = 0.95; m.drive = 0.05
        case .bass808: m.gain = 1.0;  m.drive = 0.4; m.glide = 0.05
        case .bass:    m.gain = 0.85; m.drive = 0.2
        case .reese:   m.gain = 0.8;  m.drive = 0.3
        case .keys:    m.gain = 0.7;  m.reverb = 0.16; m.drive = 0.08
        case .pad:     m.gain = 0.5;  m.reverb = 0.34
        case .pluck:   m.gain = 0.6;  m.reverb = 0.18; m.delay = 0.12
        case .lead:    m.gain = 0.6;  m.reverb = 0.2;  m.delay = 0.1
        case .bell:    m.gain = 0.5;  m.reverb = 0.28; m.delay = 0.18
        case .organ:   m.gain = 0.6;  m.reverb = 0.14
        }
        return m
    }
}

struct MelodyTrack: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var timbre: TrackTimbre
    var notes: [Note]
    var muted: Bool = false
    var mix: TrackMix

    init(_ name: String, _ timbre: TrackTimbre, _ notes: [Note] = [], muted: Bool = false) {
        self.name = name
        self.timbre = timbre
        self.notes = notes
        self.muted = muted
        self.mix = timbre.defaultMix
    }

    func character(gain: Double? = nil, pan: Double? = nil, drive: Double? = nil,
                   reverb: Double? = nil, delay: Double? = nil, cutoff: Double? = nil,
                   glide: Double? = nil, timing: Double? = nil) -> MelodyTrack {
        var copy = self
        if let gain { copy.mix.gain = gain }
        if let pan { copy.mix.pan = pan }
        if let drive { copy.mix.drive = drive }
        if let reverb { copy.mix.reverb = reverb }
        if let delay { copy.mix.delay = delay }
        if let cutoff { copy.mix.cutoff = cutoff }
        if let glide { copy.mix.glide = glide }
        if let timing { copy.mix.timing = timing }
        return copy
    }
}

// MARK: - Beat

struct Beat: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var bpm: Double
    var swing: Double = 0        // 0...1, amount the off-8ths are pushed late
    var steps: Int = 16          // 16 steps = one bar of 16ths
    var drums: [DrumTrack] = []
    var melodies: [MelodyTrack] = []
    var mix: MixSettings = .neutral

    static let empty = Beat(name: "UNTITLED", bpm: 90)

    var bars: Int { max(1, steps / 16) }
}

// MARK: - Limits shared with the audio engine

enum SeqLimits {
    static let maxSteps = 64
    static let maxDrumTracks = Drum.allCases.count
    static let maxMelodyTracks = 6
    static let maxNotesPerStep = 8
    /// Number of Float slots per track in the flat parameter grid.
    static let paramStride = 11
}

/// Slot indices into the flat per-track parameter buffers.
enum ParamSlot {
    static let gain = 0, pan = 1, tune = 2, tone = 3, decay = 4
    static let drive = 5, reverb = 6, delay = 7, timing = 8
    static let cutoff = 9, glide = 10
}

extension TrackMix {
    /// Flatten into the render thread's parameter buffer.
    func write(into p: UnsafeMutablePointer<Float>, base: Int) {
        p[base + ParamSlot.gain]   = Float(gain)
        p[base + ParamSlot.pan]    = Float(pan)
        p[base + ParamSlot.tune]   = Float(tune)
        p[base + ParamSlot.tone]   = Float(tone)
        p[base + ParamSlot.decay]  = Float(decay)
        p[base + ParamSlot.drive]  = Float(drive)
        p[base + ParamSlot.reverb] = Float(reverb)
        p[base + ParamSlot.delay]  = Float(delay)
        p[base + ParamSlot.timing] = Float(timing)
        p[base + ParamSlot.cutoff] = Float(cutoff)
        p[base + ParamSlot.glide]  = Float(glide)
    }
}
