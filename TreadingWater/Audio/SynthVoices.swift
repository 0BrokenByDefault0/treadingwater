import Foundation

enum Timbre: Int, CaseIterable {
    case sub = 0        // clean sine sub bass
    case bass808        // long 808 with pitch glide and drive
    case bass           // punchy filtered synth bass
    case reese          // detuned saw bass, the drum & bass sound
    case keys           // FM electric piano
    case pad            // slow supersaw pad
    case pluck          // short filtered pluck
    case lead           // supersaw lead
    case bell           // FM bell
    case organ          // additive drawbar organ

    /// How many detuned copies of the oscillator to stack.
    var unison: Int {
        switch self {
        case .sub, .bass808:   return 1
        case .bass:            return 2
        case .reese:           return 3
        case .pluck:           return 2
        case .pad:             return 7
        case .lead:            return 5
        case .keys, .bell:     return 1
        case .organ:           return 1
        }
    }

    var detuneCents: Float {
        switch self {
        case .reese: return 26
        case .pad:   return 18
        case .lead:  return 14
        case .bass:  return 6
        case .pluck: return 8
        default:     return 0
        }
    }

    /// Stereo spread of the unison stack, 0 = mono. Low end stays centred.
    var spread: Float {
        switch self {
        case .sub, .bass808, .bass: return 0
        case .reese:                return 0.25
        case .pad:                  return 0.85
        case .lead:                 return 0.5
        case .keys:                 return 0.22
        case .bell:                 return 0.3
        case .pluck:                return 0.3
        case .organ:                return 0.18
        }
    }
}

struct SynthParams {
    var gain: Float = 1.0
    var pan: Float = 0.0
    var reverb: Float = 0.0
    var delay: Float = 0.0
    var drive: Float = 0.0
    var cutoff: Float = 1.0     // 0...1 scaling on the timbre's base cutoff
    var glide: Float = 0.0      // seconds
}

struct SynthVoice {
    var active = false
    var timbre: Timbre = .keys
    var trackIndex = -1
    var params = SynthParams()

    var pitch: Float = 60       // current, may be gliding
    var target: Float = 60
    var vel: Float = 0.8
    var gateSamples = 0
    var startDelay = 0

    var amp = ADSR()
    var fenv = ADSR()
    var ladder = Ladder()
    var ladderR = Ladder()
    var hp = Biquad()
    var hpR = Biquad()

    // Unison phases.
    var u0: Float = 0, u1: Float = 0, u2: Float = 0, u3: Float = 0
    var u4: Float = 0, u5: Float = 0, u6: Float = 0
    // FM / auxiliary.
    var fmPhase: Float = 0
    var subPhase: Float = 0
    var tine: Decay = Decay()

    var baseCutoff: Float = 2000
    var envDepth: Float = 0
    var resonance: Float = 0.2

    // MARK: Trigger

