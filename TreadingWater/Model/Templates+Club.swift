import Foundation
import SwiftUI

enum ClubTemplates {

    static let deepHouse = GenreTemplate(
        id: "deephouse", name: "DEEP HOUSE", tagline: "SOFT KICK, JAZZY CHORDS, PATIENT",
        keyName: "F MINOR", scaleName: "DORIAN", feel: "122 BPM, warm and understated.",
        beat: Beat(
            name: "DEEP HOUSE REFERENCE", bpm: 122, swing: 0.12, steps: 32,
            drums: [
                DrumTrack(.kick, p("x---x---x---x---", "x---x---x---x---"))
                    .character(gain: 0.92, tune: -2, tone: 0.30, decay: 0.38, drive: 0.28),
                DrumTrack(.clap, p("----x-------x---", "----x-------x---"))
                    .character(gain: 0.46, pan: 0.06, tone: 0.4, decay: 0.45, reverb: 0.34),
                DrumTrack(.openHat, p("--x---x---x---x-", "--x---x---x---x-"))
                    .character(gain: 0.30, pan: -0.14, tune: -2, tone: 0.4, decay: 0.28),
                DrumTrack(.closedHat, p("x-x-x-x-x-x-x-x-", "x-x-x-x-x-x-x-x-"))
                    .character(gain: 0.18, pan: 0.24, tone: 0.35, decay: 0.16),
                DrumTrack(.perc, p("------x-----x---", "------x---x-x---"))
                    .character(gain: 0.24, pan: -0.36, tune: 3, reverb: 0.30, delay: 0.16)
            ],
            melodies: [
                MelodyTrack("BASS", .bass, [
                    Note(29, 0, 3), Note(29, 6, 3), Note(29, 10, 3), Note(29, 14, 2),
                    Note(32, 16, 3), Note(32, 22, 3), Note(32, 26, 4)
                ]).character(gain: 0.84, drive: 0.20, cutoff: 0.66),
                MelodyTrack("CHORDS", .keys, [
                    Note(65, 2, 4), Note(68, 2, 4), Note(72, 2, 4), Note(75, 2, 4),
                    Note(63, 18, 4), Note(67, 18, 4), Note(70, 18, 4), Note(74, 18, 4)
                ]).character(gain: 0.48, pan: -0.08, reverb: 0.36, cutoff: 0.55),
                MelodyTrack("PAD", .pad, [
                    Note(77, 0, 15), Note(80, 0, 15),
                    Note(75, 16, 15), Note(79, 16, 15)
                ]).character(gain: 0.22, reverb: 0.52, cutoff: 0.6)
            ],
            mix: MixSettings(
                reverbSize: 0.72, reverbDamp: 0.5, reverbPreDelay: 0.024,
                delaySync: .quarter, delayFeedback: 0.34,
                sidechain: 0.46, sidechainRelease: 0.22,
                drumDrive: 0.18, drumGlue: 0.32,
                masterDrive: 0.08, masterGlue: 0.4,
                width: 0.48, humanize: 0.16, chorus: 0.22
            )
        ),
        palette: [
            "Kick with the click rolled off — felt more than heard.",
            "Rhodes-style 7th and 9th chords on the off-beats.",
            "Rolling 8th-note bass, filtered dark.",
            "Soft clap with a long plate, well behind the kick."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "16", whats: "Drums and bass only."),
            SectionNote(section: "GROOVE", bars: "32", whats: "Chords enter, filter slowly opening."),
            SectionNote(section: "BREAK", bars: "16", whats: "Kick out, pad and chords."),
            SectionNote(section: "DROP", bars: "32", whats: "Everything back, perc added.")
        ],
        makesItWork: [
            "The kick is dark and soft. Deep house is not about impact.",
            "Chords sit on the off-beats and are filtered to 55% — present, never forward.",
            "Sidechain at 46% with a slow release gives the long, breathing pump.",
            "Patience: 32-bar sections and almost no variation."
        ],
        mixNotes: [
            "Roll the top off everything. Nothing here should sparkle.",
            "Chorus on the music bus widens the Rhodes without a widener.",
            "Long reverb on chords and perc, none on the bass.",
            "Keep the master nearly untouched — this genre stays dynamic."
        ],
        mistakes: [
            "A bright, clicky kick. That's tech house.",
            "Plain triads — deep house needs 7ths and 9ths.",
            "Rushing the arrangement. Sections are long on purpose.",
            "Too much top end. Filter it all down."
        ],
        tint: Ink.steel, family: .house
    )

    static let techHouse = GenreTemplate(
        id: "techhouse", name: "TECH HOUSE", tagline: "TIGHT, MINIMAL, RELENTLESS",
        keyName: "A MINOR", scaleName: "MINOR", feel: "126 BPM, dry and mechanical.",
        beat: Beat(
            name: "TECH HOUSE REFERENCE", bpm: 126, swing: 0.04, steps: 32,
            drums: [
                DrumTrack(.kick, p("x---x---x---x---", "x---x---x---x---"))
                    .character(gain: 1.0, tune: 1, tone: 0.62, decay: 0.24, drive: 0.42),
                DrumTrack(.clap, p("----x-------x---", "----x-------x---"))
                    .character(gain: 0.56, pan: 0.04, tone: 0.62, decay: 0.22, reverb: 0.12),
                DrumTrack(.closedHat, p("--x---x---x---x-", "--x---x---x---x-"))
                    .character(gain: 0.32, pan: 0.22, tune: 2, tone: 0.6, decay: 0.12),
                DrumTrack(.perc, p("---x--x----x--x-", "---x--x----x-xx-"))
                    .character(gain: 0.34, pan: -0.34, tune: 5, decay: 0.2, reverb: 0.14),
                DrumTrack(.rim, p("------x-------x-", "------x-------x-"))
                    .character(gain: 0.28, pan: 0.30, tune: 4)
            ],
            melodies: [
                MelodyTrack("BASS", .bass, [
                    Note(33, 2, 2), Note(33, 6, 2), Note(33, 10, 2), Note(33, 14, 2),
                    Note(33, 18, 2), Note(36, 22, 2), Note(33, 26, 2), Note(31, 30, 2)
                ]).character(gain: 0.90, drive: 0.34, cutoff: 0.72),
                MelodyTrack("STAB", .organ, [
                    Note(69, 6, 1), Note(72, 14, 1), Note(69, 22, 1), Note(76, 30, 1)
                ]).character(gain: 0.34, pan: 0.14, reverb: 0.22, delay: 0.24)
            ],
            mix: MixSettings(
                reverbSize: 0.40, reverbDamp: 0.6, reverbPreDelay: 0.014,
                delaySync: .dottedEighth, delayFeedback: 0.30,
                sidechain: 0.58, sidechainRelease: 0.14,
                drumDrive: 0.30, drumGlue: 0.45,
                masterDrive: 0.14, masterGlue: 0.5,
                width: 0.38, humanize: 0.06
            )
        ),
        palette: [
            "Short punchy kick with an audible click.",
            "Dry tight clap, almost no reverb.",
            "Off-beat closed hats rather than open hats.",
            "A rolling, filtered bass playing off-beat 8ths."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "16", whats: "Drums, percussion loop."),
            SectionNote(section: "GROOVE", bars: "32", whats: "Bass in, stabs occasionally."),
            SectionNote(section: "BREAK", bars: "16", whats: "Filter down, kick out."),
            SectionNote(section: "DROP", bars: "32", whats: "Full, percussion doubled.")
        ],
        makesItWork: [
            "Everything is dry and short. Reverb size 40% and heavily damped.",
            "The bass plays the off-beats against the four-on-the-floor kick.",
            "Sidechain at 58% is doing a lot of the rhythmic work.",
            "Humanize at 6% — this is the most machine-locked template here."
        ],
        mixNotes: [
            "Kick and bass are the whole low end; keep them tightly interlocked.",
            "Percussion panned hard and dry — width comes from placement, not effects.",
            "One stab per bar with delay is all the melody this needs.",
            "Drum glue at 45% keeps the loop sounding like one machine."
        ],
        mistakes: [
            "Long reverbs — they clutter the gaps that make it groove.",
            "A busy melody. Tech house is a drum genre.",
            "Swing. Keep it straight.",
            "Bass on the downbeats with the kick — put it on the off-beats."
        ],
        tint: Ink.orange, family: .house
    )

    static let amapiano = GenreTemplate(
        id: "amapiano", name: "AMAPIANO", tagline: "LOG DRUM, SHAKERS, WIDE SPACE",
        keyName: "A MINOR", scaleName: "MINOR", feel: "112 BPM, spacious and rolling.",
        beat: Beat(
            name: "AMAPIANO REFERENCE", bpm: 112, swing: 0.14, steps: 32,
            drums: [
                DrumTrack(.kick, p("x---x---x---x---", "x---x---x---x---"))
                    .character(gain: 0.86, tune: -2, tone: 0.35, decay: 0.34, drive: 0.24),
                DrumTrack(.rim, p("----x-------x---", "----x-------x---"))
                    .character(gain: 0.42, pan: -0.20, tune: 2, reverb: 0.24),
                DrumTrack(.closedHat, p("x-xxx-x-x-xxx-x-", "x-xxx-x-x-xxx-xx"))
                    .character(gain: 0.30, pan: 0.28, tune: 4, tone: 0.55, decay: 0.14),
                DrumTrack(.perc, p("--x---x-x---x-x-", "--x---x-x---x-xx"))
                    .character(gain: 0.36, pan: -0.44, tune: 5, reverb: 0.30, delay: 0.12),
                DrumTrack(.openHat, p("------------x---", "------------x---"))
                    .character(gain: 0.24, pan: 0.16, tune: 2, decay: 0.30)
            ],
            melodies: [
                MelodyTrack("LOG DRUM", .bass, [
                    Note(45, 4, 2), Note(40, 6, 2), Note(45, 10, 2), Note(43, 12, 3),
                    Note(45, 20, 2), Note(40, 22, 2), Note(48, 26, 4)
                ]).character(gain: 0.92, drive: 0.40, cutoff: 0.55, glide: 0.02),
                MelodyTrack("KEYS", .keys, [
                    Note(69, 0, 6), Note(72, 0, 6), Note(76, 0, 6),
                    Note(67, 16, 6), Note(71, 16, 6), Note(74, 16, 6)
                ]).character(gain: 0.44, pan: -0.10, reverb: 0.40, cutoff: 0.65),
                MelodyTrack("PAD", .pad, [
                    Note(81, 0, 15), Note(84, 0, 15),
                    Note(79, 16, 15), Note(83, 16, 15)
                ]).character(gain: 0.20, reverb: 0.55, cutoff: 0.7)
            ],
            mix: MixSettings(
                reverbSize: 0.78, reverbDamp: 0.4, reverbPreDelay: 0.028,
                delaySync: .eighth, delayFeedback: 0.32,
                sidechain: 0.36, sidechainRelease: 0.20,
                drumDrive: 0.18, drumGlue: 0.30,
                masterDrive: 0.08, masterGlue: 0.38,
                width: 0.66, humanize: 0.24, chorus: 0.16
            )
        ),
        palette: [
            "Log drum — a deep, pitched, gliding bass melody. The signature.",
            "Shakers and rim doing constant intricate 16th work.",
            "Soft four-on-the-floor kick, well behind the percussion.",
            "Jazzy piano chords with a long reverb."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "16", whats: "Percussion and keys."),
            SectionNote(section: "GROOVE", bars: "32", whats: "Log drum enters — the moment."),
            SectionNote(section: "BREAK", bars: "16", whats: "Drums out, keys and pad."),
            SectionNote(section: "MAIN", bars: "32", whats: "Everything, extra shakers.")
        ],
        makesItWork: [
            "The log drum plays a melody, not a root note. It's the hook and the bass at once.",
            "Percussion is dense and wide (66%) while the kick stays soft and central.",
            "Big bright reverb — amapiano is the most spacious template here.",
            "Everything swings slightly and is heavily humanised."
        ],
        mixNotes: [
            "Log drum filtered dark and driven, centred and mono.",
            "Pan shakers and percussion hard and keep them moving.",
            "Keys wet and soft, sitting behind the percussion.",
            "Kick quieter than you think — the groove is percussive, not kick-led."
        ],
        mistakes: [
            "A loud, clicky kick. It should sit under everything.",
            "A static root-note bass instead of a melodic log drum.",
            "Narrow percussion. The width is the vibe.",
            "Rushing sections — this genre unfolds slowly."
        ],
        tint: Ink.amber, family: .house
    )

    static let garage = GenreTemplate(
        id: "garage", name: "UK GARAGE", tagline: "2-STEP, SWUNG EIGHTHS, SKIPPY",
        keyName: "G MINOR", scaleName: "MINOR", feel: "134 BPM with a heavy 8th-note shuffle.",
        beat: Beat(
            name: "GARAGE REFERENCE", bpm: 134, swing: 0.34, steps: 32,
            drums: [
                DrumTrack(.kick, p("x---------x-----", "x-------x-------"))
                    .character(gain: 0.94, tune: 0, tone: 0.55, decay: 0.30, drive: 0.34),
                DrumTrack(.snare, p("----x-------x---", "----x-------x---"))
                    .character(gain: 0.72, tune: 2, tone: 0.68, decay: 0.26, reverb: 0.18),
                DrumTrack(.closedHat, p("x-x-x-x-x-x-x-x-", "x-x-x-x-x-x-xxx-"))
                    .character(gain: 0.32, pan: 0.22, tune: 3, tone: 0.6, decay: 0.13),
                DrumTrack(.rim, p("--x-------x-----", "--x---x---x-----"))
                    .character(gain: 0.30, pan: -0.28, tune: 5),
                DrumTrack(.openHat, p("------------x---", "------------x---"))
                    .character(gain: 0.26, pan: -0.16, tune: 2, decay: 0.28)
            ],
            melodies: [
                MelodyTrack("BASS", .bass, [
                    Note(31, 0, 3), Note(31, 6, 2), Note(34, 10, 3),
                    Note(31, 16, 3), Note(29, 22, 3), Note(31, 28, 3)
                ]).character(gain: 0.88, drive: 0.30, cutoff: 0.62),
                MelodyTrack("CHORDS", .keys, [
                    Note(70, 2, 3), Note(74, 2, 3), Note(77, 2, 3),
                    Note(72, 18, 3), Note(75, 18, 3), Note(79, 18, 3)
                ]).character(gain: 0.42, pan: 0.10, reverb: 0.30, delay: 0.20, cutoff: 0.7)
            ],
            mix: MixSettings(
                reverbSize: 0.62, reverbDamp: 0.45, reverbPreDelay: 0.022,
                delaySync: .eighth, delayFeedback: 0.28,
                sidechain: 0.30, sidechainRelease: 0.15,
                drumDrive: 0.24, drumGlue: 0.38,
                masterDrive: 0.12, masterGlue: 0.45,
                width: 0.44, humanize: 0.20, swingGrid: .eighth
            )
        ),
        palette: [
            "2-step pattern: kick on 1, snare on 2, kick on the 'and' of 3, snare on 4.",
            "Heavy 8th-note swing — this is the one genre where the 8ths shuffle.",
            "Skippy rim and shaker fills between the main hits.",
            "Warm filtered bass and clipped organ chords."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Drums and bass."),
            SectionNote(section: "VERSE", bars: "16", whats: "Chords in, vocal chops."),
            SectionNote(section: "BREAK", bars: "8", whats: "Drums out, chords and reverb."),
            SectionNote(section: "DROP", bars: "16", whats: "Full, extra percussion.")
        ],
        makesItWork: [
            "The swing is set to displace 8ths, not 16ths — twice as much material moves, and that lope is garage.",
            "The kick avoids beat 3 entirely. That hole is what makes it skip.",
            "Snare on 2 and 4 stays straight while everything around it shuffles.",
            "Rim and shaker fills in the gaps keep it busy without adding weight."
        ],
        mixNotes: [
            "Bass filtered and warm, never sub-heavy — garage lives in the low mids.",
            "Snare bright and forward with a short room.",
            "Chords clipped short and delayed.",
            "Moderate width; the interest is rhythmic."
        ],
        mistakes: [
            "16th swing instead of 8th swing — completely different feel.",
            "A four-on-the-floor kick. That's speed garage, not 2-step.",
            "A heavy sub bass. Keep the low end light and bouncy.",
            "Straight, even hats. They need to skip."
        ],
        tint: Ink.plum, family: .house
    )

    static let jerseyClub = GenreTemplate(
        id: "jersey", name: "JERSEY CLUB", tagline: "TRIPLET KICK BOUNCE, CHOPPED VOCALS",
        keyName: "C MINOR", scaleName: "MINOR", feel: "140 BPM, frantic and bouncing.",
        beat: Beat(
            name: "JERSEY REFERENCE", bpm: 140, swing: 0, steps: 32,
            drums: [
                DrumTrack(.kick, p("x--x--x---x--x--", "x--x--x---x--x--"))
                    .character(gain: 0.96, tune: 0, tone: 0.6, decay: 0.24, drive: 0.45),
                DrumTrack(.snare, p("--------x-------", "--------x---x-x-"))
                    .character(gain: 0.74, tune: 2, tone: 0.66, decay: 0.24, reverb: 0.14),
                DrumTrack(.closedHat, p("x-x-x-x-x-x-x-x-", "x-x-x-x-x-x-x-x-"))
                    .character(gain: 0.28, pan: 0.20, tune: 3, decay: 0.12),
                DrumTrack(.clap, p("----x-------x---", "----x-------x---"))
                    .character(gain: 0.50, pan: 0.05, tone: 0.6, decay: 0.25, reverb: 0.20),
                DrumTrack(.perc, p("--------------x-", "----------x---x-"))
                    .character(gain: 0.30, pan: -0.32, tune: 7, reverb: 0.18)
            ],
            melodies: [
                MelodyTrack("BASS", .bass808, [
                    Note(36, 0, 3), Note(36, 6, 3), Note(36, 10, 4),
                    Note(34, 16, 3), Note(39, 22, 3), Note(36, 26, 5)
                ]).character(gain: 0.92, drive: 0.35, glide: 0.015),
                MelodyTrack("STAB", .pluck, [
                    Note(72, 0, 2), Note(75, 8, 2), Note(79, 16, 2), Note(75, 24, 2)
                ]).character(gain: 0.38, pan: 0.12, reverb: 0.24, delay: 0.18)
            ],
            mix: MixSettings(
                reverbSize: 0.50, reverbDamp: 0.5, reverbPreDelay: 0.016,
                delaySync: .sixteenth, delayFeedback: 0.20,
                sidechain: 0.40, sidechainRelease: 0.10,
                drumDrive: 0.32, drumGlue: 0.45,
                masterDrive: 0.18, masterGlue: 0.5,
                width: 0.34, humanize: 0.08
            )
        ),
        palette: [
            "The five-kick bounce: three, three, then two — the Jersey signature.",
            "Chopped vocal stabs used as percussion.",
            "Bright clap on 2 and 4 over the top.",
            "Short punchy bass following the kick exactly."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Kick pattern alone."),
            SectionNote(section: "MAIN", bars: "16", whats: "Full, vocal chops in."),
            SectionNote(section: "BREAK", bars: "8", whats: "Kick out, chops and reverb."),
            SectionNote(section: "DROP", bars: "16", whats: "Back in, chops doubled.")
        ],
        makesItWork: [
            "The kick grouping is 3-3-2 across the bar. Everything else follows it.",
            "No swing at all — the bounce comes from the grouping, not from timing.",
            "The bass locks to the kick note for note.",
            "Vocal chops replace a melody entirely."
        ],
        mixNotes: [
            "Kick short and loud; it is the lead instrument.",
            "Keep reverb short — this needs to stay punchy.",
            "Sidechain fast so the busy kick pattern always reads.",
            "Narrow and loud. This is a club-system mix."
        ],
        mistakes: [
            "An even kick pattern. The 3-3-2 grouping is non-negotiable.",
            "Long bass notes — they blur the bounce.",
            "Adding swing. The grouping already does that job.",
            "A big melodic hook. Chops carry it."
        ],
        tint: Ink.orange, family: .house
    )

    static let disco = GenreTemplate(
        id: "disco", name: "DISCO / NU-DISCO", tagline: "OCTAVE BASS, OPEN HATS, STRINGS",
        keyName: "D MINOR", scaleName: "DORIAN", feel: "118 BPM, bright and driving.",
        beat: Beat(
            name: "DISCO REFERENCE", bpm: 118, swing: 0.08, steps: 32,
            drums: [
                DrumTrack(.kick, p("x---x---x---x---", "x---x---x---x---"))
                    .character(gain: 0.92, tune: -1, tone: 0.45, decay: 0.32, drive: 0.30),
                DrumTrack(.snare, p("----x-------x---", "----x-------x---"))
                    .character(gain: 0.66, tune: 0, tone: 0.55, decay: 0.35, reverb: 0.26),
                DrumTrack(.openHat, p("--x---x---x---x-", "--x---x---x---x-"))
                    .character(gain: 0.40, pan: -0.12, tune: 0, tone: 0.55, decay: 0.30),
                DrumTrack(.closedHat, p("x-x-x-x-x-x-x-x-", "x-x-x-x-x-x-x-x-"))
                    .character(gain: 0.24, pan: 0.22, decay: 0.15),
                DrumTrack(.perc, p("------x-----x--x", "------x-----x--x"))
                    .character(gain: 0.28, pan: -0.38, tune: 4, reverb: 0.22)
            ],
            melodies: [
                MelodyTrack("BASS", .bass, [
                    Note(38, 0, 2), Note(50, 2, 2), Note(38, 4, 2), Note(50, 6, 2),
                    Note(38, 8, 2), Note(50, 10, 2), Note(41, 12, 2), Note(53, 14, 2),
                    Note(36, 16, 2), Note(48, 18, 2), Note(36, 20, 2), Note(48, 22, 2),
                    Note(36, 24, 2), Note(48, 26, 2), Note(43, 28, 2), Note(55, 30, 2)
                ]).character(gain: 0.86, drive: 0.26, cutoff: 0.9),
                MelodyTrack("STRINGS", .pad, [
                    Note(74, 0, 15), Note(77, 0, 15), Note(81, 0, 15),
                    Note(72, 16, 15), Note(76, 16, 15), Note(79, 16, 15)
                ]).character(gain: 0.30, reverb: 0.44, cutoff: 0.9),
                MelodyTrack("STABS", .organ, [
                    Note(62, 6, 1), Note(65, 6, 1), Note(69, 6, 1),
                    Note(60, 22, 1), Note(64, 22, 1), Note(67, 22, 1)
                ]).character(gain: 0.34, pan: 0.16, reverb: 0.24, delay: 0.18)
            ],
            mix: MixSettings(
                reverbSize: 0.66, reverbDamp: 0.35, reverbPreDelay: 0.024,
                delaySync: .dottedEighth, delayFeedback: 0.26,
                sidechain: 0.24, sidechainRelease: 0.18,
                drumDrive: 0.26, drumGlue: 0.40,
                masterDrive: 0.14, masterGlue: 0.45,
                width: 0.58, humanize: 0.22, chorus: 0.20
            )
        ),
        palette: [
            "Octave-jumping bassline — the single most recognisable disco element.",
            "Open hat on every off-beat, bright and ringing.",
            "String pad holding long chords above everything.",
            "Short organ or guitar stabs on the off-beats."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Drums and bass."),
            SectionNote(section: "VERSE", bars: "16", whats: "Stabs and strings enter."),
            SectionNote(section: "BREAK", bars: "8", whats: "Filter down, strings only."),
            SectionNote(section: "CHORUS", bars: "16", whats: "Everything, wide and bright.")
        ],
        makesItWork: [
            "The bass alternates root and octave on every 8th. That motion is the engine.",
            "Off-beat open hats against four-on-the-floor — same tension as house, brighter.",
            "Strings are wide and constant, giving the whole thing lift.",
            "Light sidechain only; disco predates heavy pumping."
        ],
        mixNotes: [
            "Bass filtered fairly open — it needs to be heard as notes, not felt.",
            "Bright reverb with low damping; this mix should sparkle.",
            "Wide strings, centred bass and kick.",
            "Keep it dynamic — resist squashing the master."
        ],
        mistakes: [
            "A static root-note bass. The octave jump is the whole idea.",
            "Dark, filtered mixes. Disco is bright.",
            "Heavy sidechain pumping — wrong era.",
            "Forgetting the off-beat open hat."
        ],
        tint: Ink.clay, family: .house
    )

    static let all: [GenreTemplate] = [deepHouse, techHouse, amapiano, garage, jerseyClub, disco]
}
