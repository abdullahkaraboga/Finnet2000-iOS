import Foundation
import SwiftUI
import Combine

@MainActor
final class StockDetailViewModel: ObservableObject {
    @Published var data: StockDetailData?
    @Published var ratiosData: StockDetailRatiosData?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    func fetch(stockCode: String) {
        isLoading = true
        errorMessage = nil
        
        StockDetailService.shared.fetchSummary(stockCode: stockCode) { [weak self] result in
            guard let self = self else { return }
            
            Task {
                switch result {
                case .success(let data):
                    self.data = data
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
                
                // Fetch ratios after summary
                StockDetailService.shared.fetchRatios(stockCode: stockCode) { ratiosResult in
                    Task {
                        self.isLoading = false
                        switch ratiosResult {
                        case .success(let ratiosData):
                            self.ratiosData = ratiosData
                        case .failure(let error):
                            if self.errorMessage == nil {
                                self.errorMessage = error.localizedDescription
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties for View
    
    var symbol: String { data?.stockTag?.code ?? "" }
    var company: String { data?.stockTag?.name ?? "" }
    var price: String {
        guard let p = data?.stockTag?.price else { return "-" }
        return String(format: "%.2f₺", p) // or better formatting
    }
    var change: String {
        guard let c = data?.stockTag?.dailyReturn else { return "-" }
        let sign = c >= 0 ? "%" : "%-"
        return String(format: "%@%.2f", sign, abs(c))
    }
    var date: String {
        guard let d = data?.stockTag?.date else { return "-" }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        if let dateObj = formatter.date(from: d) {
            let outFormatter = DateFormatter()
            outFormatter.dateFormat = "dd/MM/yyyy"
            return outFormatter.string(from: dateObj)
        }
        return d
    }
    
    // In actual implementation, parse SDRadarEntry
    // For now we don't have SDRadarEntry defined in this snippet context
    
    var pricePoints: [Double] {
        return data?.datePriceList?.values ?? []
    }
    
    var returnsRows: [[String]] {
        guard let ret = data?.returns else { return [] }
        
        func fmt(_ val: Double?) -> String {
            guard let v = val else { return "-" }
            let sign = v >= 0 ? "%" : "%-"
            return String(format: "%@%.2f", sign, abs(v))
        }
        
        let stockRow = [
            symbol,
            fmt(ret.daily?.stock),
            fmt(ret.weekly?.stock),
            fmt(ret.monthly?.stock),
            fmt(ret.annual?.stock)
        ]
        
        let benchmarkRow = [
            "Endeks",
            fmt(ret.daily?.benchmark),
            fmt(ret.weekly?.benchmark),
            fmt(ret.monthly?.benchmark),
            fmt(ret.annual?.benchmark)
        ]
        
        return [stockRow, benchmarkRow]
    }
    
    var movingAvgRows: [[String]] {
        guard let ma = data?.movingAverages else { return [] }
        
        func fmtPct(_ val: Double?) -> String {
            guard let v = val else { return "-" }
            let sign = v >= 0 ? "%" : "%-"
            return String(format: "%@%.2f", sign, abs(v))
        }
        
        func fmtVal(_ val: Double?) -> String {
            guard let v = val else { return "-" }
            return String(format: "%.2f", v)
        }
        
        let diffRow = [
            "Fark",
            fmtPct(ma.sma20?.percentageDifference),
            fmtPct(ma.sma50?.percentageDifference),
            fmtPct(ma.sma100?.percentageDifference),
            fmtPct(ma.sma200?.percentageDifference)
        ]
        
        let valRow = [
            "Değer",
            fmtVal(ma.sma20?.smaValue),
            fmtVal(ma.sma50?.smaValue),
            fmtVal(ma.sma100?.smaValue),
            fmtVal(ma.sma200?.smaValue)
        ]
        
        return [diffRow, valRow]
    }
    
    var momentumRows: [[String]] {
        guard let mom = data?.momentumIndicators else { return [] }
        
        func name(_ id: IndicatorDetail?) -> String { id?.name ?? "-" }
        func val(_ id: IndicatorDetail?) -> String {
            guard let v = id?.value else { return "-" }
            return String(format: "%.2f", v)
        }
        
        let durumRow = [
            "Durum",
            name(mom.rsi),
            name(mom.stochastic),
            name(mom.macd),
            name(mom.stochasticAvg)
        ]
        
        let degerRow = [
            "Değer",
            val(mom.rsi),
            val(mom.stochastic),
            val(mom.macd),
            val(mom.stochasticAvg)
        ]
        
        return [durumRow, degerRow]
    }
    
    var funds: [(String, String)] {
        guard let topFunds = data?.topHoldingFunds else { return [] }
        return topFunds.map { ($0.key, String(format: "%.2f", $0.value)) }.sorted { $0.0 < $1.0 }
    }
    
    var multiplesRows: [(String, String)] {
        guard let mult = data?.summaryMultipliers else { return [] }
        return mult.values.map { ($0.name ?? "", String(format: "%.2f", $0.value ?? 0.0)) }.sorted { $0.0 < $1.0 }
    }
    
    var balanceRows: [(String, String)] {
        guard let bal = data?.summaryBalanceSheet else { return [] }
        // Simple formatting, divided by 1 Million for display maybe?
        return bal.values.map { 
            let v = ($0.value ?? 0) / 1_000_000
            return ($0.name ?? "", String(format: "%.2fMi ₺", v))
        }.sorted { $0.0 < $1.0 }
    }
    
    var incomeRows: [(String, String)] {
        guard let inc = data?.summaryIncomeStatement else { return [] }
        return inc.values.map { 
            let v = ($0.value ?? 0) / 1_000_000
            return ($0.name ?? "", String(format: "%.2fMi ₺", v))
        }.sorted { $0.0 < $1.0 }
    }
    
    var sectoralValueHeader: String {
        data?.summarySectoralAnalysis?.values.first?.name ?? "Değer"
    }

    var sectoralRows: [(String, String)] {
        guard let sec = data?.summarySectoralAnalysis else { return [] }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = ","
        formatter.groupingSeparator = "."
        
        return sec.map { key, sectoralData in 
            let v = (sectoralData.value ?? 0) / 1_000_000_000
            let formattedValue = formatter.string(from: NSNumber(value: v)) ?? String(format: "%.2f", v)
            return (key, "\(formattedValue)Mr ₺")
        }.sorted { $0.0 < $1.0 }
    }
    
    var pairTradeRows: [(String, String)] {
        guard let pt = data?.pairTrade else { return [] }
        return pt.map { 
            ($0.key, String(format: "%.2f", $0.value))
        }.sorted { $0.0 < $1.0 }
    }
    
    var partnershipRows: [[String]] {
        guard let p = data?.partnerships else { return [] }
        var rows: [[String]] = []
        for partner in p {
            let name = partner.name ?? "-"
            let capital = String(format: "%.2fMi %@", (partner.capital ?? 0) / 1_000_000, partner.currency ?? "₺")
            let rate = String(format: "%%%.2f", partner.rate ?? 0)
            rows.append([name, capital, rate])
        }
        return rows
    }
    
    // MARK: - Ratios Data Formatting
    
    func ratioRows(for categoryName: String) -> [[String]] {
        guard let ratiosData = ratiosData,
              let types = ratiosData.ratioTypes,
              let ratios = ratiosData.ratios else {
            return []
        }
        
        // Find the category ID by name
        guard let categoryId = types.first(where: { $0.value == categoryName })?.key,
              let items = ratios[categoryId] else {
            return []
        }
        
        var result: [[String]] = []
        for item in items {
            let name = item.ratioName ?? "-"
            
            // Format value: check if percentage
            let isPct = item.isPercentage == true
            
            // Assuming we just want to show the stock's value and sector average
            // The API returns dictionary with keys like "TKNSA", "Sektör Ortalama", etc.
            let stockVal = item.ratioValues?[symbol] ?? 0
            let sectorAvg = item.ratioValues?["Sektör Ortalama"] ?? 0
            let sectorMed = item.ratioValues?["Sektör Medyan"] ?? 0
            
            func fmt(_ val: Double) -> String {
                if isPct {
                    let sign = val >= 0 ? "%" : "%-"
                    return String(format: "%@%.2f", sign, abs(val))
                } else {
                    return String(format: "%.2f", val)
                }
            }
            
            result.append([name, fmt(stockVal), fmt(sectorAvg), fmt(sectorMed)])
        }
        
        return result
    }
}
