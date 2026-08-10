import Foundation
import AVFoundation
import Combine
import os

// MARK: - Real-time sequencer state
//
// Two copies of a flat, preallocated grid. The UI fills `staging` and raises a
// dirty flag; the render thread try-locks, copies into `live`, and never
// touches Swift objects again.

final class SeqGrid {
    let drum: UnsafeMutablePointer<Float>          // [track][step] velocity, 0 = off
    let drumTone: UnsafeMutablePointer<Float>      // [track]
    let melPitch: UnsafeMutablePointer<Int32>      // [track][step][slot], -1 = empty
    let melLen: UnsafeMutablePointer<Int32>
    let melVel: UnsafeMutablePointer<Float>
    let melTimbre: UnsafeMutablePointer<Int32>     // [track]
    var length: Int32 = 16

    static let drumCount = SeqLimits.maxDrumTracks
    static let melCount = SeqLimits.maxMelodyTracks
    static let stepCount = SeqLimits.maxSteps
    static let slotCount = SeqLimits.maxNotesPerStep

    static let drumSize = drumCount * stepCount
    static let melSize = melCount * stepCount * slotCount

    init() {
        drum = .allocate(capacity: SeqGrid.drumSize)
        drum.initialize(repeating: 0, count: SeqGrid.drumSize)
        drumTone = .allocate(capacity: SeqGrid.drumCount)
        drumTone.initialize(repeating: 0.5, count: SeqGrid.drumCount)
        melPitch = .allocate(capacity: SeqGrid.melSize)
        melPitch.initialize(repeating: -1, count: SeqGrid.melSize)
        melLen = .allocate(capacity: SeqGrid.melSize)
        melLen.initialize(repeating: 0, count: SeqGrid.melSize)
        melVel = .allocate(capacity: SeqGrid.melSize)
        melVel.initialize(repeating: 0, count: SeqGrid.melSize)
        melTimbre = .allocate(capacity: SeqGrid.melCount)
        melTimbre.initialize(repeating: 0, count: SeqGrid.melCount)
    }

    deinit {
        drum.deallocate(); drumTone.deallocate()
        melPitch.deallocate(); melLen.deallocate()
        melVel.deallocate(); melTimbre.deallocate()
    }

    func clear() {
        drum.update(repeating: 0, count: SeqGrid.drumSize)
        melPitch.update(repeating: -1, count: SeqGrid.melSize)
        melLen.update(repeating: 0, count: SeqGrid.melSize)
        melVel.update(repeating: 0, count: SeqGrid.melSize)
    }

    func copy(from o: SeqGrid) {
        drum.update(from: o.drum, count: SeqGrid.drumSize)
        drumTone.update(from: o.drumTone, count: SeqGrid.drumCount)
        melPitch.update(from: o.melPitch, count: SeqGrid.melSize)
        melLen.update(from: o.melLen, count: SeqGrid.melSize)
        melVel.update(from: o.melVel, count: SeqGrid.melSize)
        melTimbre.update(from: o.melTimbre, count: SeqGrid.melCount)
        length = o.length
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

    // Published for the UI. Updated from a display-rate timer, never from the
    // render thread.
    @Published private(set) var isPlaying = false
    @Published private(set) var playhead: Int = -1
    @Published private(set) var level: Double = 0
    @Published var bpm: Double = 90 { didSet { bpmRT = bpm } }
    @Published var swing: Double = 0 { didSet { swingRT = swing } }
    @Published var metronome = false { didSet { metronomeRT = metronome } }
    @Published var masterVolume: Double = 0.85 { didSet { volumeRT = Float(masterVolume) } }

    private let engine = AVAudioEngine()
    private var source: AVAudioSourceNode?
    private var sampleRate: Float = 44100
    private var started = false

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

    // Audition ring buffer (UI -> render).
    private static let cmdCapacity = 64
    private let cmds: UnsafeMutablePointer<Int32>
    private let cmdHead: UnsafeMutablePointer<Int32>   // written by render
    private let cmdTail: UnsafeMutablePointer<Int32>   // written by UI

    // Voice pools (render thread only).
    private var drumVoices = [DrumVoice](repeating: DrumVoice(), count: 14)
    private var drumPan = [Float](repeating: 0, count: 14)
    private var synthVoices = [SynthVoice](repeating: SynthVoice(), count: 20)
    private var nextDrumVoice = 0
    private var nextSynthVoice = 0
    private var rng: UInt32 = 0x1234567

    // Transport (render thread only).
    private var playing = false
    private var pos: Double = 0
    private var nextStep: Int = 0

    private var uiTimer: Timer?
    private var observers: [NSObjectProtocol] = []

    private init() {
        lock = .allocate(capacity: 1)
        lock.initialize(to: os_unfair_lock())
        stepOut = .allocate(capacity: 1); stepOut.initialize(to: -1)
        levelOut = .allocate(capacity: 1); levelOut.initialize(to: 0)
        cmds = .allocate(capacity: AudioEngine.cmdCapacity)
        cmds.initialize(repeating: 0, count: AudioEngine.cmdCapacity)
        cmdHead = .allocate(capacity: 1); cmdHead.initialize(to: 0)
        cmdTail = .allocate(capacity: 1); cmdTail.initialize(to: 0)
        configureSession()
        buildGraph()
        startUITimer()
    }

    // MARK: Setup

    private func configureSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            // .mixWithOthers matters here: the phone is sitting next to a DAW.
            // The app should never duck or stop whatever else is playing.
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setPreferredIOBufferDuration(0.005)
            try session.setActive(true)
            sampleRate = Float(session.sampleRate > 0 ? session.sampleRate : 44100)
        } catch {
            sampleRate = 44100
        }

