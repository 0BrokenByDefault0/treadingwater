import Foundation
import SwiftUI

// MARK: - Global

enum GlobalTemplates {

    static let reggaeton = GenreTemplate(
        id: "reggaeton", name: "REGGAETON", tagline: "DEMBOW: THE MOST COPIED PATTERN ON EARTH",
        keyName: "A MINOR", scaleName: "MINOR", feel: "95 BPM. One rhythm, endlessly reused.",
        beat: Beat(
            name: "REGGAETON REFERENCE", bpm: 95, swing: 0.08, steps: 32,
            drums: [
                DrumTrack(.kick, p("x-----x-x-----x-", "x-----x-x-----x-"))
                    .character(gain: 0.94, tune: -2, tone: 0.4, decay: 0.38, drive: 0.32),
                DrumTrack(.snare, p("---x--x----x--x-", "---x--x----x--x-"))
                    .character(gain: 0.76, tune: 2, tone: 0.6, decay: 0.28, reverb: 0.18),
                DrumTrack(.closedHat, p("x-x-x-x-x-x-x-x-", "x-x-x-x-x-x-x-xx"))
                    .character(gain: 0.26, pan: 0.22, tune: 3, decay: 0.14),
                DrumTrack(.perc, p("--x-------x-----", "--x-------x---x-"))
                    .character(gain: 0.28, pan: -0.34, tune: 5, reverb: 0.20)
            ],
            melodies: [
                MelodyTrack("BASS", .bass, [
                    Note(33, 0, 5), Note(33, 6, 2), Note(33, 8, 5), Note(33, 14, 2),
                    Note(31, 16, 5), Note(31, 22, 2), Note(36, 24, 6)
                ]).character(gain: 0.88, drive: 0.28, cutoff: 0.68),
                MelodyTrack("CHORDS", .pluck, [
                    Note(69, 2, 2), Note(72, 2, 2), Note(76, 2, 2),
                    Note(67, 18, 2), Note(71, 18, 2), Note(74, 18, 2)
                ]).character(gain: 0.38, pan: -0.12, reverb: 0.28, delay: 0.16)
            ],
            mix: MixSettings(
                reverbSize: 0.56, reverbDamp: 0.5, reverbPreDelay: 0.020,
                delaySync: .eighth, delayFeedback: 0.24,
                sidechain: 0.26, sidechainRelease: 0.14,
                drumDrive: 0.28, drumGlue: 0.40,
                masterDrive: 0.14, masterGlue: 0.48,
                width: 0.40, humanize: 0.16
            )
        ),
        palette: [
            "The dembow: snare on the 'a' of every beat, kick on 1 and the 'and' of 2.",
            "Kick and snare land together on some steps — that collision is correct.",
            "Bright hats keeping straight 16ths underneath.",
            "Short plucked chords, sparse and rhythmic."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Dembow and bass."),
            SectionNote(section: "VERSE", bars: "16", whats: "Chords in, space for vocals."),
            SectionNote(section: "PRE", bars: "8", whats: "Drums out, tension builds."),
            SectionNote(section: "HOOK", bars: "16", whats: "Full, perc doubled.")
        ],
        makesItWork: [
            "The dembow never changes. Learn it once and it works across the whole genre.",
            "The snare lands late in each beat, which is what gives it the characteristic lean.",
            "Bass follows the kick exactly, so the low end is a single locked unit.",
            "Everything else is deliberately sparse to leave room for a vocal."
        ],
        mixNotes: [
            "Kick and bass interlocked and mono.",
            "Snare bright with a short room; it has to cut over the hats.",
            "Keep the midrange open for vocals.",
            "Moderate width — the groove is the focus."
        ],
        mistakes: [
            "Altering the dembow. It's a fixed pattern.",
            "A busy melody competing with the vocal.",
            "Heavy sidechain pumping.",
            "A trap-style 808 — reggaeton bass is shorter and rounder."
        ],
        tint: Ink.orange, family: .global
    )

