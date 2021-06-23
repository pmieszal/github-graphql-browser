import Apollo
import Foundation
import TestsUtils
import XCTest
@testable import Networking
@testable import NetworkingMocks

// swiftlint:disable force_try
class GraphQLClientTests: XCTestCase {
    /// Change to false if you want to run failing tests with Apollo bug
    let shouldSkipFailingTests = true
    var apolloStore: ApolloStore!
    var clientMock: URLSessionClientMock!
    var sut: GraphQLClient!
    
    var bundle: Bundle {
        NetworkingMocksResources.bundle
    }
    
    var repositoryListResponseMock: Data {
        let url = bundle.url(forResource: "repository-list-response-mock", withExtension: "json")!
        return try! Data(contentsOf: url)
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        apolloStore = ApolloStore(cache: InMemoryNormalizedCache())
        apolloStore.cacheKeyForObject = {
            $0["id"]
        }
        
        clientMock = URLSessionClientMock()
        sut = GraphQLClientMockBuilder.build(
            sessionClientMock: clientMock,
            apolloStore: apolloStore
        )
    }

    /*
     Failing test that represents bug described in GraphQLClientWatcherWorkaround file.
     When starting to watch cache changes with CachePolicy.returnCacheDataDontFetch
     but without initialized cache, watch closure is invoked with JSONDecodingError.missingValue
     and never called again.
      */
    func testWatchAndRefresh() throws {
        try XCTSkipIf(shouldSkipFailingTests)
        
        let query = RepositoryListQuery(owner: "", count: 0)
        let data = repositoryListResponseMock
        let response = HTTPURLResponse()
        let result = (data, response)
        clientMock.appendResult(.success(result))
        
        let watcher = watchCallbackEvents { handler in
            self.sut.watch(
                query,
                handler: handler)
        }
        watcher.expectEventsCount(1)
        var value = watcher.lastValue
        XCTAssertNil(value??.repositoryOwner)
        
        let refreshResult = waitForCallback { handler in
            self.sut.fetchIgnoringCacheData(query, completion: handler)
        }
        XCTAssertNotNil(refreshResult?.success)
        
        watcher.expectEventsCount(2)
        value = watcher.lastValue
        let repository = value??.repositoryOwner?.repositories.nodes?.first
        XCTAssertEqual(repository?.underlying?.url, "https://github.com/apollographql/apollo-client")
    }
    
    func testWatchWithInitiallyFilledCache() {
        let query = RepositoryListQuery(owner: "", count: 0)
        
        let data = RepositoryListQuery.Data(
            repositoryOwner: .makeOrganization(
                id: UUID().uuidString,
                repositories: .init(
                    nodes: [
                        .init(id: UUID().uuidString, name: "Test", url: "testUrl"),
                    ],
                    pageInfo: .init(hasNextPage: false))))
        
        apolloStore.withinReadWriteTransaction { transaction in
            try! transaction.write(data: data, forQuery: query)
        }
        
        let watcher = watchCallbackEvents { handler in
            self.sut.watch(
                query,
                handler: handler)
        }
        
        watcher.expectEventsCount(1)
        let value = watcher.lastValue
        
        let node = value??.repositoryOwner?.repositories.nodes?.first
        XCTAssertEqual(node?.underlying?.name, "Test")
        XCTAssertEqual(node?.underlying?.url, "testUrl")
    }
    
    func testFetchIgnoringCacheWithInitiallyFilledCache() {
        let query = RepositoryListQuery(owner: "", count: 0)
        let data = repositoryListResponseMock
        let response = HTTPURLResponse()
        let result = (data, response)
        clientMock.appendResult(.success(result))
        
        let repository = RepositoryListQuery.Data(
            repositoryOwner: .makeOrganization(
                id: UUID().uuidString,
                repositories: .init(
                    nodes: [
                        .init(id: UUID().uuidString, name: "Test", url: "testUrl"),
                    ],
                    pageInfo: .init(hasNextPage: false))))
        
        apolloStore.withinReadWriteTransaction { transaction in
            try! transaction.write(data: repository, forQuery: query)
        }
        
        let watcher = watchCallbackEvents { handler in
            self.sut.fetchIgnoringCacheData(query, completion: handler)
        }
        
        // Data from response
        watcher.expectEventsCount(1)
        let value = watcher.lastValue
        let node = value?.success?.data?.repositoryOwner?.repositories.nodes?.first
        XCTAssertEqual(node?.underlying?.name, "apollo-client")
        XCTAssertEqual(node?.underlying?.url, "https://github.com/apollographql/apollo-client")
        
        watcher.expectToNotBeInvoked()
    }
    
    func testFetchWithInitiallyFilledCache() {
        let query = RepositoryListQuery(owner: "", count: 0)
        let data = repositoryListResponseMock
        let response = HTTPURLResponse()
        let result = (data, response)
        clientMock.appendResult(.success(result))
        
        let repository = RepositoryListQuery.Data(
            repositoryOwner: .makeOrganization(
                id: UUID().uuidString,
                repositories: .init(
                    nodes: [
                        .init(id: UUID().uuidString, name: "Test", url: "testUrl"),
                    ],
                    pageInfo: .init(hasNextPage: false))))
        
        apolloStore.withinReadWriteTransaction { transaction in
            try! transaction.write(data: repository, forQuery: query)
        }
        
        let watcher = watchCallbackEvents { handler in
            self.sut.fetch(query, completion: handler)
        }
        
        watcher.expectEventsCount(2)
        
        // Data from cache
        var value = watcher.values.first
        var node = value?.success?.data?.repositoryOwner?.repositories.nodes?.first
        XCTAssertEqual(node?.underlying?.name, "Test")
        XCTAssertEqual(node?.underlying?.url, "testUrl")
        
        // Data from response
        value = watcher.values.last
        node = value?.success?.data?.repositoryOwner?.repositories.nodes?.first
        XCTAssertEqual(node?.underlying?.name, "apollo-client")
        XCTAssertEqual(node?.underlying?.url, "https://github.com/apollographql/apollo-client")
    }
    
    func testFetchWithEmptyCache() {
        let query = RepositoryListQuery(owner: "", count: 0)
        let data = repositoryListResponseMock
        let response = HTTPURLResponse()
        let result = (data, response)
        clientMock.appendResult(.success(result))
        
        let watcher = watchCallbackEvents { handler in
            self.sut.fetch(query, completion: handler)
        }
        
        watcher.expectEventsCount(1)
        
        // Data from response
        let value = watcher.lastValue
        let node = value?.success?.data?.repositoryOwner?.repositories.nodes?.first
        XCTAssertEqual(node?.underlying?.name, "apollo-client")
        XCTAssertEqual(node?.underlying?.url, "https://github.com/apollographql/apollo-client")
        
        watcher.expectToNotBeInvoked()
    }
}
