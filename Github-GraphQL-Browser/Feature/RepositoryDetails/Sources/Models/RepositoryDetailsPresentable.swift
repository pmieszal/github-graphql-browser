import Domain
import Foundation

struct RepositoryDetailsPresentable {
    let openedIssuesItems: RepositoryDetailsPresentableItemWrapper
    let closedIssuesItems: RepositoryDetailsPresentableItemWrapper
    let openedPRsItems: RepositoryDetailsPresentableItemWrapper
    let closedPRsItems: RepositoryDetailsPresentableItemWrapper
    let error: LocalizedError?
    
    init(state: RepositoryDetailsState) {
        openedIssuesItems = Self.itemWrapperFrom(state.details?.openedIssues)
        closedIssuesItems = Self.itemWrapperFrom(state.details?.closedIssues)
        openedPRsItems = Self.itemWrapperFrom(state.details?.openedPRs)
        closedPRsItems = Self.itemWrapperFrom(state.details?.closedPRs)
        
        error = state.error
    }
    
    static func itemWrapperFrom(
        _ wrapper: RepositoryDetailsItemWrapper<RepositoryIssue>?
    ) -> RepositoryDetailsPresentableItemWrapper {
        wrapper.map { wrapper in
            let items = wrapper.items.map {
                RepositoryDetailsItem.issue(RepositoryDetailsListCellPresentable(issue: $0))
            }
            
            return RepositoryDetailsPresentableItemWrapper(items: items, totalCount: wrapper.totalCount)
        } ?? .empty()
    }
    
    static func itemWrapperFrom(
        _ wrapper: RepositoryDetailsItemWrapper<RepositoryPullRequest>?
    ) -> RepositoryDetailsPresentableItemWrapper {
        wrapper.map { wrapper in
            let items = wrapper.items.map {
                RepositoryDetailsItem.issue(RepositoryDetailsListCellPresentable(pullRequest: $0))
            }
            
            return RepositoryDetailsPresentableItemWrapper(items: items, totalCount: wrapper.totalCount)
        } ?? .empty()
    }
}

struct RepositoryDetailsPresentableItemWrapper {
    let items: [RepositoryDetailsItem]
    let totalCount: Int
}

extension RepositoryDetailsPresentableItemWrapper {
    static func empty() -> RepositoryDetailsPresentableItemWrapper {
        RepositoryDetailsPresentableItemWrapper(items: [], totalCount: 0)
    }
}
