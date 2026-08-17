import Foundation

struct FilterRequest: Encodable {
    var currency: String = ""
    var marketIdList: [Int] = [0]
    var indexIdList: [Int] = [0]
    var sectorIdList: [Int] = [0]
    var ratioMinMaxValues: [RatioMinMax] = [.init(id: 0, minValue: 0, maxValue: 0)]
    var balanceSheetMinMaxValues: [FinancialMinMax] = [.init(id: 0, itemTypeId: 0, minValue: 0, maxValue: 0)]
    var incomeStatementsMinMaxValues: [FinancialMinMax] = [.init(id: 0, itemTypeId: 0, minValue: 0, maxValue: 0)]
    var cashFlowMinMaxValues: [FinancialMinMax] = [.init(id: 0, itemTypeId: 0, minValue: 0, maxValue: 0)]
    var returnType: String = ""
    var ratioId: Int = 0
    var sheetTypeAndId: SheetTypeAndId = .init()
    var direction: String = ""
}
struct RatioMinMax: Encodable {
    let id: Int
    let minValue: Double
    let maxValue: Double
}
struct FinancialMinMax: Encodable {
    let id: Int
    let itemTypeId: Int
    let minValue: Double
    let maxValue: Double
}
struct SheetTypeAndId: Encodable {
    var id: Int = 0
    var itemListId: Int = 0
}

let encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted
if let data = try? encoder.encode(FilterRequest()) {
    print(String(data: data, encoding: .utf8)!)
}
