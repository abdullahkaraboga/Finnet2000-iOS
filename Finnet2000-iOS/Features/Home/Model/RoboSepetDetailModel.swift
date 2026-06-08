import Foundation

// MARK: - RoboSepetDetailResponse

struct RoboSepetDetailResponse: Decodable, Sendable {
    let portfolioId: Int
    let code: String
    let name: String
    let logoPath: String
    let dailyReturn: Double
    let monthName: String
    let strategy: String
    let riskValue: Int          // 1–10
    let disclaimer: String
    let holdings: [RoboSepetHolding]
    let returns: RoboSepetReturns
    let annualPrices: [Double]
    let annualDates: [String]
    let radarValues: RoboSepetRadarValues
    let otherPortfolios: [RobofundPortfolio]
}

// MARK: - Portfolio Holdings

struct RoboSepetHolding: Decodable, Identifiable, Sendable {
    let assetName: String
    let ratio: Double   // e.g. 0.92 means %0,92
    var id: String { assetName }
}

// MARK: - Returns

struct RoboSepetReturns: Decodable, Sendable {
    let daily: RoboSepetReturnItem
    let weekly: RoboSepetReturnItem
    let monthly: RoboSepetReturnItem
    let threeMonthly: RoboSepetReturnItem
    let sixMonthly: RoboSepetReturnItem
    let annual: RoboSepetReturnItem
}

struct RoboSepetReturnItem: Decodable, Sendable {
    let percentage: Double
    let amount: Double
}

// MARK: - Radar Values (each 0–1 normalised)

struct RoboSepetRadarValues: Decodable, Sendable {
    let volatility: Double
    let vro: Double
    let getiri: Double
    let sharpe: Double
    let riskDegeri: Double

    var asArray: [Double] { [volatility, vro, getiri, sharpe, riskDegeri] }
}

// MARK: - Mock data for design preview

extension RoboSepetDetailResponse {
    static let mock = RoboSepetDetailResponse(
        portfolioId: 1,
        code: "TST1",
        name: "Test 1 Şehende",
        logoPath: "",
        dailyReturn: 0.21,
        monthName: "Temmuz",
        strategy: "Eeee çok stratejik",
        riskValue: 7,
        disclaimer: """
        Burada yer alan bilgiler yatırım analizi değildir ve hiçbir şekilde yatırım tavsiyesi \
        veya sonucu hakkında bilgi değildir. Bu bilgilerden elde edilecek işlemlerde oluşacak \
        zararlar için şirketimiz hiçbir şekilde sorumluluk kabul etmez. Finansal piyasalardaki \
        değer artış ya da düşüşlerin nedenine ya da değişme nedeni hakkında geliştirilen \
        tahminler kesinlikle gerçekleşeceği garantisi vermemektedir. Bu nedenle, analistlerin \
        bu yorumlarına dayanarak bir yatırım kararı verilmesini uygun bulmamaktayız. \
        Finansal veriler durumunuza ve tahminlerinize ve yatırım hedeflerinizi değerlendirerek \
        daha kişisel ve bir yatırım profesyoneli ile bir finansal cs varlığınızı yapmanızı tavsiye \
        edilmez edilir.
        """,
        holdings: [
            RoboSepetHolding(assetName: "Tatlıpınar Enerji Üretim", ratio: 0.92),
            RoboSepetHolding(assetName: "Lila Kağıt",               ratio: 1.4),
            RoboSepetHolding(assetName: "TAV Havalimanları",         ratio: 22.08),
            RoboSepetHolding(assetName: "Emlak Konut GMYO",          ratio: 25.0),
            RoboSepetHolding(assetName: "Katılımevim Tas. Fin.",     ratio: 25.0),
            RoboSepetHolding(assetName: "TAB Gıda",                  ratio: 25.0),
        ],
        returns: RoboSepetReturns(
            daily:        RoboSepetReturnItem(percentage: 0.21,   amount: 10021),
            weekly:       RoboSepetReturnItem(percentage: 4.2,    amount: 10420),
            monthly:      RoboSepetReturnItem(percentage: 33.45,  amount: 13345),
            threeMonthly: RoboSepetReturnItem(percentage: 106.32, amount: 20631),
            sixMonthly:   RoboSepetReturnItem(percentage: 249.98, amount: 34998),
            annual:       RoboSepetReturnItem(percentage: 382.82, amount: 48281)
        ),
        annualPrices: [
            10000, 10200, 10100, 10350, 10800, 11200, 11500, 12000, 13000, 14200,
            15500, 17000, 19000, 21000, 23500, 26000, 29000, 32000, 36000, 40000,
            42000, 44000, 46000, 47500, 48281
        ],
        annualDates: [
            "01-25", "02-25", "03-25", "04-25", "05-25", "06-25",
            "07-25", "08-25", "09-25", "10-25", "11-25", "12-25",
            "01-26", "02-26", "03-26", "04-26", "05-26"
        ],
        radarValues: RoboSepetRadarValues(
            volatility: 0.60,
            vro:        0.75,
            getiri:     0.85,
            sharpe:     0.55,
            riskDegeri: 0.70
        ),
        otherPortfolios: [
            RobofundPortfolio(portfolioId: 2, code: "TST2", name: "Test 2", logoPath: "", dailyReturn: 1.64, weeklyReturn: 3.2,  monthlyReturn: 12.0, weeklyReturnList: [1.0, 1.5, 1.2, 1.8, 2.0, 1.6, 1.64]),
            RobofundPortfolio(portfolioId: 3, code: "TST3", name: "Test 3", logoPath: "", dailyReturn: 1.84, weeklyReturn: 4.1,  monthlyReturn: 14.5, weeklyReturnList: [1.2, 1.8, 1.5, 2.0, 1.9, 1.7, 1.84]),
            RobofundPortfolio(portfolioId: 4, code: "TST4", name: "Test 4", logoPath: "", dailyReturn: 1.64, weeklyReturn: 3.8,  monthlyReturn: 13.0, weeklyReturnList: [0.9, 1.3, 1.6, 1.4, 1.7, 1.5, 1.64]),
        ]
    )
}
