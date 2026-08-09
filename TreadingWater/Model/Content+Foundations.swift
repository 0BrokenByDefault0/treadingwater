import Foundation

enum Foundations {
    static let lessons: [Lesson] = [

        Lesson(
            id: "f1", title: "WHAT A DAW ACTUALLY IS", kicker: "THE WHOLE PICTURE IN ONE PAGE",
            minutes: 4,
            blocks: [
                .text("Every DAW — Ableton, FL Studio, Logic, Reaper, Pro Tools — is the same four things wearing different paint. Once you see the four, an unfamiliar DAW stops being scary."),
                .bullets([
                    "A CLOCK. Tempo, the grid, and the playhead. Everything else hangs off it.",
                    "TRACKS. Parallel lanes of sound. One instrument or one sample per lane.",
                    "AN EDITOR. Where you draw notes (piano roll) or place audio (arrangement).",
                    "A MIXER. Where each lane gets a volume, a position in the stereo field, and effects."
                ]),
                .text("That's it. Everything you'll ever click lives inside one of those four boxes. When you're lost in a tutorial, ask which box the person is in — it narrows the whole screen down instantly."),
                .callout(.rule, "The order never changes",
                         "Clock → tracks → editor → mixer. You set the tempo, you make lanes, you put notes in them, then you balance them. Producers who mix before they arrange spend all night polishing something that isn't finished."),
                .heading("THE ONE SCREEN DIFFERENCE"),
                .text("Ableton has two views of the same project: SESSION (a grid of loops you trigger by hand, for jamming) and ARRANGEMENT (a left-to-right timeline, for building a finished song). FL Studio splits the same idea into the CHANNEL RACK / PIANO ROLL for making patterns and the PLAYLIST for arranging them. Logic and Pro Tools only give you the timeline."),
                .dawPaths([
                    DAWLocation(daw: "ABLETON", path: "Tab key toggles Session ↔ Arrangement"),
                    DAWLocation(daw: "FL STUDIO", path: "Pattern/Song switch, top-left of the transport"),
                    DAWLocation(daw: "LOGIC", path: "Timeline only — loops live in the Live Loops grid")
                ]),
                .terms(["daw", "arrangement", "mixer", "track"])
            ]
        ),

        Lesson(
            id: "f2", title: "TEMPO & THE TRANSPORT", kicker: "THE CLOCK EVERYTHING HANGS OFF",
            minutes: 4,
            blocks: [
                .text("BPM — beats per minute — is how fast the grid moves. It's the first decision in a project and the one people agonise over least and regret most."),
                .dial("PICK A TEMPO", [
                    "60–75  Lo-fi, slow soul, half-time ballads",
                    "80–95  Boom bap, R&B, most modern rap",
                    "100–115  Afrobeats, reggaeton, pop",
                    "120–128  House, disco, dance pop",
                    "130–145  Drill (feels like 65), techno, garage",
                    "140–150  Trap (feels like 70), dubstep",
                    "170–175  Drum & bass, jungle"
                ]),
                .callout(.rule, "Trap and drill are written at double speed",
                         "A trap beat at 140 BPM feels like 70. The hi-hats subdivide fast, the kick and snare stay slow. If your trap beat feels frantic, you didn't pick the wrong tempo — you're putting the snare on every 2 and 4 of the fast grid instead of every other one."),
                .heading("THE TRANSPORT"),
                .bullets([
                    "PLAY / STOP — spacebar in every DAW ever made.",
                    "LOOP (or CYCLE) — repeats a chosen region forever. This is where you'll live while making a beat.",
                    "RECORD — arms the DAW to capture what you play. Not needed for drawing notes with the mouse.",
                    "METRONOME (or CLICK) — a tick on every beat. Turn it on when recording, off when auditioning."
                ]),
                .text("Set your loop to bars 1–4 and never leave it while you're building. Four bars is enough to hear whether an idea works and short enough that you notice when it gets boring."),
                .callout(.trap, "Making a beat with the loop off",
                         "You end up hitting play, listening to eight seconds, stopping, editing, hitting play again. Loop the four bars, leave it running, and edit while it plays. Every good producer edits in motion."),
                .terms(["bpm", "loop", "transport", "metronome", "timeSignature"])
            ]
        ),

        Lesson(
            id: "f3", title: "THE GRID", kicker: "BARS, BEATS AND SIXTEENTHS",
            minutes: 5,
            blocks: [
                .text("Music is counted in BARS. One bar = 4 BEATS (that's the 4/4 that ~95% of popular music uses). Each beat splits into 2 eighths, or 4 sixteenths. Nearly every drum grid you'll see is 16 boxes long: one bar of sixteenth notes."),
                .text("Count out loud: ONE-ee-and-uh TWO-ee-and-uh THREE-ee-and-uh FOUR-ee-and-uh. That's sixteen syllables and sixteen boxes. Step 1 is 'ONE'. Step 5 is 'TWO'. Step 9 is 'THREE'. Step 13 is 'FOUR'."),
                .pattern("The grid, spelled out. Kick on every beat, hat on every sixteenth.", DemoBeats.gridCounting),
                .heading("SNAP AND QUANTIZE"),
                .text("SNAP forces anything you draw onto the nearest grid line as you draw it. QUANTIZE takes something already recorded and drags it onto the grid after the fact. Same idea, different moment."),
                .bullets([
                    "1/4 snap — you can only place things on beats. Good for chords.",
                    "1/8 snap — off-beats become available. Good for basslines.",
                    "1/16 snap — the standard for drums. Default here.",
                    "1/32 or triplets — hi-hat rolls and fills.",
                    "Snap OFF — for nudging something slightly early or late on purpose."
                ]),
                .callout(.shortcut, "Quantize strength",
                         "Most DAWs let you quantize to 50% instead of 100%. It pulls a sloppy performance halfway to the grid — tightened up but still human. This one setting is the difference between 'live drummer' and 'drum machine'."),
                .dawPaths([
                    DAWLocation(daw: "ABLETON", path: "Cmd+U quantize · grid menu on right-click in a clip"),
                    DAWLocation(daw: "FL STUDIO", path: "Piano roll → Quantize (Alt+Q) · snap dropdown in toolbar"),
                    DAWLocation(daw: "LOGIC", path: "Region inspector → Quantize · Q-Strength below it")
                ]),
                .terms(["bar", "quantize", "snap", "swing", "timeSignature"])
            ]
        ),

        Lesson(
            id: "f4", title: "TRACKS, CLIPS & CHANNELS", kicker: "HOW A PROJECT IS ORGANISED",
            minutes: 4,
            blocks: [
                .text("A TRACK is a lane. It holds one instrument or one sound source, and it has exactly one channel in the mixer. A CLIP (region, pattern, item — same thing) is a block of content sitting on that lane."),
                .compare("MIDI TRACK", "Holds notes, not sound. The notes tell an instrument what to play. You can change the instrument afterwards and the part still plays.",
                         "AUDIO TRACK", "Holds an actual recording or sample. Fixed pitch and timing unless you stretch it. What you hear is what's there."),
                .text("This distinction causes more beginner confusion than anything else. If you drag a drum loop in and it won't let you edit the individual hits, that's audio. If you're drawing coloured bars in a grid, that's MIDI."),
                .heading("ONE SOUND, ONE TRACK"),
                .text("Put your kick on its own track, your snare on its own track, your hats on their own track. It feels like more work up front. It means that four hours later, when the kick is too loud, you can turn down the kick instead of re-recording the entire drum pattern."),
                .callout(.trap, "Everything on one drum track",
                         "FL Studio's Channel Rack encourages routing all drums to one mixer insert. Do the opposite: give the kick, snare and hats their own inserts from the start. You'll thank yourself at mix time."),
                .bullets([
                    "NAME your tracks. 'Audio 4' tells you nothing in a week.",
                    "COLOUR your tracks by group — drums one colour, melodic another.",
                    "GROUP them (bus / folder / submix) once you have more than six."
                ]),
                .terms(["midi", "audioTrack", "clip", "bus", "channelStrip"])
            ]
        ),

        Lesson(
            id: "f5", title: "YOUR FIRST FOUR BARS", kicker: "THE ACTUAL WORKFLOW",
            minutes: 6,
            blocks: [
                .text("Here is the order that gets a beat finished. Not the only order — but the one that stops you staring at an empty project."),
                .steps([
                    "Set the tempo. Pick from the ranges in lesson 02 and move on. You can change it later.",
                    "Loop bars 1–4. Turn the loop on and leave it on.",
                    "Kick and snare only. Get the skeleton to nod your head before anything else exists.",
                    "Add hats. Now it has speed and it feels like music.",
                    "Add a bass note on the root. One note, following the kick. The beat suddenly has weight.",
                    "Add the chords or the sample. This is where the mood arrives.",
                    "Add one melodic hook on top. Short. Four to eight notes.",
                    "Only now: balance the volumes so nothing buries anything else."
                ]),
                .callout(.rule, "Drums before melody, almost always",
                         "A great melody over a limp drum pattern sounds amateur. A simple melody over a great drum pattern sounds professional. If you start with a sample or a chord loop, that's fine — but get the drums right before you add anything else on top."),
                .heading("THE FOUR-BAR TEST"),
                .text("If you can listen to your four-bar loop ten times in a row without wanting to skip, you have a beat. If you get bored on loop three, adding more layers won't fix it — something in the drums or the chords is wrong. Go back and change one thing, not five."),
                .lab(.drums, "Open the Drum Lab and build the skeleton from step 3. Kick, snare, hats, in that order."),
                .callout(.shortcut, "Steal the skeleton",
                         "Open a genre template, copy the kick and snare placement exactly, then change the sounds and one or two hits. That's not cheating, that's how everybody learns. Originality comes from the sounds and the melody, not from inventing a new backbeat."),
                .terms(["loop", "arrangement", "gainStaging"])
            ]
        )
    ]
}
