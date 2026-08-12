import Foundation
import SwiftUI

/// Templates are grouped so 30 of them stay browsable.
enum GenreFamily: String, CaseIterable, Identifiable, Codable {
    case hiphop = "HIP HOP"
    case rnb    = "R&B / SOUL"
    case house  = "HOUSE & CLUB"
    case bass   = "BASS & BREAKS"
    case global = "GLOBAL"
    case chill  = "CHILL"
    case pop    = "POP & SYNTH"

    var id: String { rawValue }

    var blurb: String {
        switch self {
        case .hiphop: return "Half-time backbeats and 808s."
        case .rnb:    return "Space left for a voice."
        case .house:  return "Four on the floor and its descendants."
        case .bass:   return "Breakbeats and sub-heavy drops."
        case .global: return "Syncopated, percussion-led."
        case .chill:  return "Slow, swung, deliberately imperfect."
        case .pop:    return "Bright, arranged, hook-first."
        }
    }
}

struct SectionNote: Identifiable {
    var id: String { section }
    var section: String
    var bars: String
    var whats: String
}

struct GenreTemplate: Identifiable {
    var id: String
    var name: String
    var tagline: String
    var keyName: String
    var scaleName: String
    var feel: String
    var beat: Beat
    var palette: [String]
    var structure: [SectionNote]
    var makesItWork: [String]
    var mixNotes: [String]
    var mistakes: [String]
    var tint: Color
    var family: GenreFamily = .hiphop

    var bpm: Double { beat.bpm }
}

// Patterns are written a bar at a time so they stay readable. Shared with the
// other template files.
func p(_ a: String, _ b: String) -> String { a + b }

enum Templates {

    // MARK: TRAP

    static let trap = GenreTemplate(
        id: "trap", name: "TRAP", tagline: "HALF-TIME SNARE, 808 CARRYING THE BASS",
        keyName: "F MINOR", scaleName: "MINOR", feel: "140 BPM that feels like 70.",
        beat: Beat(
            name: "TRAP REFERENCE", bpm: 140, swing: 0.04, steps: 32,
            drums: [
                DrumTrack(.kick, p("x-----x---x-----", "x-----x---x--x--"))
                    .character(gain: 1.0, tune: -1, tone: 0.75, decay: 0.30, drive: 0.55),
                DrumTrack(.snare, p("--------x-------", "--------x-------"))
                    .character(gain: 0.82, tune: 2, tone: 0.72, decay: 0.30, drive: 0.30, reverb: 0.14),
                DrumTrack(.clap, p("--------x-------", "--------x-------"))
                    .character(gain: 0.44, pan: 0.06, tone: 0.7, decay: 0.25, reverb: 0.20),
                DrumTrack(.closedHat, p("x.o.x.o.x.o.x.o.", "x.o.x.o.x.oxxxxx"))
                    .character(gain: 0.40, pan: 0.16, tune: 3, tone: 0.68, decay: 0.16),
                DrumTrack(.openHat, p("----------------", "--------------x-"))
                    .character(gain: 0.34, pan: -0.20, tune: 2, decay: 0.40, reverb: 0.12),
                DrumTrack(.perc, p("----x-------x---", "----x-----------"))
                    .character(gain: 0.30, pan: -0.34, tune: 5, reverb: 0.24, timing: 0.3)
            ],
            melodies: [
                MelodyTrack("808", .bass808, [
                    Note(29, 0, 6, vel: 1.0), Note(32, 10, 5), Note(29, 16, 6, vel: 1.0), Note(36, 26, 5)
                ]).character(gain: 1.0, drive: 0.5, glide: 0.035),
                MelodyTrack("BELLS", .bell, [
                    Note(77, 0, 4), Note(80, 6, 2), Note(84, 8, 6),
                    Note(77, 16, 4), Note(80, 22, 2), Note(75, 24, 6)
                ]).character(gain: 0.42, pan: 0.10, reverb: 0.34, delay: 0.22),
                MelodyTrack("PAD", .pad, [
                    Note(65, 0, 15), Note(68, 0, 15), Note(72, 0, 15),
                    Note(63, 16, 15), Note(68, 16, 15), Note(70, 16, 15)
                ]).character(gain: 0.22, reverb: 0.45, cutoff: 0.55)
            ],
            mix: MixSettings(
                reverbSize: 0.70, reverbDamp: 0.55, reverbPreDelay: 0.028,
                delaySync: .dottedEighth, delayFeedback: 0.30,
                sidechain: 0.38, sidechainRelease: 0.13,
                drumDrive: 0.30, drumGlue: 0.42,
                masterDrive: 0.16, masterGlue: 0.5,
                width: 0.34, humanize: 0.10
            )
        ),
        palette: [
            "808 — long, tuned to the key, gliding between notes",
            "Kick — short and clicky, sits ON the 808 rather than under it",
            "Snare layered with a quiet clap for width",
            "Hats — closed 16ths with rolls, one open hat per two bars",
            "Bells for the hook, a dark pad underneath for glue",
            "Vocal chops, risers and one reverse crash per section"
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Bells alone, then hats join. No 808 yet."),
            SectionNote(section: "VERSE", bars: "16", whats: "Everything in. 808 following the kick pattern."),
            SectionNote(section: "HOOK", bars: "16", whats: "Add an octave-up bell layer and a second perc."),
            SectionNote(section: "BREAK", bars: "4", whats: "Drums out, pad and a riser only."),
            SectionNote(section: "HOOK 2", bars: "16", whats: "Back in harder. Hat rolls doubled.")
        ],
        makesItWork: [
            "The snare hits ONCE per bar. That single choice is what makes 140 feel slow.",
            "The 808 is the bassline and the low kick at the same time — there's no separate bass part.",
            "Sidechain at 38% means the kick punches a hole in the 808 rather than fighting it.",
            "Hat rolls land at the END of a two-bar phrase, ramping in velocity into the next one.",
            "The kick pattern is asymmetrical — bar 2 differs from bar 1. That's what stops it being a metronome.",
            "The pad is at 22% and heavily filtered. You shouldn't hear it; you should miss it when it's muted."
        ],
        mixNotes: [
            "808 dead centre and mono, driven hard so it survives on a phone speaker.",
            "The kick is short and bright so it reads through the 808 instead of adding to it.",
            "Bells are high-passed and sent to both reverb and delay — they're the only wet element.",
            "Hats sit at 40% and are panned slightly right, with the open hat opposite.",
            "Drum bus saturation at 30% glues the kit before anything else touches it."
        ],
        mistakes: [
            "Two snares per bar — that's a 70 BPM boom bap pattern at double speed and it feels frantic.",
            "A long 808 note under a busy kick — they overlap and the low end turns to mush.",
            "Hat rolls everywhere. One per 4 bars is the ceiling.",
            "Layering a big boomy kick on top of the 808. Use a short clicky one or none at all."
        ],
        tint: Ink.orange, family: .hiphop
    )

