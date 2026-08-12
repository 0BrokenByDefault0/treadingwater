import Foundation

// Primitives shared by every voice and effect. All of it runs on the audio
// render thread: no allocation, no branching on Swift objects, no ARC.

// MARK: - Frame

struct Frame {
    var l: Float = 0
    var r: Float = 0

    @inline(__always) static func + (a: Frame, b: Frame) -> Frame {
        Frame(l: a.l + b.l, r: a.r + b.r)
    }
    @inline(__always) static func += (a: inout Frame, b: Frame) {
        a.l += b.l; a.r += b.r
    }
    @inline(__always) static func * (a: Frame, s: Float) -> Frame {
        Frame(l: a.l * s, r: a.r * s)
    }
    @inline(__always) var mono: Float { (l + r) * 0.5 }
}

// MARK: - Noise

struct Rng {
    var state: UInt32 = 0x9E3779B9

    @inline(__always) mutating func next() -> Float {
        state ^= state << 13
        state ^= state >> 17
        state ^= state << 5
        return Float(Int32(bitPattern: state)) / Float(Int32.max)
    }

    @inline(__always) mutating func uni() -> Float {
        (next() + 1) * 0.5
    }
}

// MARK: - Oscillator helpers

@inline(__always) func midiToHz(_ pitch: Float) -> Float {
    440.0 * powf(2.0, (pitch - 69.0) / 12.0)
}

