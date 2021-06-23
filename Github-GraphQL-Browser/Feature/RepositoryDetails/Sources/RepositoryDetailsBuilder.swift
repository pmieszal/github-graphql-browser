import Domain
import UIKit

public protocol RepositoryDetailsDependency {
    var repositoryDetailsFetchUseCase: RepositoryDetailsFetchUseCase { get }
}

public final class RepositoryDetailsBuilder {
    public init() {}
    public func buildRepositoryDetailsModule(dependency: RepositoryDetailsDependency,
                                             owner: String,
                                             name: String) -> UIViewController {
        let viewController = RepositoryDetailsViewController()
        let presenter = RepositoryDetailsPresenter(viewController: viewController)
        let interactor = RepositoryDetailsInteractor(
            presenter: presenter,
            dependency: dependency,
            owner: owner,
            name: name)
        viewController.interactor = interactor
        return viewController
    }
}
