import Foundation

enum MixLessons {
    static let lessons: [Lesson] = [

        Lesson(
            id: "x1", title: "GAIN STAGING", kicker: "THE BORING STEP THAT FIXES EVERYTHING",
            minutes: 4,
            blocks: [
                .text("Gain staging means keeping the level sensible at every point in the chain. It's unglamorous and it prevents about half of all mix problems."),
                .steps([
                    "Set your loudest element (usually the kick) to peak around −8 to −6 dB on its channel meter.",
                    "Balance everything else against it using faders only. No plugins yet.",
                    "Check the master. It should peak around −6 dB with nothing on it and never touch 0.",
                    "If the master is clipping, pull ALL the faders down together rather than the master fader."
                ]),
                .callout(.rule, "Mix quietly",
                         "Loud always sounds better — that's psychoacoustics, not your mix. Turn your monitors or headphones down until it's slightly quieter than comfortable and make decisions there. Mixes made quiet translate; mixes made loud fall apart everywhere else."),
                .callout(.trap, "Turning things up to make them louder",
                         "When something's buried the instinct is to raise it. That raises everything's noise floor and eventually you're at the ceiling with a flat, squashed mix. Turn the competing element DOWN instead. Mixing is mostly subtraction."),
                .terms(["gainStaging", "fader", "headroom", "clipping", "peak", "lufs"])
            ]
        ),

        Lesson(
            id: "x2", title: "EQ", kicker: "GIVING EVERY SOUND ITS OWN LANE",
            minutes: 7,
            blocks: [
                .text("EQ turns frequencies up or down. There are only 20,000 Hz to go around and every instrument wants the good ones. EQ is how you decide who gets what."),
                .heading("THE FREQUENCY MAP"),
                .dial("WHAT LIVES WHERE", [
                    "20–60 Hz  Sub. Felt, not heard. 808s, sub bass. Cut it everywhere else.",
                    "60–120 Hz Weight and power. Kick body, bass fundamental.",
                    "120–300 Hz Warmth — and mud. The first place to cut when it sounds cloudy.",
                    "300–800 Hz Boxiness. Cut a little here and mixes open up.",
                    "1–4 kHz   Presence and attack. Where snares crack and vocals cut through.",
                    "4–8 kHz   Definition and bite. Too much = harsh and fatiguing.",
                    "8–16 kHz  Air and sparkle. Hats, cymbals, breath, sheen."
                ]),
                .heading("THE FOUR MOVES YOU'LL ACTUALLY MAKE"),
                .bullets([
                    "HIGH-PASS everything that isn't kick or bass. Roll off below 100–200 Hz on hats, synths, vocals, samples. This alone cleans up 80% of muddy mixes.",
                    "CUT, don't boost. Find the ugly frequency and take 3 dB out. Boosting adds energy you then have to make room for.",
                    "NARROW cuts, WIDE boosts. Surgical when removing a problem, gentle when adding character.",
                    "CARVE for a competing pair. If the bass and kick fight, cut the bass a little where the kick is strongest."
                ]),
                .callout(.shortcut, "The sweep-and-destroy",
                         "Boost a narrow band by +10 dB and sweep it across the spectrum until you find the frequency that makes you wince. That's the problem frequency. Now invert the boost into a cut of −3 to −5 dB and move on."),
                .callout(.trap, "EQ'ing in solo",
                         "A snare EQ'd to perfection alone will be wrong in the mix, because the job of EQ is to arrange sounds relative to each other. Solo only to identify a problem, then unsolo to fix it."),
                .dawPaths([
                    DAWLocation(daw: "ABLETON", path: "EQ Eight — audio effects"),
                    DAWLocation(daw: "FL STUDIO", path: "Fruity Parametric EQ 2 — mixer insert"),
                    DAWLocation(daw: "LOGIC", path: "Channel EQ — top of every channel strip")
                ]),
                .terms(["eq", "highPass", "lowPass", "bell", "shelf", "qFactor", "mud"])
            ]
        ),

        Lesson(
            id: "x3", title: "COMPRESSION", kicker: "THE ONE EVERYBODY PRETENDS TO UNDERSTAND",
            minutes: 7,
            blocks: [
                .text("A compressor turns things down when they get loud. That's the whole mechanism. Everything else is timing. The result is a smaller gap between the quietest and loudest parts — so you can raise the whole thing and it sounds bigger and more consistent."),
                .heading("THE FIVE CONTROLS"),
                .bullets([
                    "THRESHOLD — the level above which it starts working. Lower threshold = more compression.",
                    "RATIO — how hard it clamps. 2:1 gentle, 4:1 standard, 10:1+ is limiting.",
                    "ATTACK — how fast it reacts. FAST kills the punch, SLOW lets the transient through first.",
                    "RELEASE — how fast it lets go. Too fast = pumping, too slow = it never recovers.",
                    "MAKEUP GAIN — turn the now-quieter signal back up. This is the part that makes it sound 'bigger'."
                ]),
                .callout(.rule, "Slow attack = more punch",
                         "This is the counterintuitive one. A slow attack (10–30 ms) lets the initial hit through before clamping down, so the drum actually sounds punchier after compression. Fast attack (0–3 ms) squashes the transient and makes it sound flat and controlled. Choose based on whether you want punch or control."),
                .heading("STARTING POINTS"),
                .dial("SETTINGS BY SOURCE", [
                    "KICK / SNARE  4:1, attack 10–20 ms, release 80–150 ms, 3–5 dB reduction",
                    "BASS          4:1, attack 5–10 ms, release 100 ms, 4–6 dB — bass needs consistency",
                    "VOCAL         3:1, attack 5 ms, release 50–100 ms, 3–6 dB, ride it",
                    "DRUM BUS      2:1, attack 30 ms, release auto, 2–3 dB — glue, not squash",
                    "MASTER        1.5:1, 1–2 dB max, or don't"
                ]),
                .callout(.trap, "Compressing because you're supposed to",
                         "If you can't hear what the compressor is doing, take it off. An uncompressed mix that's balanced beats a compressed mix that isn't. Bypass every compressor you've added and see which ones you actually miss."),
                .text("Watch the GAIN REDUCTION meter, not the settings. 3–5 dB of reduction on the loud hits is a normal, useful amount. 15 dB is a creative effect you should be choosing on purpose."),
                .terms(["compressor", "threshold", "ratio", "attack", "release", "makeupGain", "limiter"])
            ]
        ),

        Lesson(
            id: "x4", title: "REVERB & DELAY", kicker: "PUTTING SOUNDS IN A SPACE",
            minutes: 6,
            blocks: [
                .text("Reverb is a room. Delay is an echo. Both push a sound backwards, away from the listener. Used well they create depth; used badly they turn a mix into soup."),
                .heading("REVERB CONTROLS"),
                .bullets([
                    "SIZE / DECAY — how big the room is and how long the tail rings. Short = tight room, long = cathedral.",
                    "PRE-DELAY — a gap before the reverb starts. 20–40 ms keeps the source clear and up front while still being in a big space. Massively underused.",
                    "DRY/WET or SEND LEVEL — how much of it you hear.",
                    "HIGH-CUT / DAMPING — roll the top off the reverb tail so it sits behind instead of hissing on top."
                ]),
                .callout(.rule, "Use a send, not an insert",
                         "Put ONE reverb on a send/aux/return channel and feed several tracks into it. They all end up in the same room, which is what makes a mix sound cohesive. Ten separate reverbs = ten different rooms = incoherent mush, and ten times the CPU."),
                .callout(.shortcut, "High-pass the reverb",
                         "Put an EQ before or after the reverb and cut everything below 300 Hz. Low frequencies in a reverb tail are the number one source of mud. Instant improvement on every mix, no exceptions."),
                .heading("DELAY"),
                .bullets([
                    "SYNC IT to the tempo — 1/4 for wide obvious echoes, 1/8 dotted for the classic rhythmic push, 1/16 for tightness.",
                    "FEEDBACK — how many repeats. Two or three is usually plenty.",
                    "PING-PONG bounces left to right and instantly widens something without touching the centre.",
                    "SLAPBACK — a single very short delay (60–120 ms), no feedback. Thickens vocals and snares without sounding like an effect."
                ]),
                .callout(.trap, "Reverb on the kick and bass",
                         "Almost never. Low frequencies plus a reverb tail equals a permanent low-frequency wash that eats all your headroom. Keep the low end dry and put the space on the mids and highs."),
                .terms(["reverb", "delay", "send", "return", "preDelay", "feedback", "wetDry"])
            ]
        ),

        Lesson(
            id: "x5", title: "SIDECHAIN", kicker: "MAKING ROOM FOR THE KICK",
            minutes: 5,
            blocks: [
                .text("Sidechain compression makes one sound duck out of the way whenever another one plays. In practice: the bass gets quieter for a fraction of a second every time the kick hits, so the kick always punches through."),
                .steps([
                    "Put a compressor on the BASS (the thing you want to duck).",
                    "Set its sidechain input to the KICK track.",
                    "Ratio 4:1, threshold low enough to get 3–6 dB of reduction on each kick.",
                    "Attack fast (0–5 ms) so it ducks immediately.",
                    "Release timed to the tempo — it should recover just before the next kick, not after."
                ]),
                .text("The release is where the sound comes from. Set it too long and you get the audible breathing pump of French house and EDM — which is a legitimate creative choice, and on a pad it can be the whole hook. Set it short and it's invisible: you just notice the kick sounds louder without being louder."),
                .callout(.shortcut, "Volume shaper instead",
                         "Ableton, FL and Logic all have envelope tools (LFOTool, ShaperBox, Volume Shaper, or just automation) that let you DRAW the ducking curve. Much more predictable than a compressor and you can make the pump exactly as musical as you want."),
                .callout(.rule, "It's not just for kick and bass",
                         "Sidechain the reverb send off the vocal so the space only blooms in the gaps. Sidechain the pads off the snare. Anywhere two things compete for the same moment, ducking one is cleaner than turning it down forever."),
                .dawPaths([
                    DAWLocation(daw: "ABLETON", path: "Compressor → Sidechain arrow (bottom left) → pick source"),
                    DAWLocation(daw: "FL STUDIO", path: "Right-click kick mixer track → Sidechain to this track → then Fruity Limiter/Compressor"),
                    DAWLocation(daw: "LOGIC", path: "Compressor → Side Chain menu (top right) → pick source track")
                ]),
                .terms(["sidechain", "ducking", "compressor", "pumping", "808"])
            ]
        ),

        Lesson(
            id: "x6", title: "PANNING & WIDTH", kicker: "THE LEFT-TO-RIGHT DIMENSION",
            minutes: 5,
            blocks: [
                .text("Depth comes from reverb and volume. Width comes from panning. Most beginner mixes are entirely in the centre, which is why they sound small and crowded even when every level is right."),
                .callout(.rule, "Low frequencies stay centred",
                         "Kick, bass, 808, sub — dead centre, mono, always. Panned low end wastes energy, sounds unstable on club systems, and can cause problems if the track ever gets pressed to vinyl."),
                .heading("WHAT GOES WHERE"),
                .bullets([
                    "CENTRE — kick, snare, bass, lead vocal. The spine of the track.",
                    "SLIGHTLY OFF (10–25%) — hats, rides, secondary percussion.",
                    "WIDE (40–70%) — doubled guitars, backing vocals, stereo pads, ear candy.",
                    "HARD (100%) — deliberate effects, call-and-response elements, one-off risers."
                ]),
                .callout(.shortcut, "Pan in pairs",
                         "Panning one thing left leaves the mix lopsided. Find something to put on the right at a similar level — a shaker against a tambourine, an answering synth against a guitar. The mix stays balanced and gets wider at the same time."),
                .heading("STEREO WIDENERS"),
                .text("Widening plugins work by making the left and right channels slightly different. Overdo it and the sound gets thin, phasey, and can partially disappear when a club system or a phone speaker sums it to mono."),
                .callout(.trap, "Not checking in mono",
                         "Bounce your mix to mono and listen. Phones, most Bluetooth speakers, and club subs are mono or near-mono. If something vanishes or gets weirdly thin, a widener or a phase problem is the cause. Every DAW has a mono button on the master — use it once per session."),
                .terms(["pan", "stereo", "mono", "width", "midSide", "phase"])
            ]
        ),

        Lesson(
            id: "x7", title: "BUSES & PARALLEL", kicker: "PROCESSING GROUPS, NOT TRACKS",
            minutes: 5,
            blocks: [
                .text("A BUS (group, submix, folder) is a channel that several tracks feed into. Route all your drums to a Drums bus and you get one fader for the whole kit, plus one place to process them as a unit."),
                .bullets([
                    "DRUM BUS — light compression (2:1, 2–3 dB) glues the kit into one instrument.",
                    "MUSIC BUS — everything melodic, so you can duck it all under a vocal at once.",
                    "FX RETURN — one reverb and one delay everything shares.",
                    "MASTER — the final stop. Keep it nearly empty while you're writing."
                ]),
                .heading("PARALLEL COMPRESSION"),
                .text("Send a copy of your drums to a second channel, compress that copy brutally (10:1, fast attack, 10+ dB of reduction), then blend it in underneath the original. You get the weight and density of heavy compression while the original keeps all its punch. It's the classic 'New York' drum sound and it works on almost any drum bus."),
                .callout(.shortcut, "The order on a channel strip",
                         "Corrective EQ → compression → tone-shaping EQ → saturation → reverb/delay sends. Not a law, but when you're unsure, this order gets you a predictable result: fix the problem, control the dynamics, then add character and space."),
                .callout(.trap, "Mastering your own unfinished mix",
                         "A limiter on the master while you're still writing hides every balance problem — everything sounds glued and loud so you stop hearing what's wrong. Leave the master empty until the arrangement is finished."),
                .terms(["bus", "send", "return", "parallel", "master", "limiter", "saturation"])
            ]
        )
    ]
}
