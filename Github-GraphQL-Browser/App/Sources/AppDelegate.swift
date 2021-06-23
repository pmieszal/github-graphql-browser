import UIKit
import Core

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var dependencies: Dependencies = {
        if isRunningUITests {
            return UITestsMockDependencies()
        } else {
            return Dependencies()
        }
    }()

    var window: UIWindow?
    var appRouter: AppRouter?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        appRouter = AppRouter(window: window, dependency: dependencies)
        appRouter?.start()
        
        return true
    }
}
