import Foundation
import AVFoundation
import Combine
import os

// MARK: - Real-time mix parameters
//
// A plain struct of Floats so it can be copied wholesale under the lock.

struct RTMix {
    var reverbSize: Float = 0.62
    var reverbDamp: Float = 0.5
    var reverbPreDelay: Float = 0.022
    var delayBeats: Float = 0.75
    var delayFeedback: Float = 0.32
    var delayPingPong: Float = 1
    var sidechain: Float = 0
    var sidechainRelease: Float = 0.16
    var drumDrive: Float = 0.20
    var drumGlue: Float = 0.35
    var masterDrive: Float = 0.12
    var masterGlue: Float = 0.45
    var width: Float = 0.30
    var humanize: Float = 0.15
    var chorus: Float = 0

    init() {}

    init(_ m: MixSettings) {
        reverbSize = Float(m.reverbSize)
        reverbDamp = Float(m.reverbDamp)
        reverbPreDelay = Float(m.reverbPreDelay)
        delayBeats = Float(m.delaySync.beats)
        delayFeedback = Float(m.delayFeedback)
        delayPingPong = m.delayPingPong ? 1 : 0
        sidechain = Float(m.sidechain)
        sidechainRelease = Float(m.sidechainRelease)
        drumDrive = Float(m.drumDrive)
        drumGlue = Float(m.drumGlue)
        masterDrive = Float(m.masterDrive)
        masterGlue = Float(m.masterGlue)
        width = Float(m.width)
        humanize = Float(m.humanize)
        chorus = Float(m.chorus)
    }
}

// MARK: - Sequencer grid

final class SeqGrid {
    let drum: UnsafeMutablePointer<Float>          // [track][step] velocity
    let drumParam: UnsafeMutablePointer<Float>     // [track][slot]
    let melPitch: UnsafeMutablePointer<Int32>      // [track][step][slot], -1 = empty
    let melLen: UnsafeMutablePointer<Int32>
    let melVel: UnsafeMutablePointer<Float>
    let melTimbre: UnsafeMutablePointer<Int32>     // [track]
    let melParam: UnsafeMutablePointer<Float>      // [track][slot]
    var length: Int32 = 16
    var mix = RTMix()

    static let drumCount = SeqLimits.maxDrumTracks
    static let melCount = SeqLimits.maxMelodyTracks
    static let stepCount = SeqLimits.maxSteps
    static let slotCount = SeqLimits.maxNotesPerStep
    static let stride = SeqLimits.paramStride

    static let drumSize = drumCount * stepCount
    static let melSize = melCount * stepCount * slotCount
    static let drumParamSize = drumCount * stride
    static let melParamSize = melCount * stride

    init() {
        drum = .allocate(capacity: SeqGrid.drumSize)
        drum.initialize(repeating: 0, count: SeqGrid.drumSize)
        drumParam = .allocate(capacity: SeqGrid.drumParamSize)
        drumParam.initialize(repeating: 0, count: SeqGrid.drumParamSize)
        melPitch = .allocate(capacity: SeqGrid.melSize)
        melPitch.initialize(repeating: -1, count: SeqGrid.melSize)
        melLen = .allocate(capacity: SeqGrid.melSize)
        melLen.initialize(repeating: 0, count: SeqGrid.melSize)
        melVel = .allocate(capacity: SeqGrid.melSize)
        melVel.initialize(repeating: 0, count: SeqGrid.melSize)
        melTimbre = .allocate(capacity: SeqGrid.melCount)
        melTimbre.initialize(repeating: 0, count: SeqGrid.melCount)
        melParam = .allocate(capacity: SeqGrid.melParamSize)
        melParam.initialize(repeating: 0, count: SeqGrid.melParamSize)

        // Sensible defaults so an empty grid still has usable gains.
        for t in 0..<SeqGrid.drumCount {
            Drum(rawValue: t)?.defaultMix.write(into: drumParam, base: t * SeqGrid.stride)
        }
        for t in 0..<SeqGrid.melCount {
            TrackMix().write(into: melParam, base: t * SeqGrid.stride)
        }
    }

    deinit {
        drum.deallocate(); drumParam.deallocate()
        melPitch.deallocate(); melLen.deallocate()
        melVel.deallocate(); melTimbre.deallocate(); melParam.deallocate()
    }

