import Apollo

public struct GraphQLQueryResponse<TQuery: GraphQLQuery> {
    let data: TQuery.Data?
    let graphQlErrors: [GraphQLError]?
}
