import SwiftUI

private struct AutoTapConfiguration: Equatable {
    let active: Bool
    let owned: Bool
    let interval: Double
}

struct ContentView: View {
    @Environment(GameState.self) private var game
    @Environment(\.scenePhase) private var scenePhase

    private var autoTap: AutoTapConfiguration {
        .init(active: scenePhase == .active, owned: game.snapshot.autoClickerOwned, interval: game.snapshot.autoClickInterval)
    }

    var body: some View {
        TabView {
            GameView().tabItem { Label("Play", systemImage: "hand.tap.fill") }
            UpgradesView().tabItem { Label("Upgrades", systemImage: "bolt.fill") }
            ShopView().tabItem { Label("Coin shop", systemImage: "bag.fill") }
        }
        .tint(Palette.gold)
        .task(id: autoTap) {
            guard autoTap.active, autoTap.owned else { return }
            let interval = autoTap.interval
            while !Task.isCancelled {
                do { try await Task.sleep(for: .seconds(interval)) }
                catch { return }
                guard !Task.isCancelled else { return }
                game.tapBalloon()
            }
        }
    }
}

enum Palette {
    static let navy = Color(red: 0.035, green: 0.04, blue: 0.12)
    static let gold = Color(red: 1, green: 0.77, blue: 0.25)
    static func balloon(_ color: BalloonColor) -> Color {
        switch color {
        case .red: Color(red: 1, green: 0.24, blue: 0.34)
        case .yellow: Color(red: 1, green: 0.91, blue: 0.22)
        case .gold: gold
        case .blue: Color(red: 0.2, green: 0.57, blue: 1)
        case .purple: Color(red: 0.66, green: 0.36, blue: 1)
        }
    }
}

struct GameView: View {
    @Environment(GameState.self) private var game
    @Environment(AudioController.self) private var audio
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Palette.navy.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    header
                    HStack(spacing: 12) {
                        StatCard(icon: "circle.fill", title: "COINS", value: game.snapshot.coins.formatted(), tint: Palette.gold)
                        StatCard(icon: "sparkles", title: "POPPED", value: game.snapshot.totalPops.formatted(), tint: .purple)
                    }
                    balloonStage
                    HStack(spacing: 12) {
                        StatCard(icon: "bolt.fill", title: "TAP POWER", value: "\(game.snapshot.strength)", tint: .yellow)
                        StatCard(icon: "plus.circle.fill", title: "PER POP", value: "+\(game.snapshot.reward.formatted())", tint: Palette.gold)
                    }
                    Text(game.message)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .frame(minHeight: 36)
                    Label(game.snapshot.autoClickerOwned ? "AUTO · \(game.snapshot.tapsPerSecond) taps / sec" : "Pop. Upgrade. Repeat.", systemImage: game.snapshot.autoClickerOwned ? "timer" : "hand.tap")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Palette.gold)
                        .padding(.horizontal, 18).padding(.vertical, 10)
                        .background(Palette.gold.opacity(0.09), in: Capsule())
                }
                .padding(22)
                .padding(.bottom, 28)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("BALLAPS").font(.system(size: 30, weight: .black, design: .rounded))
                Text("BALLOON TAPS").font(.system(size: 10, weight: .heavy)).tracking(3).foregroundStyle(Palette.gold)
            }
            Spacer()
            Button { game.toggleMusic() } label: {
                Image(systemName: game.snapshot.musicEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.headline).frame(width: 48, height: 48)
                    .background(.white.opacity(0.08), in: Circle())
            }
            .buttonStyle(.plain)
            .disabled(!audio.isAvailable)
            .accessibilityLabel(audio.isAvailable ? (game.snapshot.musicEnabled ? "Mute background music" : "Play background music") : "Background music unavailable")
        }
    }

    private var balloonStage: some View {
        VStack(spacing: 12) {
            HStack {
                Label(game.snapshot.balloonColor.title, systemImage: game.snapshot.balloonColor == .gold ? "sparkles" : "circle.fill")
                    .foregroundStyle(Palette.balloon(game.snapshot.balloonColor))
                Spacer()
                Text("\(game.snapshot.currentHP) / \(game.snapshot.maxHP) HP")
                    .monospacedDigit().foregroundStyle(.white.opacity(0.7))
            }.font(.caption.weight(.bold))
            ProgressView(value: game.snapshot.hpFraction)
                .tint(Palette.balloon(game.snapshot.balloonColor))
                .accessibilityLabel("Balloon health")
                .accessibilityValue("\(game.snapshot.currentHP) of \(game.snapshot.maxHP)")
            BalloonButton(color: game.snapshot.balloonColor, hitCount: game.hitCount, totalPops: game.snapshot.totalPops, strength: game.snapshot.strength, reduceMotion: reduceMotion) {
                game.tapBalloon()
            }
            Text("TAP TO POP").font(.system(size: 10, weight: .heavy)).tracking(4).foregroundStyle(.white.opacity(0.45))
            if game.snapshot.balloonColor == .gold {
                Text("GOLD BALLOON · 10% CHANCE").font(.system(size: 10, weight: .bold)).foregroundStyle(Palette.gold)
            }
        }
    }
}

