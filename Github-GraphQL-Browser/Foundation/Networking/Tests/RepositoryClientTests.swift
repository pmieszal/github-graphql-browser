import Apollo
import Foundation
import TestsUtils
import XCTest
@testable import Domain
@testable import Networking
@testable import NetworkingMocks

// swiftlint:disable force_try
class RepositoryClientTests: XCTestCase {
    var clientMock: URLSessionClientMock!
    var sut: RepositoriesClient!
    
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
        let graphQLClient = GraphQLClientMockBuilder.build(sessionClientMock: clientMock)
        let workaround = GraphQLClientWatcherWorkaround(graphQLClient: graphQLClient)
        sut = RepositoriesClient(graphQLClient: workaround)
    }

    func testWatchAndRefresh() throws {
        let data = repositoryListResponseMock
        let response = HTTPURLResponse()
        let result = (data, response)
        clientMock.appendResult(.success(result))
        
        let query = RepositoriesQuery(owner: "", count: 0, after: nil)
        
        let watcher = watchCallbackEvents { (handler) in
            _ = self.sut.watchChangesForQuery(query, handler: handler)
        }
        
        let refreshResult = waitForCallback { (handler) in
            _ = self.sut.refreshQuery(query, completion: handler)
        }
        XCTAssertNotNil(refreshResult?.result)
        
        watcher.expectEventsCount(1)
        let value = watcher.lastValue
        XCTAssertEqual(value?.data.count, 10)
    }
}
