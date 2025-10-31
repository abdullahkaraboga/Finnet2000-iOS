// CompareStocksModels.swift
import Foundation

typealias CompareStocksResponse = [String: CompareStockDetail]

struct CompareStockDetail: Decodable, Sendable {
    let name: String?
    let logo: String?
    let datePriceList: TimeSeriesList<Double>?
    let dateReturnList: TimeSeriesList<Double>?
    let riskParams: [RiskParam]?
    let periodicalReturns: PeriodicalReturns?
    let ratios: [String: Double]? // unknown, keep flexible
    let balanceSheet: [String: Double]?
    let incomeStatement: [String: Double]?
    let cashFlowStatement: [String: Double]?
    let topHoldingFunds: [String: Double]?
    let movingAverages: MovingAverages?
    let momentumIndicators: MomentumIndicators?
}

struct TimeSeriesList<T: Decodable & Sendable>: Decodable, Sendable {
    let dates: [String]
    let values: [T]
}

struct RiskParam: Decodable, Sendable {
    let name: String
    let value: String
}

struct PeriodicalReturns: Decodable, Sendable {
    let daily: Double
    let weekly: Double
    let monthly: Double
    let threeMonthly: Double
    let sixMonthly: Double
    let annual: Double
}

struct MovingAverages: Decodable, Sendable {
    let sma20: SMA?
    let sma50: SMA?
    let sma100: SMA?
    let sma200: SMA?
    struct SMA: Decodable, Sendable {
        let smaValue: Double
        let percentageDifference: Double
    }
}

struct MomentumIndicators: Decodable, Sendable {
    let rsi: IndicatorValue?
    let macd: IndicatorValue?
    let stochastic: IndicatorValue?
    let stochasticAvg: IndicatorValue?

    struct IndicatorValue: Decodable, Sendable {
        let name: String?
        let value: Double
    }
}

