import Foundation
import Observation

@Observable @MainActor
final class GameState {
    private(set) var snapshot: GameSnapshot
    private(set) var message = "Five taps. One satisfying pop."
    private(set) var lastReward: Int64 = 0
    private(set) var hitCount = 0
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let saveKey = "ballaps_save_v2"
    @ObservationIgnored private var saveTask: Task<Void, Never>?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: saveKey),
           var loaded = try? JSONDecoder().decode(GameSnapshot.self, from: data) {
            loaded.sanitize()
            snapshot = loaded
        } else {
            snapshot = GameSnapshot()
        }
    }

    func tapBalloon() {
        let earned = snapshot.tap(nextColor: .draw(roll: Int.random(in: 0..<100)))
        hitCount = (hitCount + 1) % 1_000_000
        if earned > 0 {
            lastReward = earned
            message = "+\(earned.formatted()) coins. Keep popping!"
        }
        scheduleSave()
    }

    func purchase(_ upgrade: Upgrade) {
        guard snapshot.purchase(upgrade) else {
            message = snapshot.isAvailable(upgrade) ? "Keep popping to earn more coins." : "This upgrade is not available."
            return
        }
        switch upgrade {
        case .reward: message = "Every pop now earns \(snapshot.reward.formatted()) coins."
        case .strength: message = "Your taps now deal \(snapshot.strength) damage."
        case .balloon: message = "+10 balloon HP and +10 coins per pop!"
        case .autoclicker: message = "Autoclicker is on. One tap per second."
        case .speed: message = "Autoclicker now taps \(snapshot.tapsPerSecond) times per second."
        }
        saveNow()
    }

    func toggleMusic() {
        snapshot.musicEnabled.toggle()
        saveNow()
    }

    // Coalesce repeated taps; lifecycle changes flush immediately.
    private func scheduleSave() {
        guard saveTask == nil else { return }
        saveTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            self?.saveNow()
        }
    }

    func saveNow() {
        saveTask?.cancel()
        saveTask = nil
        if let data = try? JSONEncoder().encode(snapshot) {
            defaults.set(data, forKey: saveKey)
        }
    }
}
