import Foundation

// MARK: - RoboSepetDetailResponse

struct RoboSepetDetailResponse: Decodable, Sendable {
    let code: String
    let name: String
    let robofundRiskValue: Int?
    let robofundStrategy: String?
    let returnList: [Double]?
    let dateList: [String]?
    let otherRobofunds: [OtherRobofund]?
    let robofundLastPortfolioMonth: String?
    let dailyReturn: Double
    let robofundAssetLists: [RobofundAssetList]?
    let weeklyReturn: Double?
    let monthlyReturn: Double?
    let threeMonthlyReturn: Double?
    let sixMonthlyReturn: Double?
    let yearlyReturn: Double?
    let isFavourite: Bool?
    let radarChartValues: RoboSepetRadarChartData?
}

// MARK: - JSON Models

struct OtherRobofund: Decodable, Sendable {
    let portfolioId: Int?
    let robofundCode: String?
    let dailyReturn: Double?
}

struct RobofundAssetList: Decodable, Sendable {
    let type: String?
    let assets: [RobofundAsset]?
}

struct RobofundAsset: Decodable, Sendable {
    let varlikAd: String?
    let varlikPortfoyOran: Double?
}

struct RoboSepetRadarChartData: Decodable, Sendable {
    let ticks: [Double]?
    let feautures: [String]?
    let data: [Double]?
}

// MARK: - View Compatibility Computed Properties

extension RoboSepetDetailResponse {
    var logoPath: String { "" }
    var monthName: String { robofundLastPortfolioMonth ?? "" }
    var strategy: String { robofundStrategy ?? "" }
    var riskValue: Int { robofundRiskValue ?? 1 }
    var disclaimer: String {
        """
        Burada yer alan bilgiler yatırım analizi değildir ve hiçbir şekilde yatırım tavsiyesi \
        veya sonucu hakkında bilgi değildir. Bu bilgilerden elde edilecek işlemlerde oluşacak \
        zararlar için şirketimiz hiçbir şekilde sorumluluk kabul etmez. Finansal piyasalardaki \
        değer artış ya da düşüşlerin nedenine ya da değişme nedeni hakkında geliştirilen \
        tahminler kesinlikle gerçekleşeceği garantisi vermemektedir.
        """
    }

    var holdings: [RoboSepetHolding] {
        guard let assets = robofundAssetLists?.first?.assets else { return [] }
        return assets.compactMap {
            guard let name = $0.varlikAd, let ratio = $0.varlikPortfoyOran else { return nil }
            return RoboSepetHolding(assetName: name, ratio: ratio)
        }
    }
    
    var returns: RoboSepetReturns {
        func createItem(pct: Double?) -> RoboSepetReturnItem {
            let p = pct ?? 0.0
            return RoboSepetReturnItem(percentage: p, amount: 10000 * (1 + p / 100.0))
        }
        return RoboSepetReturns(
            daily: createItem(pct: dailyReturn),
            weekly: createItem(pct: weeklyReturn),
            monthly: createItem(pct: monthlyReturn),
            threeMonthly: createItem(pct: threeMonthlyReturn),
            sixMonthly: createItem(pct: sixMonthlyReturn),
            annual: createItem(pct: yearlyReturn)
        )
    }
    
    var annualPrices: [Double] { returnList ?? [] }
    
    var annualDates: [String] {
        dateList?.map { dateStr in
            let components = dateStr.split(separator: "-")
            if components.count == 3 {
                return "\(components[1])-\(components[0].suffix(2))"
            }
            return dateStr
        } ?? []
    }
    
    var radarValues: RoboSepetRadarValues {
        guard let ticks = radarChartValues?.ticks,
              let maxTick = ticks.last, maxTick > 0,
              let data = radarChartValues?.data, data.count >= 5 else {
            return RoboSepetRadarValues(volatility: 0, vro: 0, getiri: 0, sharpe: 0, riskDegeri: 0)
        }
        return RoboSepetRadarValues(
            volatility: data[0] / maxTick,
            vro: data[1] / maxTick,
            getiri: data[2] / maxTick,
            sharpe: data[3] / maxTick,
            riskDegeri: data[4] / maxTick
        )
    }
    
    var otherPortfolios: [RobofundPortfolio] {
        otherRobofunds?.compactMap { o in
            guard let id = o.portfolioId, let code = o.robofundCode else { return nil }
            return RobofundPortfolio(
                portfolioId: id,
                code: code,
                name: code,
                logoPath: "",
                dailyReturn: o.dailyReturn ?? 0.0,
                weeklyReturn: 0.0,
                monthlyReturn: 0.0,
                weeklyReturnList: []
            )
        } ?? []
    }
}

// MARK: - Portfolio Holdings
struct RoboSepetHolding: Identifiable, Sendable {
    let assetName: String
    let ratio: Double
    var id: String { assetName }
}

// MARK: - Returns
struct RoboSepetReturns: Sendable {
    let daily: RoboSepetReturnItem
    let weekly: RoboSepetReturnItem
    let monthly: RoboSepetReturnItem
    let threeMonthly: RoboSepetReturnItem
    let sixMonthly: RoboSepetReturnItem
    let annual: RoboSepetReturnItem
}

struct RoboSepetReturnItem: Sendable {
    let percentage: Double
    let amount: Double
}

// MARK: - Radar Values
struct RoboSepetRadarValues: Sendable {
    let volatility: Double
    let vro: Double
    let getiri: Double
    let sharpe: Double
    let riskDegeri: Double
    var asArray: [Double] { [volatility, vro, getiri, sharpe, riskDegeri] }
}
