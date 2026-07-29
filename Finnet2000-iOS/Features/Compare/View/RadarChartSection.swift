//
//  RadarChartSection.swift
//  Finnet2000-iOS
//
//  Created by Karaboğa on 10/31/25.
//

import SwiftUI

struct RadarChartSection: View {
    let result: CompareStocksResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if buildCategories().isEmpty {
                Text("Risk parametreleri bulunamadı.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            } else {
                RadarChartView(
                    categories: buildCategories(),
                    series: buildSeries(),
                    gridLineCount: 5
                )
                .frame(height: 220)

                // Legend
                HStack(spacing: 16) {
                    if let first = result.keys.first {
                        LegendDot(color: Color(red: 0.22, green: 0.47, blue: 0.80).opacity(0.7))
                        Text(first)
                            .font(.caption)
                    }

                    if let second = result.keys.dropFirst().first {
                        LegendDot(color: Color.midGreen.opacity(0.7))
                        Text(second)
                            .font(.caption)
                    }
                }
                .foregroundColor(.secondary)
                .padding(.top, 4)
            }
        }
    }

    private static let maxAxes = 5

    // MARK: - Helper: Dinamik eksenler (risk parametre adları)
    private func buildCategories() -> [String] {
        guard let firstKey = result.keys.first,
              let params = result[firstKey]?.riskParams else {
            return []
        }
        return Array(params.prefix(Self.maxAxes).map { $0.name })
    }

    // MARK: - Helper: İki hisse için seriler
    private func buildSeries() -> [RadarSeries] {
        let keys = Array(result.keys.prefix(2))
        guard !keys.isEmpty else { return [] }

        func parseValue(_ raw: String) -> Double {
            let cleaned = raw
                .replacingOccurrences(of: "%", with: "")
                .replacingOccurrences(of: ",", with: ".")
                .trimmingCharacters(in: .whitespaces)
            return Double(cleaned) ?? 0.0
        }

        // Her eksen için iki hissenin max'ına göre normalize et
        let axisCount = keys.compactMap { result[$0]?.riskParams }.first.map { min($0.count, Self.maxAxes) } ?? 0

        func normalizedValues(for key: String) -> [Double] {
            guard let params = result[key]?.riskParams else { return [] }
            let limited = Array(params.prefix(Self.maxAxes))
            return (0..<axisCount).map { i in
                let rawSelf = parseValue(limited[i].value ?? "0")
                // Diğer hissedeki aynı eksendeki değerle karşılaştırarak normalize et
                let axisMax = keys.compactMap { k -> Double? in
                    guard let p = result[k]?.riskParams else { return nil }
                    return parseValue(Array(p.prefix(Self.maxAxes))[i].value ?? "0")
                }.max() ?? 1
                return axisMax > 0 ? rawSelf / axisMax : 0
            }
        }

        var list: [RadarSeries] = []

        if let first = keys.first {
            list.append(
                RadarSeries(name: first, values: normalizedValues(for: first),
                            color: Color(red: 0.22, green: 0.47, blue: 0.80).opacity(0.55))
            )
        }
        if keys.count > 1 {
            let second = keys[1]
            list.append(
                RadarSeries(name: second, values: normalizedValues(for: second),
                            color: Color.midGreen.opacity(0.55))
            )
        }

        return list
    }
}
