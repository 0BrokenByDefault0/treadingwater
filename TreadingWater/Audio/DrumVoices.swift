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

/// Six inharmonic ratios, the way the TR-808 builds metal. The base frequency
/// matters as much as the ratios: too low and the bandpass has nothing but weak
/// upper harmonics to work with, which is what makes a synthesised hat sound
/// thin and whistly rather than metallic.
private let metalRatios: (Float, Float, Float, Float, Float, Float) =
    (1.0, 1.4471, 1.6170, 1.9265, 2.5028, 2.6637)

struct DrumVoice {
    var kind: DrumVoiceKind = .kick
    var active = false
    var startDelay = 0

    var params = DrumParams()
    var vel: Float = 1
    var t: Float = 0

    var p1: Float = 0, p2: Float = 0, p3: Float = 0
    var m0: Float = 0, m1: Float = 0, m2: Float = 0
    var m3: Float = 0, m4: Float = 0, m5: Float = 0

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

    var life: Float = 1

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
            // Two pitch envelopes: a very fast one for the beater snap and a
            // slower one for the body drop. Separating them is what makes a
            // kick read as a drum rather than as a sine sweep.
            pitchEnv.trigger(0.005 + 0.006 * (1 - tone), sr)
            pitchEnv2.trigger(0.045 + 0.055 * dec, sr)
            ampEnv.trigger(0.20 + 0.85 * dec, sr)
            clickEnv.trigger(0.0018 + 0.003 * tone, sr)
            hp.highpass(1600 + 2600 * tone, q: 0.7, sr: sr)
            lp.lowpass(220 + 260 * tone, q: 0.7, sr: sr)
            life = 1.6

        case .snare:
            pitchEnv.trigger(0.018, sr)
            ampEnv.trigger(0.050 + 0.11 * dec, sr)
            noiseEnv.trigger(0.050 + 0.28 * dec, sr)
            clickEnv.trigger(0.0022, sr)
            bp.bandpass(1450 + 2400 * tone, q: 0.5, sr: sr)
            hp.highpass(3400 + 3200 * tone, q: 0.7, sr: sr)
            life = 0.95

        case .clap:
            noiseEnv.trigger(0.040 + 0.24 * dec, sr)
            bp.bandpass(1000 + 1000 * tone, q: 1.0, sr: sr)
            hp.highpass(600, q: 0.7, sr: sr)
            life = 0.85

        case .closedHat:
            noiseEnv.trigger(0.010 + 0.040 * dec, sr)
            bp.bandpass((8200 + 2600 * tone) * ratio, q: 0.75, sr: sr)
            hp.highpass(6800 * ratio, q: 0.7, sr: sr)
            life = 0.32

        case .openHat:
            noiseEnv.trigger(0.13 + 0.55 * dec, sr)
            bp.bandpass((7600 + 2400 * tone) * ratio, q: 0.6, sr: sr)
            hp.highpass(5800 * ratio, q: 0.7, sr: sr)
            life = 1.3

        case .rim:
            ampEnv.trigger(0.009 + 0.018 * dec, sr)
            noiseEnv.trigger(0.0035, sr)
            bp.bandpass(1750 * ratio, q: 2.6, sr: sr)
            hp.highpass(800, q: 0.7, sr: sr)
            life = 0.28

        case .tom:
            pitchEnv.trigger(0.042, sr)
            ampEnv.trigger(0.22 + 0.55 * dec, sr)
            noiseEnv.trigger(0.018, sr)
            hp.highpass(110, q: 0.7, sr: sr)
            life = 1.2

        case .perc:
            ampEnv.trigger(0.040 + 0.18 * dec, sr)
            // Bandpass sits just above the two oscillators, which is what makes
            // a cowbell read as metal instead of as two square waves.
            bp.bandpass(1150 * ratio, q: 1.1, sr: sr)
            life = 0.65

