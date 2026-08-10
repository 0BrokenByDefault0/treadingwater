import Foundation

// Just enough theory to keep a beginner inside the lines without turning the
// app into a theory course.

enum Theory {
    static let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

    static func name(for pitch: Int) -> String {
        let n = ((pitch % 12) + 12) % 12
        return noteNames[n]
    }

    static func fullName(for pitch: Int) -> String {
        "\(name(for: pitch))\(pitch / 12 - 1)"
    }

    static func isBlackKey(_ pitch: Int) -> Bool {
        let n = ((pitch % 12) + 12) % 12
        return [1, 3, 6, 8, 10].contains(n)
    }
}

struct Scale: Identifiable, Hashable {
    var id: String { name }
    var name: String
    var intervals: [Int]
    var mood: String

    func contains(_ pitch: Int, root: Int) -> Bool {
        let d = ((pitch - root) % 12 + 12) % 12
        return intervals.contains(d)
    }

    /// Ascending pitches of the scale across a range, used to draw the roll.
    func pitches(root: Int, from low: Int, to high: Int) -> [Int] {
        (low...high).filter { contains($0, root: root) }
    }

    static let all: [Scale] = [
        Scale(name: "MINOR", intervals: [0, 2, 3, 5, 7, 8, 10],
              mood: "Dark, serious, the default for most rap and electronic music."),
        Scale(name: "MAJOR", intervals: [0, 2, 4, 5, 7, 9, 11],
              mood: "Bright and resolved. Pop, gospel, house, afrobeats."),
        Scale(name: "DORIAN", intervals: [0, 2, 3, 5, 7, 9, 10],
              mood: "Minor with one bright note. Funk, house, neo-soul, lo-fi."),
        Scale(name: "PHRYGIAN", intervals: [0, 1, 3, 5, 7, 8, 10],
              mood: "Tense and menacing. Drill, trap, anything that needs threat."),
        Scale(name: "MIN PENT", intervals: [0, 3, 5, 7, 10],
              mood: "Five notes that cannot clash. The safest place to write a melody."),
        Scale(name: "MAJ PENT", intervals: [0, 2, 4, 7, 9],
              mood: "Bright five-note scale. Afrobeats, country, big open hooks."),
        Scale(name: "HARM MIN", intervals: [0, 2, 3, 5, 7, 8, 11],
              mood: "Cinematic and eastern. One dramatic leap near the top.")
    ]
}

struct ChordShape: Identifiable, Hashable {
    var id: String { name }
    var name: String
    var intervals: [Int]
    var use: String

    static let all: [ChordShape] = [
        ChordShape(name: "MIN", intervals: [0, 3, 7], use: "The default sad chord."),
        ChordShape(name: "MAJ", intervals: [0, 4, 7], use: "The default happy chord."),
        ChordShape(name: "MIN7", intervals: [0, 3, 7, 10], use: "Smoother minor. Lo-fi, R&B, house."),
        ChordShape(name: "MAJ7", intervals: [0, 4, 7, 11], use: "Dreamy and jazzy. Careful under vocals."),
        ChordShape(name: "SUS2", intervals: [0, 2, 7], use: "Neither happy nor sad. Great for pads."),
        ChordShape(name: "SUS4", intervals: [0, 5, 7], use: "Suspended tension that wants to resolve."),
        ChordShape(name: "5TH", intervals: [0, 7], use: "No third, no mood. Sits under anything.")
    ]

    func pitches(root: Int) -> [Int] { intervals.map { root + $0 } }
}

struct Progression: Identifiable, Hashable {
    var id: String { name }
    var name: String
    /// Scale degrees, 1-indexed, negative marks a major chord in a minor key.
    var degrees: [Int]
    var quality: [String]
    var where_: String

    static let all: [Progression] = [
        Progression(name: "i – VI – III – VII", degrees: [1, 6, 3, 7],
                    quality: ["min", "maj", "maj", "maj"],
                    where_: "The single most used minor loop in modern music. Sad but moving."),
        Progression(name: "i – VII – VI – VII", degrees: [1, 7, 6, 7],
                    quality: ["min", "maj", "maj", "maj"],
                    where_: "Trap and drill. Circular, never resolves, loops forever."),
        Progression(name: "i – iv – i – V", degrees: [1, 4, 1, 5],
                    quality: ["min", "min", "min", "maj"],
                    where_: "Classic and dramatic. The V pulls hard back to the i."),
        Progression(name: "I – V – vi – IV", degrees: [1, 5, 6, 4],
                    quality: ["maj", "maj", "min", "maj"],
                    where_: "The pop progression. Works every time, which is the problem."),
        Progression(name: "ii – V – I", degrees: [2, 5, 1],
                    quality: ["min7", "maj", "maj7"],
                    where_: "Jazz motion. Instant sophistication in lo-fi and neo-soul."),
        Progression(name: "i – III – VII – VI", degrees: [1, 3, 7, 6],
                    quality: ["min", "maj", "maj", "maj"],
                    where_: "Anthemic minor. Builds without ever getting happy.")
    ]
}