    mutating func trigger(pitch: Float, vel: Float, timbre: Timbre, params: SynthParams,
                          gate: Int, track: Int, delay: Int, glideFrom: Float?, sr: Float) {
        self.active = true
        self.timbre = timbre
        self.trackIndex = track
        self.params = params
        self.target = pitch
        self.pitch = glideFrom ?? pitch
        self.vel = vel
        self.gateSamples = gate
        self.startDelay = delay

        // Randomised start phases stop stacked notes from phase-cancelling.
        u0 = 0.00; u1 = 0.17; u2 = 0.33; u3 = 0.51
        u4 = 0.66; u5 = 0.79; u6 = 0.91
        fmPhase = 0; subPhase = 0
        ladder.reset(); ladderR.reset()
        hp.reset(); hpR.reset()
        amp.hardReset(); fenv.hardReset()

        switch timbre {
        case .sub:
            amp.attack = 0.006; amp.decay = 0.10; amp.sustain = 0.95; amp.release = 0.10
            fenv.attack = 0.001; fenv.decay = 0.10; fenv.sustain = 1.0; fenv.release = 0.05
            baseCutoff = 320; envDepth = 0; resonance = 0.05
            hp.highpass(20, q: 0.7, sr: sr)

        case .bass808:
            // Long, loud, barely filtered. The drive is what makes it audible
            // on a phone speaker where the fundamental doesn't exist.
            amp.attack = 0.002; amp.decay = 0.9; amp.sustain = 0.82; amp.release = 0.09
            fenv.attack = 0.001; fenv.decay = 0.25; fenv.sustain = 0.4; fenv.release = 0.05
            baseCutoff = 900; envDepth = 400; resonance = 0.08
            hp.highpass(22, q: 0.7, sr: sr)
            tine.trigger(0.004, sr)

        case .bass:
            amp.attack = 0.003; amp.decay = 0.16; amp.sustain = 0.72; amp.release = 0.07
            fenv.attack = 0.001; fenv.decay = 0.12; fenv.sustain = 0.20; fenv.release = 0.06
            baseCutoff = 260; envDepth = 1700; resonance = 0.42
            hp.highpass(32, q: 0.7, sr: sr)

        case .reese:
            amp.attack = 0.006; amp.decay = 0.3; amp.sustain = 0.85; amp.release = 0.10
            fenv.attack = 0.02; fenv.decay = 0.5; fenv.sustain = 0.5; fenv.release = 0.1
            baseCutoff = 420; envDepth = 900; resonance = 0.30
            hp.highpass(28, q: 0.7, sr: sr)

        case .keys:
            amp.attack = 0.002; amp.decay = 0.9; amp.sustain = 0.30; amp.release = 0.35
            fenv.attack = 0.001; fenv.decay = 0.5; fenv.sustain = 0.3; fenv.release = 0.2
            baseCutoff = 4200; envDepth = 1800; resonance = 0.10
            hp.highpass(110, q: 0.7, sr: sr)
            tine.trigger(0.05, sr)

        case .pad:
            amp.attack = 0.35; amp.decay = 1.2; amp.sustain = 0.75; amp.release = 0.9
            fenv.attack = 0.5; fenv.decay = 1.5; fenv.sustain = 0.6; fenv.release = 0.8
            baseCutoff = 900; envDepth = 1800; resonance = 0.16
            hp.highpass(180, q: 0.7, sr: sr)

        case .pluck:
            amp.attack = 0.001; amp.decay = 0.22; amp.sustain = 0.0; amp.release = 0.16
            fenv.attack = 0.001; fenv.decay = 0.11; fenv.sustain = 0.0; fenv.release = 0.10
            baseCutoff = 380; envDepth = 5200; resonance = 0.36
            hp.highpass(140, q: 0.7, sr: sr)

        case .lead:
            amp.attack = 0.008; amp.decay = 0.35; amp.sustain = 0.68; amp.release = 0.22
            fenv.attack = 0.004; fenv.decay = 0.28; fenv.sustain = 0.42; fenv.release = 0.2
            baseCutoff = 1400; envDepth = 3200; resonance = 0.26
            hp.highpass(160, q: 0.7, sr: sr)

        case .bell:
            amp.attack = 0.001; amp.decay = 1.6; amp.sustain = 0.0; amp.release = 0.8
            fenv.attack = 0.001; fenv.decay = 0.8; fenv.sustain = 0.0; fenv.release = 0.4
            baseCutoff = 7000; envDepth = 2000; resonance = 0.06
            hp.highpass(240, q: 0.7, sr: sr)

        case .organ:
            amp.attack = 0.006; amp.decay = 0.05; amp.sustain = 0.9; amp.release = 0.08
            fenv.attack = 0.001; fenv.decay = 0.2; fenv.sustain = 0.8; fenv.release = 0.1
            baseCutoff = 3200; envDepth = 900; resonance = 0.10
            hp.highpass(120, q: 0.7, sr: sr)
        }

        hpR = hp    // same coefficients, independent state
        amp.gateOn()
        fenv.gateOn()
    }

    /// True when the voice genuinely produces two different channels, which
    /// decides whether the right side needs its own filter state.
    @inline(__always) var isStereo: Bool { timbre.spread > 0.001 }

    @inline(__always) mutating func release() {
        amp.gateOff()
        fenv.gateOff()
    }

    // MARK: Render

