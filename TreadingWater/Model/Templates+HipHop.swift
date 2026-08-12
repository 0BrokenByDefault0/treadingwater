import Foundation
import SwiftUI

enum HipHopTemplates {

    // MARK: PHONK

    static let phonk = GenreTemplate(
        id: "phonk", name: "PHONK", tagline: "MEMPHIS COWBELL, DISTORTED 808",
        keyName: "A MINOR", scaleName: "MINOR", feel: "130 BPM half-time. Grimy on purpose.",
        beat: Beat(
            name: "PHONK REFERENCE", bpm: 130, swing: 0.06, steps: 32,
            drums: [
                DrumTrack(.kick, p("x-----x---x-----", "x-----x---x--x--"))
                    .character(gain: 0.95, tune: -2, tone: 0.6, decay: 0.35, drive: 0.7),
                DrumTrack(.snare, p("--------x-------", "--------x-------"))
                    .character(gain: 0.86, tune: -2, tone: 0.5, decay: 0.45, drive: 0.6, reverb: 0.20),
                DrumTrack(.closedHat, p("x-o-x-o-x-o-x-o-", "x-o-x-o-x-o-xxxx"))
                    .character(gain: 0.34, pan: 0.14, tune: 2, tone: 0.5, decay: 0.18),
                DrumTrack(.perc, p("x---x---x---x---", "x---x---x---x---"))
                    .character(gain: 0.30, pan: -0.30, tune: -2, decay: 0.3, reverb: 0.18)
            ],
            melodies: [
                MelodyTrack("808", .bass808, [
                    Note(33, 0, 6, vel: 1.0), Note(33, 10, 5), Note(36, 16, 6), Note(31, 26, 5)
                ]).character(gain: 1.0, drive: 0.75, glide: 0.03),
                MelodyTrack("COWBELL", .pluck, [
                    Note(69, 0, 2), Note(72, 4, 2), Note(69, 8, 2), Note(76, 10, 2),
                    Note(69, 16, 2), Note(72, 20, 2), Note(74, 24, 2), Note(69, 28, 2)
                ]).character(gain: 0.44, pan: 0.10, drive: 0.35, reverb: 0.26, cutoff: 1.4)
            ],
            mix: MixSettings(
                reverbSize: 0.58, reverbDamp: 0.6, reverbPreDelay: 0.018,
                delaySync: .eighth, delayFeedback: 0.24,
                sidechain: 0.34, sidechainRelease: 0.12,
                drumDrive: 0.62, drumGlue: 0.55,
                masterDrive: 0.34, masterGlue: 0.55,
                width: 0.26, humanize: 0.14
            )
        ),
        palette: [
            "808 pushed into obvious distortion — clean is wrong here.",
            "Cowbell playing the actual melody, not a percussion accent.",
            "Snare drenched in a short dark room, tuned down.",
            "Everything crushed with drum-bus saturation at 60%.",
            "Vocal samples from old Memphis tapes, deliberately low quality."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Cowbell riff alone with tape hiss."),
            SectionNote(section: "MAIN", bars: "16", whats: "Everything in, 808 distorted."),
            SectionNote(section: "BREAK", bars: "8", whats: "Drums out, vocal sample."),
            SectionNote(section: "MAIN 2", bars: "16", whats: "Add hat rolls, drive harder.")
        ],
        makesItWork: [
            "The cowbell is the hook. Give it the melody, not a supporting role.",
            "Distortion is the aesthetic. Drum drive at 62% and master drive at 34% would be a mistake anywhere else.",
            "Half-time snare at 130 gives that dragging, menacing weight.",
            "Nothing is clean or wide. This is a narrow, crushed, mono-leaning mix."
        ],
        mixNotes: [
            "Drive the 808 until it clips — that grit is the point.",
            "Keep width low (26%). Phonk sounds wrong when it's spacious.",
            "Short dark reverb on the snare only.",
            "Master drive high; this genre wants to sound like a worn cassette."
        ],
        mistakes: [
            "A clean, polished 808. Without distortion it's just slow trap.",
            "Bright modern hats. Tune them down and dull them.",
            "Too much melody. One cowbell riff, repeated, is the whole track.",
            "Wide stereo processing — it kills the claustrophobia."
        ],
        tint: Ink.plum, family: .hiphop
    )

