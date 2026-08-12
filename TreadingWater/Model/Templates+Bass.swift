import Foundation
import SwiftUI

enum BassTemplates {

    static let jungle = GenreTemplate(
        id: "jungle", name: "JUNGLE", tagline: "CHOPPED BREAK, RAGGA SUB",
        keyName: "E MINOR", scaleName: "MINOR", feel: "170 BPM. The break is the whole arrangement.",
        beat: Beat(
            name: "JUNGLE REFERENCE", bpm: 170, swing: 0.10, steps: 32,
            drums: [
                DrumTrack(.kick, p("x-----x-----x---", "x---------x-----"))
                    .character(gain: 0.92, tune: 0, tone: 0.6, decay: 0.26, drive: 0.5),
                DrumTrack(.snare, p("----x-.-x---x-.-", "----x-------x-x-"))
                    .character(gain: 0.90, tune: 1, tone: 0.7, decay: 0.34, drive: 0.4, reverb: 0.24),
                DrumTrack(.closedHat, p("x-x-x-x-x-x-x-x-", "x-x-x-x-x-x-xxx-"))
                    .character(gain: 0.26, pan: 0.24, tune: 2, decay: 0.13),
                DrumTrack(.rim, p("--.---.---.---.-", "--.---.---.---.-"))
                    .character(gain: 0.22, pan: -0.30, tune: 4)
            ],
            melodies: [
                MelodyTrack("SUB", .sub, [
                    Note(28, 0, 12, vel: 1.0), Note(28, 16, 8), Note(31, 24, 7)
                ]).character(gain: 0.95),
                MelodyTrack("PAD", .pad, [
                    Note(64, 0, 15), Note(67, 0, 15), Note(71, 0, 15),
                    Note(62, 16, 15), Note(66, 16, 15), Note(69, 16, 15)
                ]).character(gain: 0.24, reverb: 0.58, cutoff: 0.55)
            ],
            mix: MixSettings(
                reverbSize: 0.80, reverbDamp: 0.4, reverbPreDelay: 0.026,
                delaySync: .quarter, delayFeedback: 0.30,
                sidechain: 0.18, sidechainRelease: 0.08,
                drumDrive: 0.48, drumGlue: 0.62,
                masterDrive: 0.22, masterGlue: 0.55,
                width: 0.44, humanize: 0.26
            )
        ),
        palette: [
            "A chopped and rearranged breakbeat — ghost snares everywhere.",
            "Deep clean sine sub, moving at a quarter of the drum speed.",
            "Ragga vocal samples and air-horn stabs.",
            "Dark filtered pad in the background."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "16", whats: "Pad and sub, drums filtered."),
            SectionNote(section: "DROP", bars: "32", whats: "Full break, sub loud."),
            SectionNote(section: "BREAKDOWN", bars: "16", whats: "Drums out entirely."),
            SectionNote(section: "DROP 2", bars: "32", whats: "New break edit, same sub.")
        ],
        makesItWork: [
            "Ghost snares between the main hits — that density is what separates jungle from DnB.",
            "Heavy drum-bus saturation (48%) and glue (62%) makes the break sound sampled.",
            "The sub is slow, clean and enormous, with nothing else below 100 Hz.",
            "Humanised at 26%: chopped breaks were never perfectly quantised."
        ],
        mixNotes: [
            "Crush the drum bus. This should sound like a sampled record, not a drum machine.",
            "Sub mono and centred, everything else high-passed hard.",
            "Long bright reverb on the snare only.",
            "Keep the pad very low — it is atmosphere, not harmony."
        ],
        mistakes: [
            "A clean, sparse break. Jungle is dense.",
            "An 808-style bass. Use a clean sine sub.",
            "Perfect quantisation.",
            "Too little saturation — the grit is the genre."
        ],
        tint: Ink.clay, family: .bass
    )

    static let dubstep = GenreTemplate(
        id: "dubstep", name: "DUBSTEP", tagline: "HALF-TIME, WOBBLE, ENORMOUS SPACE",
        keyName: "F MINOR", scaleName: "PHRYGIAN", feel: "140 BPM that feels like 70. Sub-led.",
        beat: Beat(
            name: "DUBSTEP REFERENCE", bpm: 140, swing: 0, steps: 32,
            drums: [
                DrumTrack(.kick, p("x---------------", "x-------x-------"))
                    .character(gain: 1.0, tune: -2, tone: 0.55, decay: 0.35, drive: 0.5),
                DrumTrack(.snare, p("--------x-------", "--------x-------"))
                    .character(gain: 0.92, tune: 0, tone: 0.6, decay: 0.5, drive: 0.35, reverb: 0.38),
                DrumTrack(.closedHat, p("----x-------x---", "----x---x---x-x-"))
                    .character(gain: 0.24, pan: 0.22, tune: 2, decay: 0.14),
                DrumTrack(.perc, p("--------------x-", "------------x---"))
                    .character(gain: 0.24, pan: -0.34, tune: 6, reverb: 0.30)
            ],
            melodies: [
                MelodyTrack("SUB", .sub, [
                    Note(29, 0, 8, vel: 1.0), Note(29, 8, 8), Note(32, 16, 8), Note(28, 24, 8)
                ]).character(gain: 0.95),
                MelodyTrack("WOBBLE", .reese, [
                    Note(41, 0, 4), Note(41, 6, 2), Note(41, 10, 4),
                    Note(44, 16, 4), Note(40, 22, 4), Note(41, 28, 4)
                ]).character(gain: 0.46, drive: 0.55, cutoff: 0.42),
                MelodyTrack("PAD", .pad, [
                    Note(65, 0, 15), Note(68, 0, 15),
                    Note(63, 16, 15), Note(68, 16, 15)
                ]).character(gain: 0.20, reverb: 0.60, cutoff: 0.5)
            ],
            mix: MixSettings(
                reverbSize: 0.85, reverbDamp: 0.35, reverbPreDelay: 0.034,
                delaySync: .dottedEighth, delayFeedback: 0.28,
                sidechain: 0.30, sidechainRelease: 0.16,
                drumDrive: 0.34, drumGlue: 0.48,
                masterDrive: 0.20, masterGlue: 0.5,
                width: 0.40, humanize: 0.06
            )
        ),
        palette: [
            "One kick, one snare per bar. Everything else is bass.",
            "Clean sine sub underneath a filtered, driven Reese for the growl.",
            "Enormous snare reverb — the space is an instrument here.",
            "Sparse, wide percussion in the gaps."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "16", whats: "Pad and atmosphere."),
            SectionNote(section: "BUILD", bars: "8", whats: "Snare rolls, filter opening."),
            SectionNote(section: "DROP", bars: "16", whats: "Wobble in, half-time drums."),
            SectionNote(section: "BREAKDOWN", bars: "16", whats: "Everything out but pad.")
        ],
        makesItWork: [
            "Half-time drums at 140 leave enormous gaps, and the bass fills all of them.",
            "The sub and the Reese are separate layers doing separate jobs.",
            "Snare reverb at 38% send with a 34 ms pre-delay — huge but still punchy.",
            "Zero swing. Dubstep is rigid so the bass movement stands out."
        ],
        mixNotes: [
            "Sub owns everything below 100 Hz; the Reese is filtered to 42% so they don't fight.",
            "Snare bright and drenched; kick dry and short.",
            "Drum glue at 48% keeps the sparse kit sounding deliberate.",
            "Keep width moderate — the low end must stay mono."
        ],
        mistakes: [
            "Two snares per bar. It has to be half-time.",
            "A single bass patch trying to be both sub and growl.",
            "Busy hats. The space is the point.",
            "Reverb on the kick or sub."
        ],
        tint: Ink.plum, family: .bass
    )

    static let techno = GenreTemplate(
        id: "techno", name: "TECHNO", tagline: "RELENTLESS, HYPNOTIC, DARK",
        keyName: "A MINOR", scaleName: "MINOR", feel: "132 BPM, machine-locked.",
        beat: Beat(
            name: "TECHNO REFERENCE", bpm: 132, swing: 0, steps: 32,
            drums: [
                DrumTrack(.kick, p("x---x---x---x---", "x---x---x---x---"))
                    .character(gain: 1.0, tune: -2, tone: 0.5, decay: 0.42, drive: 0.55),
                DrumTrack(.closedHat, p("--x---x---x---x-", "--x---x---x---x-"))
                    .character(gain: 0.30, pan: 0.20, tune: 2, tone: 0.55, decay: 0.13),
                DrumTrack(.clap, p("------------x---", "------------x---"))
                    .character(gain: 0.46, pan: 0.04, tone: 0.55, decay: 0.3, reverb: 0.28),
                DrumTrack(.perc, p("---x--x---x--x--", "---x--x---x-xx--"))
                    .character(gain: 0.30, pan: -0.36, tune: 5, decay: 0.2, reverb: 0.22),
                DrumTrack(.rim, p("x-------x-------", "x-------x-------"))
                    .character(gain: 0.20, pan: 0.32, tune: 6)
            ],
            melodies: [
                MelodyTrack("SUB", .sub, [
                    Note(33, 0, 15), Note(33, 16, 15)
                ]).character(gain: 0.70),
                MelodyTrack("STAB", .lead, [
                    Note(69, 2, 1), Note(69, 10, 1), Note(72, 18, 1), Note(69, 26, 1)
                ]).character(gain: 0.32, pan: 0.14, reverb: 0.40, delay: 0.30, cutoff: 0.8),
                MelodyTrack("DRONE", .pad, [
                    Note(57, 0, 31), Note(64, 0, 31)
                ]).character(gain: 0.18, reverb: 0.52, cutoff: 0.4)
            ],
            mix: MixSettings(
                reverbSize: 0.70, reverbDamp: 0.5, reverbPreDelay: 0.020,
                delaySync: .dottedEighth, delayFeedback: 0.40,
                sidechain: 0.52, sidechainRelease: 0.16,
                drumDrive: 0.42, drumGlue: 0.50,
                masterDrive: 0.24, masterGlue: 0.5,
                width: 0.36, humanize: 0.04
            )
        ),
        palette: [
            "Long, driven kick with real body — the kick IS the bass.",
            "Off-beat hats, dry and clipped.",
            "Clap on beat 4 only, not 2 and 4.",
            "A single filtered stab with heavy delay as the only melody."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "32", whats: "Kick and hats only."),
            SectionNote(section: "BUILD", bars: "32", whats: "Percussion layers added one at a time."),
            SectionNote(section: "PEAK", bars: "64", whats: "Stab and drone, filter slowly opening."),
            SectionNote(section: "OUTRO", bars: "32", whats: "Strip back to the kick.")
        ],
        makesItWork: [
            "Humanize at 4% — the most rigid template here, and that rigidity is the appeal.",
            "The clap on beat 4 alone stops it feeling like house.",
            "Sidechain at 52% pumps the drone and sub with every kick.",
            "Change happens over 32 and 64 bars, not 8."
        ],
        mixNotes: [
            "Kick long and saturated; it should occupy the whole low end.",
            "Sub is a drone, not a bassline — keep it under the kick.",
            "Big delay on the stab is the only obvious effect.",
            "Drive the master; techno is meant to sound pushed."
        ],
        mistakes: [
            "A melody. Techno resists melodies.",
            "Fast section changes. Patience is the genre.",
            "Swing.",
            "A short clicky kick — it needs body and length."
        ],
        tint: Ink.blackSoft, family: .bass
    )

    static let footwork = GenreTemplate(
        id: "footwork", name: "FOOTWORK / JUKE", tagline: "TRIPLET KICKS, 160, RELENTLESS",
        keyName: "C MINOR", scaleName: "MIN PENT", feel: "160 BPM built on triplet groupings.",
        beat: Beat(
            name: "FOOTWORK REFERENCE", bpm: 160, swing: 0, steps: 32,
            drums: [
                DrumTrack(.kick, p("x--x--x---x--x--", "x--x--x---x-x---"))
                    .character(gain: 0.95, tune: -1, tone: 0.55, decay: 0.26, drive: 0.45),
                DrumTrack(.clap, p("--------x-------", "--------x-------"))
                    .character(gain: 0.58, pan: 0.05, tone: 0.6, decay: 0.24, reverb: 0.18),
                DrumTrack(.closedHat, p("x-x-x-x-x-x-x-x-", "x-x-x-x-x-xxx-x-"))
                    .character(gain: 0.26, pan: 0.22, tune: 3, decay: 0.11),
                DrumTrack(.rim, p("------x-------x-", "------x---x---x-"))
                    .character(gain: 0.30, pan: -0.30, tune: 5),
                DrumTrack(.perc, p("----------x-----", "----------x---x-"))
                    .character(gain: 0.26, pan: -0.40, tune: 7, reverb: 0.20)
            ],
            melodies: [
                MelodyTrack("BASS", .sub, [
                    Note(36, 0, 3), Note(36, 6, 3), Note(36, 10, 4),
                    Note(34, 16, 3), Note(39, 22, 3), Note(36, 26, 5)
                ]).character(gain: 0.90),
                MelodyTrack("CHOP", .pluck, [
                    Note(72, 2, 1), Note(75, 5, 1), Note(72, 8, 1), Note(79, 13, 1),
                    Note(72, 18, 1), Note(75, 21, 1), Note(77, 26, 2)
                ]).character(gain: 0.34, pan: 0.16, reverb: 0.26, delay: 0.22)
            ],
            mix: MixSettings(
                reverbSize: 0.48, reverbDamp: 0.55, reverbPreDelay: 0.014,
                delaySync: .sixteenth, delayFeedback: 0.22,
                sidechain: 0.36, sidechainRelease: 0.09,
                drumDrive: 0.30, drumGlue: 0.42,
                masterDrive: 0.16, masterGlue: 0.48,
                width: 0.32, humanize: 0.06
            )
        ),
        palette: [
            "Kicks grouped in threes against a straight 4/4 — the defining tension.",
            "Single clap on beat 3, nothing on beat 1.",
            "Rapid chopped vocal or melodic stabs.",
            "Simple sub following the kick."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "16", whats: "Kick pattern and hats."),
            SectionNote(section: "MAIN", bars: "32", whats: "Chops and bass in."),
            SectionNote(section: "SWITCH", bars: "16", whats: "New kick grouping."),
            SectionNote(section: "OUT", bars: "16", whats: "Strip to drums.")
        ],
        makesItWork: [
            "The 3-3-2 kick grouping fighting the 4/4 grid is the entire rhythmic idea.",
            "The backbeat lands on 3, not 2 and 4, which is why it feels like it's tripping forward.",
            "Very short chops repeated obsessively.",
            "Almost no swing or humanize — the polyrhythm supplies the movement."
        ],
        mixNotes: [
            "Everything short and dry. Long tails destroy the rhythm.",
            "Sub simple and centred, following the kick.",
            "Chops panned and delayed for width without clutter.",
            "Fast sidechain so the dense kick pattern stays readable."
        ],
        mistakes: [
            "An even kick pattern.",
            "Backbeat on 2 and 4 — that makes it juke-flavoured house.",
            "Long reverbs.",
            "Complex harmony. Footwork is rhythm-first."
        ],
        tint: Ink.amber, family: .bass
    )

    static let all: [GenreTemplate] = [jungle, dubstep, techno, footwork]
}
