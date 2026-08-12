import Foundation
import os

// The entire signal path, with no AVFoundation and no UI. AudioEngine wraps
// this for the app; the offline render tool drives the exact same code so a
// rendered WAV is sample-identical to what the app plays.

// MARK: - Real-time mix parameters

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
    var swingGrid: Float = 16      // 8 or 16 — which subdivision swings

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
        swingGrid = m.swingGrid == .eighth ? 8 : 16
    }
}

// MARK: - Sequencer grid

final class SeqGrid {
    let drum: UnsafeMutablePointer<Float>
    let drumParam: UnsafeMutablePointer<Float>
    let melPitch: UnsafeMutablePointer<Int32>
    let melLen: UnsafeMutablePointer<Int32>
    let melVel: UnsafeMutablePointer<Float>
    let melTimbre: UnsafeMutablePointer<Int32>
    let melParam: UnsafeMutablePointer<Float>
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

// MARK: - Engine core

final class MixEngine {

    let sampleRate: Float

    // Written from the UI thread, read by the render thread.
    var bpm: Double = 90
    var swing: Double = 0
    var metronome = false
    var masterVolume: Float = 0.85
    /// Offline rendering wants a deterministic result and no jitter.
    var humanizeEnabled = true

    private let live = SeqGrid()
    private let staging = SeqGrid()
    private let lock: UnsafeMutablePointer<os_unfair_lock>
    private var dirty = false

    private let stepOut: UnsafeMutablePointer<Int32>
    private let levelOut: UnsafeMutablePointer<Float>
    private let grOut: UnsafeMutablePointer<Float>

    private static let cmdCapacity = 64
    private let cmds: UnsafeMutablePointer<Int32>
    private let cmdHead: UnsafeMutablePointer<Int32>
    private let cmdTail: UnsafeMutablePointer<Int32>

    private var drumVoices = [DrumVoice](repeating: DrumVoice(), count: 20)
    private var synthVoices = [SynthVoice](repeating: SynthVoice(), count: 24)
    private var nextDrumVoice = 0
    private var nextSynthVoice = 0
    private var lastPitch = [Float](repeating: -1, count: SeqGrid.melCount)
    private var rng = Rng()

    private let reverb: Reverb
    private let delay: TempoDelay
    private let chorus: Chorus
    private let master: MasterChain
    private var drumGlue = Compressor()
    private var ducker = Ducker()
    private var bassHP = Biquad()

    private var playing = false
    private var pos: Double = 0
    private var nextStep: Int = 0
    private var revTail = 0
    private var dlyTail = 0

    // MARK: Init

    init(sampleRate: Float) {
        self.sampleRate = sampleRate

        lock = .allocate(capacity: 1)
        lock.initialize(to: os_unfair_lock())
        stepOut = .allocate(capacity: 1); stepOut.initialize(to: -1)
        levelOut = .allocate(capacity: 1); levelOut.initialize(to: 0)
        grOut = .allocate(capacity: 1); grOut.initialize(to: 0)
        cmds = .allocate(capacity: MixEngine.cmdCapacity)
        cmds.initialize(repeating: 0, count: MixEngine.cmdCapacity)
        cmdHead = .allocate(capacity: 1); cmdHead.initialize(to: 0)
        cmdTail = .allocate(capacity: 1); cmdTail.initialize(to: 0)

        reverb = Reverb(sampleRate: sampleRate)
        delay = TempoDelay(sampleRate: sampleRate)
        chorus = Chorus(sampleRate: sampleRate)
        master = MasterChain(sampleRate: sampleRate)

        drumGlue.thresholdDB = -16
        drumGlue.ratio = 2.2
        drumGlue.attack = 0.028
        drumGlue.release = 0.140
        drumGlue.kneeDB = 8
        bassHP.highpass(26, q: 0.7, sr: sampleRate)
    }

    deinit {
        lock.deallocate(); stepOut.deallocate(); levelOut.deallocate()
        grOut.deallocate(); cmds.deallocate(); cmdHead.deallocate(); cmdTail.deallocate()
    }

    // MARK: Readouts

    var playheadStep: Int { Int(stepOut.pointee) }
    var levelPeak: Float {
        let v = levelOut.pointee
        levelOut.pointee *= 0.5
        return v
    }
    var gainReductionDB: Float { grOut.pointee }

    // MARK: Transport

    func startTransport() { pushCommand(Cmd.play) }
    func stopTransport() { pushCommand(Cmd.stop) }

    /// Wipes every tail so an offline render starts from true silence.
    func resetForRender(seed: UInt32 = 0x2BAD_F00D) {
        playing = false
        pos = 0
        nextStep = 0
        revTail = 0
        dlyTail = 0
        rng.state = seed
        for i in drumVoices.indices { drumVoices[i].active = false }
        for i in synthVoices.indices { synthVoices[i].active = false }
        for i in lastPitch.indices { lastPitch[i] = -1 }
        reverb.clear(); delay.clear(); chorus.clear(); master.reset()
        drumGlue.env = 0
        ducker.value = 0
        bassHP.reset()
        stepOut.pointee = -1
        cmdHead.pointee = 0
        cmdTail.pointee = 0
    }

    // MARK: Loading

    func load(_ beat: Beat) {
        bpm = beat.bpm
        swing = beat.swing
        upload(beat)
    }

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

    /// Offline rendering has no other thread, so the staging copy can be
    /// forced through immediately rather than waiting for the next buffer.
    func commitNow() {
        os_unfair_lock_lock(lock)
        live.copy(from: staging)
        dirty = false
        os_unfair_lock_unlock(lock)
    }

