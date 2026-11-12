# BALLAPS

Native SwiftUI balloon-tapping game for iPhone and iPad, iOS 17 or newer.

## Open the app project

Open **BALLAPS.xcodeproj** in this folder. Do not open the folder or `Package.swift` to run the app: that package is only for automated rule/state tests.

1. Choose the **BALLAPS** scheme.
2. Choose an iPhone simulator.
3. Press **Command-R**.

The separate original project in Downloads is preserved. This working version lives in `Documents/Ballaps`.

For a physical iPhone, select your own development team in Signing & Capabilities. This project has not been published or uploaded to App Store Connect.

## Game rules

- Start with 10 coins, a 15 HP balloon, and 3 damage per tap. Five taps pop the first balloon.
- Each pop initially awards 10 coins.
- Bigger rewards: +10 coins per pop. Prices: 20, 40, 60, …
- Stronger taps: +10 damage. Prices: 50, 100, 150, …
- Bigger balloons: +10 HP and +10 coins per pop. Prices: 70, 140, 210, …
- Autoclicker: 100 coins, purchased once, starts at one tap per second.
- Speed upgrades: 500, 1,000, 1,500, … Each adds one tap per second, capped at 20 taps/sec.
- Balloons are red, yellow, gold, blue, and purple. Gold has a 10% spawn chance. Colors do not change rewards.
- Autoclicking pauses while the app is inactive. Offline earnings are not implemented.
- Progress and the music preference save locally. A separate v2 save key preserves any old prototype save data.

## Music and icon

The supplied 76.98-second video is preserved in `SourceMedia/background-original.mp4`. Its audio was extracted to `BALLAPS/BackgroundMusic.m4a` (76.90 seconds) and bundled for looping playback. Use the speaker button to mute. The audio respects silent mode and mixes with other audio. Playback pauses when the app is inactive.

The app icon is a single red balloon. Its source-generation script is in `scripts/create-icon.swift`.

Before public distribution, confirm rights to use the soundtrack.

## Coin shop

Preview only, with the requested planning prices:

- 1B coins: 50 EGP
- 10B coins: 100 EGP
- 100B coins: 500 EGP
- 1T coins: 1,000 EGP

No purchases, payment collection, simulated grants, or network services are enabled. StoreKit products and actual App Store prices require a separate setup before release.

## Verification

Run the pure game-rule and save-state tests:

    swift test

Build for simulator without signing:

    xcodebuild -project BALLAPS.xcodeproj -scheme BALLAPS -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO build

See `BUILD_RESULTS.md` for the checks completed on this Mac.
