import XCTest

final class TogetherUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testMemoryPersistsAndCanBeDeleted() {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        let title = "Memory " + UUID().uuidString.prefix(8)
        app.navigationBars["Together"].buttons["Add"].tap()
        let field = app.textFields["A name for this memory"]
        XCTAssertTrue(field.waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["Save"].isEnabled)
        field.tap()
        field.typeText("   ")
        XCTAssertFalse(app.buttons["Save"].isEnabled)
        field.typeText(title)
        app.buttons["Save"].tap()
        XCTAssertTrue(app.staticTexts[title].waitForExistence(timeout: 10))
        app.terminate()
        app.launch()
        XCTAssertTrue(app.staticTexts[title].waitForExistence(timeout: 10))
        app.staticTexts[title].tap()
        XCTAssertTrue(app.buttons["Delete"].waitForExistence(timeout: 10))
        app.buttons["Edit"].tap()
        let editTitle = app.textFields["A name for this memory"]
        XCTAssertTrue(editTitle.waitForExistence(timeout: 10))
        XCTAssertEqual(editTitle.value as? String, title)
        XCTAssertTrue(app.buttons["choosePhotos"].exists)
        app.buttons["Save"].tap()
        XCTAssertTrue(app.buttons["Edit"].waitForExistence(timeout: 10))
        app.buttons["Delete"].tap()
        app.buttons["Delete memory"].tap()
        XCTAssertTrue(app.navigationBars["Together"].waitForExistence(timeout: 10))
        app.terminate()
        app.launch()
        XCTAssertTrue(app.navigationBars["Together"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts[title].exists)
    }

    @MainActor
    func testAnnualOccasionPersistsAndCanBeDeleted() {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        let title = "Anniversary " + UUID().uuidString.prefix(8)
        app.tabBars.buttons["Dates"].tap()
        app.navigationBars["Special dates"].buttons["Add"].tap()
        let field = app.textFields["Anniversary, first date…"]
        XCTAssertTrue(field.waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["Save"].isEnabled)
        field.tap()
        field.typeText(title)
        app.buttons["Save"].tap()
        XCTAssertTrue(app.staticTexts[title].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Every year"].exists)
        XCTAssertTrue(app.staticTexts["Today ♥"].exists)
        app.terminate()
        app.launch()
        app.tabBars.buttons["Dates"].tap()
        XCTAssertTrue(app.staticTexts[title].waitForExistence(timeout: 10))
        app.staticTexts[title].swipeLeft()
        app.buttons["Delete"].tap()
        app.terminate()
        app.launch()
        app.tabBars.buttons["Dates"].tap()
        XCTAssertTrue(app.navigationBars["Special dates"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts[title].exists)
    }
}
