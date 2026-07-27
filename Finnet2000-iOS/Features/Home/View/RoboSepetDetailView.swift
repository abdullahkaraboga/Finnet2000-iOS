import SwiftUI
import Charts

// MARK: - RoboSepetDetailView

struct RoboSepetDetailView: View {
    let detail: RoboSepetDetailResponse
    var onBack: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var isFavourite = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // ── Navigation Header ──────────────────────────────────
                rsDetailNavBar(
                    isFavourite: $isFavourite,
                    onBack: onBack ?? { dismiss() }
                )

                // ── Summary strip ──────────────────────────────────────
                summaryStrip

                ScrollView {
                    VStack(spacing: 0) {
                        sectionDivider

                        // Radar Chart
                        RSRadarSection(radarValues: detail.radarValues)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)

                        sectionDivider

                        // Portfolio Distribution
                        RSPortfolioSection(
                            monthName: detail.monthName,
                            holdings: detail.holdings
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)

                        sectionDivider

                        // Strategy
                        RSStrategySection(strategy: detail.strategy)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)

                        sectionDivider

                        // 10,000 Liram Ne Oldu?
                        RSReturnsSection(returns: detail.returns)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)

                        sectionDivider

                        // Risk Değeri
                        RSRiskBarSection(riskValue: detail.riskValue)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)

                        sectionDivider

                        // Yıllık Performans
                        RSAnnualChartSection(
                            prices: detail.annualPrices,
                            dates: detail.annualDates
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)

                        sectionDivider

                        // Diğer RoboSepetler
                        RSOtherPortfoliosSection(others: detail.otherPortfolios)
                            .padding(.top, 20)
                            .padding(.bottom, 20)

                        sectionDivider

                        // Çekince
                        RSDisclaimerSection(text: detail.disclaimer)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)
                    }
                    .padding(.bottom, 24)
                }
                .background(Color(.systemBackground))
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: Summary strip

    private var summaryStrip: some View {
        HStack(spacing: 12) {
            VStack(alignment: .center, spacing: 5) {
                RSRiskBadge(code: detail.code)

                HStack(spacing: 5) {
                    Text(detail.code)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)
                    Text(detail.name)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            let isPositive = detail.dailyReturn >= 0
            HStack(spacing: 4) {
                Image(systemName: isPositive ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(isPositive ? .midGreen : Color.red)
                Text(String(format: "%%%.2f", detail.dailyReturn))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isPositive ? .midGreen : Color.red)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }

    private var sectionDivider: some View {
        Divider().background(Color(.separator).opacity(0.4))
    }
}

// MARK: - Navigation Bar

private struct rsDetailNavBar: View {
    @Binding var isFavourite: Bool
    var onBack: (() -> Void)?

    var body: some View {
        HStack(spacing: 0) {
            Button { onBack?() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.15),
                                in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)

            Spacer()

            Image("finnet2000_logo_light")
                .resizable()
                .scaledToFit()
                .frame(height: 38)

            Spacer()

            Button { isFavourite.toggle() } label: {
                Image(systemName: isFavourite ? "heart.fill" : "heart")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(isFavourite ? Color.red : .white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.15),
                                in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(Color.black)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Risk Badge

struct RSRiskBadge: View {
    let code: String

    var body: some View {
        Image("riskolog_icon")
            .resizable()
            .scaledToFit()
            .frame(width: 38, height: 38)
            .cornerRadius(10)
    }
}

// MARK: - Radar Chart Section

struct RSRadarSection: View {
    let radarValues: RoboSepetRadarValues

    private let axisLabels = ["Volatilite", "VRO", "Getiri", "Sharpe", "Risk\nDeğeri"]

    var body: some View {
        RSRadarChart(
            values: radarValues.asArray,
            labels: axisLabels
        )
        .frame(height: 280)
    }
}

struct RSRadarChart: View {
    let values: [Double]    // 5 values, each 0–1
    let labels: [String]

    private let rings: [Double] = [0.33, 0.66, 1.0]
    private let n = 5
    private let labelPadding: CGFloat = 28

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let cx = w / 2
            let cy = h / 2
            // Leave room for labels on all sides
            let maxR = min(w, h) * 0.36

            ZStack {
                // ── Grid rings ───────────────────────────────────────────
                ForEach(rings.indices, id: \.self) { ri in
                    let scale = rings[ri]
                    Path { p in
                        for i in 0..<n {
                            let angle = radarAngle(i)
                            let pt = CGPoint(
                                x: cx + cos(angle) * maxR * scale,
                                y: cy + sin(angle) * maxR * scale
                            )
                            i == 0 ? p.move(to: pt) : p.addLine(to: pt)
                        }
                        p.closeSubpath()
                    }
                    .stroke(Color(.systemGray4), lineWidth: 0.8)
                }

                // ── Axis spokes ──────────────────────────────────────────
                ForEach(0..<n, id: \.self) { i in
                    Path { p in
                        let angle = radarAngle(i)
                        p.move(to: CGPoint(x: cx, y: cy))
                        p.addLine(to: CGPoint(
                            x: cx + cos(angle) * maxR,
                            y: cy + sin(angle) * maxR
                        ))
                    }
                    .stroke(Color(.systemGray4), lineWidth: 0.8)
                }

                // ── Filled polygon ───────────────────────────────────────
                Path { p in
                    for i in 0..<n {
                        let val = i < values.count ? CGFloat(values[i]) : 0
                        let angle = radarAngle(i)
                        let pt = CGPoint(
                            x: cx + cos(angle) * maxR * val,
                            y: cy + sin(angle) * maxR * val
                        )
                        i == 0 ? p.move(to: pt) : p.addLine(to: pt)
                    }
                    p.closeSubpath()
                }
                .fill(Color.midGreen.opacity(0.35))

                // ── Stroke polygon ───────────────────────────────────────
                Path { p in
                    for i in 0..<n {
                        let val = i < values.count ? CGFloat(values[i]) : 0
                        let angle = radarAngle(i)
                        let pt = CGPoint(
                            x: cx + cos(angle) * maxR * val,
                            y: cy + sin(angle) * maxR * val
                        )
                        i == 0 ? p.move(to: pt) : p.addLine(to: pt)
                    }
                    p.closeSubpath()
                }
                .stroke(Color.midGreen, lineWidth: 2)

                // ── Dot on each vertex ───────────────────────────────────
                ForEach(0..<n, id: \.self) { i in
                    let val = i < values.count ? CGFloat(values[i]) : 0
                    let angle = radarAngle(i)
                    let pt = CGPoint(
                        x: cx + cos(angle) * maxR * val,
                        y: cy + sin(angle) * maxR * val
                    )
                    Circle()
                        .fill(Color.midGreen)
                        .frame(width: 6, height: 6)
                        .position(pt)
                }

                // ── Labels ───────────────────────────────────────────────
                ForEach(0..<n, id: \.self) { i in
                    let angle = radarAngle(i)
                    let labelR = maxR + labelPadding
                    let pt = CGPoint(
                        x: cx + cos(angle) * labelR,
                        y: cy + sin(angle) * labelR
                    )
                    Text(i < labels.count ? labels[i] : "")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .position(pt)
                }
            }
        }
    }

    private func radarAngle(_ index: Int) -> CGFloat {
        // Start from top (-π/2) going clockwise
        CGFloat(-Double.pi / 2 + Double(index) * 2 * Double.pi / Double(n))
    }
}

// MARK: - Portfolio Distribution Section

struct RSPortfolioSection: View {
    let monthName: String
    let holdings: [RoboSepetHolding]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            RSSectionHeader(title: "\(monthName) Ayı Portföy Dağılımı")

            // Table header
            HStack {
                Text("Varlık Adı")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
                Text("Portföy Oranı")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))

            // Rows
            VStack(spacing: 0) {
                ForEach(Array(holdings.enumerated()), id: \.element.id) { index, holding in
                    HStack {
                        Text(holding.assetName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.primary)
                        Spacer()
                        Text("%\(formatRatioValue(holding.ratio))")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    if index < holdings.count - 1 {
                        Divider()
                    }
                }
            }

            // Detail button - Text only
            Button {
                // navigation
            } label: {
                Text("Ayrıntılı Portföy İçeriği")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.07, green: 0.50, blue: 0.68))
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private func formatRatioValue(_ value: Double) -> String {
        if value == value.rounded() {
            return String(format: "%.0f", value)
        }
        return String(format: "%g", value)
    }
}

// MARK: - Strategy Section

struct RSStrategySection: View {
    let strategy: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RoboSepet Stratejisi")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(strategy)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Returns Section  (10,000 Liram Ne Oldu?)

struct RSReturnsSection: View {
    let returns: RoboSepetReturns

    private var items: [(label: String, pct: Double, amount: Double)] {
        [
            ("Günlük",  returns.daily.percentage,        returns.daily.amount),
            ("Haftalık", returns.weekly.percentage,      returns.weekly.amount),
            ("Aylık",   returns.monthly.percentage,      returns.monthly.amount),
            ("3 Aylık", returns.threeMonthly.percentage, returns.threeMonthly.amount),
            ("6 Aylık", returns.sixMonthly.percentage,   returns.sixMonthly.amount),
            ("Yıllık",  returns.annual.percentage,       returns.annual.amount),
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            RSSectionHeader(title: "10,000 Liram Ne Oldu ?")

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 12
            ) {
                ForEach(items, id: \.label) { item in
                    RSReturnCell(
                        label: item.label,
                        percentage: item.pct,
                        amount: item.amount
                    )
                }
            }
        }
    }
}

private struct RSReturnCell: View {
    let label: String
    let percentage: Double
    let amount: Double

    private var isPositive: Bool { percentage >= 0 }
    private var color: Color { isPositive ? .midGreen : Color.red }

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Text(formattedPct)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(color)
                Text(formattedAmt)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemGray6).opacity(0.6))
        .cornerRadius(10)
    }

    private var formattedPct: String {
        String(format: "%%%.2f", percentage)
    }

    private var formattedAmt: String {
        amount.compactCurrencyString(fractionDigits: 0)
    }
}

