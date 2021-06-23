import Apollo
import Foundation

public protocol GraphQLErrorType: LocalizedError, CustomStringConvertible {
    var message: String? { get }
}

extension GraphQLError: GraphQLErrorType {}

public struct GraphQLNetworkingErrorEnvelope {
    public var graphQlErrors: [GraphQLErrorType]?, networkingError: NetworkingError?
}