    static let dancehall = GenreTemplate(
        id: "dancehall", name: "DANCEHALL", tagline: "SPARSE, SPRINGY, VOCAL-LED",
        keyName: "G MINOR", scaleName: "MINOR", feel: "100 BPM with a heavy bounce.",
        beat: Beat(
            name: "DANCEHALL REFERENCE", bpm: 100, swing: 0.12, steps: 32,
            drums: [
                DrumTrack(.kick, p("x-------x-x-----", "x-------x-------"))
                    .character(gain: 0.94, tune: -2, tone: 0.42, decay: 0.40, drive: 0.34),
                DrumTrack(.snare, p("--------x-------", "--------x-----x-"))
                    .character(gain: 0.80, tune: 0, tone: 0.58, decay: 0.32, reverb: 0.22),
                DrumTrack(.rim, p("----x-------x---", "----x-------x---"))
                    .character(gain: 0.36, pan: -0.24, tune: 3, reverb: 0.16),
                DrumTrack(.closedHat, p("x-x-x-x-x-x-x-x-", "x-x-x-x-x-x-x-x-"))
                    .character(gain: 0.24, pan: 0.24, tune: 2, decay: 0.14),
                DrumTrack(.perc, p("------------x---", "------x-----x---"))
                    .character(gain: 0.30, pan: -0.38, tune: 6, reverb: 0.24)
            ],
            melodies: [
                MelodyTrack("BASS", .bass, [
                    Note(31, 0, 6, vel: 0.95), Note(31, 8, 4), Note(34, 16, 6), Note(29, 24, 6)
                ]).character(gain: 0.92, drive: 0.30, cutoff: 0.6),
                MelodyTrack("SKANK", .organ, [
                    Note(70, 4, 1), Note(74, 4, 1), Note(77, 4, 1),
                    Note(70, 12, 1), Note(74, 12, 1), Note(77, 12, 1),
                    Note(68, 20, 1), Note(72, 20, 1), Note(75, 20, 1),
                    Note(68, 28, 1), Note(72, 28, 1), Note(75, 28, 1)
                ]).character(gain: 0.36, pan: 0.16, reverb: 0.30, delay: 0.26)
            ],
            mix: MixSettings(
                reverbSize: 0.60, reverbDamp: 0.5, reverbPreDelay: 0.022,
                delaySync: .dottedEighth, delayFeedback: 0.34,
                sidechain: 0.24, sidechainRelease: 0.16,
                drumDrive: 0.26, drumGlue: 0.36,
                masterDrive: 0.12, masterGlue: 0.42,
                width: 0.42, humanize: 0.22
            )
        ),
        palette: [
            "Deep round bass with long notes — the anchor of the riddim.",
            "Rim on 2 and 4, snare on beat 3 only.",
            "Organ skank stabs on the off-beats with heavy delay.",
            "Sparse arrangement built to sit under a vocal."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Bass and skank."),
            SectionNote(section: "VERSE", bars: "16", whats: "Full riddim, wide open midrange."),
            SectionNote(section: "BRIDGE", bars: "8", whats: "Drums out, bass and delay."),
            SectionNote(section: "HOOK", bars: "16", whats: "Everything, extra percussion.")
        ],
        makesItWork: [
            "The bass is the melody. Everything else supports it.",
            "Skank stabs on the off-beats with dotted delay create the springy feel.",
            "Very few elements — dancehall riddims are famously minimal.",
            "The midrange is left almost empty on purpose."
        ],
        mixNotes: [
            "Bass loud, dark and round; it's the loudest melodic element.",
            "Delay on the skank is a signature, not a decoration.",
            "Keep 300 Hz–3 kHz clear for a vocal.",
            "Light compression — dancehall stays punchy and dynamic."
        ],
        mistakes: [
            "Filling the midrange.",
            "A bright, clicky bass. Round and dark is right.",
            "Skank on the downbeat instead of the off-beat.",
            "Too many layers."
        ],
        tint: Ink.clay, family: .global
    )

    static let baileFunk = GenreTemplate(
        id: "baile", name: "BAILE FUNK", tagline: "TAMBORZÃO, RAW AND LOUD",
        keyName: "D MINOR", scaleName: "MINOR", feel: "130 BPM, chaotic and physical.",
        beat: Beat(
            name: "BAILE FUNK REFERENCE", bpm: 130, swing: 0.06, steps: 32,
            drums: [
                DrumTrack(.kick, p("x--x--x---x--x--", "x--x--x---x--x--"))
                    .character(gain: 0.96, tune: -1, tone: 0.5, decay: 0.28, drive: 0.55),
                DrumTrack(.rim, p("--x-x-x-x-x-x-x-", "--x-x-x-x-x-x-x-"))
                    .character(gain: 0.42, pan: -0.22, tune: 4, decay: 0.18),
                DrumTrack(.tom, p("------x-------x-", "------x---x---x-"))
                    .character(gain: 0.52, pan: 0.22, tune: -2, decay: 0.30, drive: 0.4),
                DrumTrack(.clap, p("--------x-------", "--------x-------"))
                    .character(gain: 0.52, pan: 0.06, tone: 0.6, decay: 0.24, reverb: 0.16),
                DrumTrack(.perc, p("----------x-----", "----------x---x-"))
                    .character(gain: 0.30, pan: -0.40, tune: 6)
            ],
            melodies: [
                MelodyTrack("BASS", .bass808, [
                    Note(38, 0, 3), Note(38, 6, 3), Note(38, 10, 4),
                    Note(36, 16, 3), Note(41, 22, 3), Note(38, 26, 5)
                ]).character(gain: 0.90, drive: 0.45, glide: 0.02),
                MelodyTrack("STAB", .organ, [
                    Note(74, 0, 2), Note(77, 8, 2), Note(81, 16, 2), Note(77, 24, 2)
                ]).character(gain: 0.34, pan: 0.14, reverb: 0.22, delay: 0.16)
            ],
            mix: MixSettings(
                reverbSize: 0.44, reverbDamp: 0.55, reverbPreDelay: 0.014,
                delaySync: .sixteenth, delayFeedback: 0.18,
                sidechain: 0.32, sidechainRelease: 0.10,
                drumDrive: 0.52, drumGlue: 0.52,
                masterDrive: 0.28, masterGlue: 0.52,
                width: 0.34, humanize: 0.14
            )
        ),
        palette: [
            "Tamborzão: the 3-3-2 kick with tom accents and constant rim.",
            "Loud low toms as the main accent instrument.",
            "Rim playing near-constant off-beat 16ths.",
            "Heavily driven bass, short and punchy."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Tamborzão alone."),
            SectionNote(section: "MAIN", bars: "16", whats: "Bass and stabs in."),
            SectionNote(section: "BREAK", bars: "8", whats: "Drums only, vocal chant."),
            SectionNote(section: "DROP", bars: "16", whats: "Everything, driven hard.")
        ],
        makesItWork: [
            "The tamborzão is a fixed rhythm like the dembow — learn it and the genre opens up.",
            "Toms carry accents that would be a snare in other genres.",
            "Everything is driven hard; this is a sound-system genre.",
            "Almost no reverb — it stays dry, raw and in your face."
        ],
        mixNotes: [
            "Drum drive at 52% and master drive at 28% — deliberately overdriven.",
            "Toms loud and slightly panned.",
            "Bass short so it never blurs the fast kick.",
            "Narrow and loud."
        ],
        mistakes: [
            "A polished, clean mix. Raw is correct.",
            "Replacing the toms with a snare.",
            "Long reverbs.",
            "An even kick pattern."
        ],
        tint: Ink.amber, family: .global
    )

