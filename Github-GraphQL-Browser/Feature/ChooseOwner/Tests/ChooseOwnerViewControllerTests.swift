import ChooseOwnerMocks
import Foundation
import TestsUtils
import XCTest
@testable import ChooseOwner

class ChooseOwnerViewControllerTests: XCTestCase {
    var navigationMock: ChooseOwnerNavigationMock!
    var sut: ChooseOwnerViewController!
    
    override func setUp() {
        super.setUp()
        navigationMock = ChooseOwnerNavigationMock()
        sut = ChooseOwnerViewController()
        sut.navigation = navigationMock
    }

    func testDidTapDone() {
        sut.viewDidLoad()
        
        let watcher = watchCallbackEvents {
            self.navigationMock.chooseOwnerDidSelectOwnerCallback = $0
        }
        
        // HACK: performing selector since unit tests target is run without host app
        sut.perform(Selector("didTapDone"))
        
        XCTAssertEqual(watcher.values, [""])
    }
}
