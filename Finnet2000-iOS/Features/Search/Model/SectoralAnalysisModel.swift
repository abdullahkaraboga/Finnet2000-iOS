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

struct SectorListResponse: Codable {
    let success: Bool
    let message: String
    let data: [SectorListItem]
}

struct SectorListItem: Codable, Identifiable, Equatable {
    let sektorId: Int
    let ad: String
    let kod: String
    let bilancoFormatId: Int
    let hisseSektor: Bool
    let aktif: Bool
    
    var id: Int { sektorId }
}

struct SectorAnalysisDetailResponse: Codable {
    let success: Bool
    let message: String
    let data: SectorAnalysisDetailData
}

struct SectorAnalysisDetailData: Codable {
    let stockCodes: [String]
    let financials: [String: [String: [SectorIndicator]]]?
    let ratios: [String: [String: [SectorIndicator]]]?
    let `return`: [String: [SectorIndicator]]?
    let risk: [String: [SectorIndicator]]?
    let technicalAnalysis: [String: [String: [SectorIndicator]]]?
    let valuation: [String: [SectorIndicator]]?
}