    // MARK: BOOM BAP

    static let boomBap = GenreTemplate(
        id: "boombap", name: "BOOM BAP", tagline: "SWUNG, DUSTY, SPACE BETWEEN THE HITS",
        keyName: "C MINOR", scaleName: "MINOR", feel: "88 BPM with 30% swing. Behind the beat on purpose.",
        beat: Beat(
            name: "BOOM BAP REFERENCE", bpm: 88, swing: 0.30, steps: 32,
            drums: [
                DrumTrack(.kick, p("x---------x-----", "x-------x-x-----"))
                    .character(gain: 0.98, tune: -3, tone: 0.28, decay: 0.62, drive: 0.42),
                DrumTrack(.snare, p("----x--.----x---", "----x-------x-.-"))
                    .character(gain: 0.88, tune: -1, tone: 0.42, decay: 0.55,
                               drive: 0.30, reverb: 0.16, timing: 0.35),
                DrumTrack(.closedHat, p("x-o-x-o-x-o-x-o-", "x-o-x-o-x-o-x-oo"))
                    .character(gain: 0.34, pan: 0.20, tune: -4, tone: 0.30, decay: 0.26),
                DrumTrack(.rim, p("----------------", "--------------.-"))
                    .character(gain: 0.30, pan: -0.30, tune: -2, reverb: 0.18)
            ],
            melodies: [
                MelodyTrack("BASS", .bass, [
                    Note(36, 0, 8, vel: 0.95), Note(36, 10, 5),
                    Note(41, 16, 6), Note(39, 24, 7)
                ]).character(gain: 0.82, drive: 0.30, cutoff: 0.62, timing: 0.2),
                MelodyTrack("KEYS", .keys, [
                    // Cm9 then Fm7 — the dusty two-chord loop.
                    Note(60, 0, 14), Note(63, 0, 14), Note(67, 0, 14), Note(70, 0, 14), Note(74, 0, 14),
                    Note(65, 16, 14), Note(68, 16, 14), Note(72, 16, 14), Note(75, 16, 14)
                ]).character(gain: 0.52, pan: -0.08, drive: 0.14, reverb: 0.24, cutoff: 0.52),
                MelodyTrack("ORGAN", .organ, [
                    Note(48, 0, 15), Note(55, 0, 15),
                    Note(53, 16, 15), Note(60, 16, 15)
                ]).character(gain: 0.20, reverb: 0.20, cutoff: 0.45)
            ],
            mix: MixSettings(
                reverbSize: 0.45, reverbDamp: 0.75, reverbPreDelay: 0.014,
                delaySync: .eighth, delayFeedback: 0.22,
                sidechain: 0.14, sidechainRelease: 0.10,
                drumDrive: 0.44, drumGlue: 0.55,
                masterDrive: 0.24, masterGlue: 0.55,
                width: 0.14, humanize: 0.42
            )
        ),
        palette: [
            "Kick — round, warm, tuned down, slightly soft attack. Not clicky.",
            "Snare — thick, dark, nudged late, with a short room on it.",
            "Hats — swung, dark, low velocity, deliberately imperfect.",
            "Sampled chords — filtered, pitched, ideally chopped from a record.",
            "Round electric bass following the kick, driven a little.",
            "Vinyl crackle across the whole loop at low level."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Keys alone, filtered."),
            SectionNote(section: "VERSE", bars: "16", whats: "Full drums plus bass. Top half left empty for a vocal."),
            SectionNote(section: "HOOK", bars: "8", whats: "Open the filter, add a horn or vocal chop."),
            SectionNote(section: "BREAK", bars: "4", whats: "Drums out, sample only, then a fill back in.")
        ],
        makesItWork: [
            "Swing at 30% plus 42% humanize — nothing lands exactly on the grid, ever.",
            "The snare is nudged 4 ms late. That single offset is most of the genre's feel.",
            "Ghost snares either side of the backbeat, barely audible, entirely responsible for the groove.",
            "Heavy drum-bus saturation (44%) and glue — this kit is meant to sound crushed and warm.",
            "Everything is tuned down and the hats are dark. The whole mix is deliberately dull on top.",
            "Space. There are fewer hits per bar here than in any other genre on this list."
        ],
        mixNotes: [
            "The keys are filtered at 52% cutoff so the kick and bass own the low end.",
            "Width sits at 14% — boom bap sounds right when it's narrow and nearly mono.",
            "Reverb is short and heavily damped: a small dead room, not a hall.",
            "Keep the snare loud. In this genre the snare is allowed to be the loudest thing.",
            "Sidechain is only 14% — enough to clear the kick, not enough to hear as pumping."
        ],
        mistakes: [
            "Quantising everything to 100%. Perfect timing kills this genre specifically.",
            "Too many kicks. Two or three per bar, with real gaps.",
            "A bright, clicky trap kick. It fights the sample instead of sitting under it.",
            "Forgetting to filter the sample, then wondering why the kick has no power."
        ],
        tint: Ink.clay, family: .hiphop
    )

