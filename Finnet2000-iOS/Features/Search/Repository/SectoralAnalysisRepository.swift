import Foundation
import Alamofire

protocol SectoralAnalysisRepositoryProtocol {
    func fetchSectors() async throws -> SectoralAnalysisResponse
    func fetchSectorList() async throws -> SectorListResponse
    func fetchSectorDetail(sectorName: String) async throws -> SectorAnalysisDetailResponse
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
    
    func fetchSectorList() async throws -> SectorListResponse {
        guard let url = URL(string: "https://api.finnet2000.com/api/SectoralAnalysis/GetSectorList") else {
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
            
        return try JSONDecoder().decode(SectorListResponse.self, from: data)
    }
    
    func fetchSectorDetail(sectorName: String) async throws -> SectorAnalysisDetailResponse {
        guard let encodedName = sectorName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.finnet2000.com/api/SectoralAnalysis/GetSectoralAnalysis?sectorName=\(encodedName)") else {
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
            
        return try JSONDecoder().decode(SectorAnalysisDetailResponse.self, from: data)
    }
}