    @inline(__always) mutating func render(sr: Float) -> Frame {
        guard active else { return Frame() }
        if startDelay > 0 {
            startDelay -= 1
            return Frame()
        }

        if gateSamples > 0 {
            gateSamples -= 1
            if gateSamples == 0 { release() }
        }

        let a = amp.process(sr)
        if !amp.isActive {
            active = false
            return Frame()
        }
        let f = fenv.process(sr)

        // Portamento.
        if params.glide > 0.0005 && abs(target - pitch) > 0.001 {
            let coef = expf(-1.0 / max(1.0, params.glide * sr * 0.35))
            pitch = target + (pitch - target) * coef
        } else {
            pitch = target
        }

        let hz = midiToHz(pitch)
        let inc = hz / sr

        var left: Float = 0
        var right: Float = 0

        switch timbre {

        case .sub:
            u0 += inc; if u0 >= 1 { u0 -= 1 }
            let s = fastSin(u0)
            left = s; right = s

        case .bass808:
            u0 += inc; if u0 >= 1 { u0 -= 1 }
            var s = fastSin(u0)
            // The transient click is most of what a phone speaker hears.
            s += rngLessClick() * tine.process() * 0.5
            s = warm(s * 1.15, 0.25 + params.drive * 0.6)
            left = s; right = s

        case .bass:
            let d = detuneInc(inc, cents: timbre.detuneCents, index: 1)
            u0 += inc; if u0 >= 1 { u0 -= 1 }
            u1 += d;   if u1 >= 1 { u1 -= 1 }
            subPhase += inc * 0.5; if subPhase >= 1 { subPhase -= 1 }
            let s = polyBlepSaw(u0, inc) * 0.45
                  + polyBlepSaw(u1, d) * 0.25
                  + fastSin(subPhase) * 0.55
            left = s; right = s

        case .reese:
            let d1 = detuneInc(inc, cents: timbre.detuneCents, index: 1)
            let d2 = detuneInc(inc, cents: timbre.detuneCents, index: -1)
            u0 += inc; if u0 >= 1 { u0 -= 1 }
            u1 += d1;  if u1 >= 1 { u1 -= 1 }
            u2 += d2;  if u2 >= 1 { u2 -= 1 }
            let core = polyBlepSaw(u0, inc) * 0.4
            let a1 = polyBlepSaw(u1, d1) * 0.34
            let a2 = polyBlepSaw(u2, d2) * 0.34
            let sp = timbre.spread
            left = core + a1 * (1 + sp) + a2 * (1 - sp)
            right = core + a1 * (1 - sp) + a2 * (1 + sp)

        case .keys:
            // Two-operator FM with a decaying index — the classic electric
            // piano recipe. Bright on the attack, mellow as it rings out.
            fmPhase += inc * 2.0; if fmPhase >= 1 { fmPhase -= 1 }
            let index = (1.6 + 3.4 * vel) * tine.process() + 0.35
            let mod = fastSin(fmPhase) * index
            u0 += inc; if u0 >= 1 { u0 -= 1 }
            var s = sinf(2.0 * Float.pi * u0 + mod)
            s += fastSin(u0) * 0.18
            left = s * 0.7; right = s * 0.7

        case .bell:
            fmPhase += inc * 3.51; if fmPhase >= 1 { fmPhase -= 1 }
            let index = 2.2 * tine.process() + 0.7
            let mod = fastSin(fmPhase) * index
            u0 += inc; if u0 >= 1 { u0 -= 1 }
            let s = sinf(2.0 * Float.pi * u0 + mod)
            left = s * 0.6; right = s * 0.6

        case .organ:
            // Drawbars at 1, 2, 3 and 4x. Cheap, and instantly reads as organ.
            u0 += inc;       if u0 >= 1 { u0 -= 1 }
            u1 += inc * 2;   if u1 >= 1 { u1 -= 1 }
            u2 += inc * 3;   if u2 >= 1 { u2 -= 1 }
            u3 += inc * 4;   if u3 >= 1 { u3 -= 1 }
            let s = fastSin(u0) * 0.5 + fastSin(u1) * 0.28
                  + fastSin(u2) * 0.16 + fastSin(u3) * 0.10
            left = s; right = s

        case .pluck, .pad, .lead:
            let n = timbre.unison
            let cents = timbre.detuneCents
            let sp = timbre.spread
            var l: Float = 0
            var r: Float = 0

            // Unison stack, alternating across the stereo field.
            let incs = (inc,
                        detuneInc(inc, cents: cents, index: 1),
                        detuneInc(inc, cents: cents, index: -1),
                        detuneInc(inc, cents: cents, index: 2),
                        detuneInc(inc, cents: cents, index: -2),
                        detuneInc(inc, cents: cents, index: 3),
                        detuneInc(inc, cents: cents, index: -3))

            u0 += incs.0; if u0 >= 1 { u0 -= 1 }
            let s0 = polyBlepSaw(u0, incs.0); l += s0; r += s0

            if n > 1 {
                u1 += incs.1; if u1 >= 1 { u1 -= 1 }
                let s = polyBlepSaw(u1, incs.1) * 0.8
                l += s * (1 + sp); r += s * (1 - sp)
            }
            if n > 2 {
                u2 += incs.2; if u2 >= 1 { u2 -= 1 }
                let s = polyBlepSaw(u2, incs.2) * 0.8
                l += s * (1 - sp); r += s * (1 + sp)
            }
            if n > 3 {
                u3 += incs.3; if u3 >= 1 { u3 -= 1 }
                let s = polyBlepSaw(u3, incs.3) * 0.6
                l += s * (1 + sp * 0.7); r += s * (1 - sp * 0.7)
            }
            if n > 4 {
                u4 += incs.4; if u4 >= 1 { u4 -= 1 }
                let s = polyBlepSaw(u4, incs.4) * 0.6
                l += s * (1 - sp * 0.7); r += s * (1 + sp * 0.7)
            }
            if n > 5 {
                u5 += incs.5; if u5 >= 1 { u5 -= 1 }
                let s = polyBlepSaw(u5, incs.5) * 0.45
                l += s * (1 + sp * 0.4); r += s * (1 - sp * 0.4)
            }
            if n > 6 {
                u6 += incs.6; if u6 >= 1 { u6 -= 1 }
                let s = polyBlepSaw(u6, incs.6) * 0.45
                l += s * (1 - sp * 0.4); r += s * (1 + sp * 0.4)
            }

            let norm = 1.0 / (0.9 + Float(n) * 0.55)
            left = l * norm
            right = r * norm
        }

        // Filter — velocity and the filter envelope both open it.
        let cutoff = (baseCutoff + envDepth * f * (0.35 + 0.65 * vel)) * params.cutoff
        let stereo = isStereo

        left = ladder.process(left, cutoff: cutoff, res: resonance, sr: sr)
        left = hp.process(left)
        if params.drive > 0.001 && timbre != .bass808 {
            left = saturate(left, params.drive)
        }

        if stereo {
            right = ladderR.process(right, cutoff: cutoff, res: resonance, sr: sr)
            right = hpR.process(right)
            if params.drive > 0.001 && timbre != .bass808 {
                right = saturate(right, params.drive)
            }
        } else {
            right = left
        }

        let g = a * vel * params.gain * 0.42

        // Constant-power pan on top of whatever stereo the voice produced.
        let p = max(-1, min(1, params.pan))
        let lg = sqrtf((1 - p) * 0.5) * 1.4142
        let rg = sqrtf((1 + p) * 0.5) * 1.4142

        return Frame(l: left * g * lg, r: right * g * rg)
    }

    @inline(__always) private func detuneInc(_ inc: Float, cents: Float, index: Int) -> Float {
        guard cents > 0 else { return inc }
        let c = cents * Float(index) * 0.34
        return inc * powf(2.0, c / 1200.0)
    }

    /// A tiny deterministic impulse used for the 808 click; avoids carrying a
    /// full RNG in every melodic voice.
    @inline(__always) private mutating func rngLessClick() -> Float {
        subPhase += 0.37
        if subPhase >= 1 { subPhase -= 1 }
        return subPhase * 2 - 1
    }
}
