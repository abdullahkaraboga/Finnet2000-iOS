import Foundation

struct PortfolioInfo: Decodable, Identifiable, Hashable, Sendable {
    var id: Int { portfolioId }
    
    let portfolioId: Int
    let portfolioName: String
    
    enum CodingKeys: String, CodingKey {
        case portfolioId, portfolioName
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.portfolioId = try container.decode(Int.self, forKey: .portfolioId)
        self.portfolioName = try container.decode(String.self, forKey: .portfolioName)
    }
}
