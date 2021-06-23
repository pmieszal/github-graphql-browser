import Foundation

public enum Mock: String, Module {
    case networking
    
    public var name: String {
        rawValue.capitalizingFirstLetter() + "Mocks"
    }
    
    public var path: String {
        "Github-GraphQL-Browser/Foundation/\(rawValue.capitalizingFirstLetter())"
    }
}
