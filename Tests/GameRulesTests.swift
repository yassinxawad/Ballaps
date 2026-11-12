import XCTest
@testable import BallapsRules

final class GameRulesTests: XCTestCase {
    func testStartsWithRequestedValuesAndPopsOnFifthTap() {
        var game = GameSnapshot()
        XCTAssertEqual(game.coins, 10)
        XCTAssertEqual(game.maxHP, 15)
        XCTAssertEqual(game.strength, 3)
        for _ in 0..<4 { XCTAssertEqual(game.tap(nextColor: .blue), 0) }
        XCTAssertEqual(game.currentHP, 3)
        XCTAssertEqual(game.coins, 10)
        XCTAssertEqual(game.tap(nextColor: .purple), 10)
        XCTAssertEqual(game.coins, 20)
        XCTAssertEqual(game.currentHP, 15)
        XCTAssertEqual(game.totalPops, 1)
        XCTAssertEqual(game.balloonColor, .purple)
    }
    func testCannotSpendCoinsYouDoNotHave() {
        var game = GameSnapshot()
        let before = game
        for upgrade in Upgrade.allCases { XCTAssertFalse(game.purchase(upgrade)) }
        XCTAssertEqual(game, before)
    }
    func testRewardPricesRiseIndependentlyFromBalloonUpgrade() {
        var game = GameSnapshot(); game.coins = 10000
        XCTAssertTrue(game.purchase(.reward)); XCTAssertEqual(game.cost(of: .reward), 40)
        XCTAssertEqual(game.reward, 20)
        XCTAssertTrue(game.purchase(.balloon)); XCTAssertEqual(game.reward, 30)
        XCTAssertEqual(game.maxHP, 25); XCTAssertEqual(game.currentHP, 25)
        XCTAssertEqual(game.cost(of: .balloon), 140)
        XCTAssertEqual(game.cost(of: .reward), 40)
        XCTAssertTrue(game.purchase(.reward)); XCTAssertEqual(game.cost(of: .reward), 60)
    }
    func testStrengthAndOverkillCannotDoubleReward() {
        var game = GameSnapshot(); game.coins = 10000
        XCTAssertTrue(game.purchase(.strength)); XCTAssertEqual(game.strength, 13)
        XCTAssertEqual(game.cost(of: .strength), 100)
        XCTAssertTrue(game.purchase(.strength)); XCTAssertEqual(game.strength, 23)
        let coins = game.coins
        XCTAssertEqual(game.tap(nextColor: .red), 10)
        XCTAssertEqual(game.coins, coins + 10); XCTAssertEqual(game.totalPops, 1)
    }
    func testAutoclickerAndSpeedProgression() {
        var game = GameSnapshot(); game.coins = 1_000_000
        XCTAssertFalse(game.purchase(.speed))
        XCTAssertTrue(game.purchase(.autoclicker)); XCTAssertFalse(game.purchase(.autoclicker))
        XCTAssertEqual(game.cost(of: .speed), 500)
        XCTAssertTrue(game.purchase(.speed)); XCTAssertEqual(game.cost(of: .speed), 1000)
        XCTAssertEqual(game.autoClickInterval, 0.5)
        for _ in 1..<19 { XCTAssertTrue(game.purchase(.speed)) }
        XCTAssertEqual(game.tapsPerSecond, 20)
        XCTAssertFalse(game.purchase(.speed))
    }
    func testGoldHasExactlyTenPercentOfDraws() {
        let draws = (0..<100).map { BalloonColor.draw(roll: $0) }
        XCTAssertEqual(draws.filter { $0 == .gold }.count, 10)
        XCTAssertEqual(Set(draws).count, 5)
    }
    func testPersistenceRoundTrip() throws {
        var game = GameSnapshot(); game.coins = 1000
        _ = game.purchase(.balloon); _ = game.purchase(.autoclicker)
        _ = game.tap(nextColor: .gold); game.musicEnabled = false
        let decoded = try JSONDecoder().decode(GameSnapshot.self, from: JSONEncoder().encode(game))
        XCTAssertEqual(decoded, game)
    }
    func testInvalidSaveSanitizesAndCoinOverflowIsPrevented() {
        var game = GameSnapshot()
        game.coins = .max; game.strengthLevel = .max; game.balloonLevel = -50
        game.speedLevel = .max; game.currentHP = -99
        game.sanitize()
        XCTAssertEqual(game.coins, GameSnapshot.maximumCoins)
        XCTAssertEqual(game.maxHP, 15); XCTAssertEqual(game.currentHP, 1)
        XCTAssertEqual(game.speedLevel, 0)
        _ = game.tap(nextColor: .yellow)
        XCTAssertEqual(game.coins, GameSnapshot.maximumCoins)
    }
}
