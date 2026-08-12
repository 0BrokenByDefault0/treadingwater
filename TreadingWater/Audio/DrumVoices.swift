import Foundation

enum DrumVoiceKind: Int {
    case kick = 0, snare, clap, closedHat, openHat, rim, tom, perc, crash
}

/// Per-lane character. Templates set these so a boom-bap kick and a trap kick
/// are genuinely different instruments rather than the same beep at different
/// volumes.
struct DrumParams {
    var gain: Float = 1.0
    var pan: Float = 0.0
    var tune: Float = 0.0        // semitones
    var tone: Float = 0.5        // 0 dark ... 1 bright
    var decay: Float = 0.5       // 0 tight ... 1 long
    var drive: Float = 0.25
    var reverb: Float = 0.0
    var delay: Float = 0.0
    var timing: Float = 0.0      // -1 early ... 1 late

    @inline(__always) var tuneRatio: Float { powf(2.0, tune / 12.0) }

    /// Micro-timing nudge in samples.
    @inline(__always) func timingSamples(_ sr: Float) -> Float { timing * 0.012 * sr }
}

/// The six inharmonic ratios that make a square-wave bank read as metal
/// instead of as a chord. This is the trick the TR-808 uses for its cymbals,
/// and it is the single biggest reason filtered white noise sounds like a
/// "lite" hi-hat by comparison.
private let metalRatios: (Float, Float, Float, Float, Float, Float) =
    (1.0, 1.4471, 1.6170, 1.9265, 2.5028, 2.6637)

struct DrumVoice {
    var kind: DrumVoiceKind = .kick
    var active = false
    var startDelay = 0          // samples of micro-timing offset

    var params = DrumParams()
    var vel: Float = 1
    var t: Float = 0

    // Oscillator phases.
    var p1: Float = 0, p2: Float = 0, p3: Float = 0
    var m0: Float = 0, m1: Float = 0, m2: Float = 0
    var m3: Float = 0, m4: Float = 0, m5: Float = 0

    // Envelopes.
    var ampEnv = Decay()
    var subEnv = Decay()
    var noiseEnv = Decay()
    var clickEnv = Decay()
    var pitchEnv = Decay()
    var pitchEnv2 = Decay()

    var bp = Biquad()
    var hp = Biquad()
    var lp = Biquad()
    var rng = Rng()
    var dc = DCBlock()

    var life: Float = 1          // seconds before the voice frees itself

    // MARK: Trigger

