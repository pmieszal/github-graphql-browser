import Apollo
import Foundation

public class AuthorizationInterceptor: ApolloInterceptor {
    let token: String
    
    public init(token: String) {
        self.token = token
    }
    
    public func interceptAsync<Operation: GraphQLOperation>(chain: RequestChain,
                                                            request: HTTPRequest<Operation>,
                                                            response: HTTPResponse<Operation>?,
                                                            completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>)
                                                                -> ()) {
        request.addHeader(name: "Authorization", value: "Bearer \(token)")
        chain.proceedAsync(
            request: request,
            response: response,
            completion: completion)
    }
}