    // MARK: DRILL

    static let drill = GenreTemplate(
        id: "drill", name: "UK DRILL", tagline: "SLIDING 808S, MENACING INTERVALS",
        keyName: "F# MINOR", scaleName: "PHRYGIAN", feel: "142 BPM, half-time, with a triplet-ish hat lope.",
        beat: Beat(
            name: "DRILL REFERENCE", bpm: 142, swing: 0.14, steps: 32,
            drums: [
                DrumTrack(.kick, p("x-------x-------", "x-----x---------"))
                    .character(gain: 0.72, tune: 4, tone: 0.9, decay: 0.12, drive: 0.3),
                DrumTrack(.snare, p("----------x-----", "----------x-----"))
                    .character(gain: 0.78, tune: 3, tone: 0.8, decay: 0.22, drive: 0.25, reverb: 0.05),
                DrumTrack(.rim, p("--------x-------", "--------x-------"))
                    .character(gain: 0.34, pan: -0.18, tune: 2, decay: 0.15),
                DrumTrack(.closedHat, p("x--x--x-x--x--x-", "x--x--x-x--x-xxx"))
                    .character(gain: 0.36, pan: 0.14, tune: 4, tone: 0.75, decay: 0.13),
                DrumTrack(.openHat, p("----------------", "------------x---"))
                    .character(gain: 0.30, pan: -0.22, tune: 3, decay: 0.32)
            ],
            melodies: [
                MelodyTrack("808", .bass808, [
                    // The slide is the genre.
                    Note(30, 0, 8, vel: 1.0), Note(37, 8, 4), Note(35, 12, 4),
                    Note(30, 16, 6, vel: 1.0), Note(33, 22, 4), Note(28, 26, 6)
                ]).character(gain: 1.0, drive: 0.55, glide: 0.075),
                MelodyTrack("LEAD", .pluck, [
                    Note(78, 0, 3), Note(79, 4, 2), Note(85, 6, 4), Note(78, 12, 3),
                    Note(78, 16, 3), Note(79, 20, 2), Note(83, 22, 6)
                ]).character(gain: 0.44, pan: 0.12, reverb: 0.10, delay: 0.08, cutoff: 1.2),
                MelodyTrack("SUB PAD", .pad, [
                    Note(66, 0, 31), Note(69, 0, 31), Note(73, 0, 31)
                ]).character(gain: 0.14, reverb: 0.30, cutoff: 0.4)
            ],
            mix: MixSettings(
                reverbSize: 0.35, reverbDamp: 0.7, reverbPreDelay: 0.012,
                delaySync: .sixteenth, delayFeedback: 0.18,
                sidechain: 0.30, sidechainRelease: 0.11,
                drumDrive: 0.22, drumGlue: 0.35,
                masterDrive: 0.14, masterGlue: 0.45,
                width: 0.22, humanize: 0.08
            )
        ),
        palette: [
            "808 with pitch glide between notes — this IS the genre.",
            "Kick — very short, tuned up, almost only a click so it doesn't fight the 808.",
            "Snare on beat 3 only, with a rim on 2 for the skip.",
            "Hats in a loping 3-3-2 pattern rather than straight 16ths.",
            "Dark, sparse lead — plucked strings, bells, or a detuned flute.",
            "Phrygian flavour: the flat 2nd degree in the melody is the menace."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Lead and hats. No 808."),
            SectionNote(section: "VERSE", bars: "16", whats: "Full. 808 sliding, lead dropped in volume."),
            SectionNote(section: "HOOK", bars: "8", whats: "Lead doubled an octave up, extra perc."),
            SectionNote(section: "SWITCH", bars: "8", whats: "New 808 pattern, same lead. Drill lives on switch-ups.")
        ],
        makesItWork: [
            "The 808 glides between notes over 75 ms rather than restating cleanly. That slide is the signature.",
            "Hats lope in a 3-3-2 grouping instead of even 16ths. Count 1-and-a, 2-and-a, 3-and.",
            "The kick is tuned UP four semitones and cut to 120 ms — it's a click, not a drum.",
            "Everything is dry. Reverb size is 35% and heavily damped, so the space stays cold.",
            "The lead uses the flat second, which is what separates drill from trap harmonically.",
            "Humanize sits at 8%. Unlike boom bap, drill wants machine precision."
        ],
        mixNotes: [
            "808 loud, mono and saturated at 55%. It's the loudest element and that's correct.",
            "Sidechain at 30% even though the kick is quiet — it keeps the attack readable.",
            "Almost no reverb on drums. A tiny room on the lead only.",
            "The lead is filtered open (cutoff 1.2) so it stays thin and distant rather than warm."
        ],
        mistakes: [
            "Straight 16th hats. That's trap. Drill needs the 3-3-2 lope.",
            "A big boomy kick under the 808 — the two cancel and the low end disappears.",
            "Overlapping 808 notes. Cut each one before the next starts or you get permanent mud.",
            "Too much melody. Drill hooks are three or four notes, repeated."
        ],
        tint: Ink.plum, family: .hiphop
    )

