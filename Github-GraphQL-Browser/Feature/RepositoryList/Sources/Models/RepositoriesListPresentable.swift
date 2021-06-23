import Domain
import Foundation
import Core

struct RepositoriesListPresentable: Hashable {
    public let items: [RepositoryListItem]
    public let isLoading: Bool
    
    init(state: RepositoriesListState) {
        var listElements = state.list.map {
            RepositoryListItem.repository(RepositoryListCellPresentable(repository: $0))
        }
        
        if let error = state.error {
            listElements.append(.error(ListErrorCellPresentable(error: error)))
        }
        
        items = listElements
        isLoading = state.isLoading
    }
}
