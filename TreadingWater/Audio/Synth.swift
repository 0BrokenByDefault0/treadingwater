import Foundation

// Everything here runs on the audio render thread. No allocation, no ObjC,
// no locks — all state is preallocated and mutated in place.

// MARK: - Utilities

@inline(__always) func twNoise(_ state: inout UInt32) -> Float {
    // xorshift32
    state ^= state << 13
    state ^= state >> 17
    state ^= state << 5
    return Float(Int32(bitPattern: state)) / Float(Int32.max)
}

@inline(__always) func twMidiToHz(_ pitch: Float) -> Float {
    440.0 * powf(2.0, (pitch - 69.0) / 12.0)
}

@inline(__always) func twPolyBlepSaw(_ phase: Float, _ inc: Float) -> Float {
    // Naive saw with a poly-BLEP correction so high notes don't turn to fizz.
    var v = 2.0 * phase - 1.0
    if phase < inc {
        let t = phase / inc
        v -= (t + t - t * t - 1.0)
    } else if phase > 1.0 - inc {
        let t = (phase - 1.0) / inc
        v -= (t * t + t + t + 1.0)
    }
    return v
}

// MARK: - State variable filter (Chamberlin)

struct SVF {
    var low: Float = 0
    var band: Float = 0

    @inline(__always) mutating func lowpass(_ input: Float, cutoff: Float, q: Float, sr: Float) -> Float {
        // Chamberlin stays stable while f + damp < 2, so the cutoff is clamped
        // well below Nyquist rather than trusting the caller.
        let f = 2.0 * sinf(Float.pi * min(cutoff, sr * 0.30) / sr)
        let damp = min(2.0 * (1.0 - powf(max(0.05, q), 0.25)), 1.9 - f)
        var out: Float = 0
        for _ in 0..<2 {
            let high = input - low - damp * band
            band += f * high
            low += f * band
            out = low
        }
        return out
    }

    /// Two cascaded one-pole highpasses (12 dB/oct), reusing both state slots.
    /// Unconditionally stable, which matters because the noise sources run this
    /// at 7 kHz where a resonant SVF would self-oscillate.
    @inline(__always) mutating func highpass(_ input: Float, cutoff: Float, sr: Float) -> Float {
        let a = expf(-2.0 * Float.pi * min(cutoff, sr * 0.45) / sr)
        low = (1.0 - a) * input + a * low
        let stage1 = input - low
        band = (1.0 - a) * stage1 + a * band
        return stage1 - band
    }

    @inline(__always) mutating func reset() { low = 0; band = 0 }
}

// MARK: - Drums

enum DrumVoiceKind: Int {
    case kick = 0, snare, clap, closedHat, openHat, rim, tom, perc, crash
}

struct DrumVoice {
    var kind: DrumVoiceKind = .kick
    var active: Bool = false
    var t: Float = 0            // seconds since trigger
    var phase: Float = 0
    var phase2: Float = 0
    var vel: Float = 1
    var rng: UInt32 = 0x9E3779B9
    var filt = SVF()
    var tone: Float = 0         // 0...1 character knob

    @inline(__always) mutating func trigger(_ kind: DrumVoiceKind, vel: Float, tone: Float, seed: UInt32) {
        self.kind = kind
        self.vel = vel
        self.tone = tone
        self.active = true
        self.t = 0
        self.phase = 0
        self.phase2 = 0
        self.rng = seed | 1
        self.filt.reset()
    }

