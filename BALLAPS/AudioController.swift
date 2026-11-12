import AVFoundation
import Observation

@Observable @MainActor
final class AudioController {
    private(set) var isAvailable = false
    @ObservationIgnored private var player: AVAudioPlayer?
    init() {
        guard let url = Bundle.main.url(forResource: "BackgroundMusic", withExtension: "m4a") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = 0.45
            player.prepareToPlay()
            self.player = player
            isAvailable = true
        } catch {
            // A missing/unplayable track never prevents the game from running.
            isAvailable = false
        }
    }
    func update(enabled: Bool, active: Bool) {
        if enabled && active { player?.play() } else { player?.pause() }
    }
}
