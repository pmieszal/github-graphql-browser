import Domain
import UIKit

protocol RepositoryListPresenterLogic {
    func presentOwner(_ owner: String)
    func presentList(_ presentable: RepositoriesListPresentable)
}

final class RepositoryListPresenter {
    var listItems = [RepositoryListItem]()
    weak var viewController: RepositoryListViewControllerLogic?

    init(viewController: RepositoryListViewControllerLogic?) {
        self.viewController = viewController
    }
}

extension RepositoryListPresenter: RepositoryListPresenterLogic {
    func presentOwner(_ owner: String) {
        viewController?.displayOwner(owner)
    }
    
    func presentList(_ presentable: RepositoriesListPresentable) {
        viewController?.displayLoading(presentable.isLoading)
        
        let items = presentable.items
        // Simple "distinctUntilChanged" for list element, preventing unnecessary snapshots
        guard items != listItems else {
            return
        }
        listItems = items
        
        var snapshot = NSDiffableDataSourceSnapshot<String, RepositoryListItem>()
        
        snapshot.appendSections([""])
        snapshot.appendItems(items)
        
        viewController?.applySnapshot(snapshot)
    }
}