    @inline(__always) mutating func render(sr: Float) -> Float {
        guard active else { return 0 }
        let dt = 1.0 / sr
        var out: Float = 0

        switch kind {
        case .kick:
            let f = 44.0 + 118.0 * expf(-t * 36.0)
            phase += f * dt
            if phase > 1 { phase -= 1 }
            let body = sinf(2.0 * Float.pi * phase)
            let amp = expf(-t * (6.0 + 4.0 * (1.0 - tone)))
            let click = expf(-t * 240.0) * 0.30
            out = tanhf(body * 1.9) * amp + twNoise(&rng) * click
            if t > 1.2 { active = false }

        case .snare:
            let tone1 = sinf(2.0 * Float.pi * 186.0 * t) * expf(-t * 24.0) * 0.5
            let tone2 = sinf(2.0 * Float.pi * 331.0 * t) * expf(-t * 30.0) * 0.28
            let n = filt.highpass(twNoise(&rng), cutoff: 1100.0 + 900.0 * tone, sr: sr)
            out = (tone1 + tone2) * 0.9 + n * expf(-t * (13.0 + 10.0 * (1.0 - tone))) * 0.95
            if t > 0.7 { active = false }

        case .clap:
            // Three fast bursts then a short tail — the reason a clap reads
            // as "a room full of hands" instead of a single noise hit.
            var burst: Float = 0
            if t < 0.004 { burst = 1 }
            else if t > 0.011 && t < 0.015 { burst = 0.9 }
            else if t > 0.022 && t < 0.026 { burst = 0.8 }
            let tail = expf(-t * 15.0) * 0.55
            let n = filt.highpass(twNoise(&rng), cutoff: 1000.0, sr: sr)
            out = n * (burst + tail)
            if t > 0.6 { active = false }

        case .closedHat:
            let n = filt.highpass(twNoise(&rng), cutoff: 7000.0, sr: sr)
            out = n * expf(-t * (110.0 - 45.0 * tone)) * 0.7
            if t > 0.2 { active = false }

        case .openHat:
            let n = filt.highpass(twNoise(&rng), cutoff: 6400.0, sr: sr)
            out = n * expf(-t * 11.0) * 0.6
            if t > 0.7 { active = false }

        case .rim:
            let a = sinf(2.0 * Float.pi * 1720.0 * t) * expf(-t * 170.0)
            let b = sinf(2.0 * Float.pi * 480.0 * t) * expf(-t * 120.0)
            out = (a * 0.7 + b * 0.5 + twNoise(&rng) * expf(-t * 300.0) * 0.5) * 0.9
            if t > 0.2 { active = false }

        case .tom:
            let f = 108.0 + 90.0 * expf(-t * 14.0)
            phase += f * dt
            if phase > 1 { phase -= 1 }
            out = sinf(2.0 * Float.pi * phase) * expf(-t * 8.0)
            if t > 0.9 { active = false }

        case .perc:
            phase += 545.0 * dt; if phase > 1 { phase -= 1 }
            phase2 += 812.0 * dt; if phase2 > 1 { phase2 -= 1 }
            let sq1: Float = phase < 0.5 ? 1 : -1
            let sq2: Float = phase2 < 0.5 ? 1 : -1
            out = (sq1 + sq2) * 0.28 * expf(-t * 19.0)
            if t > 0.5 { active = false }

        case .crash:
            let n = filt.highpass(twNoise(&rng), cutoff: 5200.0, sr: sr)
            out = n * expf(-t * 2.3) * 0.42
            if t > 2.5 { active = false }
        }

        t += dt
        return out * vel
    }
}

// MARK: - Melodic

enum Timbre: Int {
    case bass = 0, keys, lead, pluck, sub, bell
}

struct SynthVoice {
    var active: Bool = false
    var timbre: Timbre = .keys
    var pitch: Float = 60
    var vel: Float = 0.8
    var phase: Float = 0
    var phase2: Float = 0
    var env: Float = 0
    var stage: Int = 0          // 0 idle, 1 attack, 2 decay/sustain, 3 release
    var gateSamples: Int = 0    // samples until note-off
    var filt = SVF()
    var fenv: Float = 0
    var trackIndex: Int = -1