    // MARK: G-FUNK

    static let gfunk = GenreTemplate(
        id: "gfunk", name: "G-FUNK", tagline: "WHINY LEAD, DEEP BASS, LAID BACK",
        keyName: "G MINOR", scaleName: "MIN PENT", feel: "94 BPM, rolling and relaxed.",
        beat: Beat(
            name: "G-FUNK REFERENCE", bpm: 94, swing: 0.16, steps: 32,
            drums: [
                DrumTrack(.kick, p("x-------x---x---", "x-------x-------"))
                    .character(gain: 0.94, tune: -2, tone: 0.35, decay: 0.5, drive: 0.35),
                DrumTrack(.clap, p("----x-------x---", "----x-------x---"))
                    .character(gain: 0.68, pan: 0.06, tone: 0.5, decay: 0.4, reverb: 0.24, timing: 0.25),
                DrumTrack(.closedHat, p("x-o-x-o-x-o-x-o-", "x-o-x-o-x-o-x-oo"))
                    .character(gain: 0.30, pan: 0.20, tone: 0.45, decay: 0.22),
                DrumTrack(.perc, p("--------------x-", "------x-------x-"))
                    .character(gain: 0.24, pan: -0.34, tune: 4, reverb: 0.26)
            ],
            melodies: [
                MelodyTrack("BASS", .bass, [
                    Note(31, 0, 6, vel: 0.95), Note(31, 8, 3), Note(34, 12, 3),
                    Note(29, 16, 6), Note(31, 24, 6)
                ]).character(gain: 0.88, drive: 0.28, cutoff: 0.8, glide: 0.04),
                MelodyTrack("WHINE", .lead, [
                    Note(79, 0, 4), Note(82, 4, 2), Note(84, 6, 6),
                    Note(79, 16, 4), Note(77, 20, 2), Note(74, 22, 8)
                ]).character(gain: 0.42, pan: 0.08, reverb: 0.22, delay: 0.16,
                             cutoff: 1.5, glide: 0.05),
                MelodyTrack("KEYS", .organ, [
                    Note(58, 0, 14), Note(62, 0, 14), Note(65, 0, 14),
                    Note(56, 16, 14), Note(60, 16, 14), Note(63, 16, 14)
                ]).character(gain: 0.30, pan: -0.18, reverb: 0.20)
            ],
            mix: MixSettings(
                reverbSize: 0.60, reverbDamp: 0.45, reverbPreDelay: 0.026,
                delaySync: .dottedEighth, delayFeedback: 0.30,
                sidechain: 0.20, sidechainRelease: 0.16,
                drumDrive: 0.26, drumGlue: 0.36,
                masterDrive: 0.14, masterGlue: 0.42,
                width: 0.42, humanize: 0.30
            )
        ),
        palette: [
            "The whiny portamento lead — a single detuned saw that slides between notes.",
            "Deep, round, sliding bass with real melodic movement.",
            "Clap on 2 and 4, dragged behind the beat, with a plate reverb.",
            "Warm organ or Rhodes chords sitting low in the mix.",
            "Talkbox or vocoder vocals if you have them."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Bass and keys, no drums."),
            SectionNote(section: "VERSE", bars: "16", whats: "Full groove, lead dropped in volume."),
            SectionNote(section: "HOOK", bars: "8", whats: "Lead forward, add perc."),
            SectionNote(section: "BRIDGE", bars: "8", whats: "Drums out, lead solo.")
        ],
        makesItWork: [
            "The lead glides between notes rather than jumping. That portamento IS the genre.",
            "Minor pentatonic keeps the lead from ever sounding wrong over the changes.",
            "Everything drags: 16% swing plus 30% humanize plus a late clap.",
            "The bass moves melodically — it is a lead instrument down an octave."
        ],
        mixNotes: [
            "Lead filtered wide open and slightly panned, with delay for width.",
            "Bass round and warm, not clicky — roll the top off.",
            "Keep drums low and let bass and lead carry it.",
            "Generous plate reverb on the clap; this mix is meant to sound like a room."
        ],
        mistakes: [
            "A lead without glide. It's the single defining feature.",
            "Modern trap hats — this needs a swung, restrained hat line.",
            "Quantising everything. G-funk leans back hard.",
            "Busy drums. The bass is doing the work."
        ],
        tint: Ink.amber, family: .hiphop
    )

