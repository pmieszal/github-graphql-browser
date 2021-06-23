import XCTest
@testable import RepositoryDetails

class RepositoryDetailsViewControllerTests: XCTestCase {
    var sut: RepositoryDetailsViewController!
    
    override func setUpWithError() throws {
        sut = RepositoryDetailsViewController()
    }

    func testDisplayName() throws {
        sut.viewDidLoad()
        sut.displayName("test")
        XCTAssertEqual(sut.navigationItem.title, "test")
    }
}
