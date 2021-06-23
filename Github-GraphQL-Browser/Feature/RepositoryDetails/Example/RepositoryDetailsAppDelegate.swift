import RepositoryDetails
import RepositoryDetailsMocks
import UIKit
import Core

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let dependency: RepositoryDetailsDependencyMock
        
        if isRunningUITests {
            dependency = uiTestsMock()
        } else {
            dependency = RepositoryDetailsDependencyMock()
        }
        
        let viewController = RepositoryDetailsBuilder().buildRepositoryDetailsModule(
            dependency: dependency,
            owner: "apollographql",
            name: "apollo-ios")
        let navigation = UINavigationController(rootViewController: viewController)
        navigation.navigationBar.prefersLargeTitles = true
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        self.window = window
        
        return true
    }
}
