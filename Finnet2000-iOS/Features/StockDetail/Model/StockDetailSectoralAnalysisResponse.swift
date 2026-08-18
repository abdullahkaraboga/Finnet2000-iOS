import Foundation

// MARK: - StockDetailSectoralAnalysisResponse
struct StockDetailSectoralAnalysisResponse: Codable {
    let success: Bool?
    let message: String?
    let data: StockDetailSectoralAnalysisData?
}

// MARK: - StockDetailSectoralAnalysisData
struct StockDetailSectoralAnalysisData: Codable {
    let financials: SectoralFinancials?
    let ratios: [String: [SectoralItem]]?
    let returns: [String: [SectoralItem]]?
}

// MARK: - SectoralFinancials
struct SectoralFinancials: Codable {
    let balanceSheet: [String: [SectoralItem]]?
    let incomeStatement: [String: [SectoralItem]]?
    let cashFlowStatement: [String: [SectoralItem]]?
    
    enum CodingKeys: String, CodingKey {
        case balanceSheet = "BalanceSheet"
        case incomeStatement = "IncomeStatement"
        case cashFlowStatement = "CashFlowStatement"
    }
}

// MARK: - SectoralItem
struct SectoralItem: Codable, Identifiable {
    let name: String?
    let value: Double?
    let isPercentage: Bool?
    
    var id: String { name ?? UUID().uuidString }
}