    // MARK: PLUGG

    static let plugg = GenreTemplate(
        id: "plugg", name: "PLUGG", tagline: "DREAMY BELLS, SOFT 808, LOTS OF SPACE",
        keyName: "D# MINOR", scaleName: "MINOR", feel: "135 BPM, weightless and pretty.",
        beat: Beat(
            name: "PLUGG REFERENCE", bpm: 135, swing: 0.05, steps: 32,
            drums: [
                DrumTrack(.kick, p("x---------x-----", "x-----x---------"))
                    .character(gain: 0.80, tune: -1, tone: 0.5, decay: 0.30, drive: 0.30),
                DrumTrack(.snare, p("--------x-------", "--------x-------"))
                    .character(gain: 0.60, tune: 3, tone: 0.62, decay: 0.35, reverb: 0.30),
                DrumTrack(.closedHat, p("x---x---x---x---", "x---x---x-x-x-x-"))
                    .character(gain: 0.26, pan: 0.18, tune: 4, tone: 0.6, decay: 0.14),
                DrumTrack(.openHat, p("----------------", "------------x---"))
                    .character(gain: 0.22, pan: -0.20, tune: 3, decay: 0.35, reverb: 0.20)
            ],
            melodies: [
                MelodyTrack("808", .bass808, [
                    Note(27, 0, 8, vel: 0.9), Note(30, 16, 8, vel: 0.9)
                ]).character(gain: 0.88, drive: 0.25, glide: 0.06),
                MelodyTrack("BELLS", .bell, [
                    Note(75, 0, 4), Note(82, 4, 4), Note(79, 8, 6), Note(75, 14, 2),
                    Note(78, 16, 4), Note(82, 20, 4), Note(87, 24, 8)
                ]).character(gain: 0.50, pan: 0.06, reverb: 0.48, delay: 0.34),
                MelodyTrack("PAD", .pad, [
                    Note(63, 0, 15), Note(66, 0, 15), Note(70, 0, 15),
                    Note(66, 16, 15), Note(70, 16, 15), Note(73, 16, 15)
                ]).character(gain: 0.30, reverb: 0.55, cutoff: 0.7)
            ],
            mix: MixSettings(
                reverbSize: 0.82, reverbDamp: 0.3, reverbPreDelay: 0.030,
                delaySync: .dottedEighth, delayFeedback: 0.42,
                sidechain: 0.28, sidechainRelease: 0.18,
                drumDrive: 0.14, drumGlue: 0.25,
                masterDrive: 0.06, masterGlue: 0.32,
                width: 0.55, humanize: 0.10, chorus: 0.30
            )
        ),
        palette: [
            "Bright bells or a glassy pluck carrying a simple, pretty melody.",
            "Soft 808 with long notes and a slow glide — no aggression.",
            "Sparse drums. Quarter-note hats, one snare per bar.",
            "Huge reverb and delay on everything melodic.",
            "A wide, filtered pad holding the whole thing together."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Bells and pad, no drums."),
            SectionNote(section: "VERSE", bars: "16", whats: "Drums in, 808 long and soft."),
            SectionNote(section: "HOOK", bars: "16", whats: "Bells an octave up, more delay."),
            SectionNote(section: "OUTRO", bars: "8", whats: "Let the reverb tails ring out.")
        ],
        makesItWork: [
            "Space. Fewer drum hits than any other hip hop template here.",
            "Reverb size at 82% with 30 ms pre-delay — the bells float miles behind the beat.",
            "The 808 is soft and long. Plugg is the one rap subgenre where the low end relaxes.",
            "Chorus at 30% on the music bus keeps the bells shimmering rather than static."
        ],
        mixNotes: [
            "Almost no drive anywhere. This mix should sound clean and glassy.",
            "Width at 55% — wide, dreamy, and mono-safe because the 808 stays centred.",
            "Delay feedback at 42%; the repeats are part of the melody.",
            "Keep the snare quiet and wet."
        ],
        mistakes: [
            "Hard-hitting trap drums. Plugg is soft by design.",
            "A distorted 808 — that's phonk, not plugg.",
            "Busy hi-hat rolls. Quarter notes are usually enough.",
            "A dry mix. Without the reverb this genre has nothing."
        ],
        tint: Ink.claySoft, family: .hiphop
    )