private struct BalloonButton: View {
    let color: BalloonColor
    let hitCount: Int
    let totalPops: Int64
    let strength: Int
    let reduceMotion: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle().fill(Palette.balloon(color).opacity(0.11)).frame(width: 260, height: 260).blur(radius: 24)
                Circle().stroke(.white.opacity(0.04), lineWidth: 1).frame(width: 280, height: 280)
                BalloonArt(color: Palette.balloon(color)).frame(width: 210, height: 270)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .contentShape(Rectangle())
        }
        .buttonStyle(BalloonPressStyle(reduceMotion: reduceMotion))
        .sensoryFeedback(.impact(weight: .light), trigger: hitCount)
        .sensoryFeedback(.success, trigger: totalPops)
        .accessibilityIdentifier("balloonTapButton")
        .accessibilityLabel("Pop balloon")
        .accessibilityHint("Deals \(strength) damage per tap")
    }
}

private struct BalloonPressStyle: ButtonStyle {
    let reduceMotion: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.92 : 1)
            .animation(reduceMotion ? nil : .spring(response: 0.2, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

struct BalloonArt: View {
    let color: Color
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            ZStack(alignment: .top) {
                Path { path in
                    path.move(to: CGPoint(x: width * 0.5, y: height * 0.77))
                    path.addCurve(to: CGPoint(x: width * 0.49, y: height), control1: CGPoint(x: width * 0.35, y: height * 0.86), control2: CGPoint(x: width * 0.65, y: height * 0.9))
                }.stroke(.white.opacity(0.4), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                BalloonShape()
                    .fill(LinearGradient(colors: [color.opacity(0.65), color, color.opacity(0.65)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(BalloonShape().stroke(.white.opacity(0.24), lineWidth: 1.5))
                    .overlay(alignment: .topLeading) {
                        Ellipse().fill(.white.opacity(0.7)).frame(width: width * 0.09, height: height * 0.19)
                            .rotationEffect(.degrees(29)).blur(radius: 1)
                            .offset(x: width * 0.23, y: height * 0.11)
                    }
                    .frame(height: height * 0.81)
                    .shadow(color: color.opacity(0.25), radius: 24, y: 12)
            }
        }.accessibilityHidden(true)
    }
}

struct BalloonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to: CGPoint(x: rect.minX + w * 0.5, y: rect.minY + h * 0.9))
        p.addCurve(to: CGPoint(x: rect.minX + w * 0.5, y: rect.minY), control1: CGPoint(x: rect.minX - w * 0.2, y: rect.minY + h * 0.55), control2: CGPoint(x: rect.minX, y: rect.minY))
        p.addCurve(to: CGPoint(x: rect.minX + w * 0.5, y: rect.minY + h * 0.9), control1: CGPoint(x: rect.maxX, y: rect.minY), control2: CGPoint(x: rect.maxX + w * 0.2, y: rect.minY + h * 0.55))
        p.addLine(to: CGPoint(x: rect.minX + w * 0.55, y: rect.maxY))
        p.addQuadCurve(to: CGPoint(x: rect.minX + w * 0.45, y: rect.maxY), control: CGPoint(x: rect.midX, y: rect.maxY - h * 0.02))
        p.closeSubpath()
        return p
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let tint: Color
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon).font(.title3).foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.system(size: 9, weight: .heavy)).tracking(1.3).foregroundStyle(.white.opacity(0.45))
                Text(value).font(.system(size: 19, weight: .bold, design: .rounded)).lineLimit(1).minimumScaleFactor(0.5).monospacedDigit()
            }
            Spacer(minLength: 0)
        }.padding(15).frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 19))
            .accessibilityElement(children: .combine)
    }
}
