import Foundation
import Alamofire

final class StockDetailRepository {

    func getSummary(
        stockCode: String,
        completion: @escaping (Result<StockDetailData, AFError>) -> Void
    ) {
        let url = "https://api.finnet2000.com/api/StockDetail/Summary"
        NetworkManager.shared.authedSession
            .request(url, method: .get, parameters: ["stockCode": stockCode])
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let root = try JSONDecoder().decode(StockDetailResponse.self, from: data)
                        completion(.success(root.data))
                    } catch {
                        // Wrap decoding error into AFError for the existing completion signature
                        let afError = AFError.responseSerializationFailed(reason: .decodingFailed(error: error))
                        completion(.failure(afError))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
