import Foundation
import Alamofire

final class StockDetailService {
    static let shared = StockDetailService()
    private init() {}
    
    private let baseURL = "https://api.finnet2000.com/api/StockDetail"
    
    func fetchSummary(
        stockCode: String,
        completion: @escaping (Result<StockDetailData, AFError>) -> Void
    ) {
        let url = "\(baseURL)/Summary"
        NetworkManager.shared.authedSession
            .request(url, method: .get, parameters: ["stockCode": stockCode])
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let root = try JSONDecoder().decode(StockDetailResponse.self, from: data)
                        if let detailData = root.data {
                            completion(.success(detailData))
                        } else {
                            let error = NSError(domain: "StockDetailService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Data field is null"])
                            completion(.failure(.responseSerializationFailed(reason: .customSerializationFailed(error: error))))
                        }
                    } catch {
                        completion(.failure(.responseSerializationFailed(reason: .decodingFailed(error: error))))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    func fetchRatios(
        stockCode: String,
        completion: @escaping (Result<StockDetailRatiosData, AFError>) -> Void
    ) {
        let url = "\(baseURL)/Ratios"
        NetworkManager.shared.authedSession
            .request(url, method: .get, parameters: ["stockCode": stockCode])
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let root = try JSONDecoder().decode(StockDetailRatiosResponse.self, from: data)
                        if let detailData = root.data {
                            completion(.success(detailData))
                        } else {
                            let error = NSError(domain: "StockDetailService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Data field is null"])
                            completion(.failure(.responseSerializationFailed(reason: .customSerializationFailed(error: error))))
                        }
                    } catch {
                        completion(.failure(.responseSerializationFailed(reason: .decodingFailed(error: error))))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    func fetchSectoralAnalysis(
        stockCode: String,
        completion: @escaping (Result<StockDetailSectoralAnalysisData, AFError>) -> Void
    ) {
        let url = "\(baseURL)/SectoralAnalysis"
        NetworkManager.shared.authedSession
            .request(url, method: .get, parameters: ["stockCode": stockCode])
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let root = try JSONDecoder().decode(StockDetailSectoralAnalysisResponse.self, from: data)
                        if let detailData = root.data {
                            completion(.success(detailData))
                        } else {
                            let error = NSError(domain: "StockDetailService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Data field is null"])
                            completion(.failure(.responseSerializationFailed(reason: .customSerializationFailed(error: error))))
                        }
                    } catch {
                        completion(.failure(.responseSerializationFailed(reason: .decodingFailed(error: error))))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    func toggleFavouriteStock(
        stockCode: String,
        completion: @escaping (Result<Void, AFError>) -> Void
    ) {
        let url = "https://api.finnet2000.com/api/Favourites/AddOrDeleteFavouriteStock"
        NetworkManager.shared.authedSession
            .request(url, method: .get, parameters: ["stockCode": stockCode])
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
}
