import Foundation
import SwiftUI

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

    var bpm: Double { beat.bpm }
}

// Two-bar patterns, written a bar at a time so they're readable.
private func p(_ a: String, _ b: String) -> String { a + b }

enum Templates {

    // MARK: TRAP

    static let trap = GenreTemplate(
        id: "trap", name: "TRAP", tagline: "HALF-TIME SNARE, 808 CARRYING THE BASS",
        keyName: "F MINOR", scaleName: "MINOR", feel: "140 BPM that feels like 70.",
        beat: Beat(
            name: "TRAP REFERENCE", bpm: 140, swing: 0, steps: 32,
            drums: [
                DrumTrack(.kick,      p("x-----x---x-----", "x-----x---x--x--")),
                DrumTrack(.snare,     p("--------x-------", "--------x-------")),
                DrumTrack(.closedHat, p("x.x.x.x.x.x.x.x.", "x.x.x.x.x.xxxxxx")),
                DrumTrack(.openHat,   p("----------------", "--------------x-")),
                DrumTrack(.perc,      p("----x-------x---", "----x-----------"), gain: 0.5)
            ],
            melodies: [
                MelodyTrack("808", .bass, [
                    Note(29, 0, 6, vel: 1.0), Note(32, 10, 4), Note(29, 16, 6, vel: 1.0), Note(36, 26, 5)
                ]),
                MelodyTrack("BELLS", .bell, [
                    Note(77, 0, 4), Note(80, 6, 2), Note(84, 8, 6),
                    Note(77, 16, 4), Note(80, 22, 2), Note(75, 24, 6)
                ])
            ]
        ),
        palette: [
            "808 — long, tuned to the key, one note at a time",
            "Kick — short and clicky, sits ON the 808 or replaces it",
            "Snare or clap — tight, bright, half-time",
            "Hats — closed 16ths with rolls, one open hat per two bars",
            "Bells / plucks / dark keys for the melody",
            "Vocal chops, risers and one reverse crash per section"
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Melody alone, then hats join. No 808 yet."),
            SectionNote(section: "VERSE", bars: "16", whats: "Everything in. 808 following the kick pattern."),
            SectionNote(section: "HOOK", bars: "16", whats: "Add an octave-up melody layer and a second perc."),
            SectionNote(section: "BREAK", bars: "4", whats: "Drums out, melody and a riser only."),
            SectionNote(section: "HOOK 2", bars: "16", whats: "Back in harder. Hat rolls doubled.")
        ],
        makesItWork: [
            "The snare hits ONCE per bar. That single choice is what makes 140 feel slow.",
            "The 808 is the bassline and the low kick at the same time — it's not sitting under a separate bass.",
            "Hat rolls land at the END of a two-bar phrase, ramping in velocity into the next one.",
            "The melody is short and dark, and it repeats without variation. Space matters more than movement.",
            "The kick pattern is asymmetrical — the second bar differs from the first. That's what stops it being a metronome."
        ],
        mixNotes: [
            "808 dead centre and mono. Sidechain it to the kick with a fast attack.",
            "Saturate the 808 so it survives on phone speakers — the sub alone is invisible there.",
            "High-pass the melody at 200–300 Hz. It has no business in the low end.",
            "Keep the hats quiet. They should be felt as speed, not heard as a lead instrument.",
            "Everything except the 808 and kick gets high-passed. The low end belongs to two elements only."
        ],
        mistakes: [
            "Two snares per bar — that's a 70 BPM boom bap pattern at double speed and it feels frantic.",
            "A long 808 note under a busy kick — they overlap and the low end turns to mush. Shorten the notes.",
            "Hat rolls everywhere. One per 4 bars is the ceiling.",
            "Layering a big boomy kick on top of the 808. Use a short clicky one or none at all."
        ],
        tint: Ink.orange
    )

    // MARK: BOOM BAP

