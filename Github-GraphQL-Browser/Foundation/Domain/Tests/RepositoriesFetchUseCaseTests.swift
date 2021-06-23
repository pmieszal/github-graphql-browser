import TestsUtils
import XCTest
@testable import Domain
@testable import DomainMocks

class RepositoriesFetchUseCaseTests: XCTestCase {
    var serviceMock: RepositoryServiceMock!
    var sut: RepositoriesFetchUseCase!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        serviceMock = RepositoryServiceMock()
        sut = RepositoriesFetchUseCase(service: serviceMock)
    }
    
    func testFetch() {
        serviceMock.appendRefreshResult(repositoryFetchEvent(repositories: [.init(id: nil, name: nil, url: nil)]))
        
        let fetchWatcher = watchCallbackEvents {
            self.sut.fetch(owner: "", handler: $0)
        }
        
        fetchWatcher.expectEventsCount(1)
        let value = fetchWatcher.lastValue
        XCTAssertEqual(value?.count, 1)
    }
    
    func repositoryFetchEvent(repositories: [Repository] = [],
                              pageInfo: PageInfo? = nil) -> QueryResult<QueryPageableResultEnvelope<[Repository]>> {
        let pageableEnvelope = PageableEnvelope<[Repository]>(data: repositories, pageInfo: pageInfo)
        let queryEnvelope = QueryPageableResultEnvelope(pageableEnvelope: pageableEnvelope, queryErrors: nil)
        
        return .success(queryEnvelope)
    }
}
