import Combine
import Foundation

// MARK: - NameValueItem convenience init

private extension NameValueItem {
    init(name: String, value: Double, isPercentage: Bool? = nil) {
        self.name = name
        self.value = value
        self.isPercentage = isPercentage
    }
}

// MARK: - View Model (Mock)

@MainActor
final class StockDetailViewModel: ObservableObject {
    @Published var data: StockDetailData?

    func fetch(stockCode: String) {
        let tag = StockTag(
            code: stockCode.uppercased(),
            name: "Mock Company",
            logoPath: "",
            date: Date().f2000Formatted,
            price: 119.58,
            dailyReturn: 0.0444,
            weeklyReturn: 0.0676,
            monthlyReturn: 0.6087,
            yearlyReturn: 0.0155
        )

        let returns = PeriodReturns(
            daily: BenchmarkReturn(stock: 0.0444, benchmark: -0.0013),
            weekly: BenchmarkReturn(stock: 0.0676, benchmark: -0.0017),
            monthly: BenchmarkReturn(stock: 0.6087, benchmark: 0.1270),
            threeMonthly: BenchmarkReturn(stock: 0.15, benchmark: 0.08),
            sixMonthly: BenchmarkReturn(stock: 0.35, benchmark: 0.20),
            annual: BenchmarkReturn(stock: 0.0155, benchmark: 0.5514)
        )

        let moving = MovingAverages(
            sma20: SMAValue(smaValue: 88.91, percentageDifference: 0.2429),
            sma50: SMAValue(smaValue: 66.87, percentageDifference: 0.6526),
            sma100: SMAValue(smaValue: 47.55, percentageDifference: 1.3289),
            sma200: SMAValue(smaValue: 30.04, percentageDifference: 2.6787)
        )

        let momentum = SDMomentumIndicators(
            rsi: SDIndicatorValue(name: "Sat", value: 92.12),
            macd: SDIndicatorValue(name: "Al", value: 9.58),
            stochastic: SDIndicatorValue(name: "Sat", value: 96.50),
            stochasticAvg: SDIndicatorValue(name: "-", value: 90.20)
        )

        let funds: [String: Double] = [
            "SLG": 3.43, "R0İ1": 4.20, "KYA": 4.24, "KİS": 4.36,
            "KCL": 4.38, "YİİK": 4.41, "PPİ": 4.70, "KİİC": 5.52,
            "İLN": 5.66, "TLZ": 6.07
        ]

        let multipliers: [String: NameValueItem] = [
            "1": NameValueItem(name: "Firma Değeri / FAVÖK", value: 16.42),
            "2": NameValueItem(name: "PD / DD", value: 30.15),
            "3": NameValueItem(name: "Fiyat Kazanç", value: 26.53)
        ]

        let balance: [String: NameValueItem] = [
            "1": NameValueItem(name: "Özkaynaklar", value: 12_400_000),
            "2": NameValueItem(name: "Net Borç", value: 8_200_000),
            "3": NameValueItem(name: "Toplam Varlık", value: 24_600_000)
        ]

        let income: [String: NameValueItem] = [
            "1": NameValueItem(name: "Net Satışlar", value: 8_400_000),
            "2": NameValueItem(name: "Brüt Kar", value: 3_900_000),
            "3": NameValueItem(name: "FAVÖK", value: 3_100_000),
            "4": NameValueItem(name: "Faaliyet Karı", value: 2_700_000),
            "5": NameValueItem(name: "Net Kar", value: 2_100_000)
        ]

        let partnerships: [Partnership] = [
            Partnership(name: "Kurucu", capital: 32_500_000, rate: 32.5, currency: "TRY"),
            Partnership(name: "Yatırımcı A", capital: 12_000_000, rate: 12.0, currency: "TRY"),
            Partnership(name: "Halka Açık", capital: 55_500_000, rate: 55.5, currency: "TRY")
        ]

        let risks: [RiskItem] = [
            RiskItem(name: "Kur Riski", value: "Orta"),
            RiskItem(name: "Likidite Riski", value: "Düşük"),
            RiskItem(name: "Piyasa Riski", value: "Yüksek")
        ]

        let sectoral: [String: NameValueItem] = [
            "GARAN": NameValueItem(name: "Piyasa Değeri", value: 350_000_000_000),
            "ISCTR": NameValueItem(name: "Piyasa Değeri", value: 280_000_000_000),
            "YKBNK": NameValueItem(name: "Piyasa Değeri", value: 190_000_000_000)
        ]

        let base = Date()
        let dates = (0..<34).map { i -> String in
            Calendar.current.date(byAdding: .day, value: -i, to: base)!.f2000Formatted
        }
        let values = (0..<34).map { Double(12 + $0) }

        let datePriceList  = StockDateValueList(dates: dates, values: values)
        let dateReturnList = StockDateValueList(dates: dates, values: values.map { $0 / 100 })
        let userData = UserSpecificData(isInFavorites: false, isInPortfolio: false, isInAlertList: false)

        self.data = StockDetailData(
            stockTag: tag,
            datePriceList: datePriceList,
            dateReturnList: dateReturnList,
            returns: returns,
            movingAverages: moving,
            momentumIndicators: momentum,
            topHoldingFunds: funds,
            summaryMultipliers: multipliers,
            summaryBalanceSheet: balance,
            summaryIncomeStatement: income,
            summarySectoralAnalysis: sectoral,
            partnerships: partnerships,
            riskAnalysis: risks,
            userSpecificData: userData
        )
    }
}
