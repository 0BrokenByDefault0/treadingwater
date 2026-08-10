import Foundation

enum DrumLessons {
    static let lessons: [Lesson] = [

        Lesson(
            id: "d1", title: "ANATOMY OF A KIT", kicker: "WHAT EACH PIECE IS FOR",
            minutes: 4,
            blocks: [
                .text("A drum pattern isn't nine sounds competing. It's three jobs: the PULSE (kick), the ANSWER (snare or clap), and the CLOCK (hats). Everything else is decoration on top of those three."),
                .bullets([
                    "KICK — the floor. Owns everything below 100 Hz. Sets where the bar starts.",
                    "SNARE / CLAP — the backbeat. Almost always on beats 2 and 4. This is what makes people nod.",
                    "CLOSED HAT — the clock. Tells the listener how fast the music is.",
                    "OPEN HAT — release and lift. One well-placed open hat beats sixteen closed ones.",
                    "PERC / RIM / SHAKER — personality. The layer that makes a generic pattern sound like yours.",
                    "CRASH — a signpost. Marks the first beat of a new section, nothing else."
                ]),
                .callout(.rule, "Kick and snare should never hit at the same time",
                         "Not never-ever — but if your pattern feels muddy and undefined, check whether the kick and snare are landing on the same step. They're fighting for the same moment. Move one by a sixteenth and it snaps into focus."),
                .pattern("The three jobs, nothing else. This is a complete, working drum pattern.", DemoBeats.threeJobs),
                .terms(["kick", "snare", "hihat", "oneShot", "sampler"])
            ]
        ),

        Lesson(
            id: "d2", title: "THE BACKBONE", kicker: "KICK AND SNARE PLACEMENT",
            minutes: 6,
            blocks: [
                .text("Steps 1, 5, 9 and 13 are the four beats of the bar. The snare goes on 5 and 13 — that's beats 2 and 4, the backbeat, and it is true in almost every genre on earth."),
                .text("The kick is where the genre lives. Same snare, different kick, completely different music:"),
                .pattern("FOUR ON THE FLOOR — kick on every beat. House, disco, techno.", DemoBeats.fourOnFloor),
                .pattern("BOOM BAP — kick on 1 and the 'and' of 3. Space between the hits.", DemoBeats.boomBapSkeleton),
                .pattern("TRAP — snare on 9 only (half-time), kick roaming underneath.", DemoBeats.trapSkeleton),
                .callout(.rule, "Half-time is one snare, not two",
                         "Trap, drill and dubstep put the snare on step 9 only — once per bar instead of twice. That single change is what makes 140 BPM feel slow and heavy. If your trap beat feels rushed, you have two snares where you need one."),
                .heading("WHERE TO PUT THE SECOND KICK"),
                .text("Once you have a kick on step 1, the second kick decides the feel. Try these one at a time and listen:"),
                .bullets([
                    "Step 11 (the 'and' of 3) — classic hip hop lean. Slightly late, very heavy.",
                    "Step 8 (the 'uh' of 2) — pushes into the snare. Modern, urgent.",
                    "Step 4 — a fast double off the top. Trap and drill.",
                    "Step 9 — under the beat 3. Straight, driving, pop."
                ]),
                .callout(.trap, "Too many kicks",
                         "A kick on eight of the sixteen steps doesn't sound powerful, it sounds like a lawnmower. The kick is loud and low; every extra one eats the space that made the last one hit. Start with two per bar and only add a third if the bar feels empty."),
                .lab(.drums, "Build the boom bap skeleton, then move the second kick one step at a time and listen to what changes."),
                .terms(["backbeat", "halfTime", "fourOnTheFloor", "kick"])
            ]
        ),

        Lesson(
            id: "d3", title: "HATS & SUBDIVISION", kicker: "THE LAYER THAT SETS THE SPEED",
            minutes: 5,
            blocks: [
                .text("Hats don't carry the groove — they carry the *tempo perception*. The same kick and snare with eighth-note hats feels half as fast as with sixteenth-note hats."),
                .bullets([
                    "QUARTER hats (steps 1,5,9,13) — sparse, heavy, old-school.",
                    "EIGHTH hats (every other step) — the safe default. Never wrong.",
                    "SIXTEENTH hats (every step) — busy and driving. Trap, drill, dance.",
                    "OFF-BEAT only (steps 3,7,11,15) — the house / disco lift."
                ]),
                .pattern("Same kick and snare, sixteenth hats. Feels fast.", DemoBeats.hatsSixteenth),
                .pattern("Same kick and snare, off-beat hats only. Feels like a different genre.", DemoBeats.hatsOffbeat),
                .heading("HAT ROLLS"),
                .text("A roll is just hats at a faster subdivision for a short burst — 32nds or triplets over one or two steps. In trap they're the signature. Three rules that keep them from sounding cheap:"),
                .bullets([
                    "Put them at the END of a bar or the end of a 2-bar phrase, leading into the next section.",
                    "Ramp the velocity up across the roll so it accelerates into the landing.",
                    "One roll per four bars. Two is a stylistic choice. Four is a mess."
                ]),
                .callout(.shortcut, "The one open hat trick",
                         "Take a boring sixteenth hat pattern and replace ONE closed hat — usually step 15, right before the bar loops — with an open hat. The bar suddenly breathes and pushes into the next one. This is the single highest-value edit in drum programming."),
                .lab(.drums, "Load sixteenth hats, then swap step 15 to an open hat and A/B it."),
                .terms(["hihat", "openHat", "roll", "subdivision"])
            ]
        ),

        Lesson(
            id: "d4", title: "SWING & GROOVE", kicker: "WHY YOUR PATTERN SOUNDS STIFF",
            minutes: 5,
            blocks: [
                .text("A perfectly quantized pattern is mathematically correct and emotionally dead. SWING delays every second sixteenth note by a small amount, which is exactly what a human drummer does without thinking about it."),
                .dial("SWING AMOUNT", [
                    "0%    Machine-straight. Techno, drill, hard trap.",
                    "8–15%  A subtle lean. Almost any modern beat benefits.",
                    "16–25% Obvious groove. House, garage, neo-soul.",
                    "26–40% Heavy shuffle. Boom bap, J Dilla territory, lo-fi.",
                    "50%+   Full triplet feel. Blues shuffle, some UK funky."
                ]),
                .text("Swing is a global setting in most DAWs, but the good move is applying it to the hats and perc only, leaving the kick and snare dead on the grid. The contrast between a straight backbeat and swung hats is where 'pocket' actually comes from."),
                .callout(.shortcut, "Groove templates",
                         "Ableton's Groove Pool, FL's Shuffle knob, and Logic's Groove Templates all do the same job: apply a real drummer's timing and velocity fingerprint to your programmed pattern. Drag the MPC-16 or MPC-swing groove onto your hats and it's instantly less robotic."),
                .heading("NUDGE, DON'T SWING"),
                .text("The manual version: turn snap off and drag individual hits a few milliseconds early or late. Late feels relaxed and heavy. Early feels urgent and pushy."),
                .bullets([
                    "Snare 10–20 ms LATE — laid back, lazy, soulful.",
                    "Hats slightly EARLY — nervous energy, pushes the tempo.",
                    "Kick dead on the grid — always. It's the reference everything else leans against."
                ]),
                .callout(.trap, "Swinging everything",
                         "If you apply 25% swing globally, your kick moves too, and the whole beat sounds like it's falling over. Swing the fast stuff, leave the slow stuff alone."),
                .terms(["swing", "groove", "quantize", "pocket"])
            ]
        ),

        Lesson(
            id: "d5", title: "VELOCITY & GHOST NOTES", kicker: "THE DIFFERENCE BETWEEN FLAT AND ALIVE",
            minutes: 5,
            blocks: [
                .text("VELOCITY is how hard a note is hit — 0 to 127 in MIDI, usually a bar height in the piano roll. Every hit at 127 is why programmed drums sound programmed."),
                .heading("HOW A REAL DRUMMER PLAYS HATS"),
                .text("Loud on the beats, quiet on the in-between. On a sixteenth hat pattern, try 100 on steps 1/5/9/13, 70 on the eighths, and 45 on everything else. Play it. It's the same notes and it sounds like a person."),
                .pattern("Sixteenth hats, all at full velocity. Notice how it drills into your head.", DemoBeats.velocityFlat),
                .pattern("Identical pattern with accents and ghost notes. Same notes, alive.", DemoBeats.velocityShaped),
                .callout(.rule, "Accent the downbeats, ghost the rest",
                         "This one habit — loud on 1, 2, 3, 4 and quiet in between — fixes more stiff drum patterns than any plugin will."),
                .heading("GHOST NOTES"),
                .text("A ghost note is a hit at very low velocity (20–45), usually a snare, tucked between the real hits. You barely hear it as a note; you hear it as texture and forward motion. Boom bap and funk live on ghost snares. Put them on the 'e' and 'uh' either side of the backbeat and drop them to 30% volume."),
                .callout(.shortcut, "Humanize / randomize",
                         "Most DAWs have a velocity randomize function. ±10 to ±15 on a hat pattern gets you 80% of the way to a human feel in one click. More than ±20 and it starts sounding like a mistake."),
                .lab(.drums, "Hold a step to open its velocity. Build a hat line with three levels: accents, mid, ghosts."),
                .terms(["velocity", "ghostNote", "humanize", "accent"])
            ]
        ),

        Lesson(
            id: "d6", title: "FILLS & VARIATION", kicker: "STOPPING A LOOP GETTING BORING",
            minutes: 5,
            blocks: [
                .text("A four-bar loop that repeats identically for three minutes is not a song, it's a test tone. Variation is what keeps attention, and it works on a schedule: change something small every 2 bars, something noticeable every 4, and something structural every 8 or 16."),
                .bullets([
                    "EVERY 2 BARS — move one hi-hat, add a ghost snare, drop one kick.",
                    "EVERY 4 BARS — a fill in the last half-bar. Tom run, hat roll, snare double.",
                    "EVERY 8 BARS — add or remove a whole layer. This is what an arrangement is.",
                    "EVERY 16 BARS — a section change: new chords, new energy, a crash on the downbeat."
                ]),
                .heading("HOW TO BUILD A FILL"),
                .steps([
                    "Duplicate your 1-bar loop to make bar 4 a separate editable copy.",
                    "Delete the drums from the last 4 steps (the final beat).",
                    "Fill that space: a snare on every 16th, or three toms descending, or a hat roll.",
                    "Ramp the velocity upward through the fill so it accelerates.",
                    "Land a crash on step 1 of the next bar so the fill has somewhere to go."
                ]),
                .callout(.rule, "A fill has to LAND somewhere",
                         "A fill that leads into an identical bar is just noise. It should mark a change: a new section, a layer arriving, a drop. If nothing changes on the other side, cut the fill."),
                .callout(.shortcut, "Subtraction beats addition",
                         "The most effective variation in modern production is removing something, not adding. Mute the hats for two bars before a drop. Cut everything but the kick for one bar. Silence is the loudest tool you have."),
                .terms(["fill", "arrangement", "drop", "automation"])
            ]
        )
    ]
}
