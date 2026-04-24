import SwiftUI

struct FinancialTablesSection: View {
    let result: CompareStocksResponse
    let leftKey: String?
    let rightKey: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Finansal Tablolar")
                .font(.headline)

            let left = (result.keys.contains(leftKey ?? "") ? leftKey : result.keys.first) ?? ""
            let right = (result.keys.contains(rightKey ?? "") ? rightKey : result.keys.dropFirst().first) ?? ""
            if let leftStock = result[left], let rightStock = result[right] {
                let leftKeys = leftStock.balanceSheet?.keys.map { $0 } ?? []
                let rightKeys = rightStock.balanceSheet?.keys.map { $0 } ?? []
                let allKeys = Set(leftKeys).union(rightKeys)
                let sortedKeys = allKeys.sorted()
                CompareTable(
                    columns: ["", left, right],
                    rows: sortedKeys.map { key in
                        [
                            key,
                            leftStock.balanceSheet?[key]?.value.asString ?? "-",
                            rightStock.balanceSheet?[key]?.value.asString ?? "-"
                        ]
                    }
                )
            } else {
                Text("Veri bulunamadı.")
                    .foregroundColor(.secondary)
            }
        }
    }
}
