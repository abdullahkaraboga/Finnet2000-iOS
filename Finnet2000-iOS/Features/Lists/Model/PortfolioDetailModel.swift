import Foundation

// MARK: - PortfolioDetailResponse (display model – not directly decoded from API)

struct PortfolioDetailResponse: Sendable {
    let portfolioId: Int
    let name: String
    let logoPath: String
    let date: String          // e.g. "2026-04-13"
    let totalValue: Double
    let dailyReturn: Double
    let totalReturn: Double
    let performance: PortfolioPerformance
    let weights: [PortfolioWeight]
    let openPositions: [OpenPosition]
}

// MARK: - Performance (100 Liram Ne Oldu?)

struct PortfolioPerformance: Sendable {
    let dates: [String]
    let values: [Double]    // indexed values, base 100
}

// MARK: - Portfolio Weights

struct PortfolioWeight: Identifiable, Sendable {
    let code: String
    let ratio: Double       // 0–1  e.g. 0.87 means 87%
    var id: String { code }
}

// MARK: - Open Positions

struct OpenPosition: Identifiable, Sendable {
    let stockCode: String
    let logoPath: String
    let costPrice: Double       // Maliyet
    let currentValue: Double    // Değer (total)
    let dailyReturn: Double     // % günlük getiri
    let lots: [PositionLot]
    var id: String { stockCode }
}

struct PositionLot: Identifiable, Sendable {
    let date: String            // "06/05/2026"
    let quantity: Int           // Adet
    let buyPrice: Double        // Alım Fiyatı
    let lastPrice: Double       // Son Fiyat
    let totalReturnPct: Double  // Toplam getiri % (API: totalReturn)
    let dailyProfit: Double     // Günlük kazanç ₺ (API: dailyProfit)
    let netProfit: Double       // Net kazanç ₺ (API: netProfit)
    var id: String { date + "\(buyPrice)" }
}

// MARK: - API Response Models (Decodable)

struct APIPortfolioDetailResponse: Decodable, Sendable {
    let portfolioStocksDTOs: [APIPortfolioStockDTO]
    let closePositions: [APIClosePosition]
    let weights: [APIPortfolioWeight]
    let date: [String]
    let portfolioValue: [Double]
    let portfolioReturn: [Double]
    let portfolioIndex: [Double]
    let portfolioName: String
    let targetValue: Double
    let createDate: String
    let isEmpty: Bool
}

struct APIPortfolioStockDTO: Decodable, Sendable {
    let stockId: Int
    let stockCode: String
    let amount: Int
    let stockLogo: String
    let currentValue: Double
    let averageCost: Double
    let openingDate: String
    let firstPriceValueDate: String
    let openPositions: [APIOpenPosition]
}

struct APIOpenPosition: Decodable, Sendable {
    let positionId: Int
    let openDate: String
    let lastDate: String
    let amount: Int
    let buyPrice: Double
    let lastPrice: Double
    let buyCost: Double
    let currentValue: Double
    let totalReturn: Double
    let dailyReturn: Double
    let dailyProfit: Double
    let netProfit: Double
    let closePositionData: APIClosePositionData?
}

struct APIClosePositionData: Decodable, Sendable {
    let positionId: Int
    let date: String
    let amount: Int
    let price: Double
    let commission: Double
    let type: Int
}

struct APIPortfolioWeight: Decodable, Sendable {
    let stockCode: String
    let date: String
    let value: Double   // percentage e.g. 100 = 100%
}

struct APIClosePosition: Decodable, Sendable {}

// MARK: - API → Display Model Conversion

