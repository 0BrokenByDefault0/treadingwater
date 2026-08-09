# TREADING WATER

An iOS app that teaches beat-making the way you actually need it taught: as a
reference you can grab mid-session. You're in Ableton, you've hit a snag, you
don't know what the next move is or what that button does — you pick up your
phone, get one specific answer, and go back to the DAW.

Native SwiftUI, iOS 17+, no backend, no account, works offline. Every sound is
synthesised on-device, so the app ships without a single audio file.

---

## Opening it

```
open TreadingWater.xcodeproj
```

Requires **Xcode 16 or newer** (the project uses file-system-synchronized
groups, so new Swift files under `TreadingWater/` are picked up automatically —
no need to add them to the target by hand).

Pick an iPhone simulator or a device and hit Run. On a device you'll need to set
your own team under *Signing & Capabilities*; the bundle ID is
`com.treadingwater.app`.

If the project file ever gets out of step, `project.yml` regenerates an
equivalent one with [XcodeGen](https://github.com/yonaskolb/XcodeGen).

---

## The five tabs

**PATH** — The beginner-to-expert curriculum. Six stages, 33 lessons, in the
order the knowledge is actually needed:

1. **GROUND ZERO** — what a DAW is, tempo, the grid, tracks vs clips, and the
   workflow that gets a first loop finished.
2. **DRUMS** — kit anatomy, kick/snare placement by genre, hats and
   subdivision, swing, velocity and ghost notes, fills.
3. **MELODY & HARMONY** — reading the piano roll, key and scale, chords,
   progressions, basslines, writing a hook.
4. **SOUND SELECTION** — choosing samples, synth controls, layering, sampling
   and chopping.
5. **MIXING** — gain staging, EQ, compression, reverb and delay, sidechain,
   panning and width, buses and parallel processing.
6. **FINISHING** — arrangement, transitions, automation, referencing, export
   and loudness.

Lessons are built from typed content blocks — prose, ordered steps, rules,
common traps, A/B comparisons, labelled ranges, per-DAW locations, and
**playable audio examples** rendered inline.

**LAB** — Two interactive sandboxes running the app's own synth engine.

- *Drum Lab*: nine lanes × sixteen steps. Three velocity brushes (accent, mid,
  ghost) plus erase, drag-to-paint, tempo and swing, a metronome, and genre
  skeletons you can load and take apart. Tapping a lane name auditions the
  sound and explains what that piece is *for*.
- *Piano Roll*: fifteen pitch rows against the same grid. Seven scales with
  plain-English moods, scale lock that greys out every note that would sound
  wrong, a chord stamp for triads/7ths/sus shapes, six synth voices, and
  drums underneath so you're writing against a groove.

**DECODE** — The DAW decoder: 134 searchable entries. Each one answers three
questions in the same shape every time — *what it is*, *what it does*, *when
you'd use it* — plus where the control lives in Ableton, FL Studio and Logic.
This is the "what is this button" feature.

**REF** — Eight expert genre templates (trap, boom bap, UK drill, house, lo-fi,
afrobeats, drum & bass, R&B/pop). Each is a real, playable two-bar reference
beat with its tempo and key, the drum grid laid out, a sound palette, an
arrangement map in bars, mix notes, why it works, and the mistakes people make
in that genre. Leave one playing next to your DAW while you build your own.

**STUCK** — Symptom in, next action out. Twenty-one entries across "I don't
know where to start", "it doesn't sound right", "I'm stuck creatively" and "I
can't finish". Each gives an ordered list of things to do and a short
explanation of *why* that works, with links into the relevant terms and lesson.

---

## Design

The visual language is pulled from the reference sheet supplied with the brief —
a wide-grotesque type specimen system. Bone paper, dead-black ink, concrete
greys, terracotta clay, and a single orange used sparingly enough that it always
means "look here". Hard 1.2pt rules, no corner radii, no shadows, no
translucency: every container is a bordered panel with a serial number and a
stencil header rail, plus barcodes, swatch strips and repeating ticker rails as
furniture.

No licensed font files are bundled. SF Pro's *expanded* width axis at black
weight gets close to the poster's wide grotesque and stays legible at 9pt for
the technical labels, with monospaced small caps for every readout.

A NIGHT mode inverts the palette (the toggle sits in the masthead) — producers
work in dark rooms, and the source material already inverts its own panels.

---

## Architecture

```
TreadingWater/
  TreadingWaterApp.swift     App entry, environment objects, scene phase
  Design/
    Theme.swift              Palette, day/night, type scale
    Components.swift         Panel, Sheet, Barcode, Ticker, Tag, meters, rules
  Audio/
    Synth.swift              DSP: drum voices, synth voices, filters — render thread only
    AudioEngine.swift        AVAudioEngine graph, sequencer, lock-free plumbing
  Model/
    MusicTypes.swift         Drum, DrumTrack, Note, MelodyTrack, Beat
    Theory.swift             Scales, chord shapes, progressions
    Lesson.swift             Content block types, Stage/Lesson, curriculum root
    Content+*.swift          The six stages of lesson content
    Glossary*.swift          The decoder entries
    Templates.swift          The eight genre references
    Troubleshoot.swift       The STUCK index
    DemoBeats.swift          Playable examples used inside lessons
    Store.swift              Progress + the two lab sketches (UserDefaults)
  Views/                     One file per screen
```

### The audio engine

There is no sampler and no bundled audio. `AVAudioSourceNode` drives a
per-sample render loop:

- **Drums** are synthesised — the kick is a pitch-swept sine through a soft
  clipper, the snare is two tones plus high-passed noise, the clap is three
  noise bursts a few milliseconds apart, hats are filtered noise with different
  decay times.
- **Melodic voices** are poly-BLEP saws, pulses and sines through a Chamberlin
  state-variable filter with per-voice envelopes. Six timbres: sub, bass, keys,
  lead, pluck, bell.
- **The sequencer** runs inside the render callback with sample-accurate step
  timing and swing applied to the off-sixteenths only.

Nothing allocates on the audio thread. Pattern edits are written into a staging
grid of flat preallocated buffers and picked up via `os_unfair_lock_trylock`;
auditions arrive through a single-producer ring buffer of packed `Int32`
commands. The playhead and output level are published back to the UI by a
30 Hz timer rather than from the render thread.

The audio session uses `.playback` with `.mixWithOthers`, so the app never
ducks or interrupts whatever else is playing — which is the whole point when
the phone is sitting next to a DAW.

---

## A note on scope

The labs are for learning placement, velocity and harmony. They are deliberately
not a portable DAW: the synthesised kick will not sound like a $200 sample pack,
and it isn't trying to. The finished beat gets made in Ableton — this is the
thing you keep open next to it.
