import Foundation

// MARK: - Root
typealias CompareStocksResponse = [String: StockCompareDetail]

// MARK: - StockCompareDetail
struct StockCompareDetail: Decodable, Sendable {
    let name: String?
    let logo: String?
    let periodicalReturns: PeriodicalReturns?
    let momentumIndicators: MomentumIndicators?
    let riskParams: [RiskParam]?
    let ratios: [String: [String: RatioDetail]]? // düzeltildi: nested dictionary
    let datePriceList: DateValueList?            // düzeltildi
    let dateReturnList: DateValueList?           // eklendi
    let balanceSheet: [String: BalanceItem]?
    let incomeStatement: [String: BalanceItem]?
    let cashFlowStatement: [String: BalanceItem]?
    let topHoldingFunds: [String: Double]?
    let movingAverages: [String: MovingAverageItem]?

    private enum CodingKeys: String, CodingKey {
        case name, logo, periodicalReturns, momentumIndicators, riskParams,
             ratios, datePriceList, dateReturnList,
             balanceSheet, incomeStatement, cashFlowStatement,
             topHoldingFunds, movingAverages
    }

    // Make Decodable conformance nonisolated to satisfy Sendable generic constraints
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try c.decodeIfPresent(String.self, forKey: .name)
        self.logo = try c.decodeIfPresent(String.self, forKey: .logo)
        self.periodicalReturns = try c.decodeIfPresent(PeriodicalReturns.self, forKey: .periodicalReturns)
        self.momentumIndicators = try c.decodeIfPresent(MomentumIndicators.self, forKey: .momentumIndicators)
        self.riskParams = try c.decodeIfPresent([RiskParam].self, forKey: .riskParams)
        self.ratios = try c.decodeIfPresent([String: [String: RatioDetail]].self, forKey: .ratios)
        self.datePriceList = try c.decodeIfPresent(DateValueList.self, forKey: .datePriceList)
        self.dateReturnList = try c.decodeIfPresent(DateValueList.self, forKey: .dateReturnList)
        self.balanceSheet = try c.decodeIfPresent([String: BalanceItem].self, forKey: .balanceSheet)
        self.incomeStatement = try c.decodeIfPresent([String: BalanceItem].self, forKey: .incomeStatement)
        self.cashFlowStatement = try c.decodeIfPresent([String: BalanceItem].self, forKey: .cashFlowStatement)
        self.topHoldingFunds = try c.decodeIfPresent([String: Double].self, forKey: .topHoldingFunds)
        self.movingAverages = try c.decodeIfPresent([String: MovingAverageItem].self, forKey: .movingAverages)
    }
}

// MARK: - DateValueList
struct DateValueList: Decodable, Sendable {
    let dates: [String]
    let values: [Double]
}

// MARK: - PeriodicalReturns
struct PeriodicalReturns: Decodable, Sendable {
    let daily, weekly, monthly, threeMonthly, sixMonthly, annual: Double?
}

// MARK: - MomentumIndicators
struct MomentumIndicators: Decodable, Sendable {
    let rsi, macd, stochastic, stochasticAvg: IndicatorItem?
}

// MARK: - IndicatorItem
struct IndicatorItem: Decodable, Sendable {
    let name: String?
    let value: Double?
}

// MARK: - RiskParam
struct RiskParam: Decodable, Sendable {
    let name: String
    let value: String
}

// MARK: - RatioDetail
struct RatioDetail: Decodable, Sendable {
    let name: String
    let value: Double
    let isPercentage: Bool?
}

// MARK: - BalanceItem
struct BalanceItem: Decodable, Sendable {
    let name: String
    let value: Double
}

// MARK: - MovingAverageItem
struct MovingAverageItem: Decodable, Sendable {
    let smaValue: Double
    let percentageDifference: Double
}
