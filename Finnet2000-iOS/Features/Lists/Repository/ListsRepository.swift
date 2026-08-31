import Foundation
import Alamofire

struct AddPositionRequest: Codable, Sendable {
    let portfolioId: Int
    let code: String
    let buyQuantity: Double
    let buyDate: String
    let buyPrice: Double
    let commission: Double
}

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
    
    func getPortfoliosInfo(completion: @escaping (Result<[PortfolioInfo], AFError>) -> Void) {
        let url = "https://api.finnet2000.com/api/Portfolio/PortfoliosInfo"

        NetworkManager.shared.authedSession
            .request(url, method: .get)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: [PortfolioInfo].self) { response in
                completion(response.result)
            }
    }
    
    func getPortfolioStockPrice(code: String, date: String, completion: @escaping (Result<Double, Error>) -> Void) {
        let url = "https://api.finnet2000.com/api/Portfolio/PortfolioStockPrice"
        
        let parameters: [String: Any] = [
            "code": code,
            "date": date
        ]
        
        NetworkManager.shared.authedSession
            .request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseString { response in
                switch response.result {
                case .success(let str):
                    // Direct number string?
                    let cleanStr = str.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: ",", with: ".")
                    if let val = Double(cleanStr) {
                        completion(.success(val))
                        return
                    }
                    // JSON dictionary fallback
                    if let data = str.data(using: .utf8),
                       let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let val = (dict["price"] ?? dict["value"] ?? dict.values.first) as? Double {
                            completion(.success(val))
                            return
                        }
                    }
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Yanıt: \(str)"])))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    func addPosition(request: AddPositionRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "https://api.finnet2000.com/api/Portfolio/AddPosition"
        
        let parameters: [String: Any] = [
            "portfolioId": request.portfolioId,
            "code": request.code,
            "buyQuantity": request.buyQuantity,
            "buyDate": request.buyDate,
            "buyPrice": request.buyPrice,
            "commission": request.commission
        ]
        
        NetworkManager.shared.authedSession
            .request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .response { response in
                switch response.result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
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