    static let boomBap = GenreTemplate(
        id: "boombap", name: "BOOM BAP", tagline: "SWUNG, DUSTY, SPACE BETWEEN THE HITS",
        keyName: "C MINOR", scaleName: "MINOR", feel: "88 BPM with 30% swing. Behind the beat on purpose.",
        beat: Beat(
            name: "BOOM BAP REFERENCE", bpm: 88, swing: 0.30, steps: 32,
            drums: [
                DrumTrack(.kick,      p("x---------x-----", "x-------x-x-----")),
                DrumTrack(.snare,     p("----x--.----x---", "----x-------x-.-")),
                DrumTrack(.closedHat, p("x-o-x-o-x-o-x-o-", "x-o-x-o-x-o-x-oo")),
                DrumTrack(.rim,       p("----------------", "--------------.-"), gain: 0.6)
            ],
            melodies: [
                MelodyTrack("BASS", .bass, [
                    Note(36, 0, 8, vel: 0.95), Note(36, 10, 5),
                    Note(41, 16, 6), Note(39, 24, 7)
                ]),
                MelodyTrack("KEYS", .keys, [
                    // Cm7 then Fm7 — the classic dusty two-chord loop.
                    Note(60, 0, 14), Note(63, 0, 14), Note(67, 0, 14), Note(70, 0, 14),
                    Note(65, 16, 14), Note(68, 16, 14), Note(72, 16, 14), Note(75, 16, 14)
                ])
            ]
        ),
        palette: [
            "Kick — round, warm, slightly soft attack. Not clicky.",
            "Snare — thick with a short tail. Vinyl noise baked in is a feature.",
            "Hats — swung, low velocity, imperfect timing.",
            "Sampled chords — filtered, pitched, ideally from a chopped record.",
            "Upright or round electric bass following the kick.",
            "Vinyl crackle across the whole loop at low level."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Sample loop alone, filtered."),
            SectionNote(section: "VERSE", bars: "16", whats: "Full drums plus bass. Leave the top half empty for a vocal."),
            SectionNote(section: "HOOK", bars: "8", whats: "Open the filter, add a horn or vocal chop."),
            SectionNote(section: "BREAK", bars: "4", whats: "Drums out, sample only, then a fill back in.")
        ],
        makesItWork: [
            "Swing on the hats, straight kick and snare. The contrast is the whole feel.",
            "Ghost snares either side of the backbeat — barely audible, entirely responsible for the groove.",
            "Space. There are fewer hits per bar here than in any other genre on this list.",
            "The sample is filtered, so the drums own the low end and the top end.",
            "The snare lands a few milliseconds late. Nudge it off the grid by hand and it instantly sounds like a record."
        ],
        mixNotes: [
            "High-pass the sample around 150–200 Hz so the kick and bass have room.",
            "Drum bus: light compression 2:1, 2–3 dB, plus tape saturation for glue.",
            "Keep the snare loud. In this genre the snare is allowed to be the loudest thing.",
            "No modern stereo widening. Boom bap sounds right when it's fairly narrow and mono-ish."
        ],
        mistakes: [
            "Quantising everything to 100%. Perfect timing kills this genre specifically.",
            "Too many kicks. Two or three per bar, with real gaps.",
            "A bright, clicky trap kick. It fights the sample instead of sitting under it.",
            "Forgetting to filter the sample, then wondering why the kick has no power."
        ],
        tint: Ink.clay
    )

    // MARK: DRILL

