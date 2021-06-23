import UIKit

public protocol ChooseOwnerDependency {}
public protocol ChooseOwnerNavigation {
    func chooseOwnerDidSelectOwner(_ owner: String)
}

public final class ChooseOwnerBuilder {
    public init() {}
    public func buildChooseOwnerModule(dependency: ChooseOwnerDependency,
                                       navigation: ChooseOwnerNavigation) -> UIViewController {
        let viewController = ChooseOwnerViewController()
        viewController.navigation = navigation

        return viewController
    }
}
