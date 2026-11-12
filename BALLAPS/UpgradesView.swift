import SwiftUI

struct UpgradesView: View {
    @Environment(GameState.self) private var game
    var body: some View {
        NavigationStack {
            ZStack {
                Palette.navy.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 14) {
                        StatCard(icon: "circle.fill", title: "YOUR COINS", value: game.snapshot.coins.formatted(), tint: Palette.gold)
                        ForEach(Upgrade.allCases) { upgrade in
                            UpgradeRow(upgrade: upgrade, snapshot: game.snapshot) { game.purchase(upgrade) }
                        }
                        Text(game.message).font(.footnote).foregroundStyle(Palette.gold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Autoclicker runs while the app is active. Each speed upgrade adds one tap per second, up to 20.")
                            .font(.caption).foregroundStyle(.white.opacity(0.45))
                    }.padding(20).frame(maxWidth: 600).frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Power up")
        }
    }
}

private struct UpgradeRow: View {
    let upgrade: Upgrade
    let snapshot: GameSnapshot
    let action: () -> Void
    private var title: String {
        switch upgrade {
        case .reward: "Bigger rewards"
        case .strength: "Stronger taps"
        case .balloon: "Bigger balloons"
        case .autoclicker: "Autoclicker"
        case .speed: "Faster autoclicker"
        }
    }
    private var detail: String {
        switch upgrade {
        case .reward: "+10 coins per pop · Now \(snapshot.reward)"
        case .strength: "+10 damage per tap · Now \(snapshot.strength)"
        case .balloon: "+10 HP and +10 coins per pop · Now \(snapshot.maxHP) HP"
        case .autoclicker: snapshot.autoClickerOwned ? "Owned · automatically taps for you" : "One automatic tap every second"
        case .speed: snapshot.autoClickerOwned ? "+1 tap/sec · Now \(snapshot.tapsPerSecond) taps/sec" : "Buy the autoclicker first"
        }
    }
    private var symbol: String {
        switch upgrade {
        case .reward: "plus.circle.fill"
        case .strength: "bolt.fill"
        case .balloon: "heart.fill"
        case .autoclicker: "timer"
        case .speed: "hare.fill"
        }
    }
    private var unavailableLabel: String {
        if upgrade == .autoclicker { return "OWNED" }
        if upgrade == .speed && !snapshot.autoClickerOwned { return "LOCKED" }
        return "MAX"
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: symbol).font(.title2).foregroundStyle(Palette.gold)
                    .frame(width: 46, height: 46).background(Palette.gold.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
                VStack(alignment: .leading, spacing: 5) {
                    Text(title).font(.headline)
                    Text(detail).font(.caption).foregroundStyle(.white.opacity(0.6)).fixedSize(horizontal: false, vertical: true)
                }
            }
            Button(action: action) {
                HStack {
                    Text(snapshot.isAvailable(upgrade) ? "Upgrade" : unavailableLabel)
                    Spacer()
                    if snapshot.isAvailable(upgrade) {
                        Text("\(snapshot.cost(of: upgrade).formatted()) coins")
                    }
                }.font(.subheadline.weight(.bold)).padding(13)
                    .foregroundStyle(snapshot.isAvailable(upgrade) && snapshot.coins >= snapshot.cost(of: upgrade) ? .black : .white.opacity(0.45))
                    .background(snapshot.isAvailable(upgrade) && snapshot.coins >= snapshot.cost(of: upgrade) ? Palette.gold : .white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(!snapshot.isAvailable(upgrade) || snapshot.coins < snapshot.cost(of: upgrade))
            .accessibilityIdentifier("upgrade_\(upgrade.rawValue)")
            .accessibilityLabel("\(title), \(snapshot.cost(of: upgrade)) coins")
        }.padding(16).background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 20))
    }
}
