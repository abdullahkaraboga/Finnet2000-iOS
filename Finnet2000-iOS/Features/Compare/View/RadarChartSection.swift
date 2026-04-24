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
            Text("Risk Radar Grafiği")
                .font(.headline)
                .padding(.leading, 4)

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
                .frame(height: 280)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 3, y: 1)

                // Legend
                HStack(spacing: 16) {
                    if let first = result.keys.first {
                        LegendDot(color: .blue.opacity(0.6))
                        Text(first)
                            .font(.caption)
                    }

                    if let second = result.keys.dropFirst().first {
                        LegendDot(color: .green.opacity(0.6))
                        Text(second)
                            .font(.caption)
                    }
                }
                .foregroundColor(.secondary)
                .padding(.top, 4)
            }
        }
    }

    // MARK: - Helper: Dinamik eksenler (risk parametre adları)
    private func buildCategories() -> [String] {
        guard let firstKey = result.keys.first,
              let params = result[firstKey]?.riskParams else {
            return []
        }
        return params.map { $0.name }
    }

    // MARK: - Helper: İki hisse için seriler
    private func buildSeries() -> [RadarSeries] {
        let keys = Array(result.keys.prefix(2)) // ilk iki hisse
        guard !keys.isEmpty else { return [] }

        func parseValue(_ raw: String) -> Double {
            let cleaned = raw
                .replacingOccurrences(of: "%", with: "")
                .replacingOccurrences(of: ",", with: ".")
                .trimmingCharacters(in: .whitespaces)
            return Double(cleaned) ?? 0.0
        }

        func normalizedValues(for key: String) -> [Double] {
            guard let params = result[key]?.riskParams else { return [] }

            // normalize değerler (0...1)
            let maxValue = params.compactMap { parseValue($0.value) }.max() ?? 1
            return params.map { parseValue($0.value) / maxValue }
        }

        var list: [RadarSeries] = []

        if let first = keys.first {
            list.append(
                RadarSeries(name: first, values: normalizedValues(for: first), color: .blue.opacity(0.6))
            )
        }
        if keys.count > 1 {
            let second = keys[1]
            list.append(
                RadarSeries(name: second, values: normalizedValues(for: second), color: .green.opacity(0.6))
            )
        }

        return list
    }
}
