import Foundation

// MARK: - StockData (WebSocket live message)

struct StockData: Codable {
    let symbol: String?
    let priceStep: Double?
    let limitDown: Double?
    let limitUp: Double?
    let updateDate: String?
    let bid: Double?
    let ask: Double?
    let last: Double?
    let dailyHigh: Double?
    let dailyLow: Double?
    let dailyClose: Double?
    let priceMean: Double?

    enum CodingKeys: String, CodingKey {
        case symbol      = "Symbol"
        case priceStep   = "PriceStep"
        case limitDown   = "LimitDown"
        case limitUp     = "LimitUp"
        case updateDate  = "UpdateDate"
        case bid         = "Bid"
        case ask         = "Ask"
        case last        = "Last"
        case dailyHigh   = "DailyHigh"
        case dailyLow    = "DailyLow"
        case dailyClose  = "DailyClose"
        case priceMean   = "PriceMean"
    }
}

// MARK: - Subscribe message

struct StockSubscribeMessage: Encodable {
    let action: String
    let codes: [String]
    let notifyOnLastChange: Bool
    let time: Int

    enum CodingKeys: String, CodingKey {
        case action             = "Action"
        case codes              = "Codes"
        case notifyOnLastChange = "NotifyOnLastChange"
        case time               = "Time"
    }

    init(codes: [String], duration: Int = 4000) {
        self.action             = "subscribe"
        self.codes              = codes
        self.notifyOnLastChange = true
        self.time               = duration
    }
}