        case .crash:
            noiseEnv.trigger(0.80 + 1.5 * dec, sr)
            bp.bandpass(5200 + 2800 * tone, q: 0.4, sr: sr)
            hp.highpass(3000, q: 0.6, sr: sr)
            life = 3.4
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
            // A single body oscillator. An independent sub layer at a fixed
            // frequency drifts out of phase with the body once the sweep
            // settles, and the two partially cancel — which is why the old
            // kick had a hollow wobble in its tail.
            let f = (47.0 + 150.0 * slow + 380.0 * fast) * ratio
            p1 += f * dt; if p1 >= 1 { p1 -= 1 }
            let body = fastSin(p1)

            let amp = ampEnv.process()
            let clickAmt = clickEnv.process()
            let click = hp.process(rng.next()) * clickAmt * (0.30 + 0.55 * tone)

            let driven = warm(body * amp * 1.3, params.drive)
            out = driven * 0.9 + click

        case .snare:
            let pe = pitchEnv.process()
            let amp = ampEnv.process()
            p1 += (183.0 * ratio + 85.0 * pe) * dt; if p1 >= 1 { p1 -= 1 }
            p2 += (327.0 * ratio + 130.0 * pe) * dt; if p2 >= 1 { p2 -= 1 }
            let body = (fastSin(p1) * 0.60 + fastSin(p2) * 0.32) * amp

            let n = rng.next()
            let rattle = bp.process(n) * noiseEnv.process()
            let crack = hp.process(n) * clickEnv.process() * 0.7

            out = saturate(body * 0.8 + rattle * (0.85 + 0.45 * tone) + crack,
                           params.drive * 0.6) * 0.85

        case .clap:
            // Four hands a few milliseconds apart. Each burst gets its own
            // fast envelope: gating noise with a rectangular window puts a
            // step discontinuity at both edges, and those clicks are audible.
            var burst = expf(-t * 520.0)
            if t > 0.0100 { burst += expf(-(t - 0.0100) * 520.0) * 0.92 }
            if t > 0.0205 { burst += expf(-(t - 0.0205) * 520.0) * 0.84 }
            if t > 0.0305 { burst += expf(-(t - 0.0305) * 460.0) * 0.76 }
            let tail = noiseEnv.process() * 0.38
            let n = hp.process(rng.next())
            out = bp.process(n * (burst * 0.55 + tail)) * 1.9

        case .closedHat, .openHat:
            // 820 Hz base: high enough that the square bank's harmonics have
            // real energy where the bandpass is listening.
            let metal = metalBank(baseHz: 820.0 * ratio, dt: dt)
            let env = noiseEnv.process()
            let n = rng.next() * 0.18
            out = hp.process(bp.process(metal * 0.75 + n)) * env * 1.6

        case .rim:
            let amp = ampEnv.process()
            p1 += 1720.0 * ratio * dt; if p1 >= 1 { p1 -= 1 }
            p2 += 2790.0 * ratio * dt; if p2 >= 1 { p2 -= 1 }
            let tone1 = fastSin(p1) * 0.7 + fastSin(p2) * 0.3
            let tick = hp.process(rng.next()) * noiseEnv.process()
            out = bp.process(tone1 * amp + tick * 0.7) * 1.8

        case .tom:
            let pe = pitchEnv.process()
            let amp = ampEnv.process()
            p1 += ((105.0 + 100.0 * pe) * ratio) * dt; if p1 >= 1 { p1 -= 1 }
            let skin = rng.next() * noiseEnv.process() * 0.22
            out = hp.process(fastSin(p1) * amp + skin)
            out = saturate(out, params.drive * 0.5) * 0.9

        case .perc:
            let amp = ampEnv.process()
            let inc1 = 540.0 * ratio * dt
            let inc2 = 806.0 * ratio * dt
            p1 += inc1; if p1 >= 1 { p1 -= 1 }
            p2 += inc2; if p2 >= 1 { p2 -= 1 }
            let sq = polyBlepSquare(p1, inc1, 0.5) * 0.38
                   + polyBlepSquare(p2, inc2, 0.5) * 0.30
            out = bp.process(sq) * amp * 1.5

        case .crash:
            let metal = metalBank(baseHz: 540.0 * ratio, dt: dt)
            let env = noiseEnv.process()
            let n = rng.next() * 0.40
            out = hp.process(bp.process(metal * 0.55 + n)) * env * 1.3
        }

        t += dt
        if t > life { active = false }

        return dc.process(out) * vel * params.gain
    }

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
