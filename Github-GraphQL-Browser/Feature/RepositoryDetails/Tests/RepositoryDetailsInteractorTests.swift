import TestsUtils
import XCTest
@testable import NetworkingMocks
@testable import RepositoryDetails
@testable import RepositoryDetailsMocks

// swiftlint:disable force_try
class RepositoryDetailsInteractorTests: XCTestCase {
    var dependencyMock: RepositoryDetailsDependencyMock!
    var presenterMock: RepositoryDetailsPresenterLogicMock!
    var clientMock: URLSessionClientMock!
    var sut: RepositoryDetailsInteractor!
    
    var bundle: Bundle {
        NetworkingMocksResources.bundle
    }
    
    var repositoryDetailsResponseMock: Data {
        let url = bundle.url(forResource: "repository-details-response-mock", withExtension: "json")!
        return try! Data(contentsOf: url)
    }
    
    override func setUpWithError() throws {
        clientMock = URLSessionClientMock()
        
        dependencyMock = RepositoryDetailsDependencyMock()
        dependencyMock.graphQLClient = GraphQLClientMockBuilder.build(sessionClientMock: clientMock)
        dependencyMock.url = "https://localhost:1234"
        dependencyMock.token = "token"
        dependencyMock.itemsCount = 10
        
        presenterMock = RepositoryDetailsPresenterLogicMock()
        sut = RepositoryDetailsInteractor(
            presenter: presenterMock,
            dependency: dependencyMock,
            owner: "owner",
            name: "name")
    }
    
    func testViewDidLoad() {
        // Given
        let data = repositoryDetailsResponseMock
        let response = HTTPURLResponse()
        let result = (data, response)
        clientMock.appendResult(.success(result))
        
        let presentNameWatcher = watchCallbackEvents {
            self.presenterMock.presentNameCallback = $0
        }
        let presentDetailsWatcher = watchCallbackEvents {
            self.presenterMock.presentDetailsCallback = $0
        }
        
        sut.viewDidLoad()
        
        presentNameWatcher.expectEventsCount(1)
        
        XCTAssertEqual(presentNameWatcher.values, ["name"])
        
        presentDetailsWatcher.expectEventsCount(1)
        let details = presentDetailsWatcher.lastValue
        XCTAssertEqual(details?.openedIssuesItems.items.count, 10)
        XCTAssertEqual(details?.closedIssuesItems.items.count, 10)
        XCTAssertEqual(details?.openedPRsItems.items.count, 4)
        XCTAssertEqual(details?.closedPRsItems.items.count, 10)
    }
}
