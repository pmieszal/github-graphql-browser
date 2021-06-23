import RepositoryList
import RepositoryListMocks
import UIKit
import Core

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let dependency: RepositoryListDependenciesMock
        
        if isRunningUITests {
            dependency = uiTestsMock()
        } else {
            dependency = RepositoryListDependenciesMock()
        }
        
        let viewController = RepositoryListBuilder().buildRepositoryListModule(
            owner: "apollographql",
            dependencies: dependency,
            navigation: self)
        let navigation = UINavigationController(rootViewController: viewController)
        navigation.navigationBar.prefersLargeTitles = true
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        self.window = window
        
        return true
    }
}

extension AppDelegate: RepositoryListNavigation {
    func repositoryListDidSelectRepository(owner: String, name: String) {}
}
