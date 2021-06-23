import Foundation
import Nimble
import Quick
import TestsUtils
@testable import Domain
@testable import DomainMocks

class RepositoryDetailsFetchUseCaseSpec: QuickSpec {
    override func spec() {
        var serviceMock: RepositoryDetailsServiceMock!
        var sut: RepositoryDetailsFetchUseCase!
        
        beforeEach {
            serviceMock = RepositoryDetailsServiceMock()
            sut = RepositoryDetailsFetchUseCase(service: serviceMock, itemsCount: 10)
        }
        
        describe("fetch") {
            context("given valid response") {
                beforeEach {
                    serviceMock.appendFetchResult(repositoryFetchSuccess(details: .empty()))
                }
                    
                it("succeeds") {
                    let fetchWatcher = watchCallbackEvents {
                        sut.fetchDetails(owner: "", name: "", handler: $0)
                    }
                    
                    fetchWatcher.expectEventsCount(1)
                    let value = fetchWatcher.values.first
                    expect(value?.details).toNot(beNil())
                    expect(value?.error).to(beNil())
                }
            }
            
            context("given query error") {
                beforeEach {
                    serviceMock.appendFetchResult(repositoryFetchSuccess(queryErrors: [DummyLocalizedError.error]))
                }
                    
                it("fails with error") {
                    let fetchWatcher = watchCallbackEvents {
                        sut.fetchDetails(owner: "", name: "", handler: $0)
                    }
                    
                    fetchWatcher.expectEventsCount(1)
                    let value = fetchWatcher.values.first
                    expect(value?.details).to(beNil())
                    expect(value?.error).to(matchError(DummyLocalizedError.error))
                }
            }
            
            context("given network error") {
                beforeEach {
                    serviceMock.appendFetchResult(.failure(DummyLocalizedError.error))
                }
                
                it("fails with error") {
                    let fetchWatcher = watchCallbackEvents {
                        sut.fetchDetails(owner: "", name: "", handler: $0)
                    }
                    
                    fetchWatcher.expectEventsCount(1)
                    let value = fetchWatcher.values.first
                    expect(value?.details).to(beNil())
                    expect(value?.error).to(matchError(DummyLocalizedError.error))
                }
            }
        }
    }
}

private func repositoryFetchSuccess(details: RepositoryDetails? = nil,
                                    queryErrors: [LocalizedError]? = nil) -> QueryResult<QueryResultEnvelope<RepositoryDetails>> {
    let envelope = QueryResultEnvelope<RepositoryDetails>(data: details, queryErrors: queryErrors)
    return .success(envelope)
}

private extension RepositoryDetails {
    static func empty() -> RepositoryDetails {
        RepositoryDetails(
            id: nil,
            name: nil,
            openedIssues: .init(items: [], totalCount: 0),
            closedIssues: .init(items: [], totalCount: 0),
            openedPRs: .init(items: [], totalCount: 0),
            closedPRs: .init(items: [], totalCount: 0))
    }
}
