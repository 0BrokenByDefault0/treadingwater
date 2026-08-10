import Foundation
import SwiftUI

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
}

struct DrumTrack: Identifiable, Codable, Equatable {
    var drum: Drum
    /// One velocity per step. 0 means the step is off.
    var vel: [Double]
    var muted: Bool = false

    var id: Int { drum.rawValue }

    init(_ drum: Drum, _ pattern: String, gain: Double = 1.0) {
        self.drum = drum
        // Compact authoring format: "x" full, "o" medium, "." ghost, "-" off.
        self.vel = pattern.compactMap { ch in
            switch ch {
            case "x", "X": return 1.0 * gain
            case "o", "O": return 0.62 * gain
            case ".":      return 0.32 * gain
            case "-", " ": return 0.0
            default:       return nil
            }
        }
    }

    init(drum: Drum, vel: [Double], muted: Bool = false) {
        self.drum = drum; self.vel = vel; self.muted = muted
    }

    func velocity(at step: Int) -> Double {
        guard step >= 0 && step < vel.count else { return 0 }
        return vel[step]
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
    case bass = 0, keys, lead, pluck, sub, bell

    var id: Int { rawValue }
    var name: String {
        switch self {
        case .bass:  return "BASS"
        case .keys:  return "KEYS"
        case .lead:  return "LEAD"
        case .pluck: return "PLUCK"
        case .sub:   return "SUB"
        case .bell:  return "BELL"
        }
    }
    var timbre: Timbre { Timbre(rawValue: rawValue) ?? .keys }
}

struct MelodyTrack: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var timbre: TrackTimbre
    var notes: [Note]
    var muted: Bool = false

    init(_ name: String, _ timbre: TrackTimbre, _ notes: [Note] = [], muted: Bool = false) {
        self.name = name; self.timbre = timbre; self.notes = notes; self.muted = muted
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

    static let empty = Beat(name: "UNTITLED", bpm: 90)

    var bars: Int { max(1, steps / 16) }
}

// MARK: - Limits shared with the audio engine

enum SeqLimits {
    static let maxSteps = 64
    static let maxDrumTracks = Drum.allCases.count
    static let maxMelodyTracks = 4
    static let maxNotesPerStep = 6
}
