import Core
import UIKit

protocol AppRouterDependency {
    func buildChooseOwner() -> UIViewController
}

final class AppRouter {
    private let window: UIWindow
    private let dependency: AppRouterDependency
    
    init(window: UIWindow,
         dependency: AppRouterDependency) {
        self.window = window
        self.dependency = dependency
    }
    
    func start() {
        let navigation = GithubBrowserNavigationController(rootViewController: dependency.buildChooseOwner())
        window.rootViewController = navigation
        window.makeKeyAndVisible()
    }
}