    @inline(__always) mutating func trigger(pitch: Float, vel: Float, timbre: Timbre, gate: Int, track: Int) {
        self.active = true
        self.pitch = pitch
        self.vel = vel
        self.timbre = timbre
        self.gateSamples = gate
        self.trackIndex = track
        self.stage = 1
        self.phase = 0
        self.phase2 = 0.13
        self.fenv = 1
        self.filt.reset()
    }

    private var attackRate: Float {
        switch timbre {
        case .bass:  return 0.004
        case .keys:  return 0.012
        case .lead:  return 0.010
        case .pluck: return 0.002
        case .sub:   return 0.006
        case .bell:  return 0.002
        }
    }

    private var releaseRate: Float {
        switch timbre {
        case .bass:  return 0.06
        case .keys:  return 0.22
        case .lead:  return 0.14
        case .pluck: return 0.10
        case .sub:   return 0.08
        case .bell:  return 0.9
        }
    }

    @inline(__always) mutating func render(sr: Float) -> Float {
        guard active else { return 0 }

        if gateSamples > 0 {
            gateSamples -= 1
            if gateSamples == 0 && stage != 3 { stage = 3 }
        }

        // Envelope (linear attack, exponential-ish release).
        let atk = 1.0 / max(attackRate * sr, 1)
        let rel = 1.0 / max(releaseRate * sr, 1)
        switch stage {
        case 1:
            env += atk
            if env >= 1 { env = 1; stage = 2 }
        case 2:
            if timbre == .pluck || timbre == .bell {
                env -= rel * 0.35
                if env <= 0 { env = 0; active = false; return 0 }
            }
        case 3:
            env -= rel
            if env <= 0 { env = 0; active = false; return 0 }
        default:
            break
        }

        let hz = twMidiToHz(pitch)
        let inc = hz / sr
        phase += inc; if phase >= 1 { phase -= 1 }

        var raw: Float = 0
        var cutoff: Float = 2000
        var q: Float = 0.4

        switch timbre {
        case .sub:
            raw = sinf(2.0 * Float.pi * phase)
            cutoff = 400; q = 0.2

        case .bass:
            let inc2 = inc * 1.004
            phase2 += inc2; if phase2 >= 1 { phase2 -= 1 }
            let saw = twPolyBlepSaw(phase, inc)
            let sub = sinf(2.0 * Float.pi * phase2 * 0.5)
            raw = saw * 0.55 + sub * 0.75
            fenv -= 1.0 / (0.18 * sr)
            if fenv < 0 { fenv = 0 }
            cutoff = 260 + 1500 * fenv * vel
            q = 0.55

        case .keys:
            let inc2 = inc * 1.006
            phase2 += inc2; if phase2 >= 1 { phase2 -= 1 }
            raw = (twPolyBlepSaw(phase, inc) + twPolyBlepSaw(phase2, inc2)) * 0.34
            cutoff = 1400 + 2200 * vel
            q = 0.35

        case .lead:
            let pulse: Float = phase < 0.42 ? 0.8 : -0.8
            raw = pulse * 0.5 + twPolyBlepSaw(phase, inc) * 0.35
            cutoff = 2200 + 2600 * vel
            q = 0.5

        case .pluck:
            let inc2 = inc * 2.0
            phase2 += inc2; if phase2 >= 1 { phase2 -= 1 }
            raw = twPolyBlepSaw(phase, inc) * 0.6 + sinf(2.0 * Float.pi * phase2) * 0.2
            fenv -= 1.0 / (0.10 * sr)
            if fenv < 0 { fenv = 0 }
            cutoff = 500 + 5000 * fenv
            q = 0.5

        case .bell:
            let inc2 = inc * 2.76
            phase2 += inc2; if phase2 >= 1 { phase2 -= 1 }
            raw = sinf(2.0 * Float.pi * phase) * 0.6 + sinf(2.0 * Float.pi * phase2) * 0.25
            cutoff = 6000; q = 0.2
        }

        let filtered = filt.lowpass(raw, cutoff: cutoff, q: q, sr: sr)
        return filtered * env * vel * 0.5
    }
}
