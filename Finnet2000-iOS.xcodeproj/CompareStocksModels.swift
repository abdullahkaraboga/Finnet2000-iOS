import Foundation

// MARK: - Ana model
struct CompareStocksResponse: Codable {
    let stocks: [String: StockDetail]
    
    // Custom CodingKeys, çünkü kök seviyede A1CAP, AKBNK gibi dinamik key’ler var
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.stocks = try container.decode([String: StockDetail].self)
    }
}

// MARK: - StockDetail (her bir hisse verisi)
struct StockDetail: Codable {
    let name: String
    let logo: String
    let datePriceList: DateValueList?
    let dateReturnList: DateValueList?
    let riskParams: [RiskParam]?
    let periodicalReturns: PeriodicalReturns?
    let ratios: [String: Double]?
    let balanceSheet: [String: Double]?
    let incomeStatement: [String: Double]?
    let cashFlowStatement: [String: Double]?
    let topHoldingFunds: [String: Double]?
    let movingAverages: MovingAverages?
    let momentumIndicators: MomentumIndicators?
}

// MARK: - Tarih-Değer listeleri
struct DateValueList: Codable {
    let dates: [String]
    let values: [Double]
}

// MARK: - Risk Parametreleri
struct RiskParam: Codable {
    let name: String
    let value: String
}

// MARK: - Dönemsel Getiriler
struct PeriodicalReturns: Codable {
    let daily: Double
    let weekly: Double
    let monthly: Double
    let threeMonthly: Double
    let sixMonthly: Double
    let annual: Double
}

// MARK: - Hareketli Ortalamalar
struct MovingAverages: Codable {
    let sma20: SMAValue
    let sma50: SMAValue
    let sma100: SMAValue
    let sma200: SMAValue
}

struct SMAValue: Codable {
    let smaValue: Double
    let percentageDifference: Double
}

// MARK: - Momentum Göstergeleri
struct MomentumIndicators: Codable {
    let rsi: Indicator
    let macd: Indicator
    let stochastic: Indicator
    let stochasticAvg: Indicator
}

struct Indicator: Codable {
    let name: String
    let value: Double
}
