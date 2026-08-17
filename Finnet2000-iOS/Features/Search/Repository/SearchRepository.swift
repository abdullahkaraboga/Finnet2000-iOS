import Foundation
import Alamofire

// MARK: - Protocol

protocol SearchRepositoryProtocol {
    func fetchFilteredStocks(request: FilterRequest, defaultRequest: Bool) async throws -> FilteredStocksResponse
}

// MARK: - Implementation

final class SearchRepository: SearchRepositoryProtocol {

    private let baseURL = "https://api.finnet2000.com/api/Filter/GetFilteredStocks"

    func fetchFilteredStocks(request: FilterRequest, defaultRequest: Bool = false) async throws -> FilteredStocksResponse {
        guard var components = URLComponents(string: baseURL) else {
            throw URLError(.badURL)
        }
        components.queryItems = [URLQueryItem(name: "defaultRequest", value: defaultRequest ? "true" : "false")]
        guard let url = components.url else { throw URLError(.badURL) }

        // Manually encode body to avoid Alamofire's generic Parameters: Encodable & Sendable
        // constraint, which conflicts with Swift 6 actor-isolated conformance checking.
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try JSONEncoder().encode(request)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let data = try await NetworkManager.shared.authedSession
            .request(urlRequest)
            .validate(statusCode: 200..<300)
            .serializingData()
            .value

        return try JSONDecoder().decode(FilteredStocksResponse.self, from: data)
    }
}
