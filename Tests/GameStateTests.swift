import XCTest
@testable import BallapsRules

final class GameStateTests: XCTestCase {
    @MainActor
    func testStatePersistsAcrossRelaunchAndRepeatedPurchases() throws {
        let suite = "ballaps.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let first = GameState(defaults: defaults)
        for _ in 0..<5 { first.tapBalloon() }
        first.purchase(.reward)
        XCTAssertEqual(first.snapshot.coins, 0)
        XCTAssertEqual(first.snapshot.reward, 20)
        first.purchase(.reward)
        XCTAssertEqual(first.snapshot.reward, 20)
        first.toggleMusic()
        first.tapBalloon()
        first.saveNow()
        let second = GameState(defaults: defaults)
        XCTAssertEqual(second.snapshot, first.snapshot)
        XCTAssertEqual(second.snapshot.currentHP, 12)
        XCTAssertFalse(second.snapshot.musicEnabled)
    }

    @MainActor
    func testMalformedSaveFallsBackWithoutCrashing() throws {
        let suite = "ballaps.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(Data("broken save".utf8), forKey: "ballaps_save_v2")
        let game = GameState(defaults: defaults)
        XCTAssertEqual(game.snapshot, GameSnapshot())
    }
}
