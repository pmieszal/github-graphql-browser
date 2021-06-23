import XCTest
import Core

class GithubQLUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = [UITestsFlag]
        app.launch()
    }

    func testAppFlow() throws {
        let textField = app.textFields.firstMatch
        textField.tap()
        textField.typeText("test")
        XCTAssertEqual(textField.value as? String, "test")
        
        let button = app.buttons["Hit me!"]
        button.tap()
        
        let listCellExists = app.cells.firstMatch.waitForExistence(timeout: 10)
        XCTAssertTrue(listCellExists)
        
        app.cells.firstMatch.tap()
        
        let detailsCellExists = app.cells.firstMatch.waitForExistence(timeout: 10)
        XCTAssertTrue(detailsCellExists)
    }
}