@inline(__always) func polyBlepSaw(_ phase: Float, _ inc: Float) -> Float {
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

@inline(__always) func polyBlepSquare(_ phase: Float, _ inc: Float, _ width: Float) -> Float {
    // Two band-limited saws subtracted gives a band-limited pulse.
    var p2 = phase + width
    if p2 >= 1 { p2 -= 1 }
    return polyBlepSaw(phase, inc) - polyBlepSaw(p2, inc)
}

@inline(__always) func fastSin(_ phase: Float) -> Float {
    sinf(2.0 * Float.pi * phase)
}

// MARK: - Shapers

/// Soft tube-ish saturation with level compensation, so turning drive up
/// changes tone rather than just volume.
@inline(__always) func saturate(_ x: Float, _ drive: Float) -> Float {
    guard drive > 0.001 else { return x }
    let d = 1.0 + drive * 9.0
    return tanhf(x * d) / tanhf(d * 0.7)
}

/// Asymmetric shaper — adds even harmonics, which is what makes an 808 read
/// on a phone speaker.
@inline(__always) func warm(_ x: Float, _ drive: Float) -> Float {
    guard drive > 0.001 else { return x }
    let d = 1.0 + drive * 6.0
    let y = x * d
    return (y / (1.0 + abs(y))) * (1.0 + 0.18 * drive) * 0.85
}

@inline(__always) func softClip(_ x: Float) -> Float {
    if x > 1.4 { return 1.0 }
    if x < -1.4 { return -1.0 }
    return x - (x * x * x) * 0.17
}

// MARK: - One-pole

struct OnePole {
    var z: Float = 0

    @inline(__always) mutating func lp(_ x: Float, _ coef: Float) -> Float {
        z = x + coef * (z - x)
        return z
    }
    @inline(__always) mutating func hp(_ x: Float, _ coef: Float) -> Float {
        z = x + coef * (z - x)
        return x - z
    }
    @inline(__always) mutating func reset() { z = 0 }
}

@inline(__always) func poleCoef(_ hz: Float, _ sr: Float) -> Float {
    expf(-2.0 * Float.pi * max(1, min(hz, sr * 0.49)) / sr)
}

// MARK: - Biquad (RBJ cookbook)
//
// Coefficients are recalculated on note-on or on a parameter change, never
// per sample.

struct Biquad {
    var b0: Float = 1, b1: Float = 0, b2: Float = 0
    var a1: Float = 0, a2: Float = 0
    var x1: Float = 0, x2: Float = 0, y1: Float = 0, y2: Float = 0

    @inline(__always) mutating func reset() {
        x1 = 0; x2 = 0; y1 = 0; y2 = 0
    }

    @inline(__always) mutating func process(_ x: Float) -> Float {
        let y = b0 * x + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
        x2 = x1; x1 = x
        y2 = y1; y1 = y
        return y
    }

    mutating func lowpass(_ hz: Float, q: Float, sr: Float) {
        let w = 2.0 * Float.pi * clampHz(hz, sr) / sr
        let cs = cosf(w), sn = sinf(w)
        let alpha = sn / (2.0 * max(0.1, q))
        let a0 = 1.0 + alpha
        b0 = (1.0 - cs) / 2.0 / a0
        b1 = (1.0 - cs) / a0
        b2 = b0
        a1 = (-2.0 * cs) / a0
        a2 = (1.0 - alpha) / a0
    }

    mutating func highpass(_ hz: Float, q: Float, sr: Float) {
        let w = 2.0 * Float.pi * clampHz(hz, sr) / sr
        let cs = cosf(w), sn = sinf(w)
        let alpha = sn / (2.0 * max(0.1, q))
        let a0 = 1.0 + alpha
        b0 = (1.0 + cs) / 2.0 / a0
        b1 = -(1.0 + cs) / a0
        b2 = b0
        a1 = (-2.0 * cs) / a0
        a2 = (1.0 - alpha) / a0
    }

    mutating func bandpass(_ hz: Float, q: Float, sr: Float) {
        let w = 2.0 * Float.pi * clampHz(hz, sr) / sr
        let cs = cosf(w), sn = sinf(w)
        let alpha = sn / (2.0 * max(0.1, q))
        let a0 = 1.0 + alpha
        b0 = alpha / a0
        b1 = 0
        b2 = -alpha / a0
        a1 = (-2.0 * cs) / a0
        a2 = (1.0 - alpha) / a0
    }

    mutating func peak(_ hz: Float, q: Float, gainDB: Float, sr: Float) {
        let A = powf(10.0, gainDB / 40.0)
        let w = 2.0 * Float.pi * clampHz(hz, sr) / sr
        let cs = cosf(w), sn = sinf(w)
        let alpha = sn / (2.0 * max(0.1, q))
        let a0 = 1.0 + alpha / A
        b0 = (1.0 + alpha * A) / a0
        b1 = (-2.0 * cs) / a0
        b2 = (1.0 - alpha * A) / a0
        a1 = (-2.0 * cs) / a0
        a2 = (1.0 - alpha / A) / a0
    }

    mutating func highShelf(_ hz: Float, gainDB: Float, sr: Float) {
        let A = powf(10.0, gainDB / 40.0)
        let w = 2.0 * Float.pi * clampHz(hz, sr) / sr
        let cs = cosf(w), sn = sinf(w)
        let alpha = sn / 2.0 * sqrtf((A + 1.0 / A) * (1.0 / 0.9 - 1.0) + 2.0)
        let ap1 = A + 1.0, am1 = A - 1.0
        let beta = 2.0 * sqrtf(A) * alpha
        let a0 = ap1 - am1 * cs + beta
        b0 = A * (ap1 + am1 * cs + beta) / a0
        b1 = -2.0 * A * (am1 + ap1 * cs) / a0
        b2 = A * (ap1 + am1 * cs - beta) / a0
        a1 = 2.0 * (am1 - ap1 * cs) / a0
        a2 = (ap1 - am1 * cs - beta) / a0
    }

    @inline(__always) private func clampHz(_ hz: Float, _ sr: Float) -> Float {
        max(20.0, min(hz, sr * 0.45))
    }
}

// MARK: - Zero-delay-feedback ladder-ish lowpass
//
// Used for the synth voices: musical resonance, stable at any cutoff, and it
// self-oscillates gracefully instead of blowing up.

struct Ladder {
    var s1: Float = 0, s2: Float = 0, s3: Float = 0, s4: Float = 0

    @inline(__always) mutating func reset() {
        s1 = 0; s2 = 0; s3 = 0; s4 = 0
    }

    @inline(__always) mutating func process(_ input: Float, cutoff: Float, res: Float, sr: Float) -> Float {
        let fc = max(30.0, min(cutoff, sr * 0.45))
        let g = tanf(Float.pi * fc / sr)
        let gg = g / (1.0 + g)
        let k = min(4.0, res * 4.0)

        // Feedback taken from the last stage, with a soft clip so resonance
        // saturates instead of exploding.
        let x = input - k * tanhf(s4 * 0.8)

        let v1 = (x - s1) * gg;      let y1 = v1 + s1;  s1 = y1 + v1
        let v2 = (y1 - s2) * gg;     let y2 = v2 + s2;  s2 = y2 + v2
        let v3 = (y2 - s3) * gg;     let y3 = v3 + s3;  s3 = y3 + v3
        let v4 = (y3 - s4) * gg;     let y4 = v4 + s4;  s4 = y4 + v4
        return y4
    }
}

// MARK: - Envelopes

/// Exponential-segment ADSR. Sounds far more natural than linear segments,
/// particularly on the release.
struct ADSR {
    enum Stage: Int { case idle, attack, decay, sustain, release }

    var stage: Stage = .idle
    var value: Float = 0
    var attack: Float = 0.005
    var decay: Float = 0.15
    var sustain: Float = 0.7
    var release: Float = 0.2

    @inline(__always) mutating func gateOn() {
        stage = .attack
    }
    @inline(__always) mutating func gateOff() {
        if stage != .idle { stage = .release }
    }
    @inline(__always) mutating func hardReset() {
        stage = .idle; value = 0
    }

    @inline(__always) mutating func process(_ sr: Float) -> Float {
        switch stage {
        case .idle:
            return 0
        case .attack:
            // Approach 1.2 so the curve through 1.0 stays convex and snappy.
            let c = expf(-1.0 / max(1.0, attack * sr))
            value = 1.2 + (value - 1.2) * c
            if value >= 1.0 { value = 1.0; stage = .decay }
        case .decay:
            let c = expf(-1.0 / max(1.0, decay * sr))
            value = sustain + (value - sustain) * c
            if value <= sustain + 0.0005 {
                value = sustain
                // A zero sustain means the note is a one-shot: free the voice
                // instead of parking it in an inaudible sustain forever.
                stage = sustain <= 0.0005 ? .idle : .sustain
            }
        case .sustain:
            value = sustain
        case .release:
            let c = expf(-1.0 / max(1.0, release * sr))
            value *= c
            if value <= 0.0002 { value = 0; stage = .idle }
        }
        return value
    }

    var isActive: Bool { stage != .idle }
}

/// One-shot exponential decay, the workhorse of every drum voice.
struct Decay {
    var value: Float = 0
    var coef: Float = 0.999

    @inline(__always) mutating func trigger(_ seconds: Float, _ sr: Float, level: Float = 1) {
        value = level
        coef = expf(-1.0 / max(1.0, seconds * sr * 0.35))
    }
    @inline(__always) mutating func process() -> Float {
        value *= coef
        return value
    }
}

// MARK: - Delay line

final class DelayLine {
    private let buffer: UnsafeMutablePointer<Float>
    private let size: Int
    private var writeIndex = 0

    init(maxSamples: Int) {
        size = max(4, maxSamples)
        buffer = .allocate(capacity: size)
        buffer.initialize(repeating: 0, count: size)
    }

    deinit { buffer.deallocate() }

    func clear() { buffer.update(repeating: 0, count: size) }

    @inline(__always) func write(_ x: Float) {
        buffer[writeIndex] = x
        writeIndex += 1
        if writeIndex >= size { writeIndex = 0 }
    }

    /// Fractional read with linear interpolation, so a moving delay time
    /// glides instead of stepping.
    @inline(__always) func read(_ delaySamples: Float) -> Float {
        let d = max(1.0, min(delaySamples, Float(size - 2)))
        let i = Int(d)
        let frac = d - Float(i)
        var a = writeIndex - i
        if a < 0 { a += size }
        var b = a - 1
        if b < 0 { b += size }
        return buffer[a] + (buffer[b] - buffer[a]) * frac
    }
}

// MARK: - Comb / allpass (reverb building blocks)

// Both are structs pointing into memory owned by the effect that holds them,
// so an array of them carries no reference counting into the render loop.

struct Comb {
    var buffer: UnsafeMutablePointer<Float>
    var size: Int
    var index: Int = 0
    var store: Float = 0

    @inline(__always) mutating func clear() {
        buffer.update(repeating: 0, count: size)
        store = 0
    }

    @inline(__always) mutating func process(_ input: Float, feedback: Float, damp: Float) -> Float {
        let output = buffer[index]
        store = output * (1.0 - damp) + store * damp
        buffer[index] = input + store * feedback
        index += 1
        if index >= size { index = 0 }
        return output
    }
}

struct Allpass {
    var buffer: UnsafeMutablePointer<Float>
    var size: Int
    var index: Int = 0

    @inline(__always) mutating func clear() {
        buffer.update(repeating: 0, count: size)
    }

    @inline(__always) mutating func process(_ input: Float, feedback: Float = 0.5) -> Float {
        let bufout = buffer[index]
        let output = -input + bufout
        buffer[index] = input + bufout * feedback
        index += 1
        if index >= size { index = 0 }
        return output
    }
}

// MARK: - Compressor

/// Feed-forward peak compressor with an external key input, which is all a
/// sidechain actually is.
struct Compressor {
    var env: Float = 0
    var gainDB: Float = 0

    var thresholdDB: Float = -18
    var ratio: Float = 4
    var attack: Float = 0.010
    var release: Float = 0.120
    var makeupDB: Float = 0
    var kneeDB: Float = 6

    @inline(__always) mutating func process(_ x: Float, key: Float, sr: Float) -> Float {
        let level = abs(key)
        let coef = level > env
            ? expf(-1.0 / max(1.0, attack * sr))
            : expf(-1.0 / max(1.0, release * sr))
        env = level + (env - level) * coef

        let levelDB = 20.0 * log10f(max(env, 1e-6))
        let over = levelDB - thresholdDB

        var reduction: Float = 0
        if over > kneeDB * 0.5 {
            reduction = over * (1.0 - 1.0 / ratio)
        } else if over > -kneeDB * 0.5 {
            // Soft knee: quadratic blend across the threshold region.
            let t = over + kneeDB * 0.5
            reduction = (1.0 - 1.0 / ratio) * t * t / (2.0 * kneeDB)
        }

        gainDB = -reduction + makeupDB
        return x * powf(10.0, gainDB / 20.0)
    }

    /// dB of gain reduction currently applied, for metering.
    var reductionDB: Float { max(0, -(gainDB - makeupDB)) }
}

// MARK: - Ducking envelope
//
// Not a compressor: sidechain pumping in modern production is usually a drawn
// volume shape, and a triggered envelope is both cleaner and more predictable.

struct Ducker {
    var value: Float = 0     // 1 right after a trigger, decaying to 0
    var coef: Float = 0.999

    @inline(__always) mutating func trigger(_ amount: Float = 1) {
        if amount > value { value = amount }
    }
    @inline(__always) mutating func setRelease(_ seconds: Float, _ sr: Float) {
        coef = expf(-1.0 / max(1.0, seconds * sr * 0.30))
    }
    /// Returns the gain multiplier to apply, given a duck depth of 0...1.
    @inline(__always) mutating func process(_ depth: Float) -> Float {
        value *= coef
        // Curved so the recovery sounds like a compressor releasing.
        let shaped = value * value * (3.0 - 2.0 * value)
        return 1.0 - depth * shaped
    }
}

// MARK: - DC blocker

struct DCBlock {
    var x1: Float = 0, y1: Float = 0
    @inline(__always) mutating func process(_ x: Float) -> Float {
        let y = x - x1 + 0.995 * y1
        x1 = x; y1 = y
        return y
    }
}
