import Foundation
import Alamofire

protocol TeknikTarayiciRepositoryProtocol {
    func fetchIndicatorSignals(request: TeknikScannerRequest) async throws -> [TeknikScannerResponseItem]
    func fetchSignalStocksChoices() async throws -> TeknikScannerChoicesResponse
}

final class TeknikTarayiciRepository: TeknikTarayiciRepositoryProtocol {
    
    private let baseURL = "https://api.finnet2000.com/api/Analysis/IndicatorSignals"
    private let choicesURL = "https://api.finnet2000.com/api/Analysis/GetSignalStocksChoices"
    
    func fetchIndicatorSignals(request: TeknikScannerRequest) async throws -> [TeknikScannerResponseItem] {
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try JSONEncoder().encode(request)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data = try await NetworkManager.shared.authedSession
            .request(urlRequest)
            .validate(statusCode: 200..<300)
            .serializingData()
            .value
            
        return try JSONDecoder().decode([TeknikScannerResponseItem].self, from: data)
    }
    
    func fetchSignalStocksChoices() async throws -> TeknikScannerChoicesResponse {
        guard let url = URL(string: choicesURL) else {
            throw URLError(.badURL)
        }
        
        let data = try await NetworkManager.shared.authedSession
            .request(url, method: .get)
            .validate(statusCode: 200..<300)
            .serializingData()
            .value
            
        return try JSONDecoder().decode(TeknikScannerChoicesResponse.self, from: data)
    }
}
