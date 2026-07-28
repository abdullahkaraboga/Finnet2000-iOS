//
//  FinancialAnalysisSection.swift
//  Finnet2000-iOS
//
//  Created by Karaboğa on 10/31/25.
//

import SwiftUI

struct FinancialAnalysisSection: View {
    let result: CompareStocksResponse
    let leftKey: String?
    let rightKey: String?
    @State private var selectedIndex = 0
    let analysisOptions = ["Analiz 1", "Analiz 2", "Analiz 3"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Finansal Analiz")
                    .font(.system(size: 17, weight: .bold))
                Spacer()
                AssetSelectionView(
                    selectedIndex: $selectedIndex,
                    values: analysisOptions
                )
            }

            let left = (result.keys.contains(leftKey ?? "") ? leftKey : result.keys.first) ?? ""
            let right = (result.keys.contains(rightKey ?? "") ? rightKey : result.keys.dropFirst().first) ?? ""
            if let leftStock = result[left], let rightStock = result[right],
               let leftRatios = leftStock.ratios, let rightRatios = rightStock.ratios {
                let allRatioNames = Set(leftRatios.keys).union(rightRatios.keys).sorted()
                CompareTable(
                    columns: ["", left, right],
                    rows: allRatioNames.map { ratioKey in
                        let leftDict = leftRatios[ratioKey] ?? [:]
                        let rightDict = rightRatios[ratioKey] ?? [:]
                        let leftValue = leftDict.values.first?.value ?? 0
                        let rightValue = rightDict.values.first?.value ?? 0
                        return [
                            ratioKey,
                            String(format: "%.2f", leftValue),
                            String(format: "%.2f", rightValue)
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