    static let all: [GenreTemplate] = [reggaeton, dancehall, baileFunk]
}

// MARK: - Soul

enum SoulTemplates {

    static let neoSoul = GenreTemplate(
        id: "neosoul", name: "NEO-SOUL", tagline: "EXTENDED CHORDS, DEEP POCKET",
        keyName: "E♭ MAJOR", scaleName: "DORIAN", feel: "78 BPM, swung and behind the beat.",
        beat: Beat(
            name: "NEO-SOUL REFERENCE", bpm: 78, swing: 0.32, steps: 32,
            drums: [
                DrumTrack(.kick, p("x-------x---x---", "x-------x-------"))
                    .character(gain: 0.88, tune: -3, tone: 0.28, decay: 0.55, drive: 0.28),
                DrumTrack(.snare, p("----x--.----x-.-", "----x--.----x---"))
                    .character(gain: 0.78, tune: -1, tone: 0.4, decay: 0.45,
                               drive: 0.22, reverb: 0.20, timing: 0.45),
                DrumTrack(.closedHat, p("x-o.x-o.x-o.x-o.", "x-o.x-o.x-o.x-oo"))
                    .character(gain: 0.28, pan: 0.20, tune: -3, tone: 0.32, decay: 0.24),
                DrumTrack(.perc, p("--------------.-", "------.---------"))
                    .character(gain: 0.20, pan: -0.34, tune: 2, reverb: 0.26)
            ],
            melodies: [
                MelodyTrack("RHODES", .keys, [
                    Note(63, 0, 14), Note(67, 0, 14), Note(70, 0, 14), Note(74, 0, 14), Note(77, 0, 14),
                    Note(60, 16, 14), Note(65, 16, 14), Note(69, 16, 14), Note(72, 16, 14)
                ]).character(gain: 0.58, pan: -0.08, drive: 0.12, reverb: 0.30,
                             cutoff: 0.5, timing: 0.25),
                MelodyTrack("BASS", .bass, [
                    Note(39, 0, 6, vel: 0.9), Note(39, 8, 3), Note(43, 12, 3),
                    Note(36, 16, 6), Note(41, 24, 6)
                ]).character(gain: 0.82, drive: 0.18, cutoff: 0.55, glide: 0.04, timing: 0.3),
                MelodyTrack("PAD", .pad, [
                    Note(82, 0, 15), Note(86, 0, 15),
                    Note(81, 16, 15), Note(84, 16, 15)
                ]).character(gain: 0.14, reverb: 0.48, cutoff: 0.45)
            ],
            mix: MixSettings(
                reverbSize: 0.58, reverbDamp: 0.7, reverbPreDelay: 0.024,
                delaySync: .quarter, delayFeedback: 0.22,
                sidechain: 0.10, sidechainRelease: 0.20,
                drumDrive: 0.26, drumGlue: 0.32,
                masterDrive: 0.14, masterGlue: 0.38,
                width: 0.32, humanize: 0.50, chorus: 0.20
            )
        ),
        palette: [
            "Rhodes playing 9th and 11th chords — five notes minimum.",
            "Snare dragged well behind the beat with ghost notes either side.",
            "Fretless-style bass with slides between notes.",
            "Everything swung at 32% and heavily humanised."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Rhodes alone."),
            SectionNote(section: "VERSE", bars: "16", whats: "Full pocket, space for a vocal."),
            SectionNote(section: "BRIDGE", bars: "8", whats: "Chord change, drums simplify."),
            SectionNote(section: "OUTRO", bars: "8", whats: "Let the Rhodes ring.")
        ],
        makesItWork: [
            "Humanize at 50% plus a snare 5 ms late — the pocket is deliberately loose.",
            "Extended chords (9ths, 11ths) are the harmonic identity.",
            "Ghost snares on the 'e' and 'a' give constant low-level motion.",
            "Almost no sidechain — this genre breathes naturally."
        ],
        mixNotes: [
            "Rhodes filtered warm and slightly left, with chorus for movement.",
            "Bass round with slides; keep it below the Rhodes.",
            "Dark damped reverb — a wooden room, not a hall.",
            "Stay dynamic. Do not squash this."
        ],
        mistakes: [
            "Triads. Neo-soul needs extensions.",
            "Quantised drums.",
            "A bright modern kit — everything should be warm and dark.",
            "Heavy compression."
        ],
        tint: Ink.claySoft, family: .rnb
    )

