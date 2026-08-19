import Foundation
import Alamofire

protocol SectoralAnalysisRepositoryProtocol {
    func fetchSectors() async throws -> SectoralAnalysisResponse
}

final class SectoralAnalysisRepository: SectoralAnalysisRepositoryProtocol {
    
    private let baseURL = "https://api.finnet2000.com/api/SectoralAnalysis/GetSectors"
    
    func fetchSectors() async throws -> SectoralAnalysisResponse {
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data = try await NetworkManager.shared.authedSession
            .request(urlRequest)
            .validate(statusCode: 200..<300)
            .serializingData()
            .value
            
        return try JSONDecoder().decode(SectoralAnalysisResponse.self, from: data)
    }
}
