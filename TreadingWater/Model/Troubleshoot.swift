import Foundation
import SwiftUI

/// The "I'm mid-session and I've hit a wall" index. Every entry answers one
/// question with an ordered list of things to actually do, in order.
struct Fix: Identifiable {
    let id: String
    let title: String
    let symptom: String
    let steps: [String]
    let why: String
    var terms: [String] = []
    var lesson: String? = nil

    var searchText: String {
        ([title, symptom, why] + steps).joined(separator: " ").lowercased()
    }
}

struct FixGroup: Identifiable {
    let id: String
    let title: String
    let blurb: String
    let tint: Color
    let fixes: [Fix]
}

enum Troubleshoot {

    static let groups: [FixGroup] = [blankPage, soundsWrong, creative, finishing]

    static var allFixes: [Fix] { groups.flatMap { $0.fixes } }

    static func search(_ q: String) -> [Fix] {
        let query = q.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return [] }
        return allFixes.filter { $0.searchText.contains(query) }
    }

    // MARK: Blank page

    static let blankPage = FixGroup(
        id: "start", title: "I DON'T KNOW WHERE TO START",
        blurb: "Empty project, cursor blinking.",
        tint: Ink.orange,
        fixes: [
            Fix(id: "s-empty", title: "EMPTY PROJECT, NO IDEA",
                symptom: "You opened the DAW and nothing is happening.",
                steps: [
                    "Pick a tempo from the genre you want. Don't think about it — 90, 124 or 140.",
                    "Loop bars 1 to 4 and turn the loop on.",
                    "Put a kick on step 1 and a snare on steps 5 and 13. That's it, that's a beat.",
                    "Add hats on every other step.",
                    "Now you have something to react to. Change one thing and listen."
                ],
                why: "A blank project has infinite options, which is paralysing. Four bars of a generic pattern reduces it to one question: what would make THIS better?",
                terms: ["bpm", "loop", "backbeat"], lesson: "f5"),

            Fix(id: "s-order", title: "WHAT ORDER DO I BUILD IN?",
                symptom: "You have elements but no idea what comes next.",
                steps: [
                    "Drums: kick and snare first.",
                    "Hats and percussion.",
                    "Bass on the root note, following the kick.",
                    "Chords or the sample.",
                    "One melodic hook on top.",
                    "Only then: balance the volumes."
                ],
                why: "This order means every new element has something to sit against. Starting with the melody means you'll rewrite the drums three times to fit it.",
                terms: ["arrangement", "kick", "bass"], lesson: "f5"),

            Fix(id: "s-key", title: "WHAT KEY SHOULD I USE?",
                symptom: "You're about to write notes and don't know where to start.",
                steps: [
                    "Choose minor unless you want it to sound happy.",
                    "Pick literally any root note. A minor, F minor, it doesn't matter.",
                    "Turn on scale highlighting in the piano roll.",
                    "Write only inside the highlighted notes."
                ],
                why: "The key doesn't affect quality, only the register things sit in. Being in a key at all is what matters. Scale lock makes wrong notes physically impossible.",
                terms: ["key", "scale", "pentatonic"], lesson: "m2"),

            Fix(id: "s-sample", title: "I HAVE A SAMPLE, NOW WHAT?",
                symptom: "You found a loop or a record you like.",
                steps: [
                    "Set the project tempo to the sample's tempo, or warp it to yours.",
                    "Find its key: play single notes against it until one disappears into it.",
                    "High-pass the sample at 120–150 Hz so your kick has room.",
                    "Chop it and rearrange the pieces so it's not just the original loop.",
                    "Build drums underneath it."
                ],
                why: "Most people layer their own drums over an unfiltered sample and wonder why the low end is a mess. The filtering step is what makes it sound produced.",
                terms: ["chop", "warp", "highPass", "rootNote"], lesson: "s4")
        ]
    )

    // MARK: Sounds wrong

    static let soundsWrong = FixGroup(
        id: "sound", title: "IT DOESN'T SOUND RIGHT",
        blurb: "You made something and it isn't landing.",
        tint: Ink.clay,
        fixes: [
            Fix(id: "w-muddy", title: "IT SOUNDS MUDDY",
                symptom: "Like a blanket over the speakers. Nothing is clear.",
                steps: [
                    "High-pass EVERYTHING that isn't the kick or bass, at 100–200 Hz.",
                    "Find the worst offender in the 200–400 Hz range and cut 3 dB with a wide bell.",
                    "Check whether two elements are playing in the same low octave. Move one up.",
                    "Cut low frequencies out of your reverb — below 300 Hz on the reverb return.",
                    "Mute things one at a time. When it suddenly clears up, you've found it."
                ],
                why: "Mud is a build-up problem, not a single-track problem. Ten sounds each with a bit of 250 Hz add up to a wall of it.",
                terms: ["mud", "highPass", "eq", "reverb"], lesson: "x2"),

            Fix(id: "w-thin", title: "IT SOUNDS THIN AND SMALL",
                symptom: "Technically fine but weak and amateur.",
                steps: [
                    "Check you actually have low-mid content — a bass playing notes, not just a sub.",
                    "Add saturation to the bass so it has harmonics above 100 Hz.",
                    "Layer the kick: one sample for weight, one for click.",
                    "Widen the mid-range elements with panning, not a stereo widener.",
                    "Check in mono. If it collapses, a widener or phase issue is eating your body."
                ],
                why: "Thinness is almost always missing 100–400 Hz. Everyone high-passes so aggressively that nothing is left holding the middle.",
                terms: ["saturation", "layering", "phase", "mono"], lesson: "x6"),

            Fix(id: "w-stiff", title: "THE DRUMS SOUND ROBOTIC",
                symptom: "Everything's on the grid and it's lifeless.",
                steps: [
                    "Vary the velocity: 100 on the downbeats, 70 on the eighths, 45 on the rest.",
                    "Add 10–15% swing to the hats only, leaving the kick and snare straight.",
                    "Add two ghost snares at velocity 30 either side of the backbeat.",
                    "Drag the snare 10–20 ms late with snap off.",
                    "Change ONE hit in the second bar so bars 1 and 2 aren't identical."
                ],
                why: "Real drummers are inconsistent in specific, predictable ways: accents on the beats, quieter in between, and slightly behind on the backbeat.",
                terms: ["velocity", "swing", "ghostNote", "humanize"], lesson: "d5"),

            Fix(id: "w-nokick", title: "THE KICK HAS NO POWER",
                symptom: "You turn it up and it just gets louder, not harder.",
                steps: [
                    "High-pass everything else so nothing else is in the kick's range.",
                    "Sidechain the bass to the kick — 3 to 6 dB of ducking, fast attack.",
                    "Check the kick has a click around 2–5 kHz. If not, layer one in.",
                    "Make sure the kick and bass aren't playing at the exact same moment constantly.",
                    "Try a slow compressor attack (20 ms) on the kick to let the transient through."
                ],
                why: "A kick sounds powerful because of contrast, not level. If the bass is filling the same space at the same moment, you can't turn the kick up enough to win.",
                terms: ["kick", "sidechain", "highPass", "attack"], lesson: "x5"),

            Fix(id: "w-harsh", title: "IT'S HARSH AND FATIGUING",
                symptom: "Your ears hurt after five minutes.",
                steps: [
                    "Sweep a narrow +10 dB boost between 2 and 6 kHz until you wince, then cut there instead.",
                    "Check the hats — they're usually the culprit. Turn them down 3 dB.",
                    "Low-pass anything bright that isn't essential.",
                    "Take the limiter off the master and see if it's the limiter.",
                    "Listen at a quieter level for ten minutes and re-judge."
                ],
                why: "The 2–5 kHz range is where human hearing is most sensitive. A small excess there is exhausting even when it measures fine.",
                terms: ["eq", "qFactor", "limiter", "lowPass"], lesson: "x2"),

            Fix(id: "w-quiet", title: "MINE IS QUIETER THAN COMMERCIAL TRACKS",
                symptom: "Your mix sounds fine until you A/B it with a real song.",
                steps: [
                    "Turn the reference DOWN to match yours before judging anything else.",
                    "Fix the balance first. Loudness comes from a good mix, not a limiter.",
                    "Check your gain staging — nothing clipping, master peaking around −6 dB.",
                    "Add saturation to individual elements rather than compressing the master harder.",
                    "Only at the very end: a limiter on the master with a −1 dB ceiling."
                ],
                why: "Commercial tracks are mastered, which is 6–10 dB of extra apparent level. Chasing that loudness during the mix squashes everything and you lose the dynamics that made it good.",
                terms: ["lufs", "limiter", "gainStaging", "reference"], lesson: "z4"),

            Fix(id: "w-bassphone", title: "THE BASS DISAPPEARS ON PHONE SPEAKERS",
                symptom: "Huge on headphones, gone in the car or on a laptop.",
                steps: [
                    "Add saturation or distortion to the bass. It creates harmonics an octave or two up.",
                    "Layer a mid-range bass sound above the sub, high-passed at 120 Hz.",
                    "Check the bass isn't below C1 — that's too low for small speakers to imply.",
                    "Test on your phone speaker specifically, not just in mono."
                ],
                why: "Small speakers can't reproduce below ~150 Hz at all. Your brain infers the missing fundamental from the harmonics above it — so if there are no harmonics, there's no bass.",
                terms: ["saturation", "sub", "layering", "translation"], lesson: "x6"),

            Fix(id: "w-clash", title: "THE MELODY CLASHES WITH THE SAMPLE",
                symptom: "Something sounds sour and you can't tell what.",
                steps: [
                    "Find the sample's root: play single notes against it until one vanishes into it.",
                    "Set your piano roll to that key with scale lock on.",
                    "Rewrite the melody using only scale notes.",
                    "If it still clashes, the sample has a chord change your loop doesn't. Shorten the sample."
                ],
                why: "Samples carry their own harmony. Anything you write on top has to agree with it, and 'close enough' is audibly wrong.",
                terms: ["key", "rootNote", "scale", "transpose"], lesson: "m2")
        ]
    )

    // MARK: Creative

    static let creative = FixGroup(
        id: "creative", title: "I'M STUCK CREATIVELY",
        blurb: "The loop is fine. It's just not going anywhere.",
        tint: Ink.plum,
        fixes: [
            Fix(id: "c-boring", title: "MY LOOP IS BORING",
                symptom: "It's technically correct and you don't want to hear it again.",
                steps: [
                    "Mute every element one at a time. If muting something makes it better, delete it.",
                    "Change one hit in bar 2 so the two bars aren't identical.",
                    "Add an open hat on step 15 leading into the loop point.",
                    "Move your chords to the off-beats instead of the downbeats.",
                    "Change one chord in the progression to a different scale degree."
                ],
                why: "Boredom is usually symmetry. Perfectly repeating patterns are predictable after two passes, and the brain stops listening.",
                terms: ["fill", "openHat", "progression"], lesson: "d6"),

            Fix(id: "c-samey", title: "EVERYTHING I MAKE SOUNDS THE SAME",
                symptom: "Different projects, same beat.",
                steps: [
                    "Change your starting element. If you always start with drums, start with chords.",
                    "Change the tempo range you work in by 30 BPM.",
                    "Use a scale you never use — dorian or phrygian instead of natural minor.",
                    "Limit yourself to four sounds for a whole beat.",
                    "Copy the drum pattern from a genre template you've never worked in."
                ],
                why: "Habits are efficient, which is exactly why they produce the same result. Changing the constraint changes the output more reliably than trying to be more creative.",
                terms: ["scale", "bpm"], lesson: "m2"),

            Fix(id: "c-melody", title: "I CAN'T WRITE A MELODY",
                symptom: "Every idea sounds like nothing.",
                steps: [
                    "Turn on scale lock and use the minor pentatonic — five notes.",
                    "Write a RHYTHM first with all the notes on one pitch. Get that memorable.",
                    "Now move the pitches around, mostly by single steps in the scale.",
                    "Use four to eight notes total, then leave the rest of the bar empty.",
                    "Repeat the phrase and change only the last note."
                ],
                why: "Melody is rhythm plus pitch, and rhythm is the part that makes it memorable. Solving them separately is far easier than solving both at once.",
                terms: ["melody", "pentatonic", "hook", "motif"], lesson: "m6"),

            Fix(id: "c-full", title: "IT FEELS EMPTY BUT ADDING THINGS MAKES IT WORSE",
                symptom: "Something's missing and every layer you add is wrong.",
                steps: [
                    "Check the 100–400 Hz range. Empty usually means no low-mid body, not missing layers.",
                    "Add a pad holding the chord underneath everything, high-passed and quiet.",
                    "Widen what's already there before adding anything new.",
                    "Add reverb to one element so the mix has depth instead of more parts.",
                    "Double the melody an octave down at low volume."
                ],
                why: "'Empty' is usually a frequency or depth problem disguised as an arrangement problem. Another layer in an already-crowded midrange makes it worse, not fuller.",
                terms: ["pad", "reverb", "eq", "width"], lesson: "x4"),

            Fix(id: "c-8bars", title: "I ONLY EVER MAKE 8 BARS",
                symptom: "Great loop, no song.",
                steps: [
                    "Copy the loop across four minutes right now. Don't write anything new.",
                    "Mute elements out of the first 16 bars to make an intro.",
                    "Mute the kick for 8 bars somewhere in the middle to make a breakdown.",
                    "Add a crash on every section's first beat.",
                    "Now go back and add ONE new element per section."
                ],
                why: "Arrangement is subtraction from a full loop, not composition from scratch. Doing it in that order takes about twenty minutes instead of forever.",
                terms: ["arrangement", "section", "solo"], lesson: "z1")
        ]
    )

    // MARK: Finishing

    static let finishing = FixGroup(
        id: "finish", title: "I CAN'T FINISH",
        blurb: "It's nearly done and you keep not exporting it.",
        tint: Ink.steel,
        fixes: [
            Fix(id: "n-ears", title: "I'VE LOST PERSPECTIVE",
                symptom: "You've heard it 400 times and can't tell if it's good.",
                steps: [
                    "Stop. Leave it for a day minimum.",
                    "Export a rough and listen on your phone speaker, not in the DAW.",
                    "Write down three specific things that are wrong, on paper.",
                    "Fix only those three. Don't open anything else."
                ],
                why: "Ear fatigue is physical, not psychological. After 30–40 minutes on the same material your hearing has genuinely adapted and your judgement is unreliable.",
                terms: ["reference", "translation"], lesson: "z4"),

            Fix(id: "n-transitions", title: "THE SECTIONS DON'T FLOW",
                symptom: "The arrangement is there but the joins sound abrupt.",
                steps: [
                    "Crash on the downbeat of every new section.",
                    "Drum fill in the last half-bar before each change.",
                    "A riser in the last 2 bars before a big section.",
                    "Cut everything for the last beat before a drop.",
                    "Two techniques per big change, one per small change. Never five."
                ],
                why: "The ear needs a signal that a change is coming. Without one, section boundaries read as edits rather than as music.",
                terms: ["transition", "riser", "fill", "drop"], lesson: "z2"),

            Fix(id: "n-mixloop", title: "I KEEP RE-MIXING INSTEAD OF FINISHING",
                symptom: "Twenty sessions on the same eight bars.",
                steps: [
                    "Set a timer for 45 minutes. When it goes, export whatever you have.",
                    "Do the arrangement BEFORE the mix, always.",
                    "Delete every plugin you can't hear the effect of.",
                    "Write down the three worst problems and fix only those.",
                    "Start the next beat. Fix these mistakes in that one instead."
                ],
                why: "Ten finished average beats teach you more than one unfinished perfect one, because the lesson is in hearing the whole thing back the next day.",
                terms: ["export", "arrangement", "master"], lesson: "z5"),

            Fix(id: "n-export", title: "MY EXPORT SOUNDS WRONG",
                symptom: "The file doesn't match what you heard in the DAW.",
                steps: [
                    "Check the export range — the number one cause is the loop brackets still being set.",
                    "Check nothing is soloed or muted that shouldn't be.",
                    "Check the master isn't clipping. Fix by pulling all faders, not the master.",
                    "Extend the render a bar past the end so reverb tails don't get cut off.",
                    "Turn normalisation OFF and dither only on a final 16-bit master."
                ],
                why: "Export bugs are almost always session state, not audio problems. Check the boring things first.",
                terms: ["export", "clipping", "dither", "solo"], lesson: "z5")
        ]
    )
}
