import Apollo
import Domain
import Foundation

/**
 Protocol defining GraphQL networking client.
 
 SHORTCUT: Ideally this protocol should not import any types of Apollo - they should be hidden behind protocols.
 I'm leaving it tightly coupled to Apollo because of lack of time for this implementation.
 */
public protocol GraphQLClientProtocol {
    @discardableResult
    func watch<TQuery: GraphQLQuery>(
        _ query: TQuery,
        handler: ((TQuery.Data?) -> ())?
    ) -> CancellableObject
    
    @discardableResult
    func fetchIgnoringCacheData<TQuery: GraphQLQuery>(
        _ query: TQuery,
        completion: ((Result<GraphQLQueryResponse<TQuery>, NetworkingError>) -> ())?
    ) -> CancellableObject
    
    @discardableResult
    func fetch<TQuery: GraphQLQuery>(
        _ query: TQuery,
        completion: ((Result<GraphQLQueryResponse<TQuery>, NetworkingError>) -> ())?
    ) -> CancellableObject
}
