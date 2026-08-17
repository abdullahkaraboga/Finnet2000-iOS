import Foundation

// MARK: - Filtered Stock Item

struct FilteredStockItem: Decodable, Identifiable, Sendable {
    var id: String { code }

    let code: String
    let logoPath: String
    let name: String
    let date: String
    let value: Double
    let price: Double

    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        code     = try c.decodeIfPresent(String.self, forKey: .code) ?? ""
        logoPath = try c.decodeIfPresent(String.self, forKey: .logoPath) ?? ""
        name     = try c.decodeIfPresent(String.self, forKey: .name) ?? ""
        date     = try c.decodeIfPresent(String.self, forKey: .date) ?? ""
        value    = try c.decodeIfPresent(Double.self, forKey: .value) ?? 0.0
        price    = try c.decodeIfPresent(Double.self, forKey: .price) ?? 0.0
    }

    private enum CodingKeys: String, CodingKey {
        case code, logoPath, name, date, value, price
    }
}

typealias FilteredStocksResponse = [FilteredStockItem]
