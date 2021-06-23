import Core
import Domain
import UIKit

protocol RepositoryDetailsPresenterLogic {
    func presentName(_ name: String)
    func presentDetails(_ details: RepositoryDetailsPresentable)
}

final class RepositoryDetailsPresenter {
    weak var viewController: RepositoryDetailsViewControllerLogic?

    init(viewController: RepositoryDetailsViewControllerLogic?) {
        self.viewController = viewController
    }
}

extension RepositoryDetailsPresenter: RepositoryDetailsPresenterLogic {
    func presentName(_ name: String) {
        viewController?.displayName(name)
    }
    
    func presentDetails(_ details: RepositoryDetailsPresentable) {
        var snapshot = NSDiffableDataSourceSnapshot<RepositoryDetailsSection, RepositoryDetailsItem>()
        
        snapshot.appendSections([
            RepositoryDetailsSection(
                type: .openedIssues,
                totalCount: details.openedIssuesItems.totalCount),
        ])
        snapshot.appendItems(details.openedIssuesItems.items)
            
        snapshot.appendSections([
            RepositoryDetailsSection(
                type: .closedIssues,
                totalCount: details.closedIssuesItems.totalCount),
        ])
        snapshot.appendItems(details.closedIssuesItems.items)
            
        snapshot.appendSections([
            RepositoryDetailsSection(
                type: .openedPRs,
                totalCount: details.openedPRsItems.totalCount),
        ])
        snapshot.appendItems(details.openedPRsItems.items)
            
        snapshot.appendSections([
            RepositoryDetailsSection(type: .closedPRs, totalCount: details.closedPRsItems.totalCount),
        ])
        snapshot.appendItems(details.closedPRsItems.items)
        
        if let error = details.error {
            snapshot.appendItems([.error(ListErrorCellPresentable(error: error))])
        }
        
        viewController?.applySnapshot(snapshot)
    }
}
