import Foundation

enum MelodyLessons {
    static let lessons: [Lesson] = [

        Lesson(
            id: "m1", title: "READING THE PIANO ROLL", kicker: "THE GRID, TURNED SIDEWAYS",
            minutes: 4,
            blocks: [
                .text("The piano roll is the drum grid with pitch added. Time still runs left to right in the same sixteen steps. Now vertical position means pitch: higher up the screen = higher note. The keyboard drawn down the left edge tells you which is which."),
                .bullets([
                    "LENGTH of the bar = how long the note is held.",
                    "POSITION left-to-right = when it starts.",
                    "POSITION top-to-bottom = which note.",
                    "COLOUR or height inside the bar = velocity, how hard it's played."
                ]),
                .text("Notes stacked vertically at the same time position are a CHORD. Notes one after another are a MELODY. That's the entire vocabulary."),
                .callout(.shortcut, "Middle C and the octave numbers",
                         "C3 or C4 depending on the DAW (Ableton calls it C3, Logic calls it C3, FL calls it C5 — nobody agrees). Don't fight it. Just know that going up 12 notes doubles the pitch and it's the same note again — that's an octave."),
                .lab(.pianoRoll, "Open the Piano Roll Lab. Tap anywhere to place a note, tap again to remove it."),
                .terms(["pianoRoll", "midi", "octave", "velocity"])
            ]
        ),

        Lesson(
            id: "m2", title: "KEY & SCALE", kicker: "HOW TO NEVER PLAY A WRONG NOTE",
            minutes: 6,
            blocks: [
                .text("A KEY is a home note plus a set of notes that sound right together. Pick a key and you've eliminated five of the twelve available notes — the five most likely to sound wrong. That's not a limitation, it's the single biggest shortcut in music."),
                .heading("PICK A KEY IN TEN SECONDS"),
                .steps([
                    "Choose MINOR unless you specifically want it to sound happy.",
                    "Choose any root note. Genuinely any. A minor and F minor are equally good.",
                    "Turn on scale highlighting in your piano roll so non-scale notes go grey.",
                    "Write only inside the highlighted notes."
                ]),
                .text("Every DAW has this. Ableton: Scale mode on the clip. FL: the piano roll's scale highlighting under the stamp menu. Logic: Scale Quantize in the region inspector. Once it's on, you cannot write a wrong note — every choice you make will be at least acceptable."),
                .callout(.rule, "The pentatonic escape hatch",
                         "Stuck writing a melody? Use the minor pentatonic — five notes instead of seven. It removes the two notes most likely to clash. Ancient trick, still undefeated: solo over almost anything using only those five and it works."),
                .heading("SCALES AND WHAT THEY FEEL LIKE"),
                .bullets([
                    "MINOR — dark, serious. Default for rap and most electronic music.",
                    "MAJOR — bright, resolved. Pop, house, afrobeats, gospel.",
                    "DORIAN — minor with one brighter note. Funk, house, neo-soul, lo-fi.",
                    "PHRYGIAN — the flat second makes it menacing. Drill and hard trap.",
                    "HARMONIC MINOR — one dramatic leap near the top. Cinematic, eastern."
                ]),
                .callout(.trap, "Writing in the wrong key as your sample",
                         "If you're sampling, the sample already has a key. Find its root note (play notes against it until one disappears into the sample), then write in that key. Otherwise everything you add will fight the sample and you won't know why."),
                .lab(.pianoRoll, "Turn on scale lock in the lab, pick a scale, and hear how you physically cannot place a bad note."),
                .terms(["key", "scale", "pentatonic", "transpose", "rootNote"])
            ]
        ),

        Lesson(
            id: "m3", title: "CHORDS", kicker: "THREE NOTES AT ONCE",
            minutes: 6,
            blocks: [
                .text("A chord is three or more notes played together. The shape is what matters, not the theory name. Count keys on the piano roll — including the black ones:"),
                .bullets([
                    "MINOR — root, +3, +7. The sad one.",
                    "MAJOR — root, +4, +7. The happy one.",
                    "MINOR 7 — root, +3, +7, +10. Smoother, jazzier. Lo-fi and R&B live here.",
                    "MAJOR 7 — root, +4, +7, +11. Dreamy. Beautiful alone, muddy under a vocal.",
                    "SUS2 / SUS4 — root, +2, +7 / root, +5, +7. No third, so no mood. Great for pads and tension.",
                    "POWER (5th) — root, +7. Two notes, no mood at all. Sits under literally anything."
                ]),
                .text("One difference between the minor and the major chord: a single note moving up one key. That's the whole distance between sad and happy."),
                .pattern("Four minor chords, one bar each. Nothing else.", DemoBeats.chordsMinor),
                .heading("INVERSIONS AND VOICING"),
                .text("An INVERSION is the same chord with the notes stacked in a different order — take the lowest note and move it up an octave. It sounds like the same chord but sits in a different place. Use inversions so that consecutive chords don't jump around the screen; keep the notes close together and the progression sounds smooth instead of blocky."),
                .callout(.shortcut, "Move the least",
                         "Between two chords, keep any shared notes exactly where they are and move the rest by the smallest possible distance. This is called voice leading and it's the difference between chords that flow and chords that clunk."),
                .callout(.trap, "Chords too low",
                         "Piling a four-note chord below middle C turns it into mud, because the low frequencies of each note overlap. Keep chords above C3, and if you want low weight, play a single bass note underneath instead."),
                .terms(["chord", "inversion", "voicing", "triad", "voiceLeading"])
            ]
        ),

        Lesson(
            id: "m4", title: "PROGRESSIONS THAT WORK", kicker: "FOUR CHORDS, INFINITE SONGS",
            minutes: 5,
            blocks: [
                .text("A progression is an order of chords that loops. Almost all modern music loops 4 chords over 4 or 8 bars. Here are the ones that carry entire genres — written as scale degrees, so they work from any root note."),
                .bullets([
                    "i – VI – III – VII — the most-used minor loop in modern music.",
                    "i – VII – VI – VII — circular and unresolved. Trap and drill.",
                    "i – iv – i – V — old, dramatic, the V pulls hard back home.",
                    "I – V – vi – IV — the pop progression. Works every time, which is the problem.",
                    "ii – V – I — jazz motion. Instant sophistication in lo-fi and neo-soul.",
                    "i – III – VII – VI — anthemic minor. Builds without ever getting happy."
                ]),
                .text("Lowercase = minor chord, uppercase = major chord. In a minor key, degrees 1, 4 and 5 are minor and 3, 6 and 7 are major. You do not need to memorise that — turn on scale lock, build a triad on each degree, and the DAW gives you the right chord automatically."),
                .callout(.rule, "Change chord on the bar, not inside it",
                         "One chord per bar, or one every two bars. Changing chords mid-bar is a deliberate advanced move; doing it by accident makes a loop feel unstable and no amount of mixing fixes it."),
                .heading("MAKING FOUR CHORDS INTERESTING"),
                .bullets([
                    "Hold them long and let a pad sustain — space, patience, atmosphere.",
                    "Chop them into rhythmic stabs following the drum pattern — energy.",
                    "Arpeggiate: play the notes one at a time instead of together — movement.",
                    "Keep the top note the same across all four chords — the ear locks onto it."
                ]),
                .lab(.pianoRoll, "Build i–VI–III–VII in the lab using the chord stamp, then invert each chord to keep them close together."),
                .terms(["progression", "chord", "degree", "arpeggio", "pad"])
            ]
        ),

        Lesson(
            id: "m5", title: "BASSLINES", kicker: "THE GLUE BETWEEN DRUMS AND CHORDS",
            minutes: 5,
            blocks: [
                .text("The bass is the only element that belongs to both the rhythm section and the harmony. It's why a beat with a good bassline sounds finished and one without sounds like a demo."),
                .heading("THE THREE LEVELS"),
                .steps([
                    "LEVEL 1 — one long root note per chord. Boring, correct, always works. Start here.",
                    "LEVEL 2 — root note following the kick drum rhythm. Now the low end is locked and the beat has weight.",
                    "LEVEL 3 — root plus movement: passing notes between chord changes, octave jumps, slides."
                ]),
                .pattern("Bass following the kick, root notes only. Level 2.", DemoBeats.bassWithKick),
                .callout(.rule, "Bass follows the kick, not the melody",
                         "If your bass and kick hit at different times, the low end sounds cluttered and neither one lands. Line the bass notes up with the kick pattern first, then add extra notes only in the gaps."),
                .heading("PICKING THE OCTAVE"),
                .text("Most basslines live between C1 and C3. Below C1 you get rumble you can feel but not hear on phones. Above C3 it starts sounding like a low melody instead of a bass. If your bass disappears on laptop speakers, it's too low — add a layer an octave up rather than turning the whole thing up."),
                .callout(.trap, "808s are a bass AND a kick",
                         "In trap, the 808 is a pitched kick drum. If you also have a separate kick sample hitting at the same time, they cancel each other out and the low end goes flabby. Either use the 808 as your kick, or use a short punchy kick that ducks out of the 808's way (sidechain — see the mixing stage)."),
                .terms(["bass", "808", "sidechain", "rootNote", "sub"])
            ]
        ),

        Lesson(
            id: "m6", title: "WRITING A MELODY", kicker: "THE PART PEOPLE REMEMBER",
            minutes: 6,
            blocks: [
                .text("A melody is a rhythm that happens to have pitches. If you hum the rhythm alone and it's memorable, the melody will be memorable. If the rhythm is a boring stream of even notes, no choice of pitch saves it."),
                .heading("FIVE RULES THAT ALWAYS WORK"),
                .bullets([
                    "SHORT. Four to eight notes. If you can't hum it back after hearing it twice, it's too long.",
                    "REPEAT IT. Say the same phrase twice, then change the ending. Statement, statement, answer.",
                    "LEAVE GAPS. Silence between phrases is what makes them memorable. Cram the bar and nothing stands out.",
                    "MOSTLY STEPS. Move to the next note in the scale most of the time, and save big jumps for one dramatic moment.",
                    "LAND ON A CHORD TONE. End your phrase on a note that's in the current chord and it sounds resolved."
                ]),
                .pattern("Four notes, repeated with a changed ending. That's a hook.", DemoBeats.melodyHook),
                .callout(.shortcut, "Steal your own rhythm",
                         "Take the rhythm of your hi-hat pattern or a vocal phrase you like, and write your melody on exactly that rhythm with different pitches. Rhythm is the hard part and you've already solved it once."),
                .heading("CALL AND RESPONSE"),
                .text("Put your melody in bars 1–2 and leave bars 3–4 nearly empty, or answer it with a different, shorter phrase. Music that talks constantly is exhausting. The gap is where the listener's brain finishes the phrase for you, and that's why hooks get stuck in people's heads."),
                .callout(.trap, "Melody in the same octave as the chords",
                         "If your lead sits in the same range as the chords, both go muddy and neither is memorable. Put the melody at least an octave above the chords, or thin the chords out underneath it."),
                .lab(.pianoRoll, "Write four notes in bars 1–2. Copy to bars 3–4 and change only the last note."),
                .terms(["melody", "hook", "motif", "callResponse", "arpeggio"])
            ]
        )
    ]
}
