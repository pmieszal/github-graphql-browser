import UIKit

class Router {
    private weak var viewController: UIViewController?
    
    func setViewController(_ viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func push(_ viewController: UIViewController, animated: Bool = true) {
        self.viewController?.navigationController?.pushViewController(viewController, animated: animated)
    }
}