    mutating func trigger(_ kind: DrumVoiceKind, vel: Float, params: DrumParams,
                          delay: Int, seed: UInt32, sr: Float) {
        self.kind = kind
        self.vel = vel
        self.params = params
        self.startDelay = delay
        self.active = true
        self.t = 0
        p1 = 0; p2 = 0; p3 = 0
        m0 = 0.13; m1 = 0.29; m2 = 0.47; m3 = 0.61; m4 = 0.79; m5 = 0.91
        rng.state = seed | 1
        bp.reset(); hp.reset(); lp.reset()
        dc = DCBlock()

        let tone = params.tone
        let dec = params.decay
        let ratio = params.tuneRatio

        switch kind {
        case .kick:
            // Two pitch envelopes: a very fast one for the beater click and a
            // slower one for the body drop. That separation is what makes a
            // kick sound like a drum rather than a sine sweep.
            pitchEnv.trigger(0.006 + 0.008 * (1 - tone), sr)
            pitchEnv2.trigger(0.055 + 0.05 * dec, sr)
            ampEnv.trigger(0.16 + 0.55 * dec, sr)
            subEnv.trigger(0.22 + 0.75 * dec, sr)
            clickEnv.trigger(0.002 + 0.004 * tone, sr)
            hp.highpass(1800 + 2500 * tone, q: 0.7, sr: sr)
            life = 1.4

        case .snare:
            pitchEnv.trigger(0.020, sr)
            ampEnv.trigger(0.055 + 0.10 * dec, sr)
            noiseEnv.trigger(0.055 + 0.26 * dec, sr)
            clickEnv.trigger(0.0025, sr)
            bp.bandpass(1500 + 2200 * tone, q: 0.55, sr: sr)
            hp.highpass(3200 + 3000 * tone, q: 0.7, sr: sr)
            life = 0.9

        case .clap:
            noiseEnv.trigger(0.045 + 0.22 * dec, sr)
            bp.bandpass(1050 + 900 * tone, q: 1.05, sr: sr)
            hp.highpass(560, q: 0.7, sr: sr)
            life = 0.8

        case .closedHat:
            noiseEnv.trigger(0.012 + 0.045 * dec, sr)
            bp.bandpass((7200 + 3200 * tone) * ratio, q: 0.85, sr: sr)
            hp.highpass(6200 * ratio, q: 0.7, sr: sr)
            life = 0.35

        case .openHat:
            noiseEnv.trigger(0.14 + 0.5 * dec, sr)
            bp.bandpass((6800 + 3000 * tone) * ratio, q: 0.7, sr: sr)
            hp.highpass(5400 * ratio, q: 0.7, sr: sr)
            life = 1.2

        case .rim:
            ampEnv.trigger(0.010 + 0.02 * dec, sr)
            noiseEnv.trigger(0.004, sr)
            bp.bandpass(1750 * ratio, q: 3.2, sr: sr)
            hp.highpass(700, q: 0.7, sr: sr)
            life = 0.3

        case .tom:
            pitchEnv.trigger(0.045, sr)
            ampEnv.trigger(0.20 + 0.5 * dec, sr)
            noiseEnv.trigger(0.020, sr)
            hp.highpass(120, q: 0.7, sr: sr)
            life = 1.1

        case .perc:
            ampEnv.trigger(0.045 + 0.16 * dec, sr)
            bp.bandpass(1900 * ratio, q: 1.6, sr: sr)
            life = 0.6

        case .crash:
            noiseEnv.trigger(0.85 + 1.4 * dec, sr)
            bp.bandpass(4200 + 2600 * tone, q: 0.45, sr: sr)
            hp.highpass(2600, q: 0.6, sr: sr)
            life = 3.2
        }
    }

    // MARK: Render

