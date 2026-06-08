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
        code     = try c.decode(String.self, forKey: .code)
        logoPath = try c.decode(String.self, forKey: .logoPath)
        name     = try c.decode(String.self, forKey: .name)
        date     = try c.decode(String.self, forKey: .date)
        value    = try c.decode(Double.self, forKey: .value)
        price    = try c.decode(Double.self, forKey: .price)
    }

    private enum CodingKeys: String, CodingKey {
        case code, logoPath, name, date, value, price
    }
}

typealias FilteredStocksResponse = [FilteredStockItem]