    static let altRnb = GenreTemplate(
        id: "altrnb", name: "ALT R&B", tagline: "SPARSE, ATMOSPHERIC, WIDE",
        keyName: "B MINOR", scaleName: "MINOR", feel: "72 BPM. Mostly empty space.",
        beat: Beat(
            name: "ALT R&B REFERENCE", bpm: 72, swing: 0.14, steps: 32,
            drums: [
                DrumTrack(.kick, p("x-----------x---", "x---------------"))
                    .character(gain: 0.86, tune: -3, tone: 0.3, decay: 0.5, drive: 0.24),
                DrumTrack(.clap, p("--------x-------", "--------x-------"))
                    .character(gain: 0.44, pan: 0.08, tone: 0.45, decay: 0.4,
                               reverb: 0.44, timing: 0.35),
                DrumTrack(.closedHat, p("----x-------x---", "----x-------x-x-"))
                    .character(gain: 0.20, pan: 0.22, tune: -2, tone: 0.35, decay: 0.18),
                DrumTrack(.perc, p("--------------x-", "----------x-----"))
                    .character(gain: 0.18, pan: -0.36, tune: 4, reverb: 0.42)
            ],
            melodies: [
                MelodyTrack("PAD", .pad, [
                    Note(71, 0, 15), Note(74, 0, 15), Note(78, 0, 15),
                    Note(69, 16, 15), Note(73, 16, 15), Note(76, 16, 15)
                ]).character(gain: 0.34, reverb: 0.60, cutoff: 0.5),
                MelodyTrack("BASS", .sub, [
                    Note(35, 0, 14, vel: 0.9), Note(33, 16, 14)
                ]).character(gain: 0.80),
                MelodyTrack("BELL", .bell, [
                    Note(83, 4, 2), Note(86, 12, 2), Note(81, 20, 2), Note(78, 28, 3)
                ]).character(gain: 0.26, pan: 0.28, reverb: 0.50, delay: 0.38)
            ],
            mix: MixSettings(
                reverbSize: 0.86, reverbDamp: 0.4, reverbPreDelay: 0.036,
                delaySync: .dottedEighth, delayFeedback: 0.40,
                sidechain: 0.20, sidechainRelease: 0.24,
                drumDrive: 0.12, drumGlue: 0.22,
                masterDrive: 0.05, masterGlue: 0.28,
                width: 0.60, humanize: 0.28, chorus: 0.26
            )
        ),
        palette: [
            "Four or five elements total, with long gaps between them.",
            "Huge wide pad holding the harmony.",
            "Clean sine sub instead of a synth bass.",
            "One sparse bell or vocal chop as the only bright element."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Pad and sub."),
            SectionNote(section: "VERSE", bars: "16", whats: "Kick and clap enter, still sparse."),
            SectionNote(section: "HOOK", bars: "16", whats: "Bell and extra perc."),
            SectionNote(section: "OUTRO", bars: "8", whats: "Everything decays out.")
        ],
        makesItWork: [
            "Restraint. The kick plays twice in two bars.",
            "Reverb size 86% with 36 ms pre-delay puts everything in a vast room while staying clear.",
            "The clap is dragged 4 ms late and drenched — it feels like a memory of a backbeat.",
            "Master drive at 5% is the lowest here; this mix stays fragile on purpose."
        ],
        mixNotes: [
            "Wide (60%) with everything except the sub spread out.",
            "Long delays on the bell feed the atmosphere.",
            "Almost no compression anywhere.",
            "Leave the entire midrange empty for a vocal."
        ],
        mistakes: [
            "Filling the space. Emptiness is the aesthetic.",
            "A loud, punchy kit.",
            "A busy bassline — one long sub note per bar is enough.",
            "Loudness processing."
        ],
        tint: Ink.plum, family: .rnb
    )

    static let all: [GenreTemplate] = [neoSoul, altRnb]
}

// MARK: - Chill

enum ChillTemplates {

