import Foundation

public protocol Module {
    var name: String { get }
    var path: String { get }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}
