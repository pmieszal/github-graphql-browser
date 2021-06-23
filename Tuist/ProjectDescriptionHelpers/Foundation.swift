import Foundation

public enum Foundation: String, CaseIterable, Module {
    case core
    case domain
    case networking
    case testsUtils
    case appSecrets
    
    public var name: String { rawValue.capitalizingFirstLetter() }
    
    public var path: String {
        "Github-GraphQL-Browser/Foundation/\(name)"
    }
    
    public static var allCasesForApp: [Foundation] {
        var cases = allCases
        cases.removeAll(where: { $0 == .testsUtils })
        
        return cases
    }
}
