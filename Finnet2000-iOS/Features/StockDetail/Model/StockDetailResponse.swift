import Foundation

// MARK: - StockDetailResponse
struct StockDetailResponse: Codable {
    let success: Bool?
    let message: String?
    let data: StockDetailData?
}

// MARK: - StockDetailData
struct StockDetailData: Codable {
    let stockTag: StockTag?
    let radarChartData: RadarChartData?
    let datePriceList: DatePriceList?
    let dateReturnList: DateReturnList?
    let returns: Returns?
    let movingAverages: MovingAverages?
    let momentumIndicators: SDMomentumIndicators?
    let topHoldingFunds: [String: Double]?
    let summaryMultipliers: [String: SummaryMultiplier]?
    let summaryBalanceSheet: [String: SummaryFinancial]?
    let summaryIncomeStatement: [String: SummaryFinancial]?
    let summarySectoralAnalysis: [String: SectoralAnalysis]?
    let pairTrade: [String: Double]?
    let partnerships: [Partnership]?
    let riskAnalysis: [RiskAnalysis]?
    let valuation: Valuation?
    let quant: Quant?
    let userSpecificData: UserSpecificData?
    let prediction: Prediction?
    let traderScreenEnabled: Bool?
    let tooltips: SDTooltips?
}

// MARK: - StockTag
struct StockTag: Codable {
    let code: String?
    let name: String?
    let logoPath: String?
    let date: String?
    let price: Double?
    let dailyReturn: Double?
    let weeklyReturn: Double?
    let monthlyReturn: Double?
    let threeMonthlyReturn: Double?
    let sixMonthlyReturn: Double?
    let yearlyReturn: Double?
    let threeYearlyReturn: Double?
}

// MARK: - RadarChartData
struct RadarChartData: Codable {
    let ticks: [String]?
    let features: [String: String]? 
}

// MARK: - DatePriceList
struct DatePriceList: Codable {
    let dates: [String]?
    let values: [Double]?
}

// MARK: - DateReturnList
struct DateReturnList: Codable {
    let dates: [String]?
    let values: [Double]?
}

// MARK: - Returns
struct Returns: Codable {
    let daily: ReturnDetail?
    let weekly: ReturnDetail?
    let monthly: ReturnDetail?
    let threeMonthly: ReturnDetail?
    let sixMonthly: ReturnDetail?
    let annual: ReturnDetail?
}

struct ReturnDetail: Codable {
    let stock: Double?
    let benchmark: Double?
}

// MARK: - MovingAverages
struct MovingAverages: Codable {
    let sma20: SmaDetail?
    let sma50: SmaDetail?
    let sma100: SmaDetail?
    let sma200: SmaDetail?
}

struct SmaDetail: Codable {
    let smaValue: Double?
    let percentageDifference: Double?
}

// MARK: - SDMomentumIndicators
struct SDMomentumIndicators: Codable {
    let rsi: IndicatorDetail?
    let macd: IndicatorDetail?
    let stochastic: IndicatorDetail?
    let stochasticAvg: IndicatorDetail?
}

struct IndicatorDetail: Codable {
    let name: String?
    let value: Double?
}

// MARK: - Summary Models
struct SummaryMultiplier: Codable {
    let name: String?
    let value: Double?
    let isPercentage: Bool?
}

struct SummaryFinancial: Codable {
    let name: String?
    let value: Double?
}

struct SectoralAnalysis: Codable {
    let name: String?
    let value: Double?
}

// MARK: - Partnership
struct Partnership: Codable {
    let name: String?
    let capital: Double?
    let rate: Double?
    let currency: String?
}

// MARK: - RiskAnalysis
struct RiskAnalysis: Codable {
    let name: String?
    let value: String?
}

// MARK: - Valuation
struct Valuation: Codable {
    let firmaDegeriFAVOK: Double?
    let firmaDegeriNetSatis: Double?
    let fiyatKazanc: Double?
    let pdDD: Double?
    let pdFAVOK: Double?
    
    enum CodingKeys: String, CodingKey {
        case firmaDegeriFAVOK = "Firma Değeri / FAVÖK"
        case firmaDegeriNetSatis = "Firma Değeri / Net Satış"
        case fiyatKazanc = "Fiyat Kazanç"
        case pdDD = "PD / DD"
        case pdFAVOK = "PD / FAVÖK"
    }
}

// MARK: - Quant
struct Quant: Codable {
}

// MARK: - UserSpecificData
struct UserSpecificData: Codable {
    let isInFavorites: Bool?
    let isInPortfolio: Bool?
    let isInAlertList: Bool?
}

// MARK: - Prediction
struct Prediction: Codable {
    let dates: [String]?
    let closePrice: [Double]?
    let s1: [Double]?
    let s2: [Double]?
    let s3: [Double]?
    let s4: [Double]?
    let s5: [Double]?
    let s6: [Double]?
    let s7: [Double]?
    let pp: [Double]?
    let r1: [Double]?
    let r2: [Double]?
    let r3: [Double]?
    let r4: [Double]?
    let r5: [Double]?
    let r6: [Double]?
    let r7: [Double]?
    let prediction: [Double]?
    let internalImpres: [Double]?
    let extrinsicImpres: [Double]?
    let averageImpres: [Double]?
}

// MARK: - SDTooltips
struct SDTooltips: Codable {
    let radarChart: String?
    let priceGraph: String?
    let returns: String?
    let movingAverages: String?
    let momentumIndicators: String?
    let includedFunds: String?
    let marketMultiples: String?
    let summaryBalanceSheet: String?
    let summaryIncomeStatement: String?
    let summarySectoralAnalysis: String?
    let pairTrade: String?
    let partnership: String?
    
    enum CodingKeys: String, CodingKey {
        case radarChart = "RadarChart"
        case priceGraph = "PriceGraph"
        case returns = "Returns"
        case movingAverages = "MovingAverages"
        case momentumIndicators = "MomentumIndicators"
        case includedFunds = "IncludedFunds"
        case marketMultiples = "MarketMultiples"
        case summaryBalanceSheet = "SummaryBalanceSheet"
        case summaryIncomeStatement = "SummaryIncomeStatement"
        case summarySectoralAnalysis = "SummarySectoralAnalysis"
        case pairTrade = "PairTrade"
        case partnership = "Partnership"
    }
}
