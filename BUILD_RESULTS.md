# Ballaps verification

Verified on the user's MacBook on 11 November 2026, with Xcode 27.2.

## Passed

- iOS simulator build, arm64 and x86_64, using the iOS 27.2 SDK.
- Final build includes the balloon icon and supplied looping soundtrack.
- Installation and launch on the iPhone 18 Pro simulator, iOS 27.0.
- Termination, reinstall without removing app data, and successful relaunch.
- Visual inspection of the running Play screen: balloon, HP, coins, damage, reward, music control, and tabs render correctly.
- 10 automated rule and save-state tests, zero failures.
- Original media SHA-256 matches the downloaded source: `38acbb4e4d556ea7a7fdc19c6cba14bab344811e7707b1f1c7240593b44e25ea`.
- Soundtrack extraction completed: source duration 76.98 seconds, audio duration 76.90 seconds.

Automated coverage includes five-tap starting pop, insufficient funds, independent upgrade pricing, HP/reward bundle, overkill, autoclicker ownership/speed progression, gold distribution, save round-trips, malformed save fallback, relaunch state, repeated purchases, and arithmetic bounds.

## Not verified / not enabled

- A complete interactive UI regression pass, iPad/small-screen/Dynamic Type coverage, and physical-device testing were not completed.
- Audible playback was not manually listened to. Audio extraction, bundling, and the available music-control state were verified.
- No real-money purchases, App Store submission, provisioning changes, or publication were performed.
- Soundtrack distribution rights must be confirmed before public release.

The iPhone simulator app is left running. To run from Xcode, open `BALLAPS.xcodeproj`, select the BALLAPS scheme and an iPhone simulator, then press Command-R. Opening the folder or Package.swift instead selects the separate rule-test package.

## Follow-up run/test fix

Xcode was displaying the separate BallapsRules package with an iPhone destination. The package declared only macOS 14, so its iOS build defaulted too low for Observation. Added `.iOS(.v17)` to the package manifest. All 10 tests passed again afterward.

Opened Xcode 27's **Device Hub** application (the simulator viewer) and interactively verified:

- Five taps reduce 15 HP to a pop; balance changes from 10 to 20 coins.
- The 20-coin reward upgrade spends 20, raises reward to 20, and its next price becomes 40.
- The next balloon gives 20 coins.
- Play, Upgrades, and Coin Shop navigation works.
- Coin Shop is preview-only, with no active purchase controls.
- Mute and unmute controls update correctly; music preference restored to enabled.

Simulator progress after these checks: 20 coins, 2 pops, reward 20 per pop. No progress was reset. The playable simulator remains open in Device Hub under iPhone 18 Pro.
