import RepositoryDetails
import RepositoryList
import UIKit

protocol RepositoryListRouterDependency {
    func buildRepositoryDetails(owner: String, name: String) -> UIViewController
}

final class RepositoryListRouter: Router {
    private let dependency: RepositoryListRouterDependency

    init(dependency: RepositoryListRouterDependency) {
        self.dependency = dependency
    }
}

extension RepositoryListRouter: RepositoryListNavigation {
    func repositoryListDidSelectRepository(owner: String, name: String) {
        let details = dependency.buildRepositoryDetails(owner: owner, name: name)
        push(details)
    }
}
