import Foundation
import Hummingbird

/// Router for GraphQL requests.
public class GraphQLRouter {

    private let verbose: Bool

    private var mockGraphQLResponses: [GraphQLEndpoint] = []

    init(verbose: Bool) {
        self.verbose = verbose
    }

    func add(_ endpoint: GraphQLEndpoint) {
        mockGraphQLResponses.append(endpoint)
    }

    /// Executes for an incoming request.
    ///
    /// This loops through the stored GraphQL endpoints to find a match and execute it for a response.
    public func execute(request: HBRequest) async throws -> HBResponse {
        if verbose { print("💀 Intercepting GraphQL request") }
        if let endpoint = try graphQLEndpoint(for: request) {
            return try await endpoint.response.hbResponse(for: request, context: request.application)
        }
        throw VoodooError.noGraphQLEndpoint
    }

    private func graphQLEndpoint(for httpRequest: HTTPRequest) throws -> GraphQLEndpoint? {

        let graphQLRequest = try GraphQLRequest(request: httpRequest)

        return mockGraphQLResponses.first { endpoint in

            // Ensure the methods match.
            guard httpRequest.method == endpoint.method else {
                return false
            }

            // Then check using the endpoint selector to see if it matches the incoming request.
            switch endpoint.selector {

            case .operations(let operations):
                return operations.allSatisfy { graphQLRequest.operations.keys.contains($0) }

            case .query(let graphQLSelector):
                return graphQLSelector.matches(graphQLRequest)
            }
        }
    }
}
