import Foundation

enum FinishLessons {
    static let lessons: [Lesson] = [

        Lesson(
            id: "z1", title: "ARRANGEMENT", kicker: "TURNING A LOOP INTO A TRACK",
            minutes: 6,
            blocks: [
                .text("Most people who 'can't finish beats' can finish loops just fine. Arrangement is the missing skill, and it's mostly a counting exercise — sections are 8 or 16 bars, and something has to change at every boundary."),
                .heading("A STRUCTURE THAT WORKS"),
                .bullets([
                    "INTRO — 8 bars. One or two elements. Set the mood.",
                    "VERSE — 16 bars. Drums plus the core loop. Leave room for a vocal even if there isn't one.",
                    "PRE / BUILD — 4–8 bars. Remove the kick, add tension, rise into the next section.",
                    "HOOK / DROP — 16 bars. Everything in. This should be the loudest and fullest part.",
                    "VERSE 2 — 16 bars. Same as verse 1 with one new element so it isn't a copy.",
                    "HOOK — 16 bars. Repeat.",
                    "OUTRO — 8 bars. Strip back down and let it end."
                ]),
                .callout(.rule, "Energy is relative, not absolute",
                         "A drop only feels big because the section before it was small. If everything is full the whole way through, nothing lands. Take things AWAY before the moment you want to hit hardest — that's the entire trick."),
                .callout(.shortcut, "Arrange by muting",
                         "Duplicate your loop across the full length of the song first, then go back and mute elements section by section. It's much faster than building each section from scratch, and it guarantees everything stays in sync."),
                .terms(["arrangement", "section", "drop", "build", "automation"])
            ]
        ),

        Lesson(
            id: "z2", title: "TRANSITIONS", kicker: "THE GLUE BETWEEN SECTIONS",
            minutes: 5,
            blocks: [
                .text("A section change with no transition sounds like a mistake. Transitions cost thirty seconds each and are the difference between a beat and a produced record."),
                .bullets([
                    "CRASH on the downbeat of the new section. The oldest and most reliable one.",
                    "RISER / UPLIFTER in the last 2 bars — a sweep that climbs into the change.",
                    "DOWNLIFTER on the downbeat — a falling whoosh that lands on the change.",
                    "DRUM FILL in the last half bar (see Drums 06).",
                    "REVERSE CYMBAL leading in — same idea as a riser, more organic.",
                    "SILENCE — cut everything for the last beat before a drop. Free, and devastating.",
                    "FILTER SWEEP — automate a low-pass closing across the build, then snap it open."
                ]),
                .callout(.shortcut, "The reverse-tail trick",
                         "Take the first chord or vocal of the new section, duplicate it, reverse it, and place it in the 1–2 bars before the change so it swells into the original. It's free, it's perfectly in key, and it sounds custom-made because it is."),
                .callout(.trap, "Every transition at once",
                         "A riser plus a crash plus a fill plus a downlifter plus silence is a car crash. Pick two. Big moments get two, small moments get one."),
                .terms(["transition", "riser", "fill", "automation", "filter"])
            ]
        ),

        Lesson(
            id: "z3", title: "AUTOMATION", kicker: "MOVEMENT OVER TIME",
            minutes: 5,
            blocks: [
                .text("Automation records a control moving over time — volume, filter cutoff, reverb amount, pan, anything. It's how a static loop becomes something that develops."),
                .steps([
                    "Open the automation lane on a track (see below for the shortcut in your DAW).",
                    "Choose the parameter — start with filter cutoff or volume.",
                    "Draw points. A line rising across 8 bars, or a step change at a section boundary.",
                    "Play it back and watch the plugin move. If you can't hear it, exaggerate until you can, then back it off."
                ]),
                .heading("THE FOUR HIGHEST-VALUE AUTOMATIONS"),
                .bullets([
                    "FILTER CUTOFF on the whole mix, closing through a build and snapping open on the drop.",
                    "VOLUME on individual elements — fade a pad in over 8 bars instead of just switching it on.",
                    "REVERB SEND up on the last note of a phrase so it blooms into the next section.",
                    "PITCH on the 808 — slides between notes are most of what makes a trap bassline feel alive."
                ]),
                .callout(.shortcut, "Automate one thing per section",
                         "You don't need moving parts everywhere. One clearly audible automated change per 8-bar section is enough to keep a listener engaged all the way through."),
                .dawPaths([
                    DAWLocation(daw: "ABLETON", path: "A key toggles automation mode · draw in the clip or arrangement lane"),
                    DAWLocation(daw: "FL STUDIO", path: "Right-click any knob → Create automation clip"),
                    DAWLocation(daw: "LOGIC", path: "A key shows automation · pick the parameter from the track header menu")
                ]),
                .terms(["automation", "filter", "envelope", "modulation", "lfo"])
            ]
        ),

        Lesson(
            id: "z4", title: "REFERENCING", kicker: "THE ONLY RELIABLE FEEDBACK",
            minutes: 4,
            blocks: [
                .text("Your ears lie after twenty minutes. A reference track — a finished, professionally mixed song in your genre — is the only honest measuring stick you have in the room."),
                .steps([
                    "Drop a commercial track into your session on a muted track routed straight to the master.",
                    "Turn it DOWN until it's the same perceived loudness as your mix. This is essential — louder always wins.",
                    "A/B them every 15 minutes while mixing.",
                    "Listen for one thing at a time: low end, then vocal/lead level, then brightness, then width."
                ]),
                .callout(.rule, "Match loudness or the test is worthless",
                         "A mastered reference is 6–10 dB louder than your unmastered mix. If you don't level-match, the reference will always sound better and you'll learn nothing."),
                .callout(.shortcut, "Reference on bad speakers",
                         "Play both on your phone speaker. It strips out the low end and shows you instantly whether your mix has a clear midrange — which is where the vast majority of listening actually happens."),
                .terms(["reference", "lufs", "master", "translation"])
            ]
        ),

        Lesson(
            id: "z5", title: "EXPORT & LOUDNESS", kicker: "GETTING IT OUT OF THE DAW",
            minutes: 5,
            blocks: [
                .text("Two different exports for two different purposes. Know which one you're doing."),
                .compare("A ROUGH / DEMO", "Full mix, WAV or 320 MP3, peak around −1 dB. For sending to an artist, posting a snippet, or listening in the car.",
                         "STEMS", "Every track or group exported separately from bar 1, all the same length. For a mixing engineer, an artist's session, or a collaborator."),
                .heading("SETTINGS THAT MATTER"),
                .bullets([
                    "FORMAT — WAV 24-bit for anything going to another person. MP3 320 only for casual listening.",
                    "SAMPLE RATE — 44.1 kHz for music, 48 kHz for video. Match your project, don't convert at the end.",
                    "DITHER — only when reducing bit depth on the final master. Never on stems.",
                    "TAIL — extend your export a bar past the end so reverb tails aren't chopped off.",
                    "NORMALIZE — off. You want to control the level yourself."
                ]),
                .heading("LOUDNESS"),
                .text("Streaming services normalise everything to roughly −14 LUFS. Mastering to −6 LUFS doesn't make you louder on Spotify, it just makes you more squashed at the same playback volume. Aim for −9 to −14 LUFS integrated with true peak at −1 dB, and spend your effort on the balance instead."),
                .callout(.trap, "Exporting with the loop still active",
                         "The single most common export mistake: your loop brackets are around bars 1–4 and the DAW exports four bars of your five-minute song. Check the export range every single time."),
                .callout(.rule, "Finished beats teach more than perfect ones",
                         "Ten finished average beats will make you better than one unfinished masterpiece. Export it, listen tomorrow, note what's wrong, and fix it in the next one. That loop is the whole skill."),
                .terms(["export", "bounce", "stems", "lufs", "truePeak", "dither", "sampleRate"])
            ]
        )
    ]
}
