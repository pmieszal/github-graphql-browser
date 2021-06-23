import Apollo
import Foundation
import Nimble
import Quick
import TestsUtils
import XCTest
@testable import Networking
@testable import NetworkingMocks

// swiftlint:disable force_try
class GraphQLClientWatcherWorkaroundTests: XCTestCase {
    #if IS_CI
    let shouldSkipFlakyTests = true
    #else
    let shouldSkipFlakyTests = false
    #endif
    
    var apolloStore: ApolloStore!
    var clientMock: URLSessionClientMock!
    var sut: GraphQLClientWatcherWorkaround!
    
    var bundle: Bundle {
        NetworkingMocksResources.bundle
    }
    
    var repositoryListResponseMock: Data {
        let url = bundle.url(forResource: "repository-list-response-mock", withExtension: "json")!
        return try! Data(contentsOf: url)
    }
    
    var repositoryListEmptyResponseMock: Data {
        let url = bundle.url(forResource: "repository-list-empty-response-mock", withExtension: "json")!
        return try! Data(contentsOf: url)
    }
    
    var repositoryDetailsResponseMock: Data {
        let url = bundle.url(forResource: "repository-details-response-mock", withExtension: "json")!
        return try! Data(contentsOf: url)
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        apolloStore = ApolloStore(cache: InMemoryNormalizedCache())
        apolloStore.cacheKeyForObject = {
            $0["id"]
        }
        
        clientMock = URLSessionClientMock()
        let graphQLClient = GraphQLClientMockBuilder.build(
            sessionClientMock: clientMock,
            apolloStore: apolloStore)
        sut = GraphQLClientWatcherWorkaround(graphQLClient: graphQLClient)
    }
    
    /**
     Tests to consider:
     - test if watchers cancels properly on rewatchQuery method
     - testFetchListThenFetchDetails with changed data on details; watcher should be invoked
     */
    
    func testWatchAndRefreshWithWorkaround() {
        let query = RepositoryListQuery(owner: "", count: 0)
        let data = repositoryListResponseMock
        let response = HTTPURLResponse()
        let result = (data, response)
        clientMock.appendResult(.success(result))
        
        let watcher = watchCallbackEvents { handler in
            self.sut.watch(query, handler: handler)
        }
        
        let refreshResult = waitForCallback { handler in
            self.sut.fetchIgnoringCacheData(query, completion: handler)
        }
        XCTAssertNotNil(refreshResult?.success)
        
        watcher.expectEventsCount(2) // empty event and then fulfilled from refresh
        let value = watcher.lastValue
        let repository = value??.repositoryOwner?.repositories.nodes?.first
        XCTAssertEqual(repository?.underlying?.url, "https://github.com/apollographql/apollo-client")
    }
    
    func testFetchListThenFetchDetails() {
        let repositoriesQuery = RepositoryListQuery(owner: "", count: 0)
        var data = repositoryListResponseMock
        let response = HTTPURLResponse()
        var result = (data, response)
        clientMock.appendResult(.success(result))
        
        let refreshRepositoriesResult = waitForCallback { handler in
            self.sut.fetchIgnoringCacheData(repositoriesQuery, completion: handler)
        }
        XCTAssertNotNil(refreshRepositoriesResult?.success)
        
        let repositoriesWatcher = watchCallbackEvents { handler in
            self.sut.watch(
                repositoriesQuery,
                handler: handler)
        }
        
        repositoriesWatcher.expectEventsCount(1)
        let repositoriesValue = repositoriesWatcher.lastValue
        let node = repositoriesValue??.repositoryOwner?.repositories.nodes?.first
        XCTAssertEqual(node?.underlying?.url, "https://github.com/apollographql/apollo-client")
        
        let detailsQuery = RepositoryDetailsQuery(
            owner: "apollographql",
            name: "apollo-ios",
            issuesCount: 10,
            pullRequestsCount: 10)
        data = repositoryDetailsResponseMock
        result = (data, response)
        clientMock.appendResult(.success(result))
        
        let refreshDetailsResult = waitForCallback { handler in
            self.sut.fetchIgnoringCacheData(detailsQuery, completion: handler)
        }
        XCTAssertNotNil(refreshDetailsResult?.success)
        
        let detailsWatcher = watchCallbackEvents { handler in
            self.sut.watch(detailsQuery, handler: handler)
        }
        
        detailsWatcher.expectEventsCount(1)
        let detailsValue = detailsWatcher.lastValue
        XCTAssertEqual(detailsValue??.repository?.name, "apollo-ios")
    }
    
    /*
     For some unknown reason, this test is flaky when it's run on iPhone 12 mini simulator
     with `Github-GraphQL-Browser-Project` target.
     When run on iPhone 12 or just separately everything is working fine 🤔
     Can't tell why, gave it couple of hours of investigation, but it turned out to nothing.
     */
    func testRefreshList() throws {
        try XCTSkipIf(shouldSkipFlakyTests)
        
        let query = RepositoryListQuery(owner: "", count: 0)
        var data = repositoryListEmptyResponseMock
        let response = HTTPURLResponse()
        var result = (data, response)
        clientMock.appendResult(.success(result))
        
        var refreshResult = waitForCallback { handler in
            self.sut.fetchIgnoringCacheData(query, completion: handler)
        }
        XCTAssertNotNil(refreshResult?.success)
        
        let watcher = watchCallbackEvents { handler in
            self.sut.watch(query, handler: handler)
        }
        watcher.expectEventsCount(1)
        var value = watcher.lastValue
        
        var nodes: [RepositoryListQuery.Data.RepositoryOwner.Repository.Node?]? {
            value??.repositoryOwner?.repositories.nodes
        }
        
        XCTAssertTrue(nodes?.isEmpty == true)
        
        data = repositoryListResponseMock
        result = (data, response)
        clientMock.appendResult(.success(result))
        
        refreshResult = waitForCallback { handler in
            self.sut.fetchIgnoringCacheData(query, completion: handler)
        }
        XCTAssertNotNil(refreshResult?.success)
        
        watcher.expectEventsCount(2)
        value = watcher.lastValue
        XCTAssertTrue(nodes?.isEmpty == false)
    }
}
