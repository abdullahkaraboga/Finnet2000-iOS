import Foundation
import Alamofire

final class ListsRepository {

    func getFavouriteList(completion: @escaping (Result<FavouriteListResponse, AFError>) -> Void) {
        let url = "https://api.finnet2000.com/api/Favourites/ListFavouriteStocksByUserId"

        // interceptor otomatik token ekliyor
        NetworkManager.shared.authedSession
            .request(url, method: .get)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: FavouriteListResponse.self) { response in
                completion(response.result)
            }
    }

    func getUserPortfolios(completion: @escaping (Result<[UserPortfolio], AFError>) -> Void) {
        let url = "https://api.finnet2000.com/api/Portfolio/GetUserPortfolios"

        NetworkManager.shared.authedSession
            .request(url, method: .get)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: [UserPortfolio].self) { response in
                completion(response.result)
            }
    }

    func getPortfolioDetail(portfolioId: Int,
                            completion: @escaping (Result<APIPortfolioDetailResponse, AFError>) -> Void) {
        let url = "https://api.finnet2000.com/api/Portfolio/GetPortfolioDetail"

        NetworkManager.shared.authedSession
            .request(url, method: .get, parameters: ["portfolioId": portfolioId])
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let value = try decoder.decode(APIPortfolioDetailResponse.self, from: data)
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
