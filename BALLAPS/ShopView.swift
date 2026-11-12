import SwiftUI

struct ShopView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Palette.navy.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("THE COIN VAULT").font(.system(size: 26, weight: .black, design: .rounded))
                        Text("Planned coin packs").font(.subheadline).foregroundStyle(.white.opacity(0.6))
                        ForEach(CoinPackage.all) { package in
                            HStack(spacing: 16) {
                                Image(systemName: "circle.fill").font(.system(size: 32)).foregroundStyle(Palette.gold)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("\(package.displayCoins) coins").font(.title3.bold())
                                    Text("COMING SOON").font(.system(size: 9, weight: .heavy)).tracking(1.5).foregroundStyle(.white.opacity(0.4))
                                }
                                Spacer()
                                Text("\(package.priceEGP) EGP").font(.headline).foregroundStyle(Palette.gold)
                            }.padding(20).background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 20))
                                .accessibilityElement(children: .combine)
                        }
                        Label("Preview only. Purchases are unavailable and no money is charged.", systemImage: "lock.fill")
                            .font(.footnote).foregroundStyle(.white.opacity(0.55)).padding(.top, 10)
                        Text("You can earn coins by playing. Store prices are planning values, not live App Store offers.")
                            .font(.caption).foregroundStyle(.white.opacity(0.4))
                    }.padding(20).frame(maxWidth: 600).frame(maxWidth: .infinity)
                }
            }.navigationTitle("Coin shop")
        }
    }
}