    static let tripHop = GenreTemplate(
        id: "triphop", name: "TRIP HOP", tagline: "HEAVY, DARK, CINEMATIC",
        keyName: "C MINOR", scaleName: "HARM MIN", feel: "88 BPM, weighted and slow.",
        beat: Beat(
            name: "TRIP HOP REFERENCE", bpm: 88, swing: 0.20, steps: 32,
            drums: [
                DrumTrack(.kick, p("x---------x-----", "x-------x-------"))
                    .character(gain: 1.0, tune: -4, tone: 0.25, decay: 0.65, drive: 0.45),
                DrumTrack(.snare, p("----x-------x---", "----x-------x---"))
                    .character(gain: 0.92, tune: -3, tone: 0.35, decay: 0.60,
                               drive: 0.35, reverb: 0.34, timing: 0.30),
                DrumTrack(.closedHat, p("x-o-x-o-x-o-x-o-", "x-o-x-o-x-o-x-o-"))
                    .character(gain: 0.24, pan: 0.18, tune: -4, tone: 0.25, decay: 0.22),
                DrumTrack(.perc, p("--------------.-", "--------------.-"))
                    .character(gain: 0.20, pan: -0.32, tune: -2, reverb: 0.34)
            ],
            melodies: [
                MelodyTrack("BASS", .bass, [
                    Note(36, 0, 8, vel: 0.95), Note(36, 10, 5),
                    Note(32, 16, 8), Note(34, 26, 5)
                ]).character(gain: 0.88, drive: 0.30, cutoff: 0.5),
                MelodyTrack("STRINGS", .pad, [
                    Note(72, 0, 15), Note(75, 0, 15), Note(80, 0, 15),
                    Note(71, 16, 15), Note(74, 16, 15), Note(79, 16, 15)
                ]).character(gain: 0.32, reverb: 0.54, cutoff: 0.45),
                MelodyTrack("KEYS", .keys, [
                    Note(60, 0, 6), Note(63, 0, 6), Note(67, 0, 6),
                    Note(59, 16, 6), Note(62, 16, 6), Note(67, 16, 6)
                ]).character(gain: 0.34, pan: -0.14, reverb: 0.34, cutoff: 0.45)
            ],
            mix: MixSettings(
                reverbSize: 0.74, reverbDamp: 0.6, reverbPreDelay: 0.028,
                delaySync: .quarter, delayFeedback: 0.30,
                sidechain: 0.14, sidechainRelease: 0.20,
                drumDrive: 0.44, drumGlue: 0.55,
                masterDrive: 0.24, masterGlue: 0.5,
                width: 0.36, humanize: 0.34
            )
        ),
        palette: [
            "Enormous slow drums, tuned way down, drenched in room.",
            "Harmonic minor strings for the cinematic edge.",
            "Deep filtered bass moving slowly.",
            "Vinyl noise and found sounds throughout."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Strings and noise."),
            SectionNote(section: "MAIN", bars: "16", whats: "Full weight of the drums."),
            SectionNote(section: "BREAK", bars: "8", whats: "Drums out, strings swell."),
            SectionNote(section: "OUTRO", bars: "8", whats: "Drums return, fade.")
        ],
        makesItWork: [
            "The drums are tuned down 3–4 semitones and hit harder than anything else in the mix.",
            "Harmonic minor gives the film-score darkness.",
            "Sparse kick, huge snare, big room — space between hits is the drama.",
            "Heavy saturation on the drum bus makes it sound sampled off vinyl."
        ],
        mixNotes: [
            "Snare is the loudest element. Let it be.",
            "Everything filtered dark; nothing above 10 kHz matters.",
            "Big damped reverb on the drums, unusually for this app's advice — it's the genre.",
            "Narrow and heavy."
        ],
        mistakes: [
            "Fast or busy drums. Slow and heavy is the point.",
            "Bright samples.",
            "A major key.",
            "Light, tight drums with no room."
        ],
        tint: Ink.steel, family: .chill
    )