    // MARK: HOUSE

    static let house = GenreTemplate(
        id: "house", name: "HOUSE", tagline: "FOUR ON THE FLOOR, OFF-BEAT LIFT",
        keyName: "A MINOR", scaleName: "DORIAN", feel: "124 BPM, relentless and hypnotic.",
        beat: Beat(
            name: "HOUSE REFERENCE", bpm: 124, swing: 0.10, steps: 32,
            drums: [
                DrumTrack(.kick, p("x---x---x---x---", "x---x---x---x---"))
                    .character(gain: 1.0, tune: 1, tone: 0.6, decay: 0.28, drive: 0.4),
                DrumTrack(.clap, p("----x-------x---", "----x-------x---"))
                    .character(gain: 0.62, pan: 0.05, tone: 0.62, decay: 0.4, reverb: 0.26),
                DrumTrack(.openHat, p("--x---x---x---x-", "--x---x---x---x-"))
                    .character(gain: 0.40, pan: -0.12, tune: 1, tone: 0.6, decay: 0.30),
                DrumTrack(.closedHat, p("x-x-x-x-x-x-x-x-", "x-x-x-x-x-x-x-x-"))
                    .character(gain: 0.22, pan: 0.22, decay: 0.18),
                DrumTrack(.perc, p("------x-----x--x", "------x---x-x--x"))
                    .character(gain: 0.28, pan: -0.36, tune: 7, reverb: 0.26, delay: 0.14)
            ],
            melodies: [
                MelodyTrack("BASS", .bass, [
                    Note(33, 0, 3), Note(33, 4, 3), Note(33, 8, 3), Note(33, 12, 3),
                    Note(38, 16, 3), Note(38, 20, 3), Note(38, 24, 3), Note(38, 28, 3)
                ]).character(gain: 0.86, drive: 0.28, cutoff: 0.85),
                MelodyTrack("STABS", .organ, [
                    // Am7 then Dm7 stabs on the off-beats.
                    Note(57, 2, 2), Note(60, 2, 2), Note(64, 2, 2), Note(67, 2, 2),
                    Note(57, 10, 2), Note(60, 10, 2), Note(64, 10, 2), Note(67, 10, 2),
                    Note(62, 18, 2), Note(65, 18, 2), Note(69, 18, 2), Note(72, 18, 2),
                    Note(62, 26, 2), Note(65, 26, 2), Note(69, 26, 2), Note(72, 26, 2)
                ]).character(gain: 0.44, pan: 0.10, reverb: 0.30, delay: 0.20),
                MelodyTrack("PAD", .pad, [
                    Note(69, 0, 15), Note(72, 0, 15), Note(76, 0, 15),
                    Note(74, 16, 15), Note(77, 16, 15), Note(81, 16, 15)
                ]).character(gain: 0.20, reverb: 0.50, cutoff: 0.7)
            ],
            mix: MixSettings(
                reverbSize: 0.75, reverbDamp: 0.4, reverbPreDelay: 0.020,
                delaySync: .dottedEighth, delayFeedback: 0.36,
                sidechain: 0.62, sidechainRelease: 0.20,
                drumDrive: 0.24, drumGlue: 0.40,
                masterDrive: 0.12, masterGlue: 0.5,
                width: 0.52, humanize: 0.10, chorus: 0.25
            )
        ),
        palette: [
            "Kick — punchy with a fast decay so it doesn't smear into the next one.",
            "Clap on 2 and 4 with a generous plate reverb.",
            "Open hat on every off-beat. This is the lift that defines house.",
            "Short organ stabs on the off-beats.",
            "A rolling bassline in 8ths, sidechained hard.",
            "Shakers and congas panned wide for movement."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "16", whats: "Drums only. DJs need this to mix in."),
            SectionNote(section: "GROOVE", bars: "16", whats: "Add bass and hats."),
            SectionNote(section: "BREAKDOWN", bars: "16", whats: "Kick out, chords and pad, filter closing."),
            SectionNote(section: "DROP", bars: "32", whats: "Everything back in. The longest section."),
            SectionNote(section: "OUTRO", bars: "16", whats: "Strip back to drums for the next DJ.")
        ],
        makesItWork: [
            "Off-beat open hats against a four-on-the-floor kick. That tension is the entire genre.",
            "Sidechain at 62% — here the pump is audible on purpose. It IS the groove.",
            "Chord stabs land off the grid's downbeats, so they push against the kick.",
            "Chorus on the music bus widens the stabs and pad without a stereo widener.",
            "Long sections. House builds over minutes, not bars.",
            "Very little changes at any one time. The hypnotism comes from patience."
        ],
        mixNotes: [
            "The kick is the loudest thing. Everything else ducks around it.",
            "Width at 52% — the widest mix here after afrobeats — but the bass stays mono.",
            "Reverb is large (75%) and bright: a real room, not a small one.",
            "Perc goes to both reverb and delay so it smears across the stereo field.",
            "Leave a long DJ-friendly intro and outro of drums only."
        ],
        mistakes: [
            "Closed hats on every 16th at full volume — it makes the groove feel busy and cheap.",
            "Changing something every four bars. House needs longer than that to hypnotise.",
            "A short intro. If a DJ can't beatmatch into it, it won't get played.",
            "Chords on the downbeat with the kick. Move them to the off-beats and it grooves."
        ],
        tint: Ink.amber, family: .house
    )

    // MARK: LO-FI

    static let lofi = GenreTemplate(
        id: "lofi", name: "LO-FI", tagline: "SWUNG, SOFT, DELIBERATELY IMPERFECT",
        keyName: "D MINOR", scaleName: "DORIAN", feel: "78 BPM, heavy swing, nothing on the grid.",
        beat: Beat(
            name: "LO-FI REFERENCE", bpm: 78, swing: 0.36, steps: 32,
            drums: [
                DrumTrack(.kick, p("x-------x-------", "x-----------x---"))
                    .character(gain: 0.86, tune: -4, tone: 0.12, decay: 0.55, drive: 0.30),
                DrumTrack(.rim, p("----x-------x---", "----x-------x---"))
                    .character(gain: 0.46, pan: -0.14, tune: -3, decay: 0.35,
                               reverb: 0.22, timing: 0.45),
                DrumTrack(.closedHat, p("x-o.x-o.x-o.x-o.", "x-o.x-o.x-o.x-oo"))
                    .character(gain: 0.26, pan: 0.16, tune: -6, tone: 0.16, decay: 0.30),
                DrumTrack(.perc, p("--------------.-", "------.---------"))
                    .character(gain: 0.18, pan: 0.34, tune: -2, reverb: 0.35)
            ],
            melodies: [
                MelodyTrack("KEYS", .keys, [
                    // Dm9 -> Gm7. The 9th is what stops it sounding like a beginner chord.
                    Note(62, 0, 14), Note(65, 0, 14), Note(69, 0, 14), Note(72, 0, 14), Note(76, 0, 14),
                    Note(67, 16, 14), Note(70, 16, 14), Note(74, 16, 14), Note(77, 16, 14)
                ]).character(gain: 0.62, pan: -0.06, drive: 0.10, reverb: 0.30,
                             cutoff: 0.40, timing: 0.25),
                MelodyTrack("BASS", .bass, [
                    Note(38, 0, 7, vel: 0.85), Note(38, 8, 5),
                    Note(31, 16, 7, vel: 0.85), Note(33, 26, 5)
                ]).character(gain: 0.78, drive: 0.16, cutoff: 0.5, timing: 0.3),
                MelodyTrack("PAD", .pad, [
                    Note(50, 0, 15), Note(57, 0, 15),
                    Note(55, 16, 15), Note(62, 16, 15)
                ]).character(gain: 0.16, reverb: 0.44, cutoff: 0.3)
            ],
            mix: MixSettings(
                reverbSize: 0.55, reverbDamp: 0.85, reverbPreDelay: 0.018,
                delaySync: .quarter, delayFeedback: 0.24,
                sidechain: 0.10, sidechainRelease: 0.22,
                drumDrive: 0.30, drumGlue: 0.30,
                masterDrive: 0.20, masterGlue: 0.35,
                width: 0.24, humanize: 0.55, chorus: 0.18
            )
        ),
        palette: [
            "Kick — soft, tuned way down, no click, almost muffled.",
            "Rimshot instead of a snare, dragged well behind the beat.",
            "Hats swung heavily, dark, and low in the mix.",
            "Rhodes with 9th chords, filtered down to 40% cutoff.",
            "Vinyl crackle, tape hiss, a low-passed field recording.",
            "Warm bass, played sparsely and slightly late."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Keys and crackle only."),
            SectionNote(section: "MAIN", bars: "16", whats: "Full loop. This is 80% of the track."),
            SectionNote(section: "BREAK", bars: "8", whats: "Drums out, keys and a sampled voice."),
            SectionNote(section: "OUTRO", bars: "8", whats: "Fade the drums, let the keys ring out.")
        ],
        makesItWork: [
            "Humanize at 55% — the highest here. Nothing is quantised, and that's the point.",
            "The rim is dragged 5 ms late and the keys 3 ms late. The whole track leans backwards.",
            "9th chords instead of plain triads — that's the entire harmonic identity.",
            "Everything is tuned down and filtered. There is almost no energy above 10 kHz.",
            "Chorus at 18% gives the Rhodes the tape-wow instability the genre lives on.",
            "Sparse. Four or five elements total, never more."
        ],
        mixNotes: [
            "Reverb damping at 85% — the tail dies dark, like a room with carpet and curtains.",
            "Sidechain is barely there (10%). Lo-fi should never audibly pump.",
            "Master drive at 20% for tape-style softness on the peaks.",
            "Keep the drums quieter than in any other genre here. The chords lead."
        ],
        mistakes: [
            "Bright, modern drum samples. They break the illusion instantly.",
            "Plain major and minor triads — it'll sound like a beginner sketch. Add the 7th and 9th.",
            "Perfect quantisation. Turn the swing up and drag hits off the grid by hand.",
            "Too many layers. If you're on element six, delete two."
        ],
        tint: Ink.claySoft, family: .chill
    )

    // MARK: AFROBEATS

    static let afrobeats = GenreTemplate(
        id: "afro", name: "AFROBEATS", tagline: "SYNCOPATED, PERCUSSIVE, BRIGHT",
        keyName: "D MINOR", scaleName: "MINOR", feel: "105 BPM, rolling, never straight.",
        beat: Beat(
            name: "AFROBEATS REFERENCE", bpm: 105, swing: 0.16, steps: 32,
            drums: [
                DrumTrack(.kick, p("x-----x---x-----", "x-----x---x---x-"))
                    .character(gain: 0.92, tune: 0, tone: 0.5, decay: 0.40, drive: 0.30),
                DrumTrack(.rim, p("----x-------x---", "----x-------x---"))
                    .character(gain: 0.44, pan: -0.20, tune: 3, reverb: 0.16),
                DrumTrack(.closedHat, p("x-xxx-x-x-xxx-x-", "x-xxx-x-x-xxx-x-"))
                    .character(gain: 0.30, pan: 0.26, tune: 5, tone: 0.66, decay: 0.16),
                DrumTrack(.perc, p("--x---x-x---x-x-", "--x---x-x---x-xx"))
                    .character(gain: 0.42, pan: -0.42, tune: 4, reverb: 0.22, delay: 0.10),
                DrumTrack(.tom, p("----------------", "------------x-x-"))
                    .character(gain: 0.40, pan: 0.34, tune: 2, decay: 0.35, reverb: 0.20),
                DrumTrack(.openHat, p("------------x---", "------------x---"))
                    .character(gain: 0.22, pan: -0.16, tune: 4, decay: 0.25)
            ],
            melodies: [
                MelodyTrack("BASS", .bass, [
                    Note(38, 0, 5), Note(38, 6, 3), Note(45, 10, 5),
                    Note(38, 16, 5), Note(41, 22, 4), Note(43, 28, 4)
                ]).character(gain: 0.84, drive: 0.22, cutoff: 0.95),
                MelodyTrack("LOG DRUM", .pluck, [
                    Note(50, 2, 2), Note(53, 4, 2), Note(57, 6, 2), Note(53, 10, 2),
                    Note(50, 18, 2), Note(53, 20, 2), Note(57, 22, 4)
                ]).character(gain: 0.56, pan: 0.16, reverb: 0.20, delay: 0.14, cutoff: 0.7),
                MelodyTrack("KEYS", .organ, [
                    Note(74, 2, 2), Note(77, 4, 2), Note(81, 6, 2), Note(77, 10, 2),
                    Note(74, 18, 2), Note(77, 20, 2), Note(81, 22, 4)
                ]).character(gain: 0.34, pan: -0.24, reverb: 0.28, delay: 0.18),
                MelodyTrack("PAD", .pad, [
                    Note(62, 0, 15), Note(65, 0, 15), Note(69, 0, 15),
                    Note(60, 16, 15), Note(65, 16, 15), Note(69, 16, 15)
                ]).character(gain: 0.18, reverb: 0.46, cutoff: 0.75)
            ],
            mix: MixSettings(
                reverbSize: 0.66, reverbDamp: 0.35, reverbPreDelay: 0.024,
                delaySync: .eighth, delayFeedback: 0.30,
                sidechain: 0.24, sidechainRelease: 0.14,
                drumDrive: 0.20, drumGlue: 0.32,
                masterDrive: 0.10, masterGlue: 0.4,
                width: 0.62, humanize: 0.24, chorus: 0.12
            )
        ),
        palette: [
            "Kick — round and mid-weight, syncopated rather than on the beat.",
            "Rim or side-stick on 2 and 4 instead of a big snare.",
            "Shakers and congas doing most of the rhythmic work, panned wide.",
            "Log drum or muted pluck playing a short repeating figure.",
            "Bright, bouncy bass with real note movement — not just root notes.",
            "Open, airy pads and guitar-like plucks."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Percussion and pluck."),
            SectionNote(section: "VERSE", bars: "16", whats: "Full groove, bass moving."),
            SectionNote(section: "HOOK", bars: "16", whats: "Add a vocal-style lead and extra perc layers."),
            SectionNote(section: "BRIDGE", bars: "8", whats: "Drop the kick, let the percussion carry it.")
        ],
        makesItWork: [
            "The kick is syncopated — it avoids landing squarely on every beat.",
            "Percussion is a lead instrument here, panned hard left against toms hard right.",
            "The bass moves melodically instead of just doubling the kick.",
            "The backbeat is a quiet rim, not a loud snare. The groove comes from layers, not impact.",
            "Width at 62% — the widest mix in the set. Everything except bass is spread.",
            "Bright reverb with low damping keeps the top end open and airy."
        ],
        mixNotes: [
            "Pan percussion wide and keep it moving.",
            "Bass sits higher than in trap — cutoff is nearly open. Don't bury it below 60 Hz.",
            "Short bright reverbs on the plucks. Long tails would kill the bounce.",
            "Keep the rim quiet and let the shakers carry the top end."
        ],
        mistakes: [
            "A four-on-the-floor kick. It flattens the whole feel.",
            "A big trap snare on 2 and 4 — too heavy for the groove.",
            "Root-note-only bass. The bass needs to sing here.",
            "Straight, unswung hats. Add 15% and it starts rolling."
        ],
        tint: Ink.orange, family: .global
    )

    // MARK: DRUM & BASS

    static let dnb = GenreTemplate(
        id: "dnb", name: "DRUM & BASS", tagline: "BREAKBEAT AT 174, SUB UNDERNEATH",
        keyName: "A MINOR", scaleName: "MINOR", feel: "174 BPM with a half-time feel on top.",
        beat: Beat(
            name: "DNB REFERENCE", bpm: 174, swing: 0.06, steps: 32,
            drums: [
                DrumTrack(.kick, p("x------------x--", "x-------x-------"))
                    .character(gain: 0.95, tune: 2, tone: 0.72, decay: 0.25, drive: 0.4),
                DrumTrack(.snare, p("--------x-------", "--------x----x--"))
                    .character(gain: 0.92, tune: 1, tone: 0.78, decay: 0.4,
                               drive: 0.32, reverb: 0.28),
                DrumTrack(.closedHat, p("x-x-x-x-x-x-x-x-", "x-x-x-x-x-x-xxx-"))
                    .character(gain: 0.26, pan: 0.24, tune: 2, decay: 0.15),
                DrumTrack(.rim, p("------.---.-----", "------.---.-----"))
                    .character(gain: 0.24, pan: -0.30, tune: 4),
                DrumTrack(.crash, p("x---------------", "----------------"))
                    .character(gain: 0.30, pan: 0.10, decay: 0.8, reverb: 0.36)
            ],
            melodies: [
                MelodyTrack("SUB", .sub, [
                    Note(33, 0, 14, vel: 1.0), Note(33, 16, 8, vel: 1.0), Note(36, 24, 7)
                ]).character(gain: 0.95),
                MelodyTrack("REESE", .reese, [
                    Note(45, 0, 14, vel: 0.8), Note(45, 16, 8), Note(48, 24, 7)
                ]).character(gain: 0.40, drive: 0.42, cutoff: 0.6),
                MelodyTrack("PAD", .pad, [
                    Note(69, 0, 15), Note(72, 0, 15), Note(76, 0, 15),
                    Note(69, 16, 15), Note(74, 16, 15), Note(77, 16, 15)
                ]).character(gain: 0.26, reverb: 0.55, cutoff: 0.6)
            ],
            mix: MixSettings(
                reverbSize: 0.82, reverbDamp: 0.35, reverbPreDelay: 0.030,
                delaySync: .quarter, delayFeedback: 0.30,
                sidechain: 0.22, sidechainRelease: 0.09,
                drumDrive: 0.34, drumGlue: 0.60,
                masterDrive: 0.14, masterGlue: 0.55,
                width: 0.46, humanize: 0.12
            )
        ),
        palette: [
            "Two-step break: kick on 1, snare on the 3rd beat of the fast grid.",
            "Chopped breakbeat layered under the main kick and snare.",
            "Pure sine sub bass, one long note per bar or two.",
            "Reese bass — detuned saws — an octave above the sub for aggression.",
            "Atmospheric pads and long reverb tails between the drums.",
            "Rides and ghost snares filling the gaps."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "16", whats: "Pad and atmosphere. Half-time drums."),
            SectionNote(section: "BUILD", bars: "16", whats: "Break rises, filter opens, snare rolls."),
            SectionNote(section: "DROP", bars: "32", whats: "Full break and sub. Longest section."),
            SectionNote(section: "BREAKDOWN", bars: "16", whats: "Drums out, pad only."),
            SectionNote(section: "DROP 2", bars: "32", whats: "Same energy, different bass patch.")
        ],
        makesItWork: [
            "Fast drums, slow bass. The sub moves at a quarter of the speed of the break.",
            "The sub is a clean sine; the Reese sits an octave above it doing the aggression.",
            "The two-step pattern leaves beats 2 and 4 mostly empty — that space is the groove.",
            "Ghost rims fill the gaps at low velocity, so it sounds busy without being cluttered.",
            "Big bright reverb (82%) with 30 ms pre-delay: the snare is in a hall, the kick isn't.",
            "Heavy drum-bus glue at 60% is what makes the break sound like one instrument."
        ],
        mixNotes: [
            "Sub is mono and owns everything below 100 Hz. Nothing else goes there.",
            "The snare is the brightest and most forward element after the kick.",
            "The Reese is filtered to 60% so it doesn't compete with the snare's midrange.",
            "High-pass every pad and atmosphere; the pad here is filtered to 60% cutoff."
        ],
        mistakes: [
            "Writing the bassline as fast as the drums. The sub should be slow and long.",
            "A trap-style 808 instead of a clean sine sub — the harmonics clash with the break.",
            "Too much reverb on the drums themselves. Send the snare only.",
            "Short sections. DnB drops run 32 bars minimum."
        ],
        tint: Ink.steel, family: .bass
    )

    // MARK: R&B / POP

    static let rnb = GenreTemplate(
        id: "rnb", name: "R&B / POP", tagline: "LAID BACK, SPACE FOR A VOCAL",
        keyName: "G MINOR", scaleName: "MINOR", feel: "92 BPM, relaxed, built around a voice that isn't there yet.",
        beat: Beat(
            name: "R&B REFERENCE", bpm: 92, swing: 0.18, steps: 32,
            drums: [
                DrumTrack(.kick, p("x-------x---x---", "x-------x-------"))
                    .character(gain: 0.90, tune: -2, tone: 0.4, decay: 0.5, drive: 0.28),
                DrumTrack(.clap, p("----x-------x---", "----x-------x---"))
                    .character(gain: 0.60, pan: 0.08, tone: 0.5, decay: 0.35,
                               reverb: 0.30, timing: 0.30),
                DrumTrack(.snare, p("------.-----.---", "------.-----.-.-"))
                    .character(gain: 0.24, tone: 0.35, decay: 0.3, reverb: 0.12),
                DrumTrack(.closedHat, p("x-o-x-o-x-o-x-o-", "x-o-x-o-x-o-x-oo"))
                    .character(gain: 0.26, pan: 0.20, tune: -2, tone: 0.4, decay: 0.2),
                DrumTrack(.perc, p("----------------", "--------------x-"))
                    .character(gain: 0.20, pan: -0.34, tune: 6, reverb: 0.34)
            ],
            melodies: [
                MelodyTrack("KEYS", .keys, [
                    // Gm9 -> Ebmaj7, voiced wide to leave the vocal range open.
                    Note(58, 0, 14), Note(62, 0, 14), Note(65, 0, 14), Note(69, 0, 14), Note(72, 0, 14),
                    Note(63, 16, 14), Note(67, 16, 14), Note(70, 16, 14), Note(74, 16, 14)
                ]).character(gain: 0.54, pan: -0.10, reverb: 0.26, cutoff: 0.6),
                MelodyTrack("BASS", .bass, [
                    Note(31, 0, 7, vel: 0.9), Note(31, 8, 3), Note(31, 12, 3),
                    Note(27, 16, 7, vel: 0.9), Note(27, 24, 5)
                ]).character(gain: 0.82, drive: 0.2, cutoff: 0.7, glide: 0.03),
                MelodyTrack("BELL", .bell, [
                    Note(82, 6, 2), Note(86, 14, 2), Note(82, 22, 2), Note(79, 30, 2)
                ]).character(gain: 0.24, pan: 0.30, reverb: 0.42, delay: 0.30),
                MelodyTrack("PAD", .pad, [
                    Note(70, 0, 15), Note(74, 0, 15),
                    Note(70, 16, 15), Note(75, 16, 15)
                ]).character(gain: 0.16, reverb: 0.48, cutoff: 0.55)
            ],
            mix: MixSettings(
                reverbSize: 0.60, reverbDamp: 0.5, reverbPreDelay: 0.032,
                delaySync: .dottedEighth, delayFeedback: 0.28,
                sidechain: 0.16, sidechainRelease: 0.16,
                drumDrive: 0.16, drumGlue: 0.28,
                masterDrive: 0.08, masterGlue: 0.35,
                width: 0.40, humanize: 0.30, chorus: 0.16
            )
        ),
        palette: [
            "Kick — deep but restrained. This mix belongs to the vocal.",
            "Clap on 2 and 4, dragged late, with a plate reverb.",
            "Ghost snares at very low velocity for motion.",
            "Rhodes playing 9th chords, voiced wide with a hole in the middle.",
            "Round, warm bass with slides between notes.",
            "One high, sparse bell as ear candy."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Keys alone, maybe a filtered vocal."),
            SectionNote(section: "VERSE", bars: "16", whats: "Drums in, everything below the vocal range."),
            SectionNote(section: "PRE", bars: "8", whats: "Drop the kick, add the pad, build tension."),
            SectionNote(section: "HOOK", bars: "16", whats: "Full arrangement, bell on top."),
            SectionNote(section: "BRIDGE", bars: "8", whats: "Strip to keys and a vocal.")
        ],
        makesItWork: [
            "A hole in the middle of the arrangement, deliberately left for a voice.",
            "9th chords voiced wide — nothing crowds 200 Hz–2 kHz where a vocal lives.",
            "The clap sits 4 ms behind the grid and humanize is at 30%. It leans, it doesn't march.",
            "Ghost snares and hat variation carry the movement instead of loud elements.",
            "32 ms pre-delay on the reverb keeps everything clear and up front despite the space.",
            "Restraint. Master drive is 8% — the lowest here. It stays dynamic."
        ],
        mixNotes: [
            "Keys filtered to 60% cutoff so they sit behind a vocal that isn't recorded yet.",
            "Short plate on the clap, longer hall on the keys and bell, none on the bass.",
            "Sidechain at 16% — this genre shouldn't pump audibly.",
            "Keep the whole mix a few dB quieter and more dynamic than a trap or house reference."
        ],
        mistakes: [
            "Filling the midrange with layers. A vocal will have nowhere to sit.",
            "A loud snappy snare — too aggressive. Use a clap or a soft ghost snare.",
            "Straight triads. Add the 7th and 9th and it immediately sounds like R&B.",
            "Too much going on in the hook. Add one element, not four."
        ],
        tint: Ink.plum, family: .rnb
    )

    static let all: [GenreTemplate] = {
        var out: [GenreTemplate] = [trap, boomBap, drill]
        out.append(contentsOf: HipHopTemplates.all)
        out.append(rnb)
        out.append(contentsOf: SoulTemplates.all)
        out.append(house)
        out.append(contentsOf: ClubTemplates.all)
        out.append(dnb)
        out.append(contentsOf: BassTemplates.all)
        out.append(afrobeats)
        out.append(contentsOf: GlobalTemplates.all)
        out.append(lofi)
        out.append(contentsOf: ChillTemplates.all)
        out.append(contentsOf: PopTemplates.all)
        return out
    }()

    static func template(_ id: String) -> GenreTemplate? {
        all.first { $0.id == id }
    }

    static func inFamily(_ f: GenreFamily) -> [GenreTemplate] {
        all.filter { $0.family == f }
    }
}
