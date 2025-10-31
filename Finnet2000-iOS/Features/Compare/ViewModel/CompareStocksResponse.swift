// CompareStocksResponse.swift
import Foundation

// API, hisse kodunu key olarak kullanarak detayları döndürüyor.
typealias CompareStocksResponse = [String: StockCompareDetail]

// Tek bir hissenin karşılaştırma detayları
struct StockCompareDetail: Decodable {
    let name: String?
    let logo: String?
    let periodicalReturns: PeriodicalReturns?
    let momentumIndicators: MomentumIndicators?
    let riskParams: [RiskParam]?
}

// Dönemsel getiriler
struct PeriodicalReturns: Decodable {
    let daily: Double
    let weekly: Double
    let monthly: Double
}

// Momentum indikatörleri
struct MomentumIndicators: Decodable {
    let rsi: RSIIndicator?
}

// RSI indikatörü
struct RSIIndicator: Decodable {
    let value: Double
}

// Risk parametreleri
struct RiskParam: Decodable {
    let name: String
    let value: Double
}
