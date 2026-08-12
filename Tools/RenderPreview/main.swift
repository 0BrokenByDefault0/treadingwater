import Foundation

// Renders every reference beat through the real MixEngine and reports enough
// analysis to catch the things you cannot see in source: levels that are wildly
// out of balance, hits that land off the grid, and clipping.

let sr: Float = 48000
let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "render-out"
try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

// MARK: - WAV

func writeWAV(path: String, left: [Float], right: [Float], sampleRate: Int) {
    let n = min(left.count, right.count)
    var data = Data()

    func u32(_ v: UInt32) { withUnsafeBytes(of: v.littleEndian) { data.append(contentsOf: $0) } }
    func u16(_ v: UInt16) { withUnsafeBytes(of: v.littleEndian) { data.append(contentsOf: $0) } }

    let byteRate = UInt32(sampleRate * 2 * 2)
    data.append(contentsOf: Array("RIFF".utf8))
    u32(UInt32(36 + n * 4))
    data.append(contentsOf: Array("WAVE".utf8))
    data.append(contentsOf: Array("fmt ".utf8))
    u32(16); u16(1); u16(2)
    u32(UInt32(sampleRate)); u32(byteRate); u16(4); u16(16)
    data.append(contentsOf: Array("data".utf8))
    u32(UInt32(n * 4))

    for i in 0..<n {
        let li = Int16(max(-32767, min(32767, left[i] * 32767)))
        let ri = Int16(max(-32767, min(32767, right[i] * 32767)))
        withUnsafeBytes(of: li.littleEndian) { data.append(contentsOf: $0) }
        withUnsafeBytes(of: ri.littleEndian) { data.append(contentsOf: $0) }
    }

    try? data.write(to: URL(fileURLWithPath: path))
}

// MARK: - Render helpers

func renderBeat(_ beat: Beat, loops: Int, tail: Double, humanize: Bool) -> ([Float], [Float]) {
    let engine = MixEngine(sampleRate: sr)
    engine.humanizeEnabled = humanize
    engine.resetForRender()
    engine.load(beat)
    engine.commitNow()
    engine.startTransport()

    let secondsPerStep = 60.0 / beat.bpm / 4.0
    let loopSeconds = secondsPerStep * Double(beat.steps)
    let total = Int((loopSeconds * Double(loops) + tail) * Double(sr))

    var left = [Float](repeating: 0, count: total)
    var right = [Float](repeating: 0, count: total)
    let block = 512

    left.withUnsafeMutableBufferPointer { lb in
        right.withUnsafeMutableBufferPointer { rb in
            var i = 0
            while i < total {
                let n = min(block, total - i)
                engine.render(frames: n,
                              left: lb.baseAddress! + i,
                              right: rb.baseAddress! + i)
                i += n
            }
        }
    }
    return (left, right)
}

// MARK: - Analysis

struct Stats {
    var peak: Float = 0
    var rms: Float = 0
    var clipped = 0
}

func stats(_ l: [Float], _ r: [Float]) -> Stats {
    var s = Stats()
    var acc: Double = 0
    for i in 0..<l.count {
        let a = max(abs(l[i]), abs(r[i]))
        if a > s.peak { s.peak = a }
        if a >= 0.999 { s.clipped += 1 }
        acc += Double(l[i] * l[i] + r[i] * r[i]) * 0.5
    }
    s.rms = Float((acc / Double(max(1, l.count))).squareRoot())
    return s
}

func db(_ x: Float) -> String {
    x <= 0.000001 ? "-inf" : String(format: "%.1f", 20 * log10f(x))
}

func pad(_ s: String, _ w: Int) -> String {
    s.count >= w ? s : s + String(repeating: " ", count: w - s.count)
}
func lpad(_ s: String, _ w: Int) -> String {
    s.count >= w ? s : String(repeating: " ", count: w - s.count) + s
}

/// Very simple onset detector: rectified energy in short frames, flagged where
/// the frame jumps well above the running average.
func onsets(_ l: [Float], _ r: [Float]) -> [Double] {
    let hop = 64
    var env: [Float] = []
    env.reserveCapacity(l.count / hop)
    var i = 0
    while i + hop <= l.count {
        var e: Float = 0
        for j in i..<(i + hop) { e += abs(l[j]) + abs(r[j]) }
        env.append(e / Float(hop * 2))
        i += hop
    }

    var result: [Double] = []
    var running: Float = 0
    var lastOnset = -999
    for k in 1..<env.count {
        running = running * 0.97 + env[k] * 0.03
        let rising = env[k] > env[k - 1] * 1.8
        let loud = env[k] > max(0.012, running * 2.2)
        if rising && loud && (k - lastOnset) > 12 {
            result.append(Double(k * hop) / Double(sr))
            lastOnset = k
        }
    }
    return result
}

/// Expected onset time of every step that has at least one drum hit.
func expectedStepTimes(_ beat: Beat, loops: Int) -> [Double] {
    let secondsPerStep = 60.0 / beat.bpm / 4.0
    let swingDivisor = beat.mix.swingGrid == .eighth ? 2 : 4
    var out: [Double] = []
    for loop in 0..<loops {
        for step in 0..<beat.steps {
            let any = beat.drums.contains { $0.velocity(at: step) > 0 }
            guard any else { continue }
            let swings = (step % swingDivisor) == (swingDivisor / 2)
            let swingOffset = beat.swing * secondsPerStep * (swingDivisor == 2 ? 0.5 : 1.0)
            out.append(Double(loop * beat.steps + step) * secondsPerStep
                       + (swings ? swingOffset : 0))
        }
    }
    return out
}

