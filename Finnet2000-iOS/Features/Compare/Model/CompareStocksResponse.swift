// CompareStocksResponse.swift
import Foundation

// API, hisse kodunu key olarak kullanarak detayları döndürüyor.
typealias CompareStocksResponse = [String: StockCompareDetail]

// Tek bir hissenin karşılaştırma detayları
struct StockCompareDetail: Decodable, Sendable {
    let name: String?
    let logo: String?
    let periodicalReturns: PeriodicalReturns?
    let momentumIndicators: MomentumIndicators?
    let riskParams: [RiskParam]?

    private enum CodingKeys: String, CodingKey {
        case name
        case logo
        case periodicalReturns
        case momentumIndicators
        case riskParams
    }

    // Ensure Decodable conformance is not actor-isolated
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.logo = try container.decodeIfPresent(String.self, forKey: .logo)
        self.periodicalReturns = try container.decodeIfPresent(PeriodicalReturns.self, forKey: .periodicalReturns)
        self.momentumIndicators = try container.decodeIfPresent(MomentumIndicators.self, forKey: .momentumIndicators)
        self.riskParams = try container.decodeIfPresent([RiskParam].self, forKey: .riskParams)
    }
}

// Dönemsel getiriler
struct PeriodicalReturns: Decodable, Sendable {
    let daily: Double
    let weekly: Double
    let monthly: Double

    private enum CodingKeys: String, CodingKey {
        case daily
        case weekly
        case monthly
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.daily = try container.decode(Double.self, forKey: .daily)
        self.weekly = try container.decode(Double.self, forKey: .weekly)
        self.monthly = try container.decode(Double.self, forKey: .monthly)
    }
}

// Momentum indikatörleri
struct MomentumIndicators: Decodable, Sendable {
    let rsi: RSIIndicator?

    private enum CodingKeys: String, CodingKey {
        case rsi
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.rsi = try container.decodeIfPresent(RSIIndicator.self, forKey: .rsi)
    }
}

// RSI indikatörü
struct RSIIndicator: Decodable, Sendable {
    let value: Double

    private enum CodingKeys: String, CodingKey {
        case value
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try container.decode(Double.self, forKey: .value)
    }
}

// Risk parametreleri
struct RiskParam: Decodable, Sendable {
    let name: String
    let value: Double

    private enum CodingKeys: String, CodingKey {
        case name
        case value
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.value = try container.decode(Double.self, forKey: .value)
    }
}