    @inline(__always) mutating func render(sr: Float) -> Float {
        guard active else { return 0 }
        if startDelay > 0 {
            startDelay -= 1
            return 0
        }

        let dt = 1.0 / sr
        let ratio = params.tuneRatio
        let tone = params.tone
        var out: Float = 0

        switch kind {

        case .kick:
            let fast = pitchEnv.process()
            let slow = pitchEnv2.process()
            // 52 Hz floor, +180 Hz slow drop, +420 Hz instantaneous snap.
            let f = (50.0 + 175.0 * slow + 420.0 * fast) * ratio
            p1 += f * dt; if p1 >= 1 { p1 -= 1 }
            let body = fastSin(p1)

            // Independent sub an octave down keeps weight after the drop.
            p2 += (50.0 * ratio) * dt; if p2 >= 1 { p2 -= 1 }
            let sub = fastSin(p2) * subEnv.process() * 0.55

            let amp = ampEnv.process()
            let clickAmt = clickEnv.process()
            let click = hp.process(rng.next()) * clickAmt * (0.25 + 0.5 * tone)

            let driven = warm(body * amp * 1.25, params.drive)
            out = driven + sub + click * 1.1

        case .snare:
            let pe = pitchEnv.process()
            let amp = ampEnv.process()
            // Two detuned bodies. The slight beat between them is the "ring".
            p1 += (183.0 * ratio + 90.0 * pe) * dt; if p1 >= 1 { p1 -= 1 }
            p2 += (327.0 * ratio + 140.0 * pe) * dt; if p2 >= 1 { p2 -= 1 }
            let body = (fastSin(p1) * 0.62 + fastSin(p2) * 0.34) * amp

            let n = rng.next()
            let rattle = bp.process(n) * noiseEnv.process()
            let crack = hp.process(n) * clickEnv.process() * 0.8

            out = saturate(body * 0.85 + rattle * (0.9 + 0.5 * tone) + crack, params.drive * 0.6)

        case .clap:
            // Four bursts a few milliseconds apart with slight jitter, then a
            // short diffuse tail. Real claps are many hands, not one.
            var burst: Float = 0
            if t < 0.0035 { burst = 1.0 }
            else if t > 0.0098 && t < 0.0132 { burst = 0.92 }
            else if t > 0.0201 && t < 0.0234 { burst = 0.86 }
            else if t > 0.0298 && t < 0.0338 { burst = 0.78 }
            let tail = noiseEnv.process() * 0.42
            let n = hp.process(rng.next())
            out = bp.process(n * (burst + tail)) * 2.4

        case .closedHat, .openHat:
            let metal = metalBank(baseHz: 318.0 * ratio, dt: dt)
            let env = noiseEnv.process()
            // A little noise on top stops the bank sounding synthetic.
            let n = rng.next() * 0.22
            out = hp.process(bp.process(metal * 0.7 + n)) * env * 2.6

        case .rim:
            let amp = ampEnv.process()
            p1 += 1720.0 * ratio * dt; if p1 >= 1 { p1 -= 1 }
            p2 += 2790.0 * ratio * dt; if p2 >= 1 { p2 -= 1 }
            let tone1 = fastSin(p1) * 0.7 + fastSin(p2) * 0.35
            let tick = hp.process(rng.next()) * noiseEnv.process()
            out = bp.process(tone1 * amp + tick * 0.8) * 2.2

        case .tom:
            let pe = pitchEnv.process()
            let amp = ampEnv.process()
            p1 += ((108.0 + 105.0 * pe) * ratio) * dt; if p1 >= 1 { p1 -= 1 }
            let skin = rng.next() * noiseEnv.process() * 0.25
            out = hp.process(fastSin(p1) * amp + skin)
            out = saturate(out, params.drive * 0.5)

        case .perc:
            let amp = ampEnv.process()
            // Cowbell-style pair of detuned squares.
            let inc1 = 540.0 * ratio * dt
            let inc2 = 806.0 * ratio * dt
            p1 += inc1; if p1 >= 1 { p1 -= 1 }
            p2 += inc2; if p2 >= 1 { p2 -= 1 }
            let sq = polyBlepSquare(p1, inc1, 0.5) * 0.34
                   + polyBlepSquare(p2, inc2, 0.5) * 0.26
            out = bp.process(sq) * amp * 1.6

        case .crash:
            let metal = metalBank(baseHz: 208.0 * ratio, dt: dt)
            let env = noiseEnv.process()
            let n = rng.next() * 0.45
            out = hp.process(bp.process(metal * 0.5 + n)) * env * 1.9
        }

        t += dt
        if t > life { active = false }

        return dc.process(out) * vel * params.gain
    }

    /// Six square waves at inharmonic ratios, summed.
    @inline(__always) private mutating func metalBank(baseHz: Float, dt: Float) -> Float {
        let i0 = baseHz * metalRatios.0 * dt
        let i1 = baseHz * metalRatios.1 * dt
        let i2 = baseHz * metalRatios.2 * dt
        let i3 = baseHz * metalRatios.3 * dt
        let i4 = baseHz * metalRatios.4 * dt
        let i5 = baseHz * metalRatios.5 * dt

        m0 += i0; if m0 >= 1 { m0 -= 1 }
        m1 += i1; if m1 >= 1 { m1 -= 1 }
        m2 += i2; if m2 >= 1 { m2 -= 1 }
        m3 += i3; if m3 >= 1 { m3 -= 1 }
        m4 += i4; if m4 >= 1 { m4 -= 1 }
        m5 += i5; if m5 >= 1 { m5 -= 1 }

        let s: Float = (m0 < 0.5 ? 1 : -1) + (m1 < 0.5 ? 1 : -1) + (m2 < 0.5 ? 1 : -1)
                     + (m3 < 0.5 ? 1 : -1) + (m4 < 0.5 ? 1 : -1) + (m5 < 0.5 ? 1 : -1)
        return s * 0.1667
    }
}
