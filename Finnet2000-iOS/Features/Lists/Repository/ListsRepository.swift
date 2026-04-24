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
}

