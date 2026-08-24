import Foundation

class FilterRepository {
    static let shared = FilterRepository()
    
    private init() {}
    
    func fetchFilterChoices() async throws -> FilterChoicesResponse {
        guard let url = URL(string: "https://api.finnet2000.com/api/Filter/GetFilterChoicesList") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(FilterChoicesResponse.self, from: data)
        return response
    }
}
