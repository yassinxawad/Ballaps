import Foundation

enum BalloonColor: String, Codable, CaseIterable, Sendable {
    case red, yellow, gold, blue, purple
    var title: String { rawValue.capitalized + " balloon" }
    /// Gold occupies exactly ten of the hundred equally likely outcomes.
    static func draw(roll: Int) -> Self {
        switch roll {
        case 0..<10: .gold
        case 10..<33: .red
        case 33..<55: .yellow
        case 55..<78: .blue
        default: .purple
        }
    }
}

enum Upgrade: String, CaseIterable, Identifiable, Sendable {
    case reward, strength, balloon, autoclicker, speed
    var id: String { rawValue }
}

struct GameSnapshot: Codable, Equatable, Sendable {
    // A generous ceiling keeps arithmetic exact and safely below Int64 overflow.
    static let maximumCoins: Int64 = 9_000_000_000_000_000
    static let maximumUpgradeLevel = 1_000_000
    static let maximumSpeedLevel = 19
    var coins: Int64 = 10
    var rewardLevel = 0
    var strengthLevel = 0
    var balloonLevel = 0
    var speedLevel = 0
    var autoClickerOwned = false
    var totalPops: Int64 = 0
    var currentHP = 15
    var balloonColor: BalloonColor = .red
    var musicEnabled = true

    var strength: Int { 3 + strengthLevel * 10 }
    var maxHP: Int { 15 + balloonLevel * 10 }
    var reward: Int64 { 10 + Int64(rewardLevel + balloonLevel) * 10 }
    var tapsPerSecond: Int { 1 + speedLevel }
    var autoClickInterval: Double { 1 / Double(tapsPerSecond) }
    var hpFraction: Double { Double(currentHP) / Double(maxHP) }

    func cost(of upgrade: Upgrade) -> Int64 {
        switch upgrade {
        case .reward: 20 * Int64(rewardLevel + 1)
        case .strength: 50 * Int64(strengthLevel + 1)
        case .balloon: 70 * Int64(balloonLevel + 1)
        case .autoclicker: 100
        case .speed: 500 * Int64(speedLevel + 1)
        }
    }

    func isAvailable(_ upgrade: Upgrade) -> Bool {
        switch upgrade {
        case .reward: rewardLevel < Self.maximumUpgradeLevel
        case .strength: strengthLevel < Self.maximumUpgradeLevel
        case .balloon: balloonLevel < Self.maximumUpgradeLevel
        case .autoclicker: !autoClickerOwned
        case .speed: autoClickerOwned && speedLevel < Self.maximumSpeedLevel
        }
    }

    @discardableResult
    mutating func purchase(_ upgrade: Upgrade) -> Bool {
        let price = cost(of: upgrade)
        guard isAvailable(upgrade), coins >= price else { return false }
        coins -= price
        switch upgrade {
        case .reward: rewardLevel += 1
        case .strength: strengthLevel += 1
        case .balloon:
            balloonLevel += 1
            currentHP += 10
        case .autoclicker: autoClickerOwned = true
        case .speed: speedLevel += 1
        }
        return true
    }

    /// Overkill pops only the current balloon, so one tap never earns twice.
    @discardableResult
    mutating func tap(nextColor: BalloonColor) -> Int64 {
        currentHP = max(0, currentHP - strength)
        guard currentHP == 0 else { return 0 }
        let earned = reward
        coins = min(Self.maximumCoins, coins + earned)
        totalPops = min(Self.maximumCoins, totalPops + 1)
        currentHP = maxHP
        balloonColor = nextColor
        return earned
    }

    mutating func sanitize() {
        coins = min(Self.maximumCoins, max(0, coins))
        totalPops = min(Self.maximumCoins, max(0, totalPops))
        rewardLevel = min(Self.maximumUpgradeLevel, max(0, rewardLevel))
        strengthLevel = min(Self.maximumUpgradeLevel, max(0, strengthLevel))
        balloonLevel = min(Self.maximumUpgradeLevel, max(0, balloonLevel))
        speedLevel = autoClickerOwned ? min(Self.maximumSpeedLevel, max(0, speedLevel)) : 0
        currentHP = min(maxHP, max(1, currentHP))
    }
}

struct CoinPackage: Identifiable {
    let id: Int
    let displayCoins: String
    let priceEGP: Int
    static let all = [
        CoinPackage(id: 0, displayCoins: "1B", priceEGP: 50),
        CoinPackage(id: 1, displayCoins: "10B", priceEGP: 100),
        CoinPackage(id: 2, displayCoins: "100B", priceEGP: 500),
        CoinPackage(id: 3, displayCoins: "1T", priceEGP: 1000)
    ]
}