    static let drill = GenreTemplate(
        id: "drill", name: "UK DRILL", tagline: "SLIDING 808S, MENACING INTERVALS",
        keyName: "F# MINOR", scaleName: "PHRYGIAN", feel: "142 BPM, half-time, with a triplet-ish hat lope.",
        beat: Beat(
            name: "DRILL REFERENCE", bpm: 142, swing: 0.12, steps: 32,
            drums: [
                DrumTrack(.kick,      p("x-------x-------", "x-----x---------")),
                DrumTrack(.snare,     p("----------x-----", "----------x-----")),
                DrumTrack(.closedHat, p("x--x--x-x--x--x-", "x--x--x-x--x-xxx")),
                DrumTrack(.rim,       p("--------x-------", "--------x-------"), gain: 0.7),
                DrumTrack(.openHat,   p("----------------", "------------x---"))
            ],
            melodies: [
                MelodyTrack("808", .bass, [
                    // The slide is the genre: same note restated at different lengths.
                    Note(30, 0, 8, vel: 1.0), Note(37, 8, 4), Note(35, 12, 4),
                    Note(30, 16, 6, vel: 1.0), Note(33, 22, 4), Note(28, 26, 6)
                ]),
                MelodyTrack("LEAD", .pluck, [
                    Note(78, 0, 3), Note(79, 4, 2), Note(85, 6, 4), Note(78, 12, 3),
                    Note(78, 16, 3), Note(79, 20, 2), Note(83, 22, 6)
                ])
            ]
        ),
        palette: [
            "808 with pitch glide between notes — this IS the genre.",
            "Kick — very short, almost only a click, so it doesn't fight the 808.",
            "Snare or rim on beat 3 only, dry and tight.",
            "Hats in a loping 3-3-2 pattern rather than straight 16ths.",
            "Dark, sparse lead — plucked strings, bells, or a detuned flute.",
            "Phrygian flavour: use the flat 2nd degree in the melody for menace."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Lead and hats. No 808."),
            SectionNote(section: "VERSE", bars: "16", whats: "Full. 808 sliding, lead dropped in volume."),
            SectionNote(section: "HOOK", bars: "8", whats: "Lead doubled an octave up, extra perc."),
            SectionNote(section: "SWITCH", bars: "8", whats: "New 808 pattern, same lead. Drill lives on switch-ups.")
        ],
        makesItWork: [
            "The 808 glides between notes rather than restating cleanly — that slide is the signature.",
            "Hats lope in a 3-3-2 grouping instead of even 16ths. Count 1-and-a, 2-and-a, 3-and.",
            "The kick is nearly absent as a sound. The 808 carries all the low end.",
            "Everything is dry. Almost no reverb — the space is what makes it sound cold.",
            "The lead uses the flat second, which is what separates drill from trap harmonically."
        ],
        mixNotes: [
            "808 loud, mono, saturated. It's the loudest element in the mix and that's correct.",
            "Sidechain the 808 to the kick even though the kick is quiet — it keeps the attack readable.",
            "Almost no reverb on drums. A tiny room on the lead only.",
            "High-pass the lead hard, around 400 Hz. It should feel thin and distant."
        ],
        mistakes: [
            "Straight 16th hats. That's trap. Drill needs the 3-3-2 lope.",
            "A big boomy kick under the 808 — the two cancel and the low end disappears.",
            "Overlapping 808 notes. Cut each one before the next starts or you get permanent mud.",
            "Too much melody. Drill hooks are three or four notes, repeated."
        ],
        tint: Ink.plum
    )

    // MARK: HOUSE

