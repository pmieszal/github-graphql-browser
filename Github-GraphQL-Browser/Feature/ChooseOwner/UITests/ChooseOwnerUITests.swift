import XCTest
import Core

class ChooseOwnerUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = [UITestsFlag]
        app.launch()
    }

    func testInputOwnerNameAndTapDone() throws {
        let textField = app.textFields.firstMatch
        textField.tap()
        textField.typeText("test")
        XCTAssertEqual(textField.value as? String, "test")
        
        let button = app.buttons["Hit me!"]
        button.tap()
    }
}
