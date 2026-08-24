import Foundation

struct FilterChoicesResponse: Codable {
    let markets: [FilterItem]?
    let indices: [FilterItem]?
    let sectors: [FilterItem]?
    let ratios: [FilterRatioGroup]?
    let financials: FilterFinancials?
}

struct FilterItem: Codable, Identifiable, Hashable {
    let id: Int
    let code: String
    let name: String
}

struct FilterRatioGroup: Codable, Hashable {
    let ratioType: String
    let ratios: [FilterRatio]
}

struct FilterRatio: Codable, Identifiable, Hashable {
    let id: Int
    let code: String
    let name: String
}

struct FilterFinancials: Codable {
    let balanceSheets: [FilterFinancialItem]?
    let incomeStatements: [FilterFinancialItem]?
}

struct FilterFinancialItem: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let itemListId: Int
    let type: String
}
