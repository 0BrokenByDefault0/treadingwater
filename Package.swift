// swift-tools-version: 5.9
import PackageDescription

// This package exists only to run the app's audio engine offline. It compiles
// the real DSP and sequencer sources — not a copy — so a rendered WAV is
// sample-identical to what the app plays on a device.
//
//   swift run render-preview out/
//
// The iOS app itself is built from TreadingWater.xcodeproj, not from here.

let package = Package(
    name: "TreadingWaterTools",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "render-preview",
            path: ".",
            exclude: [],
            sources: [
                "TreadingWater/Design/Theme.swift",
                "TreadingWater/Audio/DSP.swift",
                "TreadingWater/Audio/DrumVoices.swift",
                "TreadingWater/Audio/SynthVoices.swift",
                "TreadingWater/Audio/Effects.swift",
                "TreadingWater/Audio/MixEngine.swift",
                "TreadingWater/Model/MusicTypes.swift",
                "TreadingWater/Model/Theory.swift",
                "TreadingWater/Model/Templates.swift",
                "TreadingWater/Model/DemoBeats.swift",
                "Tools/RenderPreview/main.swift"
            ]
        )
    ]
)
