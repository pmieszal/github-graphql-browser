import Foundation

public struct RepositoryPullRequest: Hashable {
    public let id: String
    public let number: Int
    public let title: String
    public let url: String
    public let closed: Bool
    
    public init(id: String,
                number: Int,
                title: String,
                url: String,
                closed: Bool) {
        self.id = id
        self.number = number
        self.title = title
        self.url = url
        self.closed = closed
    }
}