    // MARK: DETROIT

    static let detroit = GenreTemplate(
        id: "detroit", name: "DETROIT / FLINT", tagline: "BOUNCY, SINISTER, OFF-KILTER",
        keyName: "C MINOR", scaleName: "HARM MIN", feel: "100 BPM with a nervous forward push.",
        beat: Beat(
            name: "DETROIT REFERENCE", bpm: 100, swing: 0.08, steps: 32,
            drums: [
                DrumTrack(.kick, p("x--x----x--x--x-", "x--x----x--x----"))
                    .character(gain: 0.96, tune: -1, tone: 0.62, decay: 0.28, drive: 0.5),
                DrumTrack(.snare, p("--------x-------", "--------x---x---"))
                    .character(gain: 0.84, tune: 1, tone: 0.66, decay: 0.30, drive: 0.35),
                DrumTrack(.closedHat, p("xxx-xxx-xxx-xxx-", "xxx-xxx-xxxxxxxx"))
                    .character(gain: 0.34, pan: 0.16, tune: 3, tone: 0.6, decay: 0.13),
                DrumTrack(.perc, p("------x-------x-", "------x---x---x-"))
                    .character(gain: 0.28, pan: -0.32, tune: 6, reverb: 0.18)
            ],
            melodies: [
                MelodyTrack("808", .bass808, [
                    Note(36, 0, 3), Note(36, 6, 3), Note(39, 10, 4), Note(36, 16, 3),
                    Note(41, 20, 4), Note(34, 26, 5)
                ]).character(gain: 0.98, drive: 0.45, glide: 0.02),
                MelodyTrack("STRINGS", .pluck, [
                    Note(72, 0, 2), Note(75, 2, 2), Note(80, 4, 4), Note(79, 10, 4),
                    Note(72, 16, 2), Note(75, 18, 2), Note(83, 20, 8)
                ]).character(gain: 0.40, pan: -0.10, reverb: 0.32, cutoff: 1.1)
            ],
            mix: MixSettings(
                reverbSize: 0.55, reverbDamp: 0.5, reverbPreDelay: 0.020,
                delaySync: .sixteenth, delayFeedback: 0.18,
                sidechain: 0.34, sidechainRelease: 0.10,
                drumDrive: 0.34, drumGlue: 0.45,
                masterDrive: 0.18, masterGlue: 0.5,
                width: 0.30, humanize: 0.16
            )
        ),
        palette: [
            "Kick doing a stuttering, syncopated bounce rather than a steady pulse.",
            "Short 808 notes that move constantly — almost a bassline.",
            "Hats in bursts of three, leaving gaps.",
            "Sinister string or orchestral pluck line, often harmonic minor.",
            "Ad-libs and vocal stutters as percussion."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Strings alone, ominous."),
            SectionNote(section: "VERSE", bars: "16", whats: "Full bounce, 808 moving constantly."),
            SectionNote(section: "SWITCH", bars: "8", whats: "New kick pattern, same strings."),
            SectionNote(section: "HOOK", bars: "16", whats: "Everything, plus doubled hats.")
        ],
        makesItWork: [
            "The kick bounces in an uneven pattern — that lurch is the whole identity.",
            "Short 808 notes, many of them. The opposite of the trap approach.",
            "Harmonic minor in the strings gives the sinister, almost cinematic edge.",
            "Hats grouped in threes against a 4/4 kick creates constant tension."
        ],
        mixNotes: [
            "808 short and punchy with fast glide — it needs to keep up with the kick.",
            "Sidechain fast and tight so the busy kick still reads.",
            "Strings high-passed and slightly left, with a medium room.",
            "Narrow-ish mix; the energy comes from rhythm, not width."
        ],
        mistakes: [
            "A steady, predictable kick. The bounce has to be uneven.",
            "Long 808 notes — they smear over the fast kick pattern.",
            "Even 16th hats. Group them in threes.",
            "A major-key melody. This style lives on tension."
        ],
        tint: Ink.steel, family: .hiphop
    )

    static let all: [GenreTemplate] = [phonk, gfunk, plugg, detroit]
}