    static let house = GenreTemplate(
        id: "house", name: "HOUSE", tagline: "FOUR ON THE FLOOR, OFF-BEAT LIFT",
        keyName: "A MINOR", scaleName: "DORIAN", feel: "124 BPM, relentless and hypnotic.",
        beat: Beat(
            name: "HOUSE REFERENCE", bpm: 124, swing: 0.10, steps: 32,
            drums: [
                DrumTrack(.kick,      p("x---x---x---x---", "x---x---x---x---")),
                DrumTrack(.clap,      p("----x-------x---", "----x-------x---")),
                DrumTrack(.openHat,   p("--x---x---x---x-", "--x---x---x---x-")),
                DrumTrack(.closedHat, p("x-x-x-x-x-x-x-x-", "x-x-x-x-x-x-x-x-"), gain: 0.45),
                DrumTrack(.perc,      p("------x-----x--x", "------x---x-x--x"), gain: 0.5)
            ],
            melodies: [
                MelodyTrack("BASS", .bass, [
                    Note(33, 0, 3), Note(33, 4, 3), Note(33, 8, 3), Note(33, 12, 3),
                    Note(38, 16, 3), Note(38, 20, 3), Note(38, 24, 3), Note(38, 28, 3)
                ]),
                MelodyTrack("STABS", .keys, [
                    // Am7 then Dm7 stabs on the off-beats.
                    Note(57, 2, 2), Note(60, 2, 2), Note(64, 2, 2), Note(67, 2, 2),
                    Note(57, 10, 2), Note(60, 10, 2), Note(64, 10, 2), Note(67, 10, 2),
                    Note(62, 18, 2), Note(65, 18, 2), Note(69, 18, 2), Note(72, 18, 2),
                    Note(62, 26, 2), Note(65, 26, 2), Note(69, 26, 2), Note(72, 26, 2)
                ])
            ]
        ),
        palette: [
            "Kick — punchy with a fast decay so it doesn't smear into the next one.",
            "Clap or snare on 2 and 4, often layered together.",
            "Open hat on every off-beat. This is the lift that defines house.",
            "Short chord stabs on the off-beats, ideally with a Rhodes or organ tone.",
            "A rolling bassline in 8ths, sidechained hard.",
            "Shakers and congas panned wide for movement."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "16", whats: "Drums only. DJs need this to mix in."),
            SectionNote(section: "GROOVE", bars: "16", whats: "Add bass and hats."),
            SectionNote(section: "BREAKDOWN", bars: "16", whats: "Kick out, chords and pad, filter closing."),
            SectionNote(section: "DROP", bars: "32", whats: "Everything back in. This is the longest section."),
            SectionNote(section: "OUTRO", bars: "16", whats: "Strip back to drums for the next DJ.")
        ],
        makesItWork: [
            "Off-beat open hats against a four-on-the-floor kick. That tension is the entire genre.",
            "Sidechain the bass and chords to the kick hard enough to hear the pump — it's a feature here.",
            "Chord stabs land off the grid's downbeats, so they push against the kick.",
            "Long sections. House builds over minutes, not bars. Sixteen bars is a short section here.",
            "Very little changes at any one time. The hypnotism comes from patience."
        ],
        mixNotes: [
            "The kick is the loudest thing. Everything else ducks around it.",
            "Bass mono below 120 Hz, chords wide above it.",
            "Reverb on the stabs, not the bass. A short plate at 20% send.",
            "Leave a long DJ-friendly intro and outro of drums only."
        ],
        mistakes: [
            "Closed hats on every 16th at full volume — it makes the groove feel busy and cheap.",
            "Changing something every four bars. House needs longer than that to hypnotise.",
            "A short intro. If a DJ can't beatmatch into it, it won't get played.",
            "Chords on the downbeat with the kick. Move them to the off-beats and it immediately grooves."
        ],
        tint: Ink.amber
    )

    // MARK: LO-FI

    static let lofi = GenreTemplate(
        id: "lofi", name: "LO-FI", tagline: "SWUNG, SOFT, DELIBERATELY IMPERFECT",
        keyName: "D MINOR", scaleName: "DORIAN", feel: "78 BPM, heavy swing, nothing on the grid.",
        beat: Beat(
            name: "LO-FI REFERENCE", bpm: 78, swing: 0.36, steps: 32,
            drums: [
                DrumTrack(.kick,      p("x-------x-------", "x-----------x---")),
                DrumTrack(.rim,       p("----x-------x---", "----x-------x---")),
                DrumTrack(.closedHat, p("x-o.x-o.x-o.x-o.", "x-o.x-o.x-o.x-oo"), gain: 0.75),
                DrumTrack(.perc,      p("--------------.-", "------.---------"), gain: 0.4)
            ],
            melodies: [
                MelodyTrack("KEYS", .keys, [
                    // Dm9 -> Gm7. Add the 9th and it stops sounding like a beginner chord.
                    Note(62, 0, 14), Note(65, 0, 14), Note(69, 0, 14), Note(72, 0, 14), Note(76, 0, 14),
                    Note(67, 16, 14), Note(70, 16, 14), Note(74, 16, 14), Note(77, 16, 14)
                ]),
                MelodyTrack("BASS", .bass, [
                    Note(38, 0, 7, vel: 0.85), Note(38, 8, 5),
                    Note(31, 16, 7, vel: 0.85), Note(33, 26, 5)
                ])
            ]
        ),
        palette: [
            "Kick — soft, no click, almost muffled.",
            "Rimshot or brushed snare instead of a full snare.",
            "Hats swung heavily and low in the mix.",
            "Rhodes or upright piano with 7th and 9th chords.",
            "Vinyl crackle, tape hiss, a low-passed field recording.",
            "Warm upright bass, played sparsely."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Keys and crackle only."),
            SectionNote(section: "MAIN", bars: "16", whats: "Full loop. This is 80% of the track."),
            SectionNote(section: "BREAK", bars: "8", whats: "Drums out, keys and a sampled voice."),
            SectionNote(section: "OUTRO", bars: "8", whats: "Fade the drums, let the keys ring out.")
        ],
        makesItWork: [
            "Heavy swing plus off-grid timing. Nothing is quantised to 100%.",
            "7th and 9th chords instead of plain triads — that's the whole harmonic identity.",
            "Everything is low-passed. There is almost no energy above 10 kHz.",
            "Sparse. Four or five elements total, never more.",
            "Slight pitch instability (tape wow) on the keys. Imperfection is the aesthetic."
        ],
        mixNotes: [
            "Low-pass the whole mix around 12–14 kHz. It should sound like it's coming through a wall.",
            "Vinyl crackle at −30 dB under everything, ducked slightly by the kick.",
            "Gentle bus compression with a slow attack — you want it breathing, not tight.",
            "Keep the drums quieter than in any other genre here. The chords lead."
        ],
        mistakes: [
            "Bright, modern drum samples. They break the illusion instantly.",
            "Plain major and minor triads — it'll sound like a beginner sketch. Add the 7th.",
            "Perfect quantisation. Turn the swing up and drag hits off the grid by hand.",
            "Too many layers. If you're on element six, delete two."
        ],
        tint: Ink.claySoft
    )

    // MARK: AFROBEATS

    static let afrobeats = GenreTemplate(
        id: "afro", name: "AFROBEATS", tagline: "SYNCOPATED, PERCUSSIVE, BRIGHT",
        keyName: "D MINOR", scaleName: "MINOR", feel: "105 BPM, rolling, never straight.",
        beat: Beat(
            name: "AFROBEATS REFERENCE", bpm: 105, swing: 0.14, steps: 32,
            drums: [
                DrumTrack(.kick,      p("x-----x---x-----", "x-----x---x---x-")),
                DrumTrack(.rim,       p("----x-------x---", "----x-------x---")),
                DrumTrack(.closedHat, p("x-xxx-x-x-xxx-x-", "x-xxx-x-x-xxx-x-"), gain: 0.6),
                DrumTrack(.perc,      p("--x---x-x---x-x-", "--x---x-x---x-xx"), gain: 0.7),
                DrumTrack(.tom,       p("----------------", "------------x-x-"), gain: 0.6)
            ],
            melodies: [
                MelodyTrack("BASS", .bass, [
                    Note(38, 0, 5), Note(38, 6, 3), Note(45, 10, 5),
                    Note(38, 16, 5), Note(41, 22, 4), Note(43, 28, 4)
                ]),
                MelodyTrack("PLUCK", .pluck, [
                    Note(74, 2, 2), Note(77, 4, 2), Note(81, 6, 2), Note(77, 10, 2),
                    Note(74, 18, 2), Note(77, 20, 2), Note(81, 22, 4)
                ])
            ]
        ),
        palette: [
            "Kick — round and mid-weight, syncopated rather than on the beat.",
            "Rim or side-stick on 2 and 4 instead of a big snare.",
            "Shakers and congas doing most of the rhythmic work.",
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
            "Percussion is a lead instrument here, not a decoration.",
            "The bass moves melodically instead of just doubling the kick.",
            "The backbeat is a quiet rim, not a loud snare. The groove comes from the layers, not the impact.",
            "Everything is bright and open — this genre lives in the mids and highs."
        ],
        mixNotes: [
            "Pan percussion wide and keep it moving — this is the widest mix on this list.",
            "Bass sits higher than in trap. Don't bury it below 60 Hz.",
            "Short bright reverbs on the plucks. Long tails will kill the bounce.",
            "Keep the rim quiet and let the shakers carry the top end."
        ],
        mistakes: [
            "A four-on-the-floor kick. It flattens the whole feel.",
            "A big trap snare on 2 and 4 — too heavy for the groove.",
            "Root-note-only bass. The bass needs to sing here.",
            "Straight, unswung hats. Add 10–15% and it starts rolling."
        ],
        tint: Ink.orange
    )

    // MARK: DRUM & BASS

    static let dnb = GenreTemplate(
        id: "dnb", name: "DRUM & BASS", tagline: "BREAKBEAT AT 174, SUB UNDERNEATH",
        keyName: "A MINOR", scaleName: "MINOR", feel: "174 BPM with a half-time feel on top.",
        beat: Beat(
            name: "DNB REFERENCE", bpm: 174, swing: 0.06, steps: 32,
            drums: [
                DrumTrack(.kick,      p("x------------x--", "x-------x-------")),
                DrumTrack(.snare,     p("--------x-------", "--------x----x--")),
                DrumTrack(.closedHat, p("x-x-x-x-x-x-x-x-", "x-x-x-x-x-x-xxx-"), gain: 0.55),
                DrumTrack(.rim,       p("------.---.-----", "------.---.-----"), gain: 0.5),
                DrumTrack(.crash,     p("x---------------", "----------------"), gain: 0.4)
            ],
            melodies: [
                MelodyTrack("SUB", .sub, [
                    Note(33, 0, 14, vel: 1.0), Note(33, 16, 8, vel: 1.0), Note(36, 24, 7)
                ]),
                MelodyTrack("PAD", .keys, [
                    Note(69, 0, 15), Note(72, 0, 15), Note(76, 0, 15),
                    Note(69, 16, 15), Note(74, 16, 15), Note(77, 16, 15)
                ])
            ]
        ),
        palette: [
            "Two-step break: kick on 1, snare on the 3rd beat of the fast grid.",
            "Chopped breakbeat layered under the main kick and snare.",
            "Pure sine sub bass, one long note per bar or two.",
            "Reese bass (detuned saws) for the aggressive sections.",
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
            "Fast drums, slow bass. The sub moves at half or quarter the speed of the break.",
            "The two-step pattern leaves the second and fourth beats mostly empty — that space is the groove.",
            "Ghost snares and rides fill the gaps at low velocity, which is why it sounds busy but not cluttered.",
            "Sub bass is a single clean sine. Everything else lives above 150 Hz.",
            "Reverb tails on the snare give the impression of a huge room without wetting the drums themselves."
        ],
        mixNotes: [
            "Sub is mono, centred, and gets its own frequency range below 100 Hz — nothing else goes there.",
            "The snare should be the brightest and most forward element after the kick.",
            "High-pass every pad and atmosphere at 300 Hz minimum.",
            "Compress the drum bus hard, then blend it in parallel with the untouched drums."
        ],
        mistakes: [
            "Writing the bassline as fast as the drums. The sub should be slow and long.",
            "A trap-style 808 instead of a clean sine sub — the harmonics clash with the break.",
            "Too much reverb on the drums themselves. Send the snare only.",
            "Short sections. DnB drops run 32 bars minimum."
        ],
        tint: Ink.steel
    )

    // MARK: R&B / POP

    static let rnb = GenreTemplate(
        id: "rnb", name: "R&B / POP", tagline: "LAID BACK, SPACE FOR A VOCAL",
        keyName: "G MINOR", scaleName: "MINOR", feel: "92 BPM, relaxed, built around a voice that isn't there yet.",
        beat: Beat(
            name: "R&B REFERENCE", bpm: 92, swing: 0.16, steps: 32,
            drums: [
                DrumTrack(.kick,      p("x-------x---x---", "x-------x-------")),
                DrumTrack(.clap,      p("----x-------x---", "----x-------x---")),
                DrumTrack(.closedHat, p("x-o-x-o-x-o-x-o-", "x-o-x-o-x-o-x-oo"), gain: 0.6),
                DrumTrack(.snare,     p("------.-----.---", "------.-----.-.-"), gain: 0.45),
                DrumTrack(.perc,      p("----------------", "--------------x-"), gain: 0.4)
            ],
            melodies: [
                MelodyTrack("KEYS", .keys, [
                    // Gm7 -> Ebmaj7. Leave the middle open for a vocal.
                    Note(58, 0, 14), Note(62, 0, 14), Note(65, 0, 14), Note(69, 0, 14),
                    Note(63, 16, 14), Note(67, 16, 14), Note(70, 16, 14), Note(74, 16, 14)
                ]),
                MelodyTrack("BASS", .bass, [
                    Note(31, 0, 7, vel: 0.9), Note(31, 8, 3), Note(31, 12, 3),
                    Note(27, 16, 7, vel: 0.9), Note(27, 24, 5)
                ])
            ]
        ),
        palette: [
            "Kick — deep but not overpowering. This mix belongs to the vocal.",
            "Clap or finger snap on 2 and 4, often with a short reverb.",
            "Ghost snares at very low velocity for motion.",
            "Rhodes, electric piano or nylon guitar playing 7th chords.",
            "Round, warm bass with slides between notes.",
            "One high, sparse ear-candy element — a bell, a vocal chop, a pluck."
        ],
        structure: [
            SectionNote(section: "INTRO", bars: "8", whats: "Keys alone, maybe a filtered vocal."),
            SectionNote(section: "VERSE", bars: "16", whats: "Drums in, everything below the vocal range."),
            SectionNote(section: "PRE", bars: "8", whats: "Drop the kick, add a pad, build tension."),
            SectionNote(section: "HOOK", bars: "16", whats: "Full arrangement, ear candy on top."),
            SectionNote(section: "BRIDGE", bars: "8", whats: "Strip to keys and a vocal.")
        ],
        makesItWork: [
            "A hole in the middle of the arrangement, deliberately left for a voice.",
            "7th chords with wide voicings — nothing crowds the 200 Hz–2 kHz range where a vocal lives.",
            "Ghost snares and hat variation carry the movement instead of loud elements.",
            "Swing at 15%, and the clap sits slightly behind the grid.",
            "Restraint. Five elements, and one of them is the empty space."
        ],
        mixNotes: [
            "Carve 2–4 dB out of the keys and pads around 1–3 kHz so a vocal will sit in front later.",
            "Short plate reverb on the clap, longer hall on the keys, none on the bass.",
            "Bass and kick both centred, and sidechain the bass gently — this genre shouldn't pump audibly.",
            "Keep the whole mix a few dB quieter and more dynamic than a trap or house reference."
        ],
        mistakes: [
            "Filling the midrange with layers. If a vocal has to go on top, it will have nowhere to sit.",
            "A loud snappy snare — too aggressive. Use a clap or a soft snare.",
            "Straight triads. Add the 7th and it immediately sounds like R&B instead of a demo.",
            "Too much going on in the hook. Add one element, not four."
        ],
        tint: Ink.plum
    )

    static let all: [GenreTemplate] = [trap, boomBap, drill, house, lofi, afrobeats, dnb, rnb]

    static func template(_ id: String) -> GenreTemplate? {
        all.first { $0.id == id }
    }
}