    func clear() {
        drum.update(repeating: 0, count: SeqGrid.drumSize)
        melPitch.update(repeating: -1, count: SeqGrid.melSize)
        melLen.update(repeating: 0, count: SeqGrid.melSize)
        melVel.update(repeating: 0, count: SeqGrid.melSize)
    }

    func copy(from o: SeqGrid) {
        drum.update(from: o.drum, count: SeqGrid.drumSize)
        drumParam.update(from: o.drumParam, count: SeqGrid.drumParamSize)
        melPitch.update(from: o.melPitch, count: SeqGrid.melSize)
        melLen.update(from: o.melLen, count: SeqGrid.melSize)
        melVel.update(from: o.melVel, count: SeqGrid.melSize)
        melTimbre.update(from: o.melTimbre, count: SeqGrid.melCount)
        melParam.update(from: o.melParam, count: SeqGrid.melParamSize)
        length = o.length
        mix = o.mix
    }

    @inline(__always) static func drumIndex(_ track: Int, _ step: Int) -> Int {
        track * stepCount + step
    }
    @inline(__always) static func melIndex(_ track: Int, _ step: Int, _ slot: Int) -> Int {
        (track * stepCount + step) * slotCount + slot
    }
}

// MARK: - Engine

final class AudioEngine: ObservableObject {
    static let shared = AudioEngine()

    @Published private(set) var isPlaying = false
    @Published private(set) var playhead: Int = -1
    @Published private(set) var level: Double = 0
    @Published private(set) var gainReduction: Double = 0
    @Published var bpm: Double = 90 { didSet { bpmRT = bpm } }
    @Published var swing: Double = 0 { didSet { swingRT = swing } }
    @Published var metronome = false { didSet { metronomeRT = metronome } }
    @Published var masterVolume: Double = 0.85 { didSet { volumeRT = Float(masterVolume) } }

    private let engine = AVAudioEngine()
    private var source: AVAudioSourceNode?
    private var sampleRate: Float = 44100

    // Shared with the render thread.
    private let live = SeqGrid()
    private let staging = SeqGrid()
    private let lock: UnsafeMutablePointer<os_unfair_lock>
    private var dirty = false

    private var bpmRT: Double = 90
    private var swingRT: Double = 0
    private var metronomeRT = false
    private var volumeRT: Float = 0.85

    private let stepOut: UnsafeMutablePointer<Int32>
    private let levelOut: UnsafeMutablePointer<Float>
    private let grOut: UnsafeMutablePointer<Float>

    private static let cmdCapacity = 64
    private let cmds: UnsafeMutablePointer<Int32>
    private let cmdHead: UnsafeMutablePointer<Int32>
    private let cmdTail: UnsafeMutablePointer<Int32>

    // Voice pools (render thread only).
    private var drumVoices = [DrumVoice](repeating: DrumVoice(), count: 16)
    private var synthVoices = [SynthVoice](repeating: SynthVoice(), count: 20)
    private var nextDrumVoice = 0
    private var nextSynthVoice = 0
    /// Last pitch played per melodic track, so the 808 can glide into the next.
    private var lastPitch = [Float](repeating: -1, count: SeqGrid.melCount)
    private var rng = Rng()

    // Effects (allocated once, on the main thread).
    private var reverb: Reverb!
    private var delay: TempoDelay!
    private var chorus: Chorus!
    private var master: MasterChain!
    private var drumGlue = Compressor()
    private var ducker = Ducker()
    private var bassHP = Biquad()

    // Transport (render thread only).
    private var playing = false
    private var pos: Double = 0
    private var nextStep: Int = 0
    private var revTail = 0
    private var dlyTail = 0

    private var uiTimer: Timer?
    private var observers: [NSObjectProtocol] = []

    private init() {
        lock = .allocate(capacity: 1)
        lock.initialize(to: os_unfair_lock())
        stepOut = .allocate(capacity: 1); stepOut.initialize(to: -1)
        levelOut = .allocate(capacity: 1); levelOut.initialize(to: 0)
        grOut = .allocate(capacity: 1); grOut.initialize(to: 0)
        cmds = .allocate(capacity: AudioEngine.cmdCapacity)
        cmds.initialize(repeating: 0, count: AudioEngine.cmdCapacity)
        cmdHead = .allocate(capacity: 1); cmdHead.initialize(to: 0)
        cmdTail = .allocate(capacity: 1); cmdTail.initialize(to: 0)

        configureSession()
        buildEffects()
        buildGraph()
        startUITimer()
    }

