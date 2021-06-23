import ChooseOwner
import RepositoryList
import UIKit

protocol ChooseOwnerRouterDependency {
    func buildRepositoryList(owner: String) -> UIViewController
}

final class ChooseOwnerRouter: Router {
    private let dependency: ChooseOwnerRouterDependency

    init(dependency: ChooseOwnerRouterDependency) {
        self.dependency = dependency
    }
}

extension ChooseOwnerRouter: ChooseOwnerNavigation {
    func chooseOwnerDidSelectOwner(_ owner: String) {
        let list = dependency.buildRepositoryList(owner: owner)
        push(list)
    }
}
