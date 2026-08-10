import Foundation

enum SoundLessons {
    static let lessons: [Lesson] = [

        Lesson(
            id: "s1", title: "SOUND SELECTION", kicker: "THE PART NOBODY TELLS YOU IS 80% OF IT",
            minutes: 5,
            blocks: [
                .text("The same drum pattern with a great kick and a bad kick are two different beats. Beginners assume professionals have secret processing. Mostly they just picked a better sample and then didn't need the processing."),
                .callout(.rule, "Fix it in the choice, not in the mix",
                         "If a sound needs four plugins to sit right, it's the wrong sound. Spend two minutes auditioning ten alternatives instead of twenty minutes EQ'ing the first one. This is the single biggest speed difference between beginners and professionals."),
                .heading("WHAT MAKES A KICK GOOD"),
                .bullets([
                    "It has both a CLICK (2–5 kHz, so it cuts through on phones) and a BODY (50–80 Hz, so it's felt).",
                    "It's the right LENGTH for the tempo — a long boomy kick at 140 BPM smears into the next hit.",
                    "It's TUNED to your key, or at least not fighting it. A kick with a strong pitch in the wrong key sounds subtly out of tune with everything."
                ]),
                .heading("WHAT MAKES A SNARE GOOD"),
                .bullets([
                    "It cuts through without being harsh. Test it against the hats, not in solo.",
                    "The tail length matches the tempo — long snares for slow music, tight ones for fast.",
                    "It sits somewhere the kick isn't. If both are boomy, one has to go."
                ]),
                .callout(.trap, "Auditioning in solo",
                         "A sound that's beautiful on its own often disappears in a mix, and a sound that's ugly alone often cuts through perfectly. Always audition new samples with the rest of the beat playing."),
                .callout(.shortcut, "Build a folder of 10",
                         "Pick your ten favourite kicks, ten snares, ten hats. Use only those for a month. You'll stop scrolling through 4,000 samples and start finishing beats — and you'll learn exactly what each one does."),
                .terms(["oneShot", "sample", "sampleLibrary", "tuning", "layering"])
            ]
        ),

        Lesson(
            id: "s2", title: "SYNTHS VS SAMPLES", kicker: "WHEN TO USE WHICH",
            minutes: 5,
            blocks: [
                .compare("SAMPLES", "Recordings. Instant character and realism, zero flexibility. A sampled piano is a real piano — but only at the pitches and velocities that got recorded.",
                         "SYNTHS", "Sound generated from scratch. Infinitely tweakable, needs you to make choices. A synth bass can be exactly the shape your track needs, if you know which knob does what."),
                .text("Practical answer: samples for drums and anything acoustic, synths for bass, pads and leads. Nearly every modern producer works that way."),
                .heading("THE FIVE SYNTH CONTROLS THAT MATTER"),
                .bullets([
                    "OSCILLATOR / WAVEFORM — the raw tone. Saw is bright and full, square is hollow and retro, sine is pure and bassy, triangle is soft.",
                    "FILTER CUTOFF — a brightness knob. Turn it down and the sound gets darker and further away. This is the knob you'll automate most.",
                    "RESONANCE — emphasises the frequencies right at the cutoff point. A little adds character, a lot whistles.",
                    "ENVELOPE (ADSR) — the shape over time. Attack = how fast it arrives, Decay/Sustain = how it holds, Release = how it fades after you let go.",
                    "LFO — a slow automatic wobble applied to something else. On pitch it's vibrato, on volume it's tremolo, on the filter it's the classic wobble."
                ]),
                .callout(.shortcut, "Start from a preset, change three things",
                         "Nobody builds sounds from an init patch under deadline. Find a preset that's 70% right, then change the filter cutoff, the attack and the release. Those three get you the rest of the way most of the time."),
                .dial("ADSR IN PLAIN ENGLISH", [
                    "ATTACK 0ms  Percussive, immediate. Bass, plucks, stabs.",
                    "ATTACK 200ms+  Swells in. Pads, risers, ambient.",
                    "RELEASE short  Tight, controlled, leaves space for drums.",
                    "RELEASE long  Blurry and atmospheric, eats the mix if overdone."
                ]),
                .terms(["synth", "oscillator", "filter", "adsr", "lfo", "preset"])
            ]
        ),

        Lesson(
            id: "s3", title: "LAYERING", kicker: "TWO SOUNDS, ONE INSTRUMENT",
            minutes: 4,
            blocks: [
                .text("Layering means stacking two or more sounds so they're heard as one. It's how you get a kick with both weight and click, or a snare that's both tight and huge."),
                .heading("THE RULE OF LAYERING"),
                .text("Each layer should provide something the other doesn't. If both layers are doing the same job, you're not layering, you're just making it louder and muddier."),
                .bullets([
                    "KICK — a sub layer for weight (low), a click layer for definition (high). EQ the low out of the click layer.",
                    "SNARE — a body layer for the tone, a clap or noise layer for the crack.",
                    "BASS — a clean sine sub below 100 Hz, a distorted layer above it that carries on small speakers.",
                    "LEAD — the main synth plus a quiet octave-up layer for sparkle."
                ]),
                .callout(.rule, "Phase check every kick layer",
                         "Two kicks stacked can partially cancel and get quieter instead of bigger. If your layered kick sounds weaker than either sample alone, flip the polarity (the Ø button) on one of them, or nudge one a millisecond. If it suddenly gets huge, that was it."),
                .callout(.trap, "Layering because more is better",
                         "Three snares stacked isn't three times as good, it's a smear with three different attack times. Two layers, one job each, both EQ'd so they don't overlap."),
                .terms(["layering", "phase", "polarity", "eq", "transient"])
            ]
        ),

        Lesson(
            id: "s4", title: "SAMPLING & CHOPPING", kicker: "BUILDING FROM SOMEBODY ELSE'S RECORD",
            minutes: 6,
            blocks: [
                .text("Sampling is taking a piece of existing audio and making it yours. The workflow is the same in every sampler on earth — Ableton's Simpler, FL's Slicex, Logic's Quick Sampler, an MPC."),
                .steps([
                    "Drop the audio onto a track and find a 2–4 second section you love.",
                    "Set the project tempo to the sample's tempo, or warp/stretch the sample to your tempo.",
                    "CHOP: slice it at transients, or at every beat, so each slice sits on its own pad or MIDI key.",
                    "Play the slices in a new order. This is the actual creative act.",
                    "Filter out everything below ~120 Hz on the sample so your own kick and bass have room.",
                    "Add your drums underneath the chop."
                ]),
                .callout(.rule, "High-pass the sample, always",
                         "Old records have their own kick and bass in them. If you don't cut the lows out of your sample, your kick will never sound powerful no matter how loud you push it. Roll off below 100–150 Hz and the low end instantly clears up."),
                .heading("THE TRICKS THAT MAKE IT SOUND INTENTIONAL"),
                .bullets([
                    "PITCH IT. Down for weight and darkness, up for a bright chipmunk-soul feel. ±3 to 5 semitones is the sweet spot.",
                    "REVERSE a slice for a lead-in.",
                    "CHANGE THE ORDER so the phrase resolves somewhere the original didn't.",
                    "LOOP a half-beat of it into a stutter for a fill."
                ]),
                .callout(.trap, "Chopping on the transient instead of before it",
                         "If your slice starts a millisecond after the hit, the attack is gone and everything sounds soft. Zoom in and start the slice just BEFORE the waveform jumps. Use zero-crossing snapping to avoid clicks."),
                .text("One legal note, plainly: sampling a commercial record for release requires clearance from the rights holders. For learning, practice, and beats that stay on your hard drive, sample whatever you want. If you're putting it out, use a royalty-free sample pack, a sample library that grants a licence, or clear it."),
                .terms(["sampler", "chop", "transient", "warp", "timeStretch", "highPass"])
            ]
        )
    ]
}