    static let downtempo = GenreTemplate(
        id: "downtempo", name: "DOWNTEMPO", tagline: "WARM, ROLLING, ALMOST AMBIENT",
        keyName: "A MINOR", scaleName: "DORIAN", feel: "92 BPM, gentle and continuous.",
        beat: Beat(
            name: "DOWNTEMPO REFERENCE", bpm: 92, swing: 0.18, steps: 32,
            drums: [
                DrumTrack(.kick, p("x-------x-------", "x-------x---x---"))
                    .character(gain: 0.84, tune: -3, tone: 0.28, decay: 0.5, drive: 0.22),
                DrumTrack(.rim, p("----x-------x---", "----x-------x---"))
                    .character(gain: 0.34, pan: -0.22, tune: -1, reverb: 0.30),
                DrumTrack(.closedHat, p("x-x-x-x-x-x-x-x-", "x-x-x-x-x-x-x-xx"))
                    .character(gain: 0.22, pan: 0.20, tune: -3, tone: 0.3, decay: 0.2),
                DrumTrack(.perc, p("------x-------x-", "------x---x---x-"))
                    .character(gain: 0.24, pan: -0.36, tune: 3, reverb: 0.36, delay: 0.18)
            ],
            melodies: [
                MelodyTrack("PAD", .pad, [
                    Note(69, 0, 15), Note(72, 0, 15), Note(76, 0, 15),
                    Note(67, 16, 15), Note(71, 16, 15), Note(74, 16, 15)
                ]).character(gain: 0.32, reverb: 0.56, cutoff: 0.55),
                MelodyTrack("BASS", .bass, [
                    Note(33, 0, 7), Note(33, 8, 6), Note(31, 16, 7), Note(31, 24, 6)
                ]).character(gain: 0.82, drive: 0.16, cutoff: 0.55),
                MelodyTrack("PLUCK", .pluck, [
                    Note(76, 2, 2), Note(79, 6, 2), Note(84, 10, 3),
                    Note(74, 18, 2), Note(79, 22, 2), Note(81, 26, 4)
                ]).character(gain: 0.32, pan: 0.20, reverb: 0.42, delay: 0.30, cutoff: 0.85)
            ],
            mix: MixSettings(
                reverbSize: 0.78, reverbDamp: 0.45, reverbPreDelay: 0.026,
                delaySync: .dottedEighth, delayFeedback: 0.38,
                sidechain: 0.26, sidechainRelease: 0.20,
                drumDrive: 0.20, drumGlue: 0.28,
                masterDrive: 0.10, masterGlue: 0.35,
                width: 0.52, humanize: 0.26, chorus: 0.24
            )
        ),
        palette: [
            "Soft kick on 1 and 3, rim on 2 and 4.",
            "Warm evolving pad as the main harmonic bed.",
            "Delayed pluck providing all the melodic interest.",
            "Wide, gentle percussion."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "16", whats: "Pad only."),
            SectionNote(section: "MAIN", bars: "32", whats: "Drums and bass, pluck entering."),
            SectionNote(section: "BREAK", bars: "16", whats: "Drums out."),
            SectionNote(section: "OUT", bars: "16", whats: "Fade the layers one at a time.")
        ],
        makesItWork: [
            "Nothing is aggressive. Every element is filtered and soft.",
            "The delayed pluck does the melodic work so nothing has to be loud.",
            "Wide chorus-treated pads make it feel continuous rather than rhythmic.",
            "Long sections with gradual filter movement."
        ],
        mixNotes: [
            "Everything filtered below 60–85% cutoff.",
            "Big bright reverb, long delays.",
            "Bass warm and simple.",
            "Very light compression."
        ],
        mistakes: [
            "Punchy drums.",
            "Fast arrangement changes.",
            "A dry mix.",
            "Too much midrange energy."
        ],
        tint: Ink.concreteLo, family: .chill
    )

    static let all: [GenreTemplate] = [tripHop, downtempo]
}

// MARK: - Pop & Synth

enum PopTemplates {

    static let modernPop = GenreTemplate(
        id: "pop", name: "MODERN POP", tagline: "BRIGHT, TIGHT, HOOK-FIRST",
        keyName: "C MAJOR", scaleName: "MAJOR", feel: "104 BPM, clean and forward.",
        beat: Beat(
            name: "POP REFERENCE", bpm: 104, swing: 0.06, steps: 32,
            drums: [
                DrumTrack(.kick, p("x-------x-------", "x-------x---x---"))
                    .character(gain: 0.96, tune: 0, tone: 0.55, decay: 0.30, drive: 0.35),
                DrumTrack(.clap, p("--------x-------", "--------x-------"))
                    .character(gain: 0.70, pan: 0.05, tone: 0.65, decay: 0.28, reverb: 0.22),
                DrumTrack(.closedHat, p("x-x-x-x-x-x-x-x-", "x-x-x-x-x-x-xxx-"))
                    .character(gain: 0.30, pan: 0.20, tune: 3, tone: 0.6, decay: 0.14),
                DrumTrack(.perc, p("----------------", "--------------x-"))
                    .character(gain: 0.26, pan: -0.32, tune: 6, reverb: 0.24),
                DrumTrack(.snare, p("--------------.-", "------.-------.-"))
                    .character(gain: 0.22, tone: 0.5, decay: 0.2)
            ],
            melodies: [
                MelodyTrack("BASS", .bass, [
                    Note(36, 0, 6), Note(36, 8, 6), Note(41, 16, 6), Note(43, 24, 6)
                ]).character(gain: 0.86, drive: 0.24, cutoff: 0.75),
                MelodyTrack("CHORDS", .pluck, [
                    Note(72, 0, 3), Note(76, 0, 3), Note(79, 0, 3),
                    Note(72, 8, 3), Note(76, 8, 3), Note(79, 8, 3),
                    Note(69, 16, 3), Note(72, 16, 3), Note(77, 16, 3),
                    Note(71, 24, 3), Note(74, 24, 3), Note(79, 24, 3)
                ]).character(gain: 0.44, pan: -0.10, reverb: 0.26, delay: 0.20, cutoff: 1.1),
                MelodyTrack("PAD", .pad, [
                    Note(84, 0, 15), Note(88, 0, 15),
                    Note(81, 16, 15), Note(86, 16, 15)
                ]).character(gain: 0.20, reverb: 0.46, cutoff: 0.8)
            ],
            mix: MixSettings(
                reverbSize: 0.58, reverbDamp: 0.4, reverbPreDelay: 0.026,
                delaySync: .dottedEighth, delayFeedback: 0.26,
                sidechain: 0.32, sidechainRelease: 0.16,
                drumDrive: 0.24, drumGlue: 0.42,
                masterDrive: 0.14, masterGlue: 0.5,
                width: 0.48, humanize: 0.12, chorus: 0.18
            )
        ),
        palette: [
            "Clean punchy kick with a bright clap on the backbeat.",
            "Plucked chords carrying the progression rhythmically.",
            "Simple root-note bass locked to the kick.",
            "Ghost snare fills leading into each section."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Chords and pad."),
            SectionNote(section: "VERSE", bars: "16", whats: "Drums and bass, sparse."),
            SectionNote(section: "PRE", bars: "8", whats: "Kick out, build tension."),
            SectionNote(section: "CHORUS", bars: "16", whats: "Everything, widest and brightest.")
        ],
        makesItWork: [
            "Major key, simple progression, everything in service of a vocal hook.",
            "The verse is deliberately thin so the chorus feels enormous by contrast.",
            "Plucked chords give rhythm and harmony at once, leaving space elsewhere.",
            "Tight and bright — no element is allowed to be muddy."
        ],
        mixNotes: [
            "Clap bright and forward; it defines the backbeat.",
            "High-pass everything except kick and bass aggressively.",
            "Keep 1–3 kHz clear for a lead vocal.",
            "Moderate glue on the master; pop is loud but controlled."
        ],
        mistakes: [
            "A dense verse. Save the density for the chorus.",
            "Muddy low mids.",
            "Complicated harmony — pop rewards simplicity.",
            "Forgetting the pre-chorus lift."
        ],
        tint: Ink.orange, family: .pop
    )

