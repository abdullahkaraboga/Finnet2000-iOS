import Foundation

struct UserPortfolio: Codable, Identifiable, Sendable {
    var id: Int { portfolioId }

    let portfolioId: Int
    let portfolioName: String
    let dailyReturn: Double
    let dailyValue: Double
    let isEmpty: Bool
    let weeklyIndex: [Double]
    let createDate: String
    let logoPath: String
    let target: Double

    // Swift Concurrency ile uyumlu özel init (gerekli değil ama tutarlılık için)
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.portfolioId = try c.decode(Int.self, forKey: .portfolioId)
        self.portfolioName = try c.decode(String.self, forKey: .portfolioName)
        self.dailyReturn = try c.decode(Double.self, forKey: .dailyReturn)
        self.dailyValue = try c.decode(Double.self, forKey: .dailyValue)
        self.isEmpty = try c.decode(Bool.self, forKey: .isEmpty)
        self.weeklyIndex = try c.decode([Double].self, forKey: .weeklyIndex)
        self.createDate = try c.decode(String.self, forKey: .createDate)
        self.logoPath = try c.decode(String.self, forKey: .logoPath)
        self.target = try c.decode(Double.self, forKey: .target)
    }
}

