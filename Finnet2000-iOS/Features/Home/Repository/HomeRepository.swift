import Alamofire
import Foundation

protocol HomeRepositoryProtocol {
  func fetchHomePage(currency: String) async throws -> HomePageResponse
  func getRoboSepetDetail(portfolioId: Int, completion: @escaping (Result<RoboSepetDetailResponse, Alamofire.AFError>) -> Void)
}

final class HomeRepository: HomeRepositoryProtocol {

  private let baseURL = AppConfig.apiBaseURL + AppConfig.Endpoints.homePagePath

  // MARK: - Async/Await API
  // Pure async/await version. No unnecessary try/await warnings because the awaited property is async/throws.
  func fetchHomePage(currency: String = "TRY") async throws -> HomePageResponse {
    let parameters: Parameters = ["currency": currency]

    let data = try await NetworkManager.shared.authSession
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

  func getRoboSepetDetail(portfolioId: Int, completion: @escaping (Result<RoboSepetDetailResponse, AFError>) -> Void) {
    let url = "https://api.finnet2000.com/api/Robofund/GetRobofundDetail"
    
    NetworkManager.shared.authedSession
        .request(url, method: .get, parameters: ["portfolioId": portfolioId, "currency": "TRY"])
        .validate(statusCode: 200..<300)
        .responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let value = try decoder.decode(RoboSepetDetailResponse.self, from: data)
                    completion(.success(value))
                } catch {
                    if let afError = error as? AFError {
                        completion(.failure(afError))
                    } else {
                        completion(.failure(AFError.responseSerializationFailed(reason: .decodingFailed(error: error))))
                    }
                }
            case .failure(let afError):
                completion(.failure(afError))
            }
        }
  }
}
