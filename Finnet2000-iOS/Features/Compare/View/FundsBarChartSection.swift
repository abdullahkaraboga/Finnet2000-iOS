import SwiftUI

// MARK: - FundsBarChartSection

struct FundsBarChartSection: View {
    let result: CompareStocksResponse
    let leftKey: String?
    let rightKey: String?

    private let leftColor  = Color(red: 0.40, green: 0.72, blue: 0.95)
    private let rightColor = Color.midGreen
    private let maxItems   = 10
    private let labelW: CGFloat = 36
    private let barH: CGFloat   = 14
    private let rowGap: CGFloat = 9

    private var leftFunds:  [(String, Double)] { sorted(for: leftKey)  }
    private var rightFunds: [(String, Double)] { sorted(for: rightKey) }

    var body: some View {
        let count  = max(leftFunds.count, rightFunds.count)
        let totalH = count > 0 ? CGFloat(count) * (barH + rowGap) - rowGap : 0

        VStack(alignment: .leading, spacing: 16) {
            // ── Section header ──────────────────────────────────────────
            HStack(spacing: 6) {
                Text("Hangi Fonlarda Var?")
                    .font(.system(size: 17, weight: .bold))
                Image(systemName: "info.circle")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            if leftFunds.isEmpty && rightFunds.isEmpty {
                Text("Fon verisi bulunamadı.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            } else {
                // ── Two-column bar chart ────────────────────────────────
                GeometryReader { geo in
                    let colW = (geo.size.width - 1) / 2
                    HStack(alignment: .top, spacing: 0) {
                        barsColumn(funds: leftFunds,  color: leftColor,  colWidth: colW)
                        Rectangle()
                            .fill(Color(.separator).opacity(0.5))
                            .frame(width: 1, height: totalH)
                        barsColumn(funds: rightFunds, color: rightColor, colWidth: colW)
                    }
                }
                .frame(height: totalH)
            }
        }
    }

    // MARK: - Column view

    @ViewBuilder
    private func barsColumn(funds: [(String, Double)],
                            color: Color,
                            colWidth: CGFloat) -> some View {
        let maxVal   = funds.map(\.1).max() ?? 1.0
        let hPad: CGFloat = 8
        let gap: CGFloat  = 6
        let availBar = max(colWidth - labelW - gap - hPad * 2, 8)

        VStack(alignment: .leading, spacing: rowGap) {
            ForEach(funds, id: \.0) { code, value in
                HStack(spacing: gap) {
                    Text(code)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: labelW, alignment: .trailing)
                    Capsule()
                        .fill(color)
                        .frame(width: max(CGFloat(value / maxVal) * availBar, 4),
                               height: barH)
                    Spacer(minLength: 0)
                }
            }
        }
        .frame(width: colWidth)
        .padding(.horizontal, hPad)
    }

    // MARK: - Data helper

    private func sorted(for key: String?) -> [(String, Double)] {
        guard let key,
              let funds = result[key]?.topHoldingFunds,
              !funds.isEmpty else { return [] }
        return funds
            .sorted { $0.value > $1.value }
            .prefix(maxItems)
            .map { ($0.key, $0.value) }
    }
}
