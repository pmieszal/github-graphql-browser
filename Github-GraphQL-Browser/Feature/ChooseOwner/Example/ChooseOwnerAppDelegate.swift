import ChooseOwner
import ChooseOwnerMocks
import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = ChooseOwnerBuilder().buildChooseOwnerModule(
            dependency: self,
            navigation: self)
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

extension AppDelegate: ChooseOwnerDependency {}
extension AppDelegate: ChooseOwnerNavigation {
    func chooseOwnerDidSelectOwner(_ owner: String) {}
}
