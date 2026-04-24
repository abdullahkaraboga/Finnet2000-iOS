//
//  ReturnsSection.swift
//  Finnet2000-iOS
//
//  Created by Karaboğa on 10/31/25.
//
import SwiftUI

struct ReturnsSection: View {
    let result: CompareStocksResponse
    let leftKey: String?
    let rightKey: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Getiriler")
                .font(.headline)

            let left = (result.keys.contains(leftKey ?? "") ? leftKey : result.keys.first) ?? ""
            let right = (result.keys.contains(rightKey ?? "") ? rightKey : result.keys.dropFirst().first) ?? ""
            CompareTable(
                columns: ["", "Günlük", "Haftalık", "Aylık", "Yıllık"],
                rows: [left, right].map { key in
                    let returns = result[key]?.periodicalReturns
                    return [
                        key,
                        returns?.daily.map { String(format: "%.2f%%", $0) } ?? "-",
                        returns?.weekly.map { String(format: "%.2f%%", $0) } ?? "-",
                        returns?.monthly.map { String(format: "%.2f%%", $0) } ?? "-",
                        returns?.annual.map { String(format: "%.2f%%", $0) } ?? "-"
                    ]
                }
            )
        }
    }
}

