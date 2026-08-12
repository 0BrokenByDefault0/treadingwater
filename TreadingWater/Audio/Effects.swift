import Foundation

// MARK: - Reverb
//
// Schroeder/Freeverb topology: eight damped comb filters in parallel per
// channel into four allpasses in series. The right channel's delay lengths are
// offset from the left, which is where the stereo image comes from. Cheap,
// and it's the sound people associate with "a room" rather than "a plugin".

final class Reverb {
    private static let combTuning: [Int] = [1116, 1188, 1277, 1356, 1422, 1491, 1557, 1617]
    private static let allpassTuning: [Int] = [556, 441, 341, 225]
    private static let stereoSpread = 23

    private let memory: UnsafeMutablePointer<Float>
    private let memorySize: Int

    private var combsL: [Comb] = []
    private var combsR: [Comb] = []
    private var apL: [Allpass] = []
    private var apR: [Allpass] = []

    private var preDelayLine: DelayLine
    private var inputHP = Biquad()
    private var inputLP = Biquad()

    /// 0...1 — maps to comb feedback, i.e. tail length.
    var size: Float = 0.72
    /// 0...1 — how fast the top end decays out of the tail.
    var damp: Float = 0.45
    var width: Float = 1.0
    var preDelaySeconds: Float = 0.022

    private let sr: Float

    init(sampleRate: Float) {
        sr = sampleRate
        let scale = Double(sampleRate) / 44100.0

        var sizes: [Int] = []
        for t in Reverb.combTuning {
            sizes.append(Int(Double(t) * scale))
            sizes.append(Int(Double(t + Reverb.stereoSpread) * scale))
        }
        for t in Reverb.allpassTuning {
            sizes.append(Int(Double(t) * scale))
            sizes.append(Int(Double(t + Reverb.stereoSpread) * scale))
        }

        memorySize = sizes.reduce(0, +) + 16
        memory = .allocate(capacity: memorySize)
        memory.initialize(repeating: 0, count: memorySize)

        preDelayLine = DelayLine(maxSamples: Int(sampleRate * 0.2))

        var offset = 0
        for t in Reverb.combTuning {
            let nL = Int(Double(t) * scale)
            combsL.append(Comb(buffer: memory + offset, size: nL)); offset += nL
            let nR = Int(Double(t + Reverb.stereoSpread) * scale)
            combsR.append(Comb(buffer: memory + offset, size: nR)); offset += nR
        }
        for t in Reverb.allpassTuning {
            let nL = Int(Double(t) * scale)
            apL.append(Allpass(buffer: memory + offset, size: nL)); offset += nL
            let nR = Int(Double(t + Reverb.stereoSpread) * scale)
            apR.append(Allpass(buffer: memory + offset, size: nR)); offset += nR
        }

        // Keeping lows out of the tail is the single biggest difference
        // between "spacious" and "muddy" — the same advice the mixing stage
        // gives, applied to the app's own reverb.
        inputHP.highpass(320, q: 0.7, sr: sampleRate)
        inputLP.lowpass(7800, q: 0.7, sr: sampleRate)
    }

    deinit { memory.deallocate() }

    func clear() {
        memory.update(repeating: 0, count: memorySize)
        for i in combsL.indices { combsL[i].index = 0; combsL[i].store = 0 }
        for i in combsR.indices { combsR[i].index = 0; combsR[i].store = 0 }
        for i in apL.indices { apL[i].index = 0 }
        for i in apR.indices { apR[i].index = 0 }
        preDelayLine.clear()
        inputHP.reset(); inputLP.reset()
    }

    @inline(__always) func process(_ input: Frame) -> Frame {
        let feedback = 0.70 + size * 0.28
        let damping = damp * 0.4

        var mono = (input.l + input.r) * 0.5
        mono = inputHP.process(mono)
        mono = inputLP.process(mono)

        preDelayLine.write(mono)
        let fed = preDelayLine.read(preDelaySeconds * sr) * 0.015

        var outL: Float = 0
        var outR: Float = 0
        for i in 0..<combsL.count {
            outL += combsL[i].process(fed, feedback: feedback, damp: damping)
            outR += combsR[i].process(fed, feedback: feedback, damp: damping)
        }
        for i in 0..<apL.count {
            outL = apL[i].process(outL)
            outR = apR[i].process(outR)
        }

        // Blend the two channels back toward each other for a width control.
        let w1 = width * 0.5 + 0.5
        let w2 = (1.0 - width) * 0.5
        return Frame(l: outL * w1 + outR * w2, r: outR * w1 + outL * w2)
    }
}

// MARK: - Tempo-synced stereo delay

final class TempoDelay {
    private let lineL: DelayLine
    private let lineR: DelayLine
    private var dampL = OnePole()
    private var dampR = OnePole()
    private var smoothed: Float = 0

    /// Delay time in samples, set from tempo by the engine.
    var targetSamples: Float = 12000
    var feedback: Float = 0.34
    var damping: Float = 0.5
    var pingPong: Bool = true

