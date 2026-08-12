import Foundation
import Combine

/// Lesson progress plus the two sketches the labs keep between launches.
final class Store: ObservableObject {

    @Published private(set) var completed: Set<String> {
        didSet { UserDefaults.standard.set(Array(completed), forKey: Keys.completed) }
    }
    @Published var lastLesson: String? {
        didSet { UserDefaults.standard.set(lastLesson, forKey: Keys.lastLesson) }
    }
    @Published var drumSketch: Beat {
        didSet { save(drumSketch, Keys.drumSketch) }
    }
    @Published var rollSketch: Beat {
        didSet { save(rollSketch, Keys.rollSketch) }
    }

    private enum Keys {
        static let completed = "tw.completed"
        static let lastLesson = "tw.lastLesson"
        static let drumSketch = "tw.drumSketch.v2"
        static let rollSketch = "tw.rollSketch.v2"
    }

    init() {
        let defaults = UserDefaults.standard
        completed = Set(defaults.stringArray(forKey: Keys.completed) ?? [])
        lastLesson = defaults.string(forKey: Keys.lastLesson)
        drumSketch = Store.load(Keys.drumSketch) ?? Store.starterDrums
        rollSketch = Store.load(Keys.rollSketch) ?? Store.starterRoll
    }

    // MARK: Progress

    func isDone(_ lessonID: String) -> Bool { completed.contains(lessonID) }

    func toggle(_ lessonID: String) {
        if completed.contains(lessonID) {
            completed.remove(lessonID)
        } else {
            completed.insert(lessonID)
        }
    }

    func markDone(_ lessonID: String) {
        guard !completed.contains(lessonID) else { return }
        completed.insert(lessonID)
    }

    func progress(for stage: Stage) -> Double {
        guard !stage.lessons.isEmpty else { return 0 }
        let done = stage.lessons.filter { completed.contains($0.id) }.count
        return Double(done) / Double(stage.lessons.count)
    }

    var overallProgress: Double {
        let all = Curriculum.allLessons
        guard !all.isEmpty else { return 0 }
        return Double(all.filter { completed.contains($0.id) }.count) / Double(all.count)
    }

    var doneCount: Int { completed.count }
    var totalCount: Int { Curriculum.allLessons.count }

    /// The lesson to offer on the home screen: the first unfinished one.
    var upNext: Lesson? {
        Curriculum.allLessons.first { !completed.contains($0.id) }
    }

    func resetProgress() {
        completed = []
        lastLesson = nil
    }

    // MARK: Sketch defaults

    static let starterDrums = Beat(
        name: "SKETCH", bpm: 92, swing: 0.12, steps: 16,
        drums: [
            DrumTrack(.kick,      "x-------x--x----"),
            DrumTrack(.snare,     "----x-------x---"),
            DrumTrack(.closedHat, "x-o-x-o-x-o-x-o-"),
            DrumTrack(.openHat,   "----------------"),
            DrumTrack(.clap,      "----------------"),
            DrumTrack(.rim,       "----------------"),
            DrumTrack(.perc,      "----------------"),
            DrumTrack(.tom,       "----------------"),
            DrumTrack(.crash,     "----------------")
        ],
        mix: MixSettings(sidechain: 0.25, drumDrive: 0.25, humanize: 0.2)
    )

    static let starterRoll = Beat(
        name: "ROLL SKETCH", bpm: 90, steps: 16,
        drums: [
            DrumTrack(.kick,      "x-------x--x----"),
            DrumTrack(.closedHat, "x-o-x-o-x-o-x-o-", gain: 0.7)
        ],
        melodies: [
            MelodyTrack("LEAD", .keys, [
                Note(69, 0, 4), Note(72, 4, 4), Note(76, 8, 4), Note(72, 12, 4)
            ])
        ],
        mix: MixSettings(sidechain: 0.25, drumDrive: 0.25, humanize: 0.2)
    )

    /// Every drum lane exists in the sketch so the lab grid is stable.
    func ensureAllLanes() {
        var beat = drumSketch
        var changed = false
        for drum in Drum.allCases where !beat.drums.contains(where: { $0.drum == drum }) {
            beat.drums.append(DrumTrack(drum: drum, vel: Array(repeating: 0, count: beat.steps)))
            changed = true
        }
        for i in beat.drums.indices where beat.drums[i].vel.count < beat.steps {
            beat.drums[i].vel.append(contentsOf:
                Array(repeating: 0, count: beat.steps - beat.drums[i].vel.count))
            changed = true
        }
        if changed { drumSketch = beat }
    }

    // MARK: Persistence

    private func save<T: Encodable>(_ value: T, _ key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private static func load<T: Decodable>(_ key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