        // Block-based observers: this is a plain Swift class, so it has no
        // Objective-C selectors to hand to the target/action API.
        observers.append(NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil, queue: .main
        ) { [weak self] note in
            self?.handleInterruption(note)
        })

        observers.append(NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.ensureRunning()
        })
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
            started = true
        } catch {
            started = false
        }
    }

    private func handleInterruption(_ note: Notification) {
        guard let info = note.userInfo,
              let raw = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: raw) else { return }
        if type == .began {
            stop()
        } else {
            ensureRunning()
        }
    }

    // MARK: UI polling

    private func startUITimer() {
        let t = Timer(timeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            let s = Int(self.stepOut.pointee)
            if s != self.playhead { self.playhead = s }
            let l = Double(self.levelOut.pointee)
            self.levelOut.pointee *= 0.55
            let smoothed = max(l, self.level * 0.72)
            if abs(smoothed - self.level) > 0.005 { self.level = min(1, smoothed) }
        }
        RunLoop.main.add(t, forMode: .common)
        uiTimer = t
    }

    // MARK: - Public transport

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

    /// Stops audio and releases the hardware. Called when the app backgrounds.
    func suspend() {
        stop()
        if engine.isRunning { engine.pause() }
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    }

    // MARK: - Loading patterns

    func load(_ beat: Beat) {
        bpm = beat.bpm
        swing = beat.swing
        upload(beat)
    }

    /// Push the current musical content into the staging grid. Cheap enough to
    /// call on every edit — the render thread picks it up on the next buffer.
    func upload(_ beat: Beat) {
        os_unfair_lock_lock(lock)
        staging.clear()
        staging.length = Int32(max(1, min(beat.steps, SeqLimits.maxSteps)))

        for track in beat.drums {
            guard !track.muted else { continue }
            let ti = track.drum.rawValue
            guard ti < SeqGrid.drumCount else { continue }
            for step in 0..<min(track.vel.count, SeqLimits.maxSteps) {
                let v = track.vel[step]
                if v > 0 {
                    staging.drum[SeqGrid.drumIndex(ti, step)] = Float(min(1, v))
                }
            }
        }

        for (ti, track) in beat.melodies.prefix(SeqLimits.maxMelodyTracks).enumerated() {
            staging.melTimbre[ti] = Int32(track.timbre.rawValue)
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

    func setDrumTone(_ drum: Drum, _ tone: Double) {
        os_unfair_lock_lock(lock)
        staging.drumTone[drum.rawValue] = Float(min(1, max(0, tone)))
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

    // MARK: - Command encoding
    //
    // Packed into a single Int32 so the queue stays lock-free.

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
        if next == Int(cmdHead.pointee) { return }   // queue full: drop
        cmds[tail] = c
        cmdTail.pointee = Int32(next)
    }

    // MARK: - Render (audio thread)

    private func render(frames: Int, abl: UnsafeMutableAudioBufferListPointer) {
        let sr = sampleRate

        // Pick up edits without ever blocking the audio thread.
        if os_unfair_lock_trylock(lock) {
            if dirty {
                live.copy(from: staging)
                dirty = false
            }
            os_unfair_lock_unlock(lock)
        }

        drainCommands()

        let stepsPerLoop = Int(live.length)
        let samplesPerStep = (60.0 / max(20.0, bpmRT) / 4.0) * Double(sr)
        let loopLength = samplesPerStep * Double(stepsPerLoop)
        let swingOffset = swingRT * samplesPerStep * 0.5

        var peak: Float = 0
        let out0 = abl[0].mData?.assumingMemoryBound(to: Float.self)
        let out1 = abl.count > 1 ? abl[1].mData?.assumingMemoryBound(to: Float.self) : out0

        for frame in 0..<frames {
            if playing && stepsPerLoop > 0 {
                // Fire every step whose time has arrived this sample.
                while nextStep < stepsPerLoop {
                    let target = Double(nextStep) * samplesPerStep
                        + (nextStep % 2 == 1 ? swingOffset : 0)
                    if pos >= target {
                        fire(step: nextStep, samplesPerStep: samplesPerStep)
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

            var l: Float = 0
            var r: Float = 0

            for i in 0..<drumVoices.count where drumVoices[i].active {
                let s = drumVoices[i].render(sr: sr)
                let p = drumPan[i]
                l += s * (1 - max(0, p))
                r += s * (1 + min(0, p))
            }
            for i in 0..<synthVoices.count where synthVoices[i].active {
                let s = synthVoices[i].render(sr: sr)
                l += s
                r += s
            }

            l *= volumeRT
            r *= volumeRT
            // Soft ceiling so stacked voices never spit.
            l = tanhf(l * 0.85)
            r = tanhf(r * 0.85)

            out0?[frame] = l
            out1?[frame] = r
            let a = abs(l)
            if a > peak { peak = a }
        }

        // Any extra channels get a copy of the left signal.
        if abl.count > 2, let src = out0 {
            for ch in 2..<abl.count {
                if let dst = abl[ch].mData?.assumingMemoryBound(to: Float.self) {
                    dst.update(from: src, count: frames)
                }
            }
        }

        if peak > levelOut.pointee { levelOut.pointee = peak }
    }

    private func drainCommands() {
        var head = Int(cmdHead.pointee)
        let tail = Int(cmdTail.pointee)
        while head != tail {
            let c = cmds[head]
            let op = c & 0x7F00_0000
            switch op {
            case Cmd.play:
                playing = true
                pos = 0
                nextStep = 0
            case Cmd.stop:
                playing = false
                stepOut.pointee = -1
                releaseAll()
            case 0x0300_0000:
                let kind = Int((c >> 16) & 0xFF)
                let vel = Float(c & 0x7F) / 127.0
                triggerDrum(kind: kind, vel: vel)
            case 0x0400_0000:
                let timbre = Int((c >> 20) & 0xF)
                let pitch = Int((c >> 8) & 0x7F)
                let vel = Float(c & 0x7F) / 127.0
                triggerNote(pitch: Float(pitch), vel: vel,
                            timbre: Timbre(rawValue: timbre) ?? .keys,
                            gate: Int(sampleRate * 0.55), track: -1)
            default:
                break
            }
            head = (head + 1) % AudioEngine.cmdCapacity
        }
        cmdHead.pointee = Int32(head)
    }

    private func fire(step: Int, samplesPerStep: Double) {
        for t in 0..<SeqGrid.drumCount {
            let v = live.drum[SeqGrid.drumIndex(t, step)]
            if v > 0 {
                triggerDrum(kind: t, vel: v, tone: live.drumTone[t])
            }
        }
        for t in 0..<SeqGrid.melCount {
            let timbre = Timbre(rawValue: Int(live.melTimbre[t])) ?? .keys
            for slot in 0..<SeqGrid.slotCount {
                let idx = SeqGrid.melIndex(t, step, slot)
                let p = live.melPitch[idx]
                if p < 0 { break }
                let gate = Int(Double(live.melLen[idx]) * samplesPerStep)
                triggerNote(pitch: Float(p), vel: live.melVel[idx], timbre: timbre,
                            gate: max(64, gate), track: t)
            }
        }
        if metronomeRT && step % 4 == 0 {
            triggerDrum(kind: DrumVoiceKind.rim.rawValue, vel: step == 0 ? 0.9 : 0.5)
        }
    }

    private func triggerDrum(kind: Int, vel: Float, tone: Float = 0.5) {
        guard let k = DrumVoiceKind(rawValue: kind) else { return }
        rng = rng &* 1664525 &+ 1013904223
        let i = nextDrumVoice
        nextDrumVoice = (nextDrumVoice + 1) % drumVoices.count
        drumVoices[i].trigger(k, vel: vel * gainFor(k), tone: tone, seed: rng)
        drumPan[i] = panFor(k)
    }

    private func triggerNote(pitch: Float, vel: Float, timbre: Timbre, gate: Int, track: Int) {
        // Retrigger the same pitch on the same track instead of stacking.
        for i in 0..<synthVoices.count {
            if synthVoices[i].active && synthVoices[i].trackIndex == track
                && synthVoices[i].pitch == pitch && track >= 0 {
                synthVoices[i].trigger(pitch: pitch, vel: vel, timbre: timbre, gate: gate, track: track)
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
        synthVoices[i].trigger(pitch: pitch, vel: vel, timbre: timbre, gate: gate, track: track)
    }

    private func releaseAll() {
        for i in 0..<synthVoices.count where synthVoices[i].active {
            synthVoices[i].stage = 3
        }
    }

    /// Rough per-piece balance so a default pattern already sits right.
    private func gainFor(_ k: DrumVoiceKind) -> Float {
        switch k {
        case .kick:      return 1.0
        case .snare:     return 0.78
        case .clap:      return 0.72
        case .closedHat: return 0.46
        case .openHat:   return 0.42
        case .rim:       return 0.55
        case .tom:       return 0.7
        case .perc:      return 0.5
        case .crash:     return 0.5
        }
    }

    /// Kept deliberately narrow: it teaches the convention (lows centred,
    /// percussion spread) without making the reference loops sound gimmicky.
    private func panFor(_ k: DrumVoiceKind) -> Float {
        switch k {
        case .kick, .snare: return 0
        case .clap:         return 0.08
        case .closedHat:    return 0.22
        case .openHat:      return -0.18
        case .rim:          return -0.25
        case .tom:          return 0.3
        case .perc:         return -0.32
        case .crash:        return 0.15
        }
    }
}