extension APIPortfolioDetailResponse {
    func toPortfolioDetailResponse(portfolioId: Int, logoPath: String = "") -> PortfolioDetailResponse {
        let totalValue = portfolioStocksDTOs.reduce(0.0) { $0 + $1.currentValue }
        let dailyReturn = portfolioReturn.last ?? 0.0
        let totalReturn = (portfolioIndex.last ?? 100.0) - 100.0

        let perfDates = date.map { Self.formatChartDate($0) }
        let performance = PortfolioPerformance(dates: perfDates, values: portfolioIndex)

        let totalWeight = weights.reduce(0.0) { $0 + $1.value }
        let pwts = weights.map { w -> PortfolioWeight in
            let ratio = totalWeight > 0 ? w.value / totalWeight : 0
            return PortfolioWeight(code: w.stockCode, ratio: ratio)
        }

        let ops = portfolioStocksDTOs.map { dto -> OpenPosition in
            let lots = dto.openPositions.map { op -> PositionLot in
                PositionLot(
                    date: Self.formatLotDate(op.openDate),
                    quantity: op.amount,
                    buyPrice: op.buyPrice,
                    lastPrice: op.lastPrice,
                    totalReturnPct: op.totalReturn,
                    dailyProfit: op.dailyProfit,
                    netProfit: op.netProfit
                )
            }
            return OpenPosition(
                stockCode: dto.stockCode,
                logoPath: dto.stockLogo,
                costPrice: dto.averageCost,
                currentValue: dto.currentValue,
                dailyReturn: dto.openPositions.first?.dailyReturn ?? 0.0,
                lots: lots
            )
        }

        return PortfolioDetailResponse(
            portfolioId: portfolioId,
            name: portfolioName,
            logoPath: logoPath,
            date: createDate,
            totalValue: totalValue,
            dailyReturn: dailyReturn,
            totalReturn: totalReturn,
            performance: performance,
            weights: pwts,
            openPositions: ops
        )
    }

    /// "2026-05-06" → "05/06"
    private static func formatChartDate(_ iso: String) -> String {
        let parts = iso.prefix(10).split(separator: "-")
        guard parts.count == 3 else { return iso }
        return "\(parts[1])/\(parts[2])"
    }

    /// "2026-05-06T00:00:00" → "06/05/2026"
    private static func formatLotDate(_ iso: String) -> String {
        let datePart = String(iso.prefix(10))
        let parts = datePart.split(separator: "-")
        guard parts.count == 3 else { return datePart }
        return "\(parts[2])/\(parts[1])/\(parts[0])"
    }
}

// MARK: - Mock

extension PortfolioDetailResponse {
    static let mock = PortfolioDetailResponse(
        portfolioId: 1,
        name: "ogz-port",
        logoPath: "",
        date: "08/05/2026",
        totalValue: 70020,
        dailyReturn: 0.92,
        totalReturn: -1.01,
        performance: PortfolioPerformance(
            dates: ["04/26", "05/26"],
            values: [
                100.0, 99.8, 99.4, 99.1, 98.9, 98.3,
                97.8, 97.2, 96.7, 96.1, 95.6, 95.0,
                95.1, 95.4, 95.8, 96.3, 96.9, 97.4,
                97.9, 98.3, 98.7, 99.0, 98.9
            ]
        ),
        weights: [
            PortfolioWeight(code: "THYAO", ratio: 0.87),
            PortfolioWeight(code: "AKBNK", ratio: 0.10),
            PortfolioWeight(code: "Diğer", ratio: 0.03),
        ],
        openPositions: [
            OpenPosition(
                stockCode: "AKBNK",
                logoPath: "",
                costPrice: 75.95,
                currentValue: 7520,
                dailyReturn: 1.14,
                lots: [
                    PositionLot(date: "28/04/2026", quantity: 100, buyPrice: 75.95, lastPrice: 75.20,
                               totalReturnPct: -0.99, dailyProfit: 7.0, netProfit: -75.0)
                ]
            ),
            OpenPosition(
                stockCode: "THYAO",
                logoPath: "",
                costPrice: 314.50,
                currentValue: 62500,
                dailyReturn: 0.89,
                lots: [
                    PositionLot(date: "29/04/2026", quantity: 200, buyPrice: 314.50, lastPrice: 312.50,
                               totalReturnPct: -0.64, dailyProfit: 0.0, netProfit: -400.0)
                ]
            ),
        ]
    )
}

// MARK: - Helpers

extension PortfolioDetailResponse {
    var totalValueFormatted: String {
        totalValue.compactCurrencyString()
    }
}

extension OpenPosition {
    var currentValueFormatted: String {
        currentValue.compactCurrencyString()
    }

    var costPriceFormatted: String {
        costPrice.compactCurrencyString()
    }
}
