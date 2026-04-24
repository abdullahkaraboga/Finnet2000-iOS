import Foundation

// MARK: - HomePageResponse

struct HomePageResponse: Decodable {
    let contents: [ContentItem]
    let robofundResponse: [RobofundPortfolio]
    let ipos: [IPOItem]
    let chargedStocks: [ChargedStock]
    let dailyIndexInfo: [DailyIndex]
    let dailyIndexStatistics: DailyIndexStatistics
    let stockStatsDetail: StockStatsDetail
    let currencyPriceInfo: [CurrencyPriceGroup]
    let annualGraphInfo: [AnnualGraph]
    let currencyList: [String]
    let tooltips: Tooltips

    enum CodingKeys: String, CodingKey {
        case contents
        case robofundResponse = "robofundResponseModel"
        case ipos
        case chargedStocks
        case dailyIndexInfo
        case dailyIndexStatistics
        case stockStatsDetail
        case currencyPriceInfo
        case annualGraphInfo
        case currencyList
        case tooltips
    }
}

// MARK: - Content

struct ContentItem: Decodable {
    let date: String
    let type: String
    let title: String
    let description: String?
    let contentPath: String?
    let thumbnailPath: String?
    let androidTargetPath: String?
    let iosTargetPath: String?
}

// MARK: - Robofund

struct RobofundPortfolio: Decodable {
    let portfolioId: Int
    let code: String
    let name: String
    let logoPath: String
    let dailyReturn: Double
    let weeklyReturn: Double
    let monthlyReturn: Double
    let weeklyReturnList: [Double]
}

// MARK: - IPO & ChargedStock

struct IPOItem: Decodable {}
struct ChargedStock: Decodable {}

// MARK: - Daily Index

struct DailyIndex: Decodable {
    let type: Int
    let typeName: String
    let indexName: String
    let code: String
    let price: Double
    let dailyReturn: Double
    let weeklyPriceList: [Double]
}

// MARK: - Daily Index Statistics

struct DailyIndexStatistics: Decodable {
    let name: String
    let higherCount: Int
    let lowerCount: Int
    let unchangedCount: Int
    let amount: Double
    let volume: Double
}

// MARK: - Stock Stats Detail

struct StockStatsDetail: Decodable {
    let highest: [StockStat]
    let lowest: [StockStat]
    let mostVolumes: [StockStat]
    let mostAmounts: [StockStat]
}

struct StockStat: Decodable {
    let code: String
    let logoPath: String
    let firstClosePrice: Double
    let lastClosePrice: Double
    let dailyReturn: Double
    let volume: Double
    let amount: Double
}

// MARK: - Currency Price Info

struct CurrencyPriceGroup: Decodable {
    let assetType: String
    let assetPrices: [CurrencyPrice]
}

struct CurrencyPrice: Decodable {
    let code: String
    let name: String
    let price: Double
    let date: String
}

// MARK: - Annual Graph Info

struct AnnualGraph: Decodable {
    let code: String
    let price: Double
    let dailyReturn: Double
    let name: String
    let pair: String?
    let dates: [String]
    let prices: [Double]
}

// MARK: - Tooltips

struct Tooltips: Decodable {
    let robofund: String?
    let indexReturns: String?
    let amounts: String?

    enum CodingKeys: String, CodingKey {
        case robofund    = "Robofund"
        case indexReturns = "IndexReturns"
        case amounts     = "Amounts"
    }
}
