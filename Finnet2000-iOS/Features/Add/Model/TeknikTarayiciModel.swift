import Foundation

// MARK: - Request
struct TeknikScannerRequest: Codable, Sendable {
    let nationalIndicesIds: [Int]
    let sectoralIndicesIds: [Int]
    let sectorIds: [Int]
    let analysisType: Int
    
    init(nationalIndicesIds: [Int] = [], sectoralIndicesIds: [Int] = [], sectorIds: [Int] = [], analysisType: Int) {
        self.nationalIndicesIds = nationalIndicesIds
        self.sectoralIndicesIds = sectoralIndicesIds
        self.sectorIds = sectorIds
        self.analysisType = analysisType
    }
}

// MARK: - Response
struct TeknikScannerResponseItem: Codable, Identifiable, Sendable {
    var id: String { code }
    let code: String
    let ma5Signal: String?
    let ma5To20Signal: String?
    let ma20To50Signal: String?
    let rsiSignal: String?
    let rsiAAorAS: String?
    let cciSignal: String?
    let cciAAorAS: String?
    let macdSignal: String?
}

// MARK: - Choices Response
struct TeknikScannerChoicesResponse: Codable, Sendable {
    let nationalIndices: [String: String]?
    let sectoralIndices: [String: String]?
    let sectors: [String: String]?
}
