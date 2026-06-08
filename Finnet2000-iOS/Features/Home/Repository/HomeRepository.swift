import Foundation
import Alamofire

protocol HomeRepositoryProtocol {
    func fetchHomePage(currency: String) async throws -> HomePageResponse
}

final class HomeRepository: HomeRepositoryProtocol {

    private let baseURL = "https://api.finnet2000.com/api/HomePage/HomePage"

    // MARK: - Async/Await API
    // Pure async/await version. No unnecessary try/await warnings because the awaited property is async/throws.
    func fetchHomePage(currency: String = "TRY") async throws -> HomePageResponse {
        let parameters: Parameters = ["currency": currency]

        let data = try await NetworkManager.shared.authedSession
            .request(
                baseURL,
                method: .get,
                parameters: parameters,
                encoding: URLEncoding.queryString
            )
            .validate(statusCode: 200..<300)
            .serializingData()
            .value

        let decoder = JSONDecoder()
        return try decoder.decode(HomePageResponse.self, from: data)
    }

    // MARK: - Completion-based API
    // Non-async version that bridges to the async API on a background priority, then hops to MainActor for the completion.
    func fetchHomePage(
        currency: String = "TRY",
        queue: DispatchQueue = .global(qos: .userInitiated),
        completion: @escaping (Result<HomePageResponse, AFError>) -> Void
    ) {
        // Execute the async call from a detached Task to keep this API non-blocking.
        Task(priority: .userInitiated) {
            do {
                let response = try await fetchHomePage(currency: currency)
                // Ensure completion is delivered on the provided queue, then MainActor if needed by UI.
                queue.async {
                    Task { @MainActor in
                        completion(.success(response))
                    }
                }
            } catch {
                let afError: AFError
                if let e = error as? AFError {
                    afError = e
                } else {
                    afError = AFError.createURLRequestFailed(error: error)
                }
                queue.async {
                    Task { @MainActor in
                        completion(.failure(afError))
                    }
                }
            }
        }
    }
}
