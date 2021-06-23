import TestsUtils
import XCTest
@testable import Domain
@testable import DomainMocks

class PagingTests: XCTestCase {
    var serviceMock: RepositoryServiceMock!
    var sut: Paging<[Repository]>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        serviceMock = RepositoryServiceMock()
        sut = Paging(pageItemsCount: 20)
    }
    
    func testRequestNextPage() {
        serviceMock.appendRefreshResult(repositoryFetchEvent())
        
        let pagingWatcher = watchCallbackEvents { handler in
            self.sut.start(
                eventsCallback: handler,
                watcherFactory: { pageQueryInfo, callback in
                    let query = RepositoriesQuery(
                        owner: "owner",
                        count: pageQueryInfo.pageItemsCount,
                        after: pageQueryInfo.lastPageInfo?.endCursor)
                    
                    return PageWatcher(
                        id: query,
                        dataChangeCallback: callback,
                        watchDataFactory: {
                            self.serviceMock.watchChangesForQuery(query, handler: $0)
                        },
                        fetchDataFactory: {
                            self.serviceMock.refreshQuery(query, completion: $0)
                        })
                })
        }
        
        sut.requestNextPage()
        
        pagingWatcher.expectEventsCount(2)
        let values = pagingWatcher.values
        
        XCTAssertEqual(values[0].data?.count, 0)
        XCTAssertEqual(values[0].isLoading, true)
        
        XCTAssertEqual(values[1].data?.count, 1)
        XCTAssertEqual(values[1].isLoading, false)
    }
    
    func testRequestTwoPages() {
        serviceMock.appendRefreshResult(repositoryFetchEvent(pageInfo: PageInfo(hasNextPage: true, endCursor: "test")))
        serviceMock.appendRefreshResult(repositoryFetchEvent(pageInfo: PageInfo(hasNextPage: false)))
        
        let pagingWatcher = watchCallbackEvents { handler in
            self.sut.start(
                eventsCallback: handler,
                watcherFactory: { pageQueryInfo, callback in
                    let query = RepositoriesQuery(
                        owner: "owner",
                        count: pageQueryInfo.pageItemsCount,
                        after: pageQueryInfo.lastPageInfo?.endCursor)
                    
                    return PageWatcher(
                        id: query,
                        dataChangeCallback: callback,
                        watchDataFactory: {
                            self.serviceMock.watchChangesForQuery(query, handler: $0)
                        },
                        fetchDataFactory: {
                            self.serviceMock.refreshQuery(query, completion: $0)
                        })
                })
        }
        
        // First page with page info
        sut.requestNextPage()
        pagingWatcher.expectEventsCount(2)
        var value = pagingWatcher.lastValue
        XCTAssertEqual(value?.isLoading, false)
        XCTAssertEqual(value?.data?.count, 1)
        
        // Second page with hasNextPage == false
        sut.requestNextPage()
        pagingWatcher.expectEventsCount(4)
        value = pagingWatcher.lastValue
        XCTAssertEqual(value?.data?.count, 2)
        XCTAssertEqual(value?.isLoading, false)
        
        // Third page shouldn't be called at all
        sut.requestNextPage()
        
        pagingWatcher.expectToNotBeInvoked()
        XCTAssertEqual(pagingWatcher.lastValue?.data?.count, 2)
        XCTAssertEqual(pagingWatcher.lastValue?.isLoading, false)
    }
    
    func testRequestOnlyOnePage() {
        serviceMock.appendRefreshResult(repositoryFetchEvent(pageInfo: PageInfo(hasNextPage: false)))
        
        let pagingWatcher = watchCallbackEvents { handler in
            self.sut.start(
                eventsCallback: handler,
                watcherFactory: { pageQueryInfo, callback in
                    let query = RepositoriesQuery(
                        owner: "owner",
                        count: pageQueryInfo.pageItemsCount,
                        after: pageQueryInfo.lastPageInfo?.endCursor)
                    
                    return PageWatcher(
                        id: query,
                        dataChangeCallback: callback,
                        watchDataFactory: {
                            self.serviceMock.watchChangesForQuery(query, handler: $0)
                        },
                        fetchDataFactory: {
                            self.serviceMock.refreshQuery(query, completion: $0)
                        })
                })
        }
        
        // First page with hasNextPage == false
        sut.requestNextPage()
        pagingWatcher.expectEventsCount(2)
        let value = pagingWatcher.lastValue
        XCTAssertEqual(value?.data?.count, 1)
        
        // Second page shouldn't be called at all
        sut.requestNextPage()
        pagingWatcher.expectToNotBeInvoked()
        XCTAssertEqual(pagingWatcher.lastValue?.data?.count, 1)
    }
    
    func testRequestPageWithError() {
        serviceMock.appendRefreshResult(.failure(DummyLocalizedError.error))
        serviceMock.appendRefreshResult(repositoryFetchEvent(pageInfo: PageInfo(hasNextPage: false)))
        
        let pagingWatcher = watchCallbackEvents { handler in
            self.sut.start(
                eventsCallback: handler,
                watcherFactory: { pageQueryInfo, callback in
                    let query = RepositoriesQuery(
                        owner: "owner",
                        count: pageQueryInfo.pageItemsCount,
                        after: pageQueryInfo.lastPageInfo?.endCursor)
                    
                    return PageWatcher(
                        id: query,
                        dataChangeCallback: callback,
                        watchDataFactory: {
                            self.serviceMock.watchChangesForQuery(query, handler: $0)
                        },
                        fetchDataFactory: {
                            self.serviceMock.refreshQuery(query, completion: $0)
                        })
                })
        }
        
        // First page with error
        sut.requestNextPage()
        pagingWatcher.expectEventsCount(2)
        let value = pagingWatcher.lastValue
        XCTAssertEqual(value?.data?.count, 0)
        XCTAssertNotNil(value?.errors)
        
        // Third page shouldn't be called at all
        sut.requestNextPage()
        pagingWatcher.expectToNotBeInvoked()
        XCTAssertEqual(pagingWatcher.lastValue?.data?.count, 0)
    }
    
    func testRefresh() {
        serviceMock.appendRefreshResult(repositoryFetchEvent())
        serviceMock.appendRefreshResult(repositoryFetchEvent())
        
        let pagingWatcher = watchCallbackEvents { handler in
            self.sut.start(
                eventsCallback: handler,
                watcherFactory: { pageQueryInfo, callback in
                    let query = RepositoriesQuery(
                        owner: "owner",
                        count: pageQueryInfo.pageItemsCount,
                        after: pageQueryInfo.lastPageInfo?.endCursor)
                    
                    return PageWatcher(
                        id: query,
                        dataChangeCallback: callback,
                        watchDataFactory: {
                            self.serviceMock.watchChangesForQuery(query, handler: $0)
                        },
                        fetchDataFactory: {
                            self.serviceMock.refreshQuery(query, completion: $0)
                        })
                })
        }
        
        sut.requestNextPage()
        pagingWatcher.expectEventsCount(2)
        var value = pagingWatcher.lastValue
        XCTAssertEqual(value?.data?.count, 1)
        
        sut.refresh()
        pagingWatcher.expectEventsCount(3)
        value = pagingWatcher.lastValue
        XCTAssertEqual(value?.data?.count, 1)
    }
    
    func repositoryFetchEvent(pageInfo: PageInfo? = nil) -> QueryResult<QueryPageableResultEnvelope<[Repository]>> {
        let pageableEnvelope = PageableEnvelope<[Repository]>(data: [], pageInfo: pageInfo)
        let queryEnvelope = QueryPageableResultEnvelope(pageableEnvelope: pageableEnvelope, queryErrors: nil)
        
        return .success(queryEnvelope)
    }
}
