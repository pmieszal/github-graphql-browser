import RepositoryListMocks
import XCTest
import TestsUtils
@testable import NetworkingMocks
@testable import RepositoryList

// swiftlint:disable force_try
class RepositoryListInteractorTests: XCTestCase {    
    var dependenciesMock: RepositoryListDependenciesMock!
    var presenterMock: RepositoryListPresenterLogicMock!
    var clientMock: URLSessionClientMock!
    var sut: RepositoryListInteractor!
    
    var bundle: Bundle {
        NetworkingMocksResources.bundle
    }
    
    var repositoryListResponseMock: Data {
        let url = bundle.url(forResource: "repository-list-response-mock", withExtension: "json")!
        return try! Data(contentsOf: url)
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        clientMock = URLSessionClientMock()
        
        dependenciesMock = RepositoryListDependenciesMock()
        dependenciesMock.graphQLClient = GraphQLClientMockBuilder.build(sessionClientMock: clientMock)
        dependenciesMock.url = "https://localhost:1234"
        dependenciesMock.token = "token"
        dependenciesMock.pageItemsCount = 20
        
        presenterMock = RepositoryListPresenterLogicMock()
        sut = RepositoryListInteractor(
            presenter: presenterMock,
            owner: "test",
            dependency: dependenciesMock)
    }

    func testViewDidLoad() throws {
        // Given
        let data = repositoryListResponseMock
        let response = HTTPURLResponse()
        let result = (data, response)
        clientMock.appendResult(.success(result))
        
        let presentOwnerWatcher = watchCallbackEvents { self.presenterMock.presentOwnerCallback = $0 }
        let presentListWatcher = watchCallbackEvents { self.presenterMock.presentListCallback = $0 }
                
        sut.viewDidLoad()
        
        XCTAssertEqual(presentOwnerWatcher.values, ["test"])
        
        presentListWatcher.expectEventsCount(2)
        let values = presentListWatcher.values
        
        XCTAssertEqual(values[0].items.count, 0)
        XCTAssertEqual(values[0].isLoading, true)
        
        XCTAssertEqual(values[1].items.count, 10)
        XCTAssertEqual(values[1].isLoading, false)
    }
}
