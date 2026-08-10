import Foundation
import SwiftUI

// MARK: - Content blocks

enum CalloutKind {
    case rule       // a thing that is basically always true
    case trap       // the mistake everybody makes here
    case shortcut   // the fast way once you understand it

    var label: String {
        switch self {
        case .rule:     return "RULE"
        case .trap:     return "COMMON TRAP"
        case .shortcut: return "SHORTCUT"
        }
    }
    var tint: Color {
        switch self {
        case .rule:     return Ink.clay
        case .trap:     return Ink.orange
        case .shortcut: return Ink.plum
        }
    }
}

enum LabKind: String {
    case drums
    case pianoRoll

    var title: String {
        switch self {
        case .drums:     return "DRUM LAB"
        case .pianoRoll: return "PIANO ROLL LAB"
        }
    }
}

/// Where the same control lives in the three DAWs beginners actually use.
struct DAWLocation: Identifiable {
    var id: String { daw }
    var daw: String
    var path: String
}

enum Block {
    case text(String)
    case heading(String)
    case bullets([String])
    case steps([String])
    case callout(CalloutKind, String, String)
    case pattern(String, Beat)
    case lab(LabKind, String)
    case terms([String])
    case dawPaths([DAWLocation])
    case compare(String, String, String, String)
    case dial(String, [String])       // a labelled range: title + points low->high
}

// MARK: - Lesson

enum Level: String, CaseIterable, Identifiable {
    case beginner = "BEGINNER"
    case intermediate = "INTERMEDIATE"
    case advanced = "ADVANCED"

    var id: String { rawValue }
    var tint: Color {
        switch self {
        case .beginner:     return Ink.clay
        case .intermediate: return Ink.orange
        case .advanced:     return Ink.plum
        }
    }
}

struct Lesson: Identifiable {
    var id: String
    var title: String
    var kicker: String
    var minutes: Int
    var blocks: [Block]
}

struct Stage: Identifiable {
    var id: String
    var number: Int
    var title: String
    var subtitle: String
    var level: Level
    var lessons: [Lesson]
}

// MARK: - Curriculum root

enum Curriculum {
    static let stages: [Stage] = [
        Stage(id: "ground", number: 1, title: "GROUND ZERO",
              subtitle: "What every DAW is actually doing, in the order it matters.",
              level: .beginner, lessons: Foundations.lessons),
        Stage(id: "drums", number: 2, title: "DRUMS",
              subtitle: "Build a groove that moves before you write a single note.",
              level: .beginner, lessons: DrumLessons.lessons),
        Stage(id: "melody", number: 3, title: "MELODY & HARMONY",
              subtitle: "The piano roll, and how to never write a wrong note again.",
              level: .intermediate, lessons: MelodyLessons.lessons),
        Stage(id: "sound", number: 4, title: "SOUND SELECTION",
              subtitle: "Why the same pattern slaps with one sample and dies with another.",
              level: .intermediate, lessons: SoundLessons.lessons),
        Stage(id: "mix", number: 5, title: "MIXING",
              subtitle: "Every knob on a channel strip, and when you'd actually reach for it.",
              level: .intermediate, lessons: MixLessons.lessons),
        Stage(id: "finish", number: 6, title: "FINISHING",
              subtitle: "Turning a loop into a track and getting it out of the DAW.",
              level: .advanced, lessons: FinishLessons.lessons)
    ]

    static var allLessons: [Lesson] { stages.flatMap { $0.lessons } }

    static func stage(for lessonID: String) -> Stage? {
        stages.first { $0.lessons.contains { $0.id == lessonID } }
    }

    static func lesson(_ id: String) -> Lesson? {
        allLessons.first { $0.id == id }
    }

    /// Flat running order across the whole path, for "next lesson".
    static func next(after lessonID: String) -> Lesson? {
        let all = allLessons
        guard let i = all.firstIndex(where: { $0.id == lessonID }), i + 1 < all.count else { return nil }
        return all[i + 1]
    }
}
