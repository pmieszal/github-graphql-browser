import TestsUtils
import XCTest
@testable import Domain
@testable import DomainMocks

class RepositoriesUseCaseTests: XCTestCase {
    var serviceMock: RepositoryServiceMock!
    var sut: RepositoriesWatchUseCase!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        serviceMock = RepositoryServiceMock()
        sut = RepositoriesWatchUseCase(service: serviceMock, pageItemsCount: 20)
    }
    
    func testLoadFirstPage() {
        serviceMock.appendRefreshResult(repositoryFetchEvent(repositories: [.init(id: nil, name: nil, url: nil)]))
        
        let repositoriesWatcher = watchCallbackEvents {
            self.sut.watchRepositoriesForOwner(owner: "", stateEventsHandler: $0)
        }
        
        sut.loadNextPage()
        repositoriesWatcher.expectEventsCount(2)
        let events = repositoriesWatcher.values
        XCTAssertEqual(events[0].isLoading, true)
        XCTAssertEqual(events[0].list.count, 0)
        
        XCTAssertEqual(events[1].isLoading, false)
        XCTAssertEqual(events[1].list.count, 1)
    }
    
    func testLoadTwoPages() {
        serviceMock.appendRefreshResult(
            repositoryFetchEvent(
                repositories: [.init(id: "0", name: nil, url: nil)],
                pageInfo: PageInfo(hasNextPage: true, endCursor: "1")))
        serviceMock.appendRefreshResult(repositoryFetchEvent(repositories: [.init(id: "1", name: nil, url: nil)]))
        
        let repositoriesWatcher = watchCallbackEvents {
            self.sut.watchRepositoriesForOwner(owner: "", stateEventsHandler: $0)
        }
        
        sut.loadNextPage()
        repositoriesWatcher.expectEventsCount(2)
        var events = repositoriesWatcher.values
        XCTAssertEqual(events[0].isLoading, true)
        XCTAssertEqual(events[0].list.count, 0)
        
        XCTAssertEqual(events[1].isLoading, false)
        XCTAssertEqual(events[1].list.count, 1)
        
        sut.loadNextPage()
        repositoriesWatcher.expectEventsCount(4)
        events = repositoriesWatcher.values
        XCTAssertEqual(events[2].isLoading, true)
        XCTAssertEqual(events[2].list.count, 1)
        
        XCTAssertEqual(events[3].isLoading, false)
        XCTAssertEqual(events[3].list.count, 2)
    }
    
    func repositoryFetchEvent(repositories: [Repository] = [],
                              pageInfo: PageInfo? = nil) -> QueryResult<QueryPageableResultEnvelope<[Repository]>> {
        let pageableEnvelope = PageableEnvelope<[Repository]>(data: repositories, pageInfo: pageInfo)
        let queryEnvelope = QueryPageableResultEnvelope(pageableEnvelope: pageableEnvelope, queryErrors: nil)
        
        return .success(queryEnvelope)
    }
}
