import Foundation
import Alamofire

/// API çağrılarından sorumlu katman.
/// ViewModel sadece bu repository ile haberleşir.
final class ComparisonRepository {

    // MARK: - Ortak Yardımcı (hata ayıklama)
    private func debugPrintResponse(_ data: Data?, label: String) {
        #if DEBUG
        if let data, let text = String(data: data, encoding: .utf8) {
            debugPrint("📦 \(label) raw JSON:\n\(text)")
        } else {
            debugPrint("📦 \(label): No data or non-UTF8 payload.")
        }
        #endif
    }

    // MARK: - 1️⃣ Hisse Listesi Getir
    func fetchStockList() async throws -> [StockListItem] {
        let url = "https://api.finnet2000.com/api/Comparison/StockList"

        let response = await NetworkManager.shared.authedSession
            .request(url, method: .get)
            .validate(statusCode: 200..<300)
            .serializingDecodable([StockListItem].self)
            .response

        debugPrintResponse(response.data, label: "StockList")

        switch response.result {
        case .success(let items):
            return items
        case .failure(let error):
            throw mapError(error)
        }
    }

    // MARK: - 2️⃣ Karşılaştırma Detayları Getir
    func fetchCompareStocks(first: String, second: String) async throws -> CompareStocksResponse {
        let url = "https://api.finnet2000.com/api/Comparison/CompareStocks"
        let parameters: Parameters = [
            "firstCode": first,
            "lastCode": second
        ]

        let response = await NetworkManager.shared.authedSession
            .request(url, method: .get, parameters: parameters)
            .validate(statusCode: 200..<300)
            .serializingDecodable(CompareStocksResponse.self)
            .response

        debugPrintResponse(response.data, label: "CompareStocks")

        switch response.result {
        case .success(let compareData):
            guard !compareData.isEmpty else { throw CompareError.emptyResponse }
            return compareData
        case .failure(let error):
            throw mapError(error)
        }
    }

    // MARK: - Hata Eşleştirme
    private func mapError(_ error: AFError) -> CompareError {
        // 401 → interceptor refresh dener; başarısız olursa sessionDidExpire bildirimi gönderilir.
        // Burada kullanıcıya göstermek yerine sessizce .unauthorized döndürüyoruz.
        if let statusCode = error.responseCode, statusCode == 401 {
            return .unauthorized
        }
        if case .responseValidationFailed(let reason) = error,
           case .unacceptableStatusCode(let code) = reason, code == 401 {
            return .unauthorized
        }
        if let underlying = error.underlyingError as? DecodingError {
            return .decodingError(underlying.localizedDescription)
        }
        return .networkError(error.localizedDescription)
    }
}
