import Foundation

// MARK: - StockDetailRatiosResponse
struct StockDetailRatiosResponse: Codable {
    let success: Bool?
    let message: String?
    let data: StockDetailRatiosData?
}

// MARK: - StockDetailRatiosData
struct StockDetailRatiosData: Codable {
    let ratioTypes: [String: String]?
    let ratios: [String: [StockRatioItem]]?
}

// MARK: - StockRatioItem
struct StockRatioItem: Codable, Identifiable {
    let ratioId: Int?
    let ratioName: String?
    let isPercentage: Bool?
    let ratioValues: [String: Double]?
    
    var id: Int { ratioId ?? UUID().hashValue }
}
