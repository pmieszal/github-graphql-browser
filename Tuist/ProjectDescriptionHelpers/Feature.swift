import Foundation

public enum Feature: String, CaseIterable, Module {
    case chooseOwner
    case repositoryList
    case repositoryDetails
    
    public var name: String { rawValue.capitalizingFirstLetter() }
    
    public var path: String {
        "Github-GraphQL-Browser/Feature/\(name)"
    }
}