    // MARK: Auditioning

    func audition(_ drum: Drum, vel: Double = 1.0) {
        pushCommand(Cmd.drum(drum.rawValue, vel))
    }

    func audition(pitch: Int, timbre: TrackTimbre, vel: Double = 0.85) {
        pushCommand(Cmd.note(pitch, timbre.rawValue, vel))
    }

    // MARK: Commands

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
        let next = (tail + 1) % MixEngine.cmdCapacity
        if next == Int(cmdHead.pointee) { return }
        cmds[tail] = c
        cmdTail.pointee = Int32(next)
    }

    // MARK: - Render

    func render(frames: Int, left: UnsafeMutablePointer<Float>, right: UnsafeMutablePointer<Float>) {
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
        let beatsPerSecond = max(20.0, bpm) / 60.0
        let samplesPerStep = Double(sr) / beatsPerSecond / 4.0
        let loopLength = samplesPerStep * Double(stepsPerLoop)

        // Swing pushes the off-beat of whichever grid the genre swings. A
        // shuffled boom-bap kit swings 16ths; a garage or house groove swings
        // 8ths, which moves twice as much material.
        let swingDivisor = mix.swingGrid >= 12 ? 2 : 4
        let swingOffset = swing * samplesPerStep * (swingDivisor == 2 ? 0.5 : 1.0)

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

        for frame in 0..<frames {
            if playing && stepsPerLoop > 0 {
                while nextStep < stepsPerLoop {
                    let swings = (nextStep % swingDivisor) == (swingDivisor / 2)
                    let target = Double(nextStep) * samplesPerStep + (swings ? swingOffset : 0)
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

            if mix.sidechain > 0.001 {
                let duck = ducker.process(mix.sidechain)
                bassBus = bassBus * duck
                let musicDuck = 1.0 - (1.0 - duck) * 0.55
                musicBus = musicBus * musicDuck
            }

            if mix.drumDrive > 0.001 {
                drumBus.l = saturate(drumBus.l, mix.drumDrive)
                drumBus.r = saturate(drumBus.r, mix.drumDrive)
            }
            if mix.drumGlue > 0.001 {
                let key = max(abs(drumBus.l), abs(drumBus.r))
                let g = drumGlue.process(1.0, key: key, sr: sr)
                drumBus.l *= g
                drumBus.r *= g
            }

            bassBus.l = bassHP.process(bassBus.l)
            bassBus.r = bassBus.l

            if mix.chorus > 0.001 {
                musicBus = chorus.process(musicBus)
            }

            var out = drumBus + bassBus + musicBus

            if revSend.l != 0 || revSend.r != 0 { revTail = Int(sr * 4) }
            else if revTail > 0 { revTail -= 1 }
            if revTail > 0 { out += reverb.process(revSend) * 0.85 }

            if dlySend.l != 0 || dlySend.r != 0 { dlyTail = Int(sr * 4) }
            else if dlyTail > 0 { dlyTail -= 1 }
            if dlyTail > 0 { out += delay.process(dlySend) * 0.8 }

            if mix.width > 0.001 {
                let mid = (out.l + out.r) * 0.5
                let side = (out.l - out.r) * 0.5 * (1.0 + mix.width)
                out.l = mid + side
                out.r = mid - side
            }

            out = master.process(out * masterVolume)

            left[frame] = out.l
            right[frame] = out.r
            let a = max(abs(out.l), abs(out.r))
            if a > peak { peak = a }
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
                params.reverb *= 0.5
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
            head = (head + 1) % MixEngine.cmdCapacity
        }
        cmdHead.pointee = Int32(head)
    }

    // MARK: Step firing

    private func fire(step: Int, samplesPerStep: Double, mix: RTMix, sr: Float) {
        let humanize = humanizeEnabled ? mix.humanize : 0
        let baseDelay = humanizeEnabled ? 0.004 * sr : 0

        for t in 0..<SeqGrid.drumCount {
            let v = live.drum[SeqGrid.drumIndex(t, step)]
            guard v > 0 else { continue }

            var params = drumParams(track: t)
            let jitter = rng.next() * humanize * 0.0035 * sr
            let nudge = params.timingSamples(sr)
            let delaySamples = max(0, Int(baseDelay + nudge + jitter))

            let vel = v * (1.0 - humanize * 0.22 * rng.uni())
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
            let jitter = rng.next() * humanize * 0.0025 * sr
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

        if metronome && step % 4 == 0 {
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

        // A real hi-hat chokes itself: a new hat cuts whichever one is ringing.
        var slot = -1
        if k == .closedHat || k == .openHat {
            for i in 0..<drumVoices.count
            where drumVoices[i].active && drumVoices[i].startDelay == 0
                && (drumVoices[i].kind == .closedHat || drumVoices[i].kind == .openHat) {
                slot = i
                break
            }
        }
        if slot < 0 {
            // Prefer a free slot before stealing anything.
            for i in 0..<drumVoices.count where !drumVoices[i].active {
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
        if timbre.isLow && track >= 0 {
            for i in 0..<synthVoices.count
            where synthVoices[i].active && synthVoices[i].trackIndex == track {
                synthVoices[i].trigger(pitch: pitch, vel: vel, timbre: timbre, params: params,
                                       gate: gate, track: track, delay: delay,
                                       glideFrom: glideFrom, sr: sr)
                return
            }
        }

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

// MARK: - Bridges

extension Timbre {
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