// MARK: - Risk Bar Section

struct RSRiskBarSection: View {
    let riskValue: Int  // 1–7

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            RSSectionHeader(title: "Risk Değeri")

            GeometryReader { geo in
                let w = geo.size.width
                let barH: CGFloat = 18
                let dotD: CGFloat = 22
                let fraction = CGFloat(max(1, min(riskValue, 7)) - 1) / 6.0
                let dotX = fraction * w

                ZStack(alignment: .leading) {
                    // Gradient bar
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.18, green: 0.78, blue: 0.28),
                            Color(red: 0.60, green: 0.80, blue: 0.10),
                            Color(red: 1.0,  green: 0.75, blue: 0.0),
                            Color(red: 0.95, green: 0.42, blue: 0.0),
                            Color(red: 0.87, green: 0.10, blue: 0.10),
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: barH)
                    .cornerRadius(barH / 2)

                    // Dot indicator
                    Circle()
                        .fill(Color.white)
                        .frame(width: dotD, height: dotD)
                        .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 1)
                        .overlay(
                            Text("\(riskValue)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.primary)
                        )
                        .offset(x: dotX - dotD / 2)
                }
            }
            .frame(height: 22)
        }
    }
}

// MARK: - Annual Chart Section

struct RSAnnualChartSection: View {
    let prices: [Double]
    let dates: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            RSSectionHeader(title: "Yıllık Performans Grafiği")

