import Foundation

// MARK: - Root Response
struct FavouriteListResponse: Codable, Sendable {
    let stocks: [FavouriteStock]
    let robofunds: [FavouriteRobofund]

    // 🔥 Swift concurrency fix
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.stocks = try container.decode([FavouriteStock].self, forKey: .stocks)
        self.robofunds = try container.decode([FavouriteRobofund].self, forKey: .robofunds)
    }
}

// MARK: - Stock
struct FavouriteStock: Codable, Identifiable, Sendable {
    var id: String { code }
    let logoPath: String
    let code: String
    let name: String
    let date: String
    let price: Double
    let `return`: Double

    // 🔥 Swift concurrency fix
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.logoPath = try container.decode(String.self, forKey: .logoPath)
        self.code = try container.decode(String.self, forKey: .code)
        self.name = try container.decode(String.self, forKey: .name)
        self.date = try container.decode(String.self, forKey: .date)
        self.price = try container.decode(Double.self, forKey: .price)
        self.`return` = try container.decode(Double.self, forKey: .return)
    }
}

// MARK: - Robofund
struct FavouriteRobofund: Codable, Identifiable, Sendable {
    var id: Int { portfolioId }
    let logoPath: String
    let `return`: Double
    let robofundCode: String
    let robofundName: String
    let portfolioId: Int

    // 🔥 Swift concurrency fix
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.logoPath = try container.decode(String.self, forKey: .logoPath)
        self.`return` = try container.decode(Double.self, forKey: .return)
        self.robofundCode = try container.decode(String.self, forKey: .robofundCode)
        self.robofundName = try container.decode(String.self, forKey: .robofundName)
        self.portfolioId = try container.decode(Int.self, forKey: .portfolioId)
    }
}
