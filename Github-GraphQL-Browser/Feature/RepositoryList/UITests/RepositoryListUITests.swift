import XCTest
import Core

class RepositoryListUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = [UITestsFlag]
        app.launch()
    }
    
    func testDisplayItems() throws {
        let cellExists = app.cells.firstMatch.waitForExistence(timeout: 10)
        XCTAssertTrue(cellExists)
    }
}
