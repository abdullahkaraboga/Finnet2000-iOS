//
//  RiskParametersSection.swift
//  Finnet2000-iOS
//
//  Created by Karaboğa on 10/31/25.
//

import SwiftUI

struct RiskParametersSection: View {
    let result: CompareStocksResponse
    let leftKey: String?
    let rightKey: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Risk Parametreleri")
                .font(.system(size: 17, weight: .bold))

            let left = (result.keys.contains(leftKey ?? "") ? leftKey : result.keys.first) ?? ""
            let right = (result.keys.contains(rightKey ?? "") ? rightKey : result.keys.dropFirst().first) ?? ""
            let paramNames: [String] = {
                if let params = result[left]?.riskParams {
                    return params.map { $0.name }
                }
                return []
            }()
            CompareTable(
                columns: ["", left, right],
                rows: paramNames.map { paramName in
                    [
                        paramName,
                        result[left]?.riskParams?.first(where: { $0.name == paramName })?.value ?? "-",
                        result[right]?.riskParams?.first(where: { $0.name == paramName })?.value ?? "-"
                    ]
                }
            )
        }
    }
}
