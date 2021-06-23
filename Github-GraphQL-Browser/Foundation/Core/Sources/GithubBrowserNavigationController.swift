import UIKit

public class GithubBrowserNavigationController: UINavigationController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.prefersLargeTitles = true
        navigationBar.tintColor = .label
        navigationBar.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 32, weight: .black),
        ]
        navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 24, weight: .black),
        ]
    }
}