    // MARK: Setup

    private func configureSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            // .mixWithOthers matters here: the phone is sitting next to a DAW.
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setPreferredIOBufferDuration(0.005)
            try session.setActive(true)
            sampleRate = Float(session.sampleRate > 0 ? session.sampleRate : 44100)
        } catch {
            sampleRate = 44100
        }

        observers.append(NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification, object: nil, queue: .main
        ) { [weak self] note in
            self?.handleInterruption(note)
        })
        observers.append(NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            self?.ensureRunning()
        })
    }

    private func buildEffects() {
        reverb = Reverb(sampleRate: sampleRate)
        delay = TempoDelay(sampleRate: sampleRate)
        chorus = Chorus(sampleRate: sampleRate)
        master = MasterChain(sampleRate: sampleRate)

        drumGlue.thresholdDB = -16
        drumGlue.ratio = 2.2
        drumGlue.attack = 0.028
        drumGlue.release = 0.140
        drumGlue.kneeDB = 8

        // Everything on the bass bus gets its rumble trimmed; nothing musical
        // lives below 25 Hz and it eats headroom.
        bassHP.highpass(26, q: 0.7, sr: sampleRate)
    }

    private func buildGraph() {
        let sr = Double(sampleRate)
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sr, channels: 2) else { return }

        let node = AVAudioSourceNode(format: format) { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self else { return noErr }
            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            self.render(frames: Int(frameCount), abl: abl)
            return noErr
        }

        source = node
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 1.0
        engine.prepare()
    }

    private func ensureRunning() {
        guard !engine.isRunning else { return }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
        } catch {
            // Leave the transport flag alone; the UI reflects intent.
        }
    }

    private func handleInterruption(_ note: Notification) {
        guard let info = note.userInfo,
              let raw = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: raw) else { return }
        if type == .began { stop() } else { ensureRunning() }
    }

    // MARK: UI polling

    private func startUITimer() {
        let t = Timer(timeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            let s = Int(self.stepOut.pointee)
            if s != self.playhead { self.playhead = s }

            let l = Double(self.levelOut.pointee)
            self.levelOut.pointee *= 0.5
            let smoothed = max(l, self.level * 0.72)
            if abs(smoothed - self.level) > 0.005 { self.level = min(1, smoothed) }

            let gr = Double(self.grOut.pointee)
            if abs(gr - self.gainReduction) > 0.05 { self.gainReduction = gr }
        }
        RunLoop.main.add(t, forMode: .common)
        uiTimer = t
    }

    // MARK: - Transport

    func play() {
        ensureRunning()
        guard engine.isRunning else { return }
        pushCommand(Cmd.play)
        isPlaying = true
    }

    func stop() {
        pushCommand(Cmd.stop)
        isPlaying = false
        playhead = -1
    }

    func toggle() { isPlaying ? stop() : play() }

    func suspend() {
        stop()
        if engine.isRunning { engine.pause() }
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    }

    // MARK: - Loading

    func load(_ beat: Beat) {
        bpm = beat.bpm
        swing = beat.swing
        upload(beat)
    }

    /// Push musical content and all mix settings into the staging grid. Cheap
    /// enough to call on every edit.
    func upload(_ beat: Beat) {
        os_unfair_lock_lock(lock)
        staging.clear()
        staging.length = Int32(max(1, min(beat.steps, SeqLimits.maxSteps)))
        staging.mix = RTMix(beat.mix)

        for track in beat.drums {
            let ti = track.drum.rawValue
            guard ti < SeqGrid.drumCount else { continue }
            track.mix.write(into: staging.drumParam, base: ti * SeqGrid.stride)
            guard !track.muted else { continue }
            for step in 0..<min(track.vel.count, SeqLimits.maxSteps) {
                let v = track.vel[step]
                if v > 0 {
                    staging.drum[SeqGrid.drumIndex(ti, step)] = Float(min(1, v))
                }
            }
        }

        for (ti, track) in beat.melodies.prefix(SeqLimits.maxMelodyTracks).enumerated() {
            staging.melTimbre[ti] = Int32(track.timbre.rawValue)
            track.mix.write(into: staging.melParam, base: ti * SeqGrid.stride)
            guard !track.muted else { continue }
            for note in track.notes {
                let s = note.start
                guard s >= 0 && s < SeqLimits.maxSteps else { continue }
                for slot in 0..<SeqLimits.maxNotesPerStep {
                    let idx = SeqGrid.melIndex(ti, s, slot)
                    if staging.melPitch[idx] < 0 {
                        staging.melPitch[idx] = Int32(note.pitch)
                        staging.melLen[idx] = Int32(max(1, note.length))
                        staging.melVel[idx] = Float(min(1, max(0, note.vel)))
                        break
                    }
                }
            }
        }

        dirty = true
        os_unfair_lock_unlock(lock)
    }

    // MARK: - Auditioning

    func audition(_ drum: Drum, vel: Double = 1.0) {
        ensureRunning()
        pushCommand(Cmd.drum(drum.rawValue, vel))
    }

    func audition(pitch: Int, timbre: TrackTimbre, vel: Double = 0.85) {
        ensureRunning()
        pushCommand(Cmd.note(pitch, timbre.rawValue, vel))
    }

    // MARK: - Commands

    private enum Cmd {
        static let play: Int32  = 0x0100_0000
        static let stop: Int32  = 0x0200_0000
        static func drum(_ kind: Int, _ vel: Double) -> Int32 {
            let v = Int32(max(0, min(127, Int(vel * 127))))
            return 0x0300_0000 | Int32(kind << 16) | v
        }
        static func note(_ pitch: Int, _ timbre: Int, _ vel: Double) -> Int32 {
            let v = Int32(max(0, min(127, Int(vel * 127))))
            let p = Int32(max(0, min(127, pitch)))
            return 0x0400_0000 | Int32(timbre << 20) | (p << 8) | v
        }
    }

    private func pushCommand(_ c: Int32) {
        let tail = Int(cmdTail.pointee)
        let next = (tail + 1) % AudioEngine.cmdCapacity
        if next == Int(cmdHead.pointee) { return }
        cmds[tail] = c
        cmdTail.pointee = Int32(next)
    }

    // MARK: - Render

    private func render(frames: Int, abl: UnsafeMutableAudioBufferListPointer) {
        let sr = sampleRate

        if os_unfair_lock_trylock(lock) {
            if dirty {
                live.copy(from: staging)
                dirty = false
            }
            os_unfair_lock_unlock(lock)
        }

        drainCommands()

        let mix = live.mix
        let stepsPerLoop = Int(live.length)
        let beatsPerSecond = max(20.0, bpmRT) / 60.0
        let samplesPerStep = Double(sr) / beatsPerSecond / 4.0
        let loopLength = samplesPerStep * Double(stepsPerLoop)
        let swingOffset = swingRT * samplesPerStep * 0.5

        // Effect parameters, refreshed once per buffer rather than per sample.
        reverb.size = mix.reverbSize
        reverb.damp = mix.reverbDamp
        reverb.preDelaySeconds = mix.reverbPreDelay
        reverb.width = 0.6 + mix.width
        delay.targetSamples = Float(Double(sr) * Double(mix.delayBeats) / beatsPerSecond)
        delay.feedback = mix.delayFeedback
        delay.pingPong = mix.delayPingPong > 0.5
        chorus.depth = mix.chorus
        master.drive = mix.masterDrive
        master.glueAmount = mix.masterGlue
        drumGlue.ratio = 1.6 + mix.drumGlue * 2.0
        drumGlue.thresholdDB = -10 - mix.drumGlue * 14
        ducker.setRelease(max(0.03, mix.sidechainRelease), sr)

        var peak: Float = 0
        let out0 = abl[0].mData?.assumingMemoryBound(to: Float.self)
        let out1 = abl.count > 1 ? abl[1].mData?.assumingMemoryBound(to: Float.self) : out0

        for frame in 0..<frames {
            if playing && stepsPerLoop > 0 {
                while nextStep < stepsPerLoop {
                    let target = Double(nextStep) * samplesPerStep
                        + (nextStep % 2 == 1 ? swingOffset : 0)
                    if pos >= target {
                        fire(step: nextStep, samplesPerStep: samplesPerStep, mix: mix, sr: sr)
                        stepOut.pointee = Int32(nextStep)
                        nextStep += 1
                    } else {
                        break
                    }
                }
                pos += 1
                if pos >= loopLength {
                    pos -= loopLength
                    nextStep = 0
                }
            }

            var drumBus = Frame()
            var bassBus = Frame()
            var musicBus = Frame()
            var revSend = Frame()
            var dlySend = Frame()

            // --- Drums -------------------------------------------------
            for i in 0..<drumVoices.count where drumVoices[i].active {
                let s = drumVoices[i].render(sr: sr)
                if s == 0 { continue }
                let p = max(-1, min(1, drumVoices[i].params.pan))
                let lg = sqrtf((1 - p) * 0.5) * 1.4142
                let rg = sqrtf((1 + p) * 0.5) * 1.4142
                let f = Frame(l: s * lg, r: s * rg)
                drumBus += f
                let rv = drumVoices[i].params.reverb
                if rv > 0 { revSend += f * rv }
                let dl = drumVoices[i].params.delay
                if dl > 0 { dlySend += f * dl }
            }

            // --- Melodic ------------------------------------------------
            for i in 0..<synthVoices.count where synthVoices[i].active {
                let f = synthVoices[i].render(sr: sr)
                if synthVoices[i].timbre.isLow {
                    bassBus += f
                } else {
                    musicBus += f
                }
                let rv = synthVoices[i].params.reverb
                if rv > 0 { revSend += f * rv }
                let dl = synthVoices[i].params.delay
                if dl > 0 { dlySend += f * dl }
            }

            // --- Sidechain ----------------------------------------------
            if mix.sidechain > 0.001 {
                let duck = ducker.process(mix.sidechain)
                bassBus = bassBus * duck
                // The music bus ducks less; the point is to clear the low end.
                let musicDuck = 1.0 - (1.0 - duck) * 0.55
                musicBus = musicBus * musicDuck
            }

            // --- Bus processing -----------------------------------------
            if mix.drumDrive > 0.001 {
                drumBus.l = saturate(drumBus.l, mix.drumDrive)
                drumBus.r = saturate(drumBus.r, mix.drumDrive)
            }
            if mix.drumGlue > 0.001 {
                // One detector for both channels, applied as a single gain, so
                // the stereo image never shifts under compression.
                let key = max(abs(drumBus.l), abs(drumBus.r))
                let g = drumGlue.process(1.0, key: key, sr: sr)
                drumBus.l *= g
                drumBus.r *= g
            }

            bassBus.l = bassHP.process(bassBus.l)
            bassBus.r = bassBus.l      // low end stays mono, always

            if mix.chorus > 0.001 {
                musicBus = chorus.process(musicBus)
            }

            // --- Sum and effects returns --------------------------------
            var out = drumBus + bassBus + musicBus

            // The engine keeps running between loops, so the reverb and delay
            // idle out a few seconds after their last input rather than
            // burning cycles on silence forever.
            if revSend.l != 0 || revSend.r != 0 { revTail = Int(sr * 4) }
            else if revTail > 0 { revTail -= 1 }
            if revTail > 0 { out += reverb.process(revSend) * 0.85 }

            if dlySend.l != 0 || dlySend.r != 0 { dlyTail = Int(sr * 4) }
            else if dlyTail > 0 { dlyTail -= 1 }
            if dlyTail > 0 { out += delay.process(dlySend) * 0.8 }

            // Mid/side width, low end excluded because bass is already mono.
            if mix.width > 0.001 {
                let mid = (out.l + out.r) * 0.5
                let side = (out.l - out.r) * 0.5 * (1.0 + mix.width)
                out.l = mid + side
                out.r = mid - side
            }

            out = master.process(out * volumeRT)

            out0?[frame] = out.l
            out1?[frame] = out.r
            let a = max(abs(out.l), abs(out.r))
            if a > peak { peak = a }
        }

        if abl.count > 2, let src = out0 {
            for ch in 2..<abl.count {
                if let dst = abl[ch].mData?.assumingMemoryBound(to: Float.self) {
                    dst.update(from: src, count: frames)
                }
            }
        }

        if peak > levelOut.pointee { levelOut.pointee = peak }
        grOut.pointee = master.gainReductionDB
    }

    private func drainCommands() {
        var head = Int(cmdHead.pointee)
        let tail = Int(cmdTail.pointee)
        while head != tail {
            let c = cmds[head]
            switch c & 0x7F00_0000 {
            case Cmd.play:
                playing = true
                pos = 0
                nextStep = 0
                for i in 0..<lastPitch.count { lastPitch[i] = -1 }
            case Cmd.stop:
                playing = false
                stepOut.pointee = -1
                for i in 0..<synthVoices.count where synthVoices[i].active {
                    synthVoices[i].release()
                }
            case 0x0300_0000:
                let kind = Int((c >> 16) & 0xFF)
                let vel = Float(c & 0x7F) / 127.0
                var params = drumParams(track: kind)
                params.reverb *= 0.5           // auditions stay dry and immediate
                triggerDrum(kind: kind, vel: vel, params: params, delay: 0, sr: sampleRate)
            case 0x0400_0000:
                let timbre = Int((c >> 20) & 0xF)
                let pitch = Int((c >> 8) & 0x7F)
                let vel = Float(c & 0x7F) / 127.0
                let t = TrackTimbre(rawValue: timbre) ?? .keys
                triggerNote(pitch: Float(pitch), vel: vel, timbre: t.timbre,
                            params: SynthParams(from: t.defaultMix),
                            gate: Int(sampleRate * 0.6), track: -1, delay: 0,
                            glideFrom: nil, sr: sampleRate)
            default:
                break
            }
            head = (head + 1) % AudioEngine.cmdCapacity
        }
        cmdHead.pointee = Int32(head)
    }

    // MARK: Step firing

    private func fire(step: Int, samplesPerStep: Double, mix: RTMix, sr: Float) {
        let humanize = mix.humanize
        // A small constant offset gives micro-timing room to push either way.
        let baseDelay = 0.005 * sr

        for t in 0..<SeqGrid.drumCount {
            let v = live.drum[SeqGrid.drumIndex(t, step)]
            guard v > 0 else { continue }

            var params = drumParams(track: t)
            let jitter = rng.next() * humanize * 0.004 * sr
            let nudge = params.timingSamples(sr)
            let delaySamples = max(0, Int(baseDelay + nudge + jitter))

            let velJitter = 1.0 - humanize * 0.22 * rng.uni()
            let vel = v * velJitter

            // Slight per-hit tone variation stops repeated hits sounding
            // stamped out — the machine-gun snare problem.
            params.tone = max(0, min(1, params.tone + rng.next() * humanize * 0.10))

            rng.state = rng.state &* 1664525 &+ 1013904223
            triggerDrum(kind: t, vel: vel, params: params, delay: delaySamples, sr: sr)

            if t == Drum.kick.rawValue {
                ducker.trigger(1)
            }
        }

        for t in 0..<SeqGrid.melCount {
            let raw = Int(live.melTimbre[t])
            let track = TrackTimbre(rawValue: raw) ?? .keys
            let base = t * SeqGrid.stride
            var params = SynthParams()
            params.gain = live.melParam[base + ParamSlot.gain]
            params.pan = live.melParam[base + ParamSlot.pan]
            params.reverb = live.melParam[base + ParamSlot.reverb]
            params.delay = live.melParam[base + ParamSlot.delay]
            params.drive = live.melParam[base + ParamSlot.drive]
            params.cutoff = max(0.1, live.melParam[base + ParamSlot.cutoff])
            params.glide = live.melParam[base + ParamSlot.glide]

            let timing = live.melParam[base + ParamSlot.timing]
            let jitter = rng.next() * humanize * 0.003 * sr
            let delaySamples = max(0, Int(baseDelay + timing * 0.012 * sr + jitter))

            for slot in 0..<SeqGrid.slotCount {
                let idx = SeqGrid.melIndex(t, step, slot)
                let p = live.melPitch[idx]
                if p < 0 { break }
                let gate = Int(Double(live.melLen[idx]) * samplesPerStep)
                let vel = live.melVel[idx] * (1.0 - humanize * 0.12 * rng.uni())
                let glideFrom: Float? = (params.glide > 0.001 && lastPitch[t] >= 0)
                    ? lastPitch[t] : nil
                triggerNote(pitch: Float(p), vel: vel, timbre: track.timbre,
                            params: params, gate: max(128, gate), track: t,
                            delay: delaySamples, glideFrom: glideFrom, sr: sr)
                lastPitch[t] = Float(p)
            }
        }

        if metronomeRT && step % 4 == 0 {
            var params = DrumParams()
            params.gain = step == 0 ? 0.5 : 0.3
            params.tune = step == 0 ? 7 : 0
            triggerDrum(kind: DrumVoiceKind.rim.rawValue, vel: 0.8, params: params,
                        delay: 0, sr: sr)
        }
    }

    private func drumParams(track: Int) -> DrumParams {
        let base = track * SeqGrid.stride
        var p = DrumParams()
        p.gain = live.drumParam[base + ParamSlot.gain]
        p.pan = live.drumParam[base + ParamSlot.pan]
        p.tune = live.drumParam[base + ParamSlot.tune]
        p.tone = live.drumParam[base + ParamSlot.tone]
        p.decay = live.drumParam[base + ParamSlot.decay]
        p.drive = live.drumParam[base + ParamSlot.drive]
        p.reverb = live.drumParam[base + ParamSlot.reverb]
        p.delay = live.drumParam[base + ParamSlot.delay]
        p.timing = live.drumParam[base + ParamSlot.timing]
        return p
    }

    private func triggerDrum(kind: Int, vel: Float, params: DrumParams, delay: Int, sr: Float) {
        guard let k = DrumVoiceKind(rawValue: kind) else { return }
        rng.state = rng.state &* 1664525 &+ 1013904223

        // Steal the oldest voice of the same kind first so a fast hat pattern
        // chokes itself the way a real hi-hat does.
        var slot = -1
        if k == .closedHat || k == .openHat {
            for i in 0..<drumVoices.count
            where drumVoices[i].active && (drumVoices[i].kind == .closedHat || drumVoices[i].kind == .openHat) {
                slot = i
                break
            }
        }
        if slot < 0 {
            slot = nextDrumVoice
            nextDrumVoice = (nextDrumVoice + 1) % drumVoices.count
        }
        drumVoices[slot].trigger(k, vel: vel, params: params, delay: delay,
                                 seed: rng.state, sr: sr)
    }

    private func triggerNote(pitch: Float, vel: Float, timbre: Timbre, params: SynthParams,
                             gate: Int, track: Int, delay: Int, glideFrom: Float?, sr: Float) {
        // Monophonic bass timbres retrigger their own voice so notes never
        // stack into mud — and so a glide has something to glide from.
        if timbre.isLow && track >= 0 {
            for i in 0..<synthVoices.count
            where synthVoices[i].active && synthVoices[i].trackIndex == track {
                synthVoices[i].trigger(pitch: pitch, vel: vel, timbre: timbre, params: params,
                                       gate: gate, track: track, delay: delay,
                                       glideFrom: glideFrom, sr: sr)
                return
            }
        }

        // Same pitch on the same track: retrigger rather than layer.
        if track >= 0 {
            for i in 0..<synthVoices.count
            where synthVoices[i].active && synthVoices[i].trackIndex == track
                && abs(synthVoices[i].target - pitch) < 0.01 {
                synthVoices[i].trigger(pitch: pitch, vel: vel, timbre: timbre, params: params,
                                       gate: gate, track: track, delay: delay,
                                       glideFrom: nil, sr: sr)
                return
            }
        }

        var i = nextSynthVoice
        var tries = 0
        while synthVoices[i].active && tries < synthVoices.count {
            i = (i + 1) % synthVoices.count
            tries += 1
        }
        nextSynthVoice = (i + 1) % synthVoices.count
        synthVoices[i].trigger(pitch: pitch, vel: vel, timbre: timbre, params: params,
                               gate: gate, track: track, delay: delay,
                               glideFrom: glideFrom, sr: sr)
    }
}

// MARK: - Small bridges

extension Timbre {
    /// Mirror of TrackTimbre.isLowEnd for the render thread.
    var isLow: Bool {
        switch self {
        case .sub, .bass808, .bass, .reese: return true
        default: return false
        }
    }
}

extension SynthParams {
    init(from mix: TrackMix) {
        self.init()
        gain = Float(mix.gain)
        pan = Float(mix.pan)
        reverb = Float(mix.reverb)
        delay = Float(mix.delay)
        drive = Float(mix.drive)
        cutoff = Float(mix.cutoff)
        glide = Float(mix.glide)
    }
}
