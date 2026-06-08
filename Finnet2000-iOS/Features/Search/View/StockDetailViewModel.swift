import Foundation
import SwiftUI

// MARK: - View Model (Mock)

@MainActor
final class StockDetailViewModel: ObservableObject {
    @Published var data: StockDetailData?

    func fetch(stockCode: String) {
        // Simulate async fetch by assigning mock data immediately
        let tag = StockTag(
            code: stockCode.uppercased(),
            name: "Mock Company",
            logoPath: nil,
            price: 119.58,
            dailyReturn: 0.0444,
            date: Date()
        )

        let returns = Returns(
            daily: ReturnPair(stock: 0.0444, benchmark: -0.0013),
            weekly: ReturnPair(stock: 0.0676, benchmark: -0.0017),
            monthly: ReturnPair(stock: 0.6087, benchmark: 0.1270),
            annual: ReturnPair(stock: 0.0155, benchmark: 0.5514)
        )

        let moving = MovingAverages(
            sma20: SMAInfo(percentageDifference: 0.2429, smaValue: 88.91),
            sma50: SMAInfo(percentageDifference: 0.6526, smaValue: 66.87),
            sma100: SMAInfo(percentageDifference: 1.3289, smaValue: 47.55),
            sma200: SMAInfo(percentageDifference: 2.6787, smaValue: 30.04)
        )

        let momentum = MomentumIndicators(
            rsi: Indicator(name: "Sat", value: 92.12),
            stochastic: Indicator(name: "Sat", value: 96.50),
            macd: Indicator(name: "Al", value: 9.58),
            stochasticAvg: Indicator(name: "-", value: 90.20)
        )

        let funds: [String: Double] = [
            "SLG": 3.43, "R0İ1": 4.20, "KYA": 4.24, "KİS": 4.36,
            "KCL": 4.38, "YİİK": 4.41, "PPİ": 4.70, "KİİC": 5.52,
            "İLN": 5.66, "TLZ": 6.07
        ]

        let multipliers: [String: SummaryItem] = [
            "1": SummaryItem(name: "Firma Değeri / FAVÖK", value: 16.42),
            "2": SummaryItem(name: "PD / DD", value: 30.15),
            "3": SummaryItem(name: "Fiyat Kazanç", value: 26.53)
        ]

        let balance: [String: SummaryItem] = [
            "1": SummaryItem(name: "Özkaynaklar", value: 12_400_000),
            "2": SummaryItem(name: "Net Borç", value: 8_200_000),
            "3": SummaryItem(name: "Toplam Varlık", value: 24_600_000)
        ]

        let income: [String: SummaryItem] = [
            "1": SummaryItem(name: "Net Satışlar", value: 8_400_000),
            "2": SummaryItem(name: "Brüt Kar", value: 3_900_000),
            "3": SummaryItem(name: "FAVÖK", value: 3_100_000),
            "4": SummaryItem(name: "Faaliyet Karı", value: 2_700_000),
            "5": SummaryItem(name: "Net Kar", value: 2_100_000)
        ]

        let partnerships: [Partnership] = [
            Partnership(name: "Kurucu", rate: 32.5),
            Partnership(name: "Yatırımcı A", rate: 12.0),
            Partnership(name: "Halka Açık", rate: 55.5)
        ]

        let risks: [RiskItem] = [
            RiskItem(name: "Kur Riski", value: "Orta"),
            RiskItem(name: "Likidite Riski", value: "Düşük"),
            RiskItem(name: "Piyasa Riski", value: "Yüksek")
        ]

        let sectoral: [String: SummaryItem] = [
            "GARAN": SummaryItem(name: "Piyasa Değeri", value: 350_000_000_000),
            "ISCTR": SummaryItem(name: "Piyasa Değeri", value: 280_000_000_000),
            "YKBNK": SummaryItem(name: "Piyasa Değeri", value: 190_000_000_000)
        ]

        let datePrice: [Date: Double] = {
            var dict: [Date: Double] = [:]
            let base = Date()
            for i in 0..<34 { dict[Calendar.current.date(byAdding: .day, value: -i, to: base)!] = Double(12 + i) }
            return dict
        }()

        self.data = StockDetailData(
            stockTag: tag,
            returns: returns,
            movingAverages: moving,
            momentumIndicators: momentum,
            topHoldingFunds: funds,
            summaryMultipliers: multipliers,
            summaryBalanceSheet: balance,
            summaryIncomeStatement: income,
            partnerships: partnerships,
            riskAnalysis: risks,
            summarySectoralAnalysis: sectoral,
            datePriceList: datePrice
        )
    }
}

// MARK: - Models (minimal to satisfy the view)

struct StockDetailData {
    let stockTag: StockTag
    let returns: Returns
    let movingAverages: MovingAverages
    let momentumIndicators: MomentumIndicators
    let topHoldingFunds: [String: Double]
    let summaryMultipliers: [String: SummaryItem]
    let summaryBalanceSheet: [String: SummaryItem]
    let summaryIncomeStatement: [String: SummaryItem]
    let partnerships: [Partnership]
    let riskAnalysis: [RiskItem]
    let summarySectoralAnalysis: [String: SummaryItem]
    let datePriceList: [Date: Double]
}

struct StockTag {
    let code: String
    let name: String
    let logoPath: String?
    let price: Double
    let dailyReturn: Double
    let date: Date
}

struct Returns {
    let daily: ReturnPair
    let weekly: ReturnPair
    let monthly: ReturnPair
    let annual: ReturnPair
}

struct ReturnPair { let stock: Double; let benchmark: Double }

struct MovingAverages {
    let sma20: SMAInfo
    let sma50: SMAInfo
    let sma100: SMAInfo
    let sma200: SMAInfo
}

struct SMAInfo { let percentageDifference: Double; let smaValue: Double }

struct MomentumIndicators {
    let rsi: Indicator
    let stochastic: Indicator
    let macd: Indicator
    let stochasticAvg: Indicator
}

struct Indicator { let name: String; let value: Double }

struct SummaryItem { let name: String; let value: Double }

struct Partnership { let name: String; let rate: Double }

struct RiskItem { let name: String; let value: String }

// MARK: - Helpers

extension Date {
    var f2000Formatted: String {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        return df.string(from: self)
    }
}
