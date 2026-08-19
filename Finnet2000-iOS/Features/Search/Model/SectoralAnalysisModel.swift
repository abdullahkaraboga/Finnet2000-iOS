import Foundation

struct SectoralAnalysisResponse: Codable {
    let success: Bool
    let message: String
    let data: [String: [SectorIndicator]]
}

struct SectorIndicator: Codable {
    let name: String
    let value: Double?
    let isPercentage: Bool?
}