/// For each detected onset, the distance to the nearest expected step.
func timingReport(_ detected: [Double], _ expected: [Double]) -> (Double, Double, Int) {
    guard !detected.isEmpty, !expected.isEmpty else { return (0, 0, 0) }
    var total = 0.0
    var worst = 0.0
    var strays = 0
    for d in detected {
        var best = Double.greatestFiniteMagnitude
        for e in expected { best = min(best, abs(d - e)) }
        total += best
        worst = max(worst, best)
        if best > 0.035 { strays += 1 }
    }
    return (total / Double(detected.count) * 1000, worst * 1000, strays)
}

// MARK: - Per-voice balance

print("== DRUM VOICE BALANCE (one hit, vel 1.0, default character) ==")
print(pad("VOICE", 10) + lpad("PEAK dB", 9) + lpad("RMS dB", 9))
for drum in Drum.allCases {
    let engine = MixEngine(sampleRate: sr)
    engine.humanizeEnabled = false
    engine.resetForRender()
    var probe = Beat(name: "probe", bpm: 120, steps: 16)
    probe.mix = MixSettings(reverbSize: 0, sidechain: 0, drumDrive: 0, drumGlue: 0,
                            masterDrive: 0, masterGlue: 0, width: 0, humanize: 0)
    var vel = [Double](repeating: 0, count: 16)
    vel[0] = 1.0
    probe.drums = [DrumTrack(drum: drum, vel: vel, mix: drum.defaultMix)]
    engine.load(probe)
    engine.commitNow()
    engine.startTransport()

    let n = Int(sr * 1.2)
    var l = [Float](repeating: 0, count: n)
    var r = [Float](repeating: 0, count: n)
    l.withUnsafeMutableBufferPointer { lb in
        r.withUnsafeMutableBufferPointer { rb in
            var i = 0
            while i < n {
                let c = min(512, n - i)
                engine.render(frames: c, left: lb.baseAddress! + i, right: rb.baseAddress! + i)
                i += c
            }
        }
    }
    let s = stats(l, r)
    print(pad(drum.name, 10) + lpad(db(s.peak), 9) + lpad(db(s.rms), 9))
}

// MARK: - Templates

print("\n== TEMPLATES ==")
print(pad("NAME", 15) + lpad("BPM", 5) + lpad("PEAK dB", 9) + lpad("RMS dB", 9)
      + lpad("CLIP", 6) + lpad("AVG ms", 8) + lpad("MAX ms", 8) + lpad("STRAY", 6))

var manifest: [String] = []

for t in Templates.all {
    let (l, r) = renderBeat(t.beat, loops: 2, tail: 1.5, humanize: true)
    let s = stats(l, r)
    let det = onsets(l, r)
    let exp = expectedStepTimes(t.beat, loops: 2)
    let (avg, worst, strays) = timingReport(det, exp)

    let file = "\(outDir)/\(t.id).wav"
    writeWAV(path: file, left: l, right: r, sampleRate: Int(sr))
    manifest.append("\(t.id).wav — \(t.name), \(Int(t.bpm)) BPM, \(t.keyName)")

    print(pad(t.name, 15) + lpad("\(Int(t.bpm))", 5)
          + lpad(db(s.peak), 9) + lpad(db(s.rms), 9) + lpad("\(s.clipped)", 6)
          + lpad(String(format: "%.1f", avg), 8)
          + lpad(String(format: "%.1f", worst), 8) + lpad("\(strays)", 6))
}

// MARK: - Lesson demos

print("\n== LESSON EXAMPLES ==")
let demos: [(String, Beat)] = [
    ("grid", DemoBeats.gridCounting),
    ("three-jobs", DemoBeats.threeJobs),
    ("four-on-floor", DemoBeats.fourOnFloor),
    ("boom-bap", DemoBeats.boomBapSkeleton),
    ("trap", DemoBeats.trapSkeleton),
    ("hats-16th", DemoBeats.hatsSixteenth),
    ("hats-offbeat", DemoBeats.hatsOffbeat),
    ("velocity-flat", DemoBeats.velocityFlat),
    ("velocity-shaped", DemoBeats.velocityShaped),
    ("chords-minor", DemoBeats.chordsMinor),
    ("bass-with-kick", DemoBeats.bassWithKick),
    ("melody-hook", DemoBeats.melodyHook)
]

for (name, beat) in demos {
    let (l, r) = renderBeat(beat, loops: 2, tail: 1.2, humanize: true)
    let s = stats(l, r)
    let det = onsets(l, r)
    let exp = expectedStepTimes(beat, loops: 2)
    let (avg, worst, strays) = timingReport(det, exp)
    writeWAV(path: "\(outDir)/demo-\(name).wav", left: l, right: r, sampleRate: Int(sr))
    manifest.append("demo-\(name).wav — \(beat.name)")
    print(pad(name, 17) + lpad(db(s.peak), 9) + lpad(db(s.rms), 9)
          + lpad("\(s.clipped)", 6) + lpad(String(format: "%.1f", avg), 8)
          + lpad(String(format: "%.1f", worst), 8) + lpad("\(strays)", 6))
}

try? manifest.joined(separator: "\n").write(toFile: "\(outDir)/MANIFEST.txt",
                                            atomically: true, encoding: .utf8)
print("\nwrote \(manifest.count) files to \(outDir)")