    static let synthwave = GenreTemplate(
        id: "synthwave", name: "SYNTHWAVE", tagline: "GATED SNARE, ARPS, NEON",
        keyName: "F# MINOR", scaleName: "MINOR", feel: "112 BPM, driving and nostalgic.",
        beat: Beat(
            name: "SYNTHWAVE REFERENCE", bpm: 112, swing: 0, steps: 32,
            drums: [
                DrumTrack(.kick, p("x---x---x---x---", "x---x---x---x---"))
                    .character(gain: 0.92, tune: -1, tone: 0.5, decay: 0.32, drive: 0.32),
                DrumTrack(.snare, p("----x-------x---", "----x-------x---"))
                    .character(gain: 0.86, tune: -1, tone: 0.55, decay: 0.55,
                               drive: 0.3, reverb: 0.46),
                DrumTrack(.closedHat, p("--x---x---x---x-", "--x---x---x---x-"))
                    .character(gain: 0.26, pan: 0.22, tune: 1, decay: 0.16),
                DrumTrack(.tom, p("----------------", "------------x-x-"))
                    .character(gain: 0.44, pan: 0.26, tune: -2, decay: 0.4, reverb: 0.4)
            ],
            melodies: [
                MelodyTrack("BASS", .bass, [
                    Note(30, 0, 2), Note(30, 2, 2), Note(30, 4, 2), Note(30, 6, 2),
                    Note(30, 8, 2), Note(30, 10, 2), Note(33, 12, 2), Note(33, 14, 2),
                    Note(28, 16, 2), Note(28, 18, 2), Note(28, 20, 2), Note(28, 22, 2),
                    Note(35, 24, 2), Note(35, 26, 2), Note(33, 28, 4)
                ]).character(gain: 0.88, drive: 0.30, cutoff: 0.7),
                MelodyTrack("ARP", .pluck, [
                    Note(78, 0, 1), Note(81, 2, 1), Note(85, 4, 1), Note(81, 6, 1),
                    Note(78, 8, 1), Note(81, 10, 1), Note(85, 12, 1), Note(88, 14, 1),
                    Note(76, 16, 1), Note(80, 18, 1), Note(83, 20, 1), Note(80, 22, 1),
                    Note(76, 24, 1), Note(80, 26, 1), Note(83, 28, 1), Note(87, 30, 1)
                ]).character(gain: 0.36, pan: 0.18, reverb: 0.34, delay: 0.26, cutoff: 1.2),
                MelodyTrack("LEAD", .lead, [
                    Note(66, 0, 6), Note(69, 8, 6), Note(73, 16, 8), Note(71, 26, 6)
                ]).character(gain: 0.40, pan: -0.12, reverb: 0.38, delay: 0.24, cutoff: 1.1)
            ],
            mix: MixSettings(
                reverbSize: 0.80, reverbDamp: 0.3, reverbPreDelay: 0.018,
                delaySync: .dottedEighth, delayFeedback: 0.34,
                sidechain: 0.36, sidechainRelease: 0.18,
                drumDrive: 0.24, drumGlue: 0.40,
                masterDrive: 0.16, masterGlue: 0.45,
                width: 0.62, humanize: 0.04, chorus: 0.34
            )
        ),
        palette: [
            "Gated-reverb snare — huge, bright, cut off abruptly.",
            "Driving 8th-note bass, one note per chord.",
            "Constant 16th arpeggio, wide and delayed.",
            "Supersaw lead over the top, drenched."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Arp alone."),
            SectionNote(section: "VERSE", bars: "16", whats: "Drums and bass in."),
            SectionNote(section: "CHORUS", bars: "16", whats: "Lead over everything."),
            SectionNote(section: "BRIDGE", bars: "8", whats: "Tom fill, drop to arp.")
        ],
        makesItWork: [
            "The snare's long bright reverb is the single most identifiable element.",
            "The bass never stops — straight 8ths for the whole track.",
            "Chorus at 34% and width at 62% give everything that wide analogue shimmer.",
            "Zero swing and 4% humanize: this is machine music by design."
        ],
        mixNotes: [
            "Big bright reverb with low damping — the opposite of most advice here.",
            "Arp panned and delayed, lead opposite it.",
            "Bass driven but filtered so it doesn't fight the kick.",
            "Wide, but keep the bass and kick centred."
        ],
        mistakes: [
            "A dry snare. The gated reverb IS the genre.",
            "Swing or humanisation.",
            "A busy drum pattern — it's simple by design.",
            "Modern bright digital sounds; everything should feel analogue."
        ],
        tint: Ink.plum, family: .pop
    )

