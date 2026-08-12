import Foundation
import AVFoundation
import Combine

/// Thin AVFoundation shell around MixEngine. Everything that makes sound lives
/// in MixEngine, so the offline render tool produces identical audio.
final class AudioEngine: ObservableObject {
    static let shared = AudioEngine()

    @Published private(set) var isPlaying = false
    @Published private(set) var playhead: Int = -1
    @Published private(set) var level: Double = 0
    @Published private(set) var gainReduction: Double = 0
    @Published var bpm: Double = 90 { didSet { core.bpm = bpm } }
    @Published var swing: Double = 0 { didSet { core.swing = swing } }
    @Published var metronome = false { didSet { core.metronome = metronome } }
    @Published var masterVolume: Double = 0.85 { didSet { core.masterVolume = Float(masterVolume) } }

    private let core: MixEngine
    private let engine = AVAudioEngine()
    private var source: AVAudioSourceNode?
    private var uiTimer: Timer?
    private var observers: [NSObjectProtocol] = []

    private init() {
        let session = AVAudioSession.sharedInstance()
        var sr: Float = 44100
        do {
            // .mixWithOthers matters here: the phone is sitting next to a DAW.
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setPreferredIOBufferDuration(0.005)
            try session.setActive(true)
            sr = Float(session.sampleRate > 0 ? session.sampleRate : 44100)
        } catch {
            sr = 44100
        }
        core = MixEngine(sampleRate: sr)

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

        buildGraph(sampleRate: sr)
        startUITimer()
    }

    private func buildGraph(sampleRate: Float) {
        guard let format = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate),
                                         channels: 2) else { return }

        let node = AVAudioSourceNode(format: format) { [weak self] _, _, frameCount, abl -> OSStatus in
            guard let self else { return noErr }
            let buffers = UnsafeMutableAudioBufferListPointer(abl)
            let frames = Int(frameCount)
            guard let l = buffers[0].mData?.assumingMemoryBound(to: Float.self) else { return noErr }
            let r = buffers.count > 1
                ? (buffers[1].mData?.assumingMemoryBound(to: Float.self) ?? l)
                : l
            self.core.render(frames: frames, left: l, right: r)
            if buffers.count > 2 {
                for ch in 2..<buffers.count {
                    if let dst = buffers[ch].mData?.assumingMemoryBound(to: Float.self) {
                        dst.update(from: l, count: frames)
                    }
                }
            }
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

    private func startUITimer() {
        let t = Timer(timeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            let s = self.core.playheadStep
            if s != self.playhead { self.playhead = s }

            let l = Double(self.core.levelPeak)
            let smoothed = max(l, self.level * 0.72)
            if abs(smoothed - self.level) > 0.005 { self.level = min(1, smoothed) }

            let gr = Double(self.core.gainReductionDB)
            if abs(gr - self.gainReduction) > 0.05 { self.gainReduction = gr }
        }
        RunLoop.main.add(t, forMode: .common)
        uiTimer = t
    }

    // MARK: - Transport

    func play() {
        ensureRunning()
        guard engine.isRunning else { return }
        core.startTransport()
        isPlaying = true
    }

    func stop() {
        core.stopTransport()
        isPlaying = false
        playhead = -1
    }

    func toggle() { isPlaying ? stop() : play() }

    func suspend() {
        stop()
        if engine.isRunning { engine.pause() }
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    }

    // MARK: - Content

    func load(_ beat: Beat) {
        bpm = beat.bpm
        swing = beat.swing
        core.upload(beat)
    }

    func upload(_ beat: Beat) { core.upload(beat) }

    func audition(_ drum: Drum, vel: Double = 1.0) {
        ensureRunning()
        core.audition(drum, vel: vel)
    }

    func audition(pitch: Int, timbre: TrackTimbre, vel: Double = 0.85) {
        ensureRunning()
        core.audition(pitch: pitch, timbre: timbre, vel: vel)
    }
}
