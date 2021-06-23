import Apollo
import Foundation
import TestsUtils
import XCTest
@testable import Domain
@testable import Networking
@testable import NetworkingMocks

// swiftlint:disable force_try
class RepositoryDetailsClientTests: XCTestCase {
    var clientMock: URLSessionClientMock!
    var sut: RepositoryDetailsClient!
    
    var bundle: Bundle {
        NetworkingMocksResources.bundle
    }
    
    var repositoryDetailsResponseMock: Data {
        let url = bundle.url(forResource: "repository-details-response-mock", withExtension: "json")!
        return try! Data(contentsOf: url)
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        clientMock = URLSessionClientMock()
        let graphQLClient = GraphQLClientMockBuilder.build(sessionClientMock: clientMock)
        let workaround = GraphQLClientWatcherWorkaround(graphQLClient: graphQLClient)
        sut = RepositoryDetailsClient(graphQLClient: workaround)
    }

    func testFetchSuccess() throws {
        let data = repositoryDetailsResponseMock
        let response = HTTPURLResponse()
        let result = (data, response)
        clientMock.appendResult(.success(result))
        
        let query = Domain.RepositoryDetailsQuery(
            owner: "",
            name: "",
            issuesCount: 10,
            pullRequestsCount: 10)
        let watcher = watchCallbackEvents {
            _ = self.sut.fetchQuery(query, completion: $0)
        }
        
        watcher.expectEventsCount(1)
        let value = watcher.lastValue
        XCTAssertNotNil(value?.result?.data)
        XCTAssertEqual(value?.result?.data?.name, "apollo-ios")
    }
    
    func testFetchError() throws {
        clientMock.appendResult(.failure(DummyLocalizedError.error))
        
        let query = Domain.RepositoryDetailsQuery(
            owner: "",
            name: "",
            issuesCount: 10,
            pullRequestsCount: 10)
        let watcher = watchCallbackEvents {
            _ = self.sut.fetchQuery(query, completion: $0)
        }
        
        watcher.expectEventsCount(1)
        let value = watcher.lastValue
        XCTAssertNotNil(value?.error)
    }
}