    static let hyperpop = GenreTemplate(
        id: "hyperpop", name: "HYPERPOP", tagline: "OVERBRIGHT, DISTORTED, MAXIMAL",
        keyName: "E MAJOR", scaleName: "MAJOR", feel: "150 BPM, deliberately too much.",
        beat: Beat(
            name: "HYPERPOP REFERENCE", bpm: 150, swing: 0, steps: 32,
            drums: [
                DrumTrack(.kick, p("x-------x---x---", "x-------x-x-x---"))
                    .character(gain: 1.0, tune: 1, tone: 0.7, decay: 0.26, drive: 0.65),
                DrumTrack(.clap, p("--------x-------", "--------x-------"))
                    .character(gain: 0.76, pan: 0.05, tone: 0.8, decay: 0.22, reverb: 0.24),
                DrumTrack(.closedHat, p("x-x-x-x-x-x-xxx-", "x-x-x-x-xxxxxxxx"))
                    .character(gain: 0.32, pan: 0.20, tune: 5, tone: 0.75, decay: 0.11),
                DrumTrack(.crash, p("x---------------", "----------------"))
                    .character(gain: 0.34, pan: 0.10, decay: 0.6, reverb: 0.30),
                DrumTrack(.perc, p("------------x---", "----------x---x-"))
                    .character(gain: 0.30, pan: -0.34, tune: 8, reverb: 0.24)
            ],
            melodies: [
                MelodyTrack("BASS", .bass808, [
                    Note(40, 0, 6, vel: 1.0), Note(40, 8, 4), Note(45, 16, 6), Note(38, 24, 6)
                ]).character(gain: 0.94, drive: 0.7, glide: 0.02),
                MelodyTrack("LEAD", .lead, [
                    Note(88, 0, 2), Note(92, 2, 2), Note(95, 4, 4), Note(92, 10, 4),
                    Note(88, 16, 2), Note(92, 18, 2), Note(97, 20, 8)
                ]).character(gain: 0.44, pan: 0.10, drive: 0.35, reverb: 0.30,
                             delay: 0.28, cutoff: 1.4),
                MelodyTrack("CHORDS", .pluck, [
                    Note(76, 0, 2), Note(80, 0, 2), Note(83, 0, 2),
                    Note(73, 16, 2), Note(76, 16, 2), Note(80, 16, 2)
                ]).character(gain: 0.36, pan: -0.18, reverb: 0.28, delay: 0.24, cutoff: 1.3)
            ],
            mix: MixSettings(
                reverbSize: 0.66, reverbDamp: 0.25, reverbPreDelay: 0.016,
                delaySync: .sixteenth, delayFeedback: 0.30,
                sidechain: 0.44, sidechainRelease: 0.11,
                drumDrive: 0.55, drumGlue: 0.60,
                masterDrive: 0.40, masterGlue: 0.6,
                width: 0.66, humanize: 0.04, chorus: 0.30
            )
        ),
        palette: [
            "Everything pushed past comfortable: distorted 808, clipped drums.",
            "Extremely bright supersaw lead in a very high register.",
            "Fast hat rolls and constant motion.",
            "Major key, sugary chords, at odds with the distortion."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "4", whats: "Lead alone, immediately loud."),
            SectionNote(section: "VERSE", bars: "16", whats: "Everything in — no slow build."),
            SectionNote(section: "DROP", bars: "16", whats: "Add another octave of lead."),
            SectionNote(section: "OUTRO", bars: "4", whats: "Cut abruptly.")
        ],
        makesItWork: [
            "Master drive at 40% — the highest here. Distortion is the aesthetic, not a mistake.",
            "Sweet major-key harmony against harsh processing is the central contrast.",
            "The lead sits an octave higher than would normally be sensible.",
            "No dynamics or patience: it starts at maximum and stays there."
        ],
        mixNotes: [
            "Clip the master on purpose. Nothing about this should be polite.",
            "Very wide (66%) with heavy chorus.",
            "Bright reverb with almost no damping.",
            "Sidechain hard so the distorted 808 still lets the kick through."
        ],
        mistakes: [
            "Mixing it tastefully. Restraint is the wrong instinct here.",
            "A dark or minor mood — the sweetness is the point.",
            "Slow builds.",
            "A conservative lead register."
        ],
        tint: Ink.orange, family: .pop
    )

    static let all: [GenreTemplate] = [modernPop, synthwave, hyperpop]
}
