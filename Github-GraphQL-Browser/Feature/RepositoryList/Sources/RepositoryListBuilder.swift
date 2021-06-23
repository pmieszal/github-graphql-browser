import Domain
import UIKit

public protocol RepositoryListDependency {
    var repositoriesWatchUseCase: RepositoriesWatchUseCase { get }
}

public protocol RepositoryListNavigation {
    func repositoryListDidSelectRepository(owner: String, name: String)
}

public final class RepositoryListBuilder {
    public init() {}
    public func buildRepositoryListModule(owner: String,
                                          dependencies: RepositoryListDependency,
                                          navigation: RepositoryListNavigation) -> UIViewController {
        let viewController = RepositoryListViewController()
        let presenter = RepositoryListPresenter(viewController: viewController)
        let interactor = RepositoryListInteractor(
            presenter: presenter,
            owner: owner,
            dependency: dependencies)
        viewController.interactor = interactor
        viewController.navigation = navigation
        
        return viewController
    }
}
