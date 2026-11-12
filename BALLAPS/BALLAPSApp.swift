import SwiftUI

@main
struct BALLAPSApp: App {
    @State private var game = GameState()
    @State private var audio = AudioController()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(game)
                .environment(audio)
                .preferredColorScheme(.dark)
                .onChange(of: scenePhase, initial: true) { _, phase in
                    audio.update(enabled: game.snapshot.musicEnabled, active: phase == .active)
                    if phase != .active { game.saveNow() }
                }
                .onChange(of: game.snapshot.musicEnabled) {
                    audio.update(enabled: game.snapshot.musicEnabled, active: scenePhase == .active)
                }
        }
    }
}
