import SwiftUI

@main
struct TreadingWaterApp: App {
    @StateObject private var theme = Theme()
    @StateObject private var store = Store()
    @StateObject private var audio = AudioEngine.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(theme)
                .environmentObject(store)
                .environmentObject(audio)
                .preferredColorScheme(theme.night ? .dark : .light)
                .tint(Ink.orange)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { audio.suspend() }
        }
    }
}