    private let sr: Float

    init(sampleRate: Float) {
        sr = sampleRate
        let maxSamples = Int(sampleRate * 2.2)
        lineL = DelayLine(maxSamples: maxSamples)
        lineR = DelayLine(maxSamples: maxSamples)
        smoothed = targetSamples
    }

    func clear() {
        lineL.clear(); lineR.clear()
        dampL.reset(); dampR.reset()
    }

    @inline(__always) func process(_ input: Frame) -> Frame {
        // Glide the delay time so a tempo change bends rather than clicks.
        smoothed += (targetSamples - smoothed) * 0.0008

        let dL = lineL.read(smoothed)
        let dR = lineR.read(smoothed)

        let coef = poleCoef(1200 + (1.0 - damping) * 8000, sr)
        let fL = dampL.lp(dL, coef)
        let fR = dampR.lp(dR, coef)

        let fb = min(0.92, feedback)
        if pingPong {
            lineL.write(input.l + fR * fb)
            lineR.write(input.r + fL * fb)
        } else {
            lineL.write(input.l + fL * fb)
            lineR.write(input.r + fR * fb)
        }
        return Frame(l: dL, r: dR)
    }
}

// MARK: - Chorus
//
// A single modulated delay per channel, in opposite phase. Used to widen pads
// and keys without a stereo widener's mono-collapse problems.

final class Chorus {
    private let lineL: DelayLine
    private let lineR: DelayLine
    private var phase: Float = 0
    private let sr: Float

    var depth: Float = 0.0     // 0...1
    var rate: Float = 0.45     // Hz

    init(sampleRate: Float) {
        sr = sampleRate
        lineL = DelayLine(maxSamples: Int(sampleRate * 0.05))
        lineR = DelayLine(maxSamples: Int(sampleRate * 0.05))
    }

    func clear() { lineL.clear(); lineR.clear() }

    @inline(__always) func process(_ input: Frame) -> Frame {
        guard depth > 0.001 else { return input }
        phase += rate / sr
        if phase >= 1 { phase -= 1 }

        let lfo = fastSin(phase)
        let base = 0.011 * sr
        let swing = 0.004 * sr * depth

        lineL.write(input.l)
        lineR.write(input.r)
        let wetL = lineL.read(base + lfo * swing)
        let wetR = lineR.read(base - lfo * swing)

        let mix = depth * 0.5
        return Frame(l: input.l * (1 - mix * 0.5) + wetL * mix,
                     r: input.r * (1 - mix * 0.5) + wetR * mix)
    }
}

// MARK: - Master chain

/// Glue compression, saturation, a gentle mix-bus tilt, and a look-ahead-free
/// soft limiter. Deliberately conservative: the point is that the reference
/// beats sound finished, not that they sound loud.
final class MasterChain {
    private var glue = Compressor()
    private var tiltL = Biquad()
    private var tiltR = Biquad()
    private var dcL = DCBlock()
    private var dcR = DCBlock()
    private var limiterEnv: Float = 0
    private let sr: Float

    var drive: Float = 0.12
    var glueAmount: Float = 0.5
    var ceiling: Float = 0.89

    private(set) var gainReductionDB: Float = 0

    init(sampleRate: Float) {
        sr = sampleRate
        glue.thresholdDB = -14
        glue.ratio = 2.0
        glue.attack = 0.030
        glue.release = 0.180
        glue.kneeDB = 8
        tiltL.highShelf(9000, gainDB: 1.4, sr: sampleRate)
        tiltR.highShelf(9000, gainDB: 1.4, sr: sampleRate)
    }

    func reset() {
        tiltL.reset(); tiltR.reset()
        glue.env = 0; limiterEnv = 0
    }

    @inline(__always) func process(_ input: Frame) -> Frame {
        var l = dcL.process(input.l)
        var r = dcR.process(input.r)

        if drive > 0.001 {
            l = saturate(l, drive * 0.5)
            r = saturate(r, drive * 0.5)
        }

        // One detector driving both channels keeps the stereo image stable.
        let key = max(abs(l), abs(r))
        glue.ratio = 1.4 + glueAmount * 1.6
        glue.thresholdDB = -10 - glueAmount * 10
        let g = glue.process(1.0, key: key, sr: sr)
        l *= g
        r *= g
        gainReductionDB = glue.reductionDB

        l = tiltL.process(l)
        r = tiltR.process(r)

        // Soft limiter: fast-attack gain reduction on whichever channel peaks.
        let peak = max(abs(l), abs(r))
        let over = peak / ceiling
        if over > limiterEnv { limiterEnv = over } else { limiterEnv += (over - limiterEnv) * 0.0009 }
        if limiterEnv > 1.0 {
            let g = 1.0 / limiterEnv
            l *= g
            r *= g
        }

        return Frame(l: softClip(l), r: softClip(r))
    }
}
