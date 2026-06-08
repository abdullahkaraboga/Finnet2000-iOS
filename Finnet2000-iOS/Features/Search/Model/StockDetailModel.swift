import Foundation

// MARK: - Root Response

struct StockDetailResponse: Decodable {
    let success: Bool
    let data: StockDetailData
}

// MARK: - Data Container

struct StockDetailData: Decodable {
    let stockTag: StockTag
    let datePriceList: StockDateValueList
    let dateReturnList: StockDateValueList
    let returns: PeriodReturns
    let movingAverages: MovingAverages
    let momentumIndicators: SDMomentumIndicators
    let topHoldingFunds: [String: Double]
    let summaryMultipliers: [String: NameValueItem]
    let summaryBalanceSheet: [String: NameValueItem]
    let summaryIncomeStatement: [String: NameValueItem]
    let summarySectoralAnalysis: [String: NameValueItem]
    let partnerships: [Partnership]
    let riskAnalysis: [RiskItem]
    let userSpecificData: UserSpecificData

    enum CodingKeys: String, CodingKey {
        case stockTag
        case datePriceList
        case dateReturnList
        case returns
        case movingAverages
        case momentumIndicators
        case topHoldingFunds
        case summaryMultipliers
        case summaryBalanceSheet
        case summaryIncomeStatement
        case summarySectoralAnalysis
        case partnerships
        case riskAnalysis
        case userSpecificData
    }
}

// MARK: - Stock Tag

struct StockTag: Decodable {
    let code: String
    let name: String
    let logoPath: String
    let date: String
    let price: Double
    let dailyReturn: Double
    let weeklyReturn: Double?
    let monthlyReturn: Double?
    let yearlyReturn: Double?
}

// MARK: - Date / Value Series

struct StockDateValueList: Decodable {
    let dates: [String]
    let values: [Double]
}

// MARK: - Returns

struct PeriodReturns: Decodable {
    let daily: BenchmarkReturn
    let weekly: BenchmarkReturn
    let monthly: BenchmarkReturn
    let threeMonthly: BenchmarkReturn
    let sixMonthly: BenchmarkReturn
    let annual: BenchmarkReturn
}

struct BenchmarkReturn: Decodable {
    let stock: Double
    let benchmark: Double
}

// MARK: - Moving Averages

struct MovingAverages: Decodable {
    let sma20: SMAValue
    let sma50: SMAValue
    let sma100: SMAValue
    let sma200: SMAValue
}

struct SMAValue: Decodable {
    let smaValue: Double
    let percentageDifference: Double
}

// MARK: - Momentum Indicators

struct SDMomentumIndicators: Decodable {
    let rsi: SDIndicatorValue
    let macd: SDIndicatorValue
    let stochastic: SDIndicatorValue
    let stochasticAvg: SDIndicatorValue
}

struct SDIndicatorValue: Decodable {
    let name: String
    let value: Double
}

// MARK: - Name + Value Item

struct NameValueItem: Decodable {
    let name: String
    let value: Double
    let isPercentage: Bool?

    enum CodingKeys: String, CodingKey { case name, value, isPercentage }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name         = try c.decode(String.self, forKey: .name)
        value        = try c.decode(Double.self, forKey: .value)
        isPercentage = try c.decodeIfPresent(Bool.self, forKey: .isPercentage)
    }
}

// MARK: - Partnership

struct Partnership: Decodable {
    let name: String
    let capital: Double
    let rate: Double
    let currency: String
}

// MARK: - Risk Item

struct RiskItem: Decodable {
    let name: String
    let value: String
}

// MARK: - User Specific Data

struct UserSpecificData: Decodable {
    let isInFavorites: Bool
    let isInPortfolio: Bool
    let isInAlertList: Bool
}