            if #available(iOS 16.0, *) {
                annualChart
            } else {
                Text("Grafik iOS 16+ gerektirir.")
                    .foregroundColor(.secondary)
            }
        }
    }

    @available(iOS 16.0, *)
    private var annualChart: some View {
        let count = min(prices.count, dates.count == 0 ? prices.count : Int.max)
        let indices = Array(0..<count)

        return Chart {
            ForEach(indices, id: \.self) { i in
                LineMark(
                    x: .value("Tarih", i),
                    y: .value("Fiyat", prices[i])
                )
                .foregroundStyle(Color.midGreen)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Tarih", i),
                    yStart: .value("Min", prices.min() ?? 0),
                    yEnd: .value("Fiyat", prices[i])
                )
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.midGreen.opacity(0.4), .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }
        }
        .chartXAxis {
            let stride = max(1, count / 6)
            let ticks = Swift.stride(from: 0, to: count, by: stride).map { $0 }
            AxisMarks(values: ticks) { v in
                if let idx = v.as(Int.self), idx < dates.count {
                    AxisValueLabel(dates[idx])
                        .font(.system(size: 9))
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing) { _ in
                AxisValueLabel()
                    .font(.system(size: 10))
                AxisGridLine()
            }
        }
        .frame(height: 220)
    }
}

// MARK: - Other Portfolios Section

struct RSOtherPortfoliosSection: View {
    let others: [RobofundPortfolio]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            RSSectionHeader(title: "Diğer RoboSepetler")
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(others, id: \.code) { portfolio in
                        RSOtherPortfolioCard(portfolio: portfolio)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
        }
    }
}

private struct RSOtherPortfolioCard: View {
    let portfolio: RobofundPortfolio

    private var isPositive: Bool { portfolio.dailyReturn >= 0 }
    private var color: Color { isPositive ? .midGreen : Color.red }

    var body: some View {
        VStack(spacing: 6) {
            RSRiskBadge(code: portfolio.code)

            Text(portfolio.code)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.primary)

            Text(String(format: "%%%.2f", portfolio.dailyReturn))
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(color)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.systemGray6).opacity(0.7))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Disclaimer Section

struct RSDisclaimerSection: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Çekince")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.primary)

            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
        }
    }
}

// MARK: - Shared Section Header

struct RSSectionHeader: View {
    let title: String

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            Image(systemName: "info.circle")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    RoboSepetDetailView(detail: .mock, onBack: {})
}

