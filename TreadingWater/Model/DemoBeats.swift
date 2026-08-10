import Foundation

/// Short, playable examples embedded in lessons. Every one of these is meant
/// to be listened to twice — once to hear the point, once to hear what changed.
enum DemoBeats {

    static let gridCounting = Beat(
        name: "THE GRID", bpm: 90, steps: 16,
        drums: [
            DrumTrack(.kick,      "x---x---x---x---"),
            DrumTrack(.closedHat, "xxxxxxxxxxxxxxxx")
        ]
    )

    static let threeJobs = Beat(
        name: "THREE JOBS", bpm: 92, steps: 16,
        drums: [
            DrumTrack(.kick,      "x-------x--x----"),
            DrumTrack(.snare,     "----x-------x---"),
            DrumTrack(.closedHat, "x-o-x-o-x-o-x-o-")
        ]
    )

    static let fourOnFloor = Beat(
        name: "FOUR ON THE FLOOR", bpm: 124, steps: 16,
        drums: [
            DrumTrack(.kick,      "x---x---x---x---"),
            DrumTrack(.clap,      "----x-------x---"),
            DrumTrack(.openHat,   "--x---x---x---x-"),
            DrumTrack(.closedHat, "x-x-x-x-x-x-x-x-", gain: 0.5)
        ]
    )

    static let boomBapSkeleton = Beat(
        name: "BOOM BAP", bpm: 88, swing: 0.28, steps: 16,
        drums: [
            DrumTrack(.kick,      "x---------x-----"),
            DrumTrack(.snare,     "----x-------x---"),
            DrumTrack(.closedHat, "x-o-x-o-x-o-x-o-")
        ]
    )

    static let trapSkeleton = Beat(
        name: "TRAP", bpm: 142, steps: 16,
        drums: [
            DrumTrack(.kick,      "x-----x---x-----"),
            DrumTrack(.snare,     "--------x-------"),
            DrumTrack(.closedHat, "x.x.x.x.x.x.x.x.")
        ]
    )

    static let hatsSixteenth = Beat(
        name: "16TH HATS", bpm: 100, steps: 16,
        drums: [
            DrumTrack(.kick,      "x-------x--x----"),
            DrumTrack(.snare,     "----x-------x---"),
            DrumTrack(.closedHat, "xxxxxxxxxxxxxxxx", gain: 0.7)
        ]
    )

    static let hatsOffbeat = Beat(
        name: "OFF-BEAT HATS", bpm: 100, steps: 16,
        drums: [
            DrumTrack(.kick,      "x-------x--x----"),
            DrumTrack(.snare,     "----x-------x---"),
            DrumTrack(.openHat,   "--x---x---x---x-")
        ]
    )

    static let velocityFlat = Beat(
        name: "FLAT VELOCITY", bpm: 96, steps: 16,
        drums: [
            DrumTrack(.kick,      "x-------x--x----"),
            DrumTrack(.snare,     "----x-------x---"),
            DrumTrack(.closedHat, "xxxxxxxxxxxxxxxx")
        ]
    )

    static let velocityShaped = Beat(
        name: "SHAPED VELOCITY", bpm: 96, swing: 0.14, steps: 16,
        drums: [
            DrumTrack(.kick,      "x-------x--x----"),
            DrumTrack(.snare,     "----x--.----x-.-"),
            DrumTrack(.closedHat, "x.o.x.o.x.o.x.o.")
        ]
    )

    /// i – VI – III – VII in A minor, four bars, chords only.
    static let chordsMinor = Beat(
        name: "MINOR PROGRESSION", bpm: 84, steps: 64,
        melodies: [
            MelodyTrack("CHORDS", .keys, [
                Note(57, 0, 15), Note(60, 0, 15), Note(64, 0, 15),      // Am
                Note(53, 16, 15), Note(57, 16, 15), Note(60, 16, 15),   // F
                Note(60, 32, 15), Note(64, 32, 15), Note(67, 32, 15),   // C
                Note(55, 48, 15), Note(59, 48, 15), Note(62, 48, 15)    // G
            ])
        ]
    )

    static let bassWithKick = Beat(
        name: "BASS FOLLOWS KICK", bpm: 88, steps: 16,
        drums: [
            DrumTrack(.kick,      "x---------x-----"),
            DrumTrack(.snare,     "----x-------x---"),
            DrumTrack(.closedHat, "x-o-x-o-x-o-x-o-", gain: 0.7)
        ],
        melodies: [
            MelodyTrack("BASS", .bass, [
                Note(33, 0, 8, vel: 0.9),
                Note(33, 10, 5, vel: 0.8)
            ])
        ]
    )

    /// Four notes, said twice, with the ending changed the second time.
    static let melodyHook = Beat(
        name: "HOOK", bpm: 92, steps: 32,
        drums: [
            DrumTrack(.kick,      "x-------x--x----x-------x--x----"),
            DrumTrack(.snare,     "----x-------x-------x-------x---"),
            DrumTrack(.closedHat, "x-o-x-o-x-o-x-o-x-o-x-o-x-o-x-o-", gain: 0.7)
        ],
        melodies: [
            MelodyTrack("LEAD", .pluck, [
                Note(69, 0, 2), Note(72, 2, 2), Note(76, 4, 4), Note(74, 8, 6),
                Note(69, 16, 2), Note(72, 18, 2), Note(76, 20, 4), Note(72, 24, 6)
            ]),
            MelodyTrack("BASS", .bass, [
                Note(33, 0, 8), Note(33, 10, 5),
                Note(29, 16, 8), Note(29, 26, 5)
            ])
        ]
    )
}
