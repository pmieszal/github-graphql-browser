import TestsUtils
import Domain
import Foundation
import RepositoryListMocks
import XCTest
@testable import RepositoryList

class RepositoryListViewControllerTests: XCTestCase {
    var navigationMock: RepositoryListNavigationMock!
    var interactorMock: RepositoryListInteractorLogicMock!
    var sut: RepositoryListViewController!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        navigationMock = RepositoryListNavigationMock()
        interactorMock = RepositoryListInteractorLogicMock()
        sut = RepositoryListViewController()
        sut.navigation = navigationMock
        sut.interactor = interactorMock
    }
    
    func testDisplayOwner() {
        sut.viewDidLoad()
        sut.displayOwner("test")
        XCTAssertEqual(sut.navigationItem.title, "test")
    }
    
    func testDisplayLoading() {
        sut.viewDidLoad()
        sut.displayLoading(true)
        XCTAssertTrue(sut.footerActivityIndicator.isAnimating)
        sut.displayLoading(false)
        XCTAssertFalse(sut.footerActivityIndicator.isAnimating)
    }
    
    func testDisplayRepositoriesAndSelect() {
        // Given
        interactorMock.owner = "test"
        
        var snapshot = NSDiffableDataSourceSnapshot<String, RepositoryListItem>()
        snapshot.appendSections([""])
        snapshot.appendItems(
            [
                .repository(
                    RepositoryListCellPresentable(
                        repository: Repository(id: nil, name: "name", url: nil))),
            ])
        
        sut.viewDidLoad()
        sut.applySnapshot(snapshot)
        
        let watcher = watchCallbackEvents {
            self.navigationMock.didSelectRepositoryCallback = $0
        }
        
        // When
        sut.tableView(sut.tableView, didSelectRowAt: IndexPath(item: 0, section: 0))
        
        // Then
        XCTAssertEqual(watcher.values.count, 1)
        XCTAssertEqual(watcher.lastValue?.name, "name")
        XCTAssertEqual(watcher.lastValue?.owner, "test")
    }
}
