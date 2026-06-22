import SwiftUI

// MARK: - Model

private struct PortfolioHolding: Identifiable {
    let id = UUID()
    let symbol: String
    let adet: String
    let totalValue: String
    let avgCost: String
    let pnl: String
    let pnlPercent: String
    let price: String
    let isGain: Bool
    let color: Color
    let weight: Double          // 0..1  for pie chart
}

private let kTotal = 8444.58

private let mockHoldings: [PortfolioHolding] = [
    .init(symbol: "ASELS", adet: "2",  totalValue: "731,00 ₺",   avgCost: "411,10 ₺",  pnl: "-91,20 ₺",   pnlPercent: "-11,09%", price: "365,50 TL",  isGain: false, color: Color(red: 1.00, green: 0.80, blue: 0.00), weight: 731.00  / kTotal),
    .init(symbol: "BLCYT", adet: "7",  totalValue: "190,54 ₺",   avgCost: "35,42 ₺",   pnl: "-57,40 ₺",   pnlPercent: "-23,15%", price: "27,22 TL",   isGain: false, color: Color(red: 0.20, green: 0.72, blue: 0.49), weight: 190.54  / kTotal),
    .init(symbol: "HURGZ", adet: "79", totalValue: "587,76 ₺",   avgCost: "6,54 ₺",    pnl: "71,10 ₺",    pnlPercent: "13,76%",  price: "7,44 TL",    isGain: true,  color: Color(red: 1.00, green: 0.55, blue: 0.00), weight: 587.76  / kTotal),
    .init(symbol: "KTLEV", adet: "4",  totalValue: "596,80 ₺",   avgCost: "98,77 ₺",   pnl: "201,72 ₺",   pnlPercent: "51,04%",  price: "149,20 TL",  isGain: true,  color: Color(red: 0.20, green: 0.60, blue: 0.90), weight: 596.80  / kTotal),
    .init(symbol: "LILAK", adet: "15", totalValue: "514,80 ₺",   avgCost: "38,17 ₺",   pnl: "-57,75 ₺",   pnlPercent: "-10,09%", price: "34,32 TL",   isGain: false, color: Color(red: 0.65, green: 0.30, blue: 0.80), weight: 514.80  / kTotal),
    .init(symbol: "PASEU", adet: "5",  totalValue: "516,50 ₺",   avgCost: "127,15 ₺",  pnl: "-119,25 ₺",  pnlPercent: "-18,76%", price: "103,30 TL",  isGain: false, color: Color(red: 1.00, green: 0.30, blue: 0.30), weight: 516.50  / kTotal),
    .init(symbol: "PEKGY", adet: "36", totalValue: "435,60 ₺",   avgCost: "14,39 ₺",   pnl: "-87,44 ₺",   pnlPercent: "-15,91%", price: "12,10 TL",   isGain: false, color: Color(red: 0.00, green: 0.80, blue: 0.80), weight: 435.60  / kTotal),
    .init(symbol: "PSGYO", adet: "96", totalValue: "312,96 ₺",   avgCost: "2,91 ₺",    pnl: "33,60 ₺",    pnlPercent: "12,03%",  price: "3,26 TL",    isGain: true,  color: Color(red: 0.90, green: 0.70, blue: 0.10), weight: 312.96  / kTotal),
    .init(symbol: "SISE",  adet: "11", totalValue: "485,76 ₺",   avgCost: "47,90 ₺",   pnl: "-41,14 ₺",   pnlPercent: "-7,81%",  price: "44,16 TL",   isGain: false, color: Color(red: 0.30, green: 0.70, blue: 0.30), weight: 485.76  / kTotal),
    .init(symbol: "TRALT", adet: "9",  totalValue: "356,48 ₺",   avgCost: "49,06 ₺",   pnl: "-36,00 ₺",   pnlPercent: "-9,17%",  price: "44,56 TL",   isGain: false, color: Color(red: 0.80, green: 0.40, blue: 0.00), weight: 356.48  / kTotal),
    .init(symbol: "TTKOM", adet: "12", totalValue: "759,00 ₺",   avgCost: "63,99 ₺",   pnl: "-8,88 ₺",    pnlPercent: "-1,16%",  price: "63,25 TL",   isGain: false, color: Color(red: 0.40, green: 0.40, blue: 0.90), weight: 759.00  / kTotal),
    .init(symbol: "TUPRS", adet: "7",  totalValue: "1.697,50 ₺", avgCost: "257,03 ₺",  pnl: "-101,71 ₺",  pnlPercent: "-5,65%",  price: "242,50 TL",  isGain: false, color: Color(red: 1.00, green: 0.60, blue: 0.20), weight: 1697.50 / kTotal),
    .init(symbol: "ULKER", adet: "6",  totalValue: "684,60 ₺",   avgCost: "124,06 ₺",  pnl: "-59,76 ₺",   pnlPercent: "-8,05%",  price: "114,10 TL",  isGain: false, color: Color(red: 0.50, green: 0.80, blue: 0.20), weight: 684.60  / kTotal),
    .init(symbol: "YYLGD", adet: "51", totalValue: "575,29 ₺",   avgCost: "11,98 ₺",   pnl: "-55,70 ₺",   pnlPercent: "-5,84%",  price: "11,28 TL",   isGain: false, color: Color(red: 0.90, green: 0.20, blue: 0.50), weight: 575.29  / kTotal),
]

// MARK: - Pie slice shape

private struct PieSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        p.move(to: center)
        p.addArc(center: center, radius: r,
                 startAngle: startAngle, endAngle: endAngle, clockwise: false)
        p.closeSubpath()
        return p
    }
}

// MARK: - Main view

struct PortfolioView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filtered: [PortfolioHolding] {
        searchText.isEmpty ? mockHoldings :
            mockHoldings.filter { $0.symbol.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            navBar

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection

                    Color(.separator).opacity(0.4).frame(height: 0.5)
                        .padding(.top, 6)

                    chartSection

                    Color(.separator).opacity(0.4).frame(height: 0.5)

                    searchBar

                    Color(.separator).opacity(0.4).frame(height: 0.5)

                    holdingsList
                }
            }
            .background(Color.white)
        }
        .navigationBarHidden(true)
        .background(Color.white)
    }

    // MARK: Nav bar

    private var navBar: some View {
        ZStack {
            Color.black
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44, alignment: .leading)
                }
                .buttonStyle(.plain)
                Spacer()
                Text("Portföyüm")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 56)
    }

    // MARK: Header

    private var headerSection: some View {
        VStack(spacing: 5) {
            Text("Toplam Portföy Değeri")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(.systemGray))

            Text("8.444,58 ₺")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color(.label))

            HStack(spacing: 4) {
                Text("Toplam Kar/Zarar:")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color(.label))
                Text("-384,81 ₺")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.red)
                Text("%-4,36")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.red)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 14)
        .padding(.bottom, 10)
    }

    // MARK: Pie chart + legend

    private var chartSection: some View {
        HStack(alignment: .center, spacing: 10) {
            // Pie chart
            ZStack {
                let base = Angle(degrees: -90)
                ForEach(Array(mockHoldings.enumerated()), id: \.offset) { idx, item in
                    let cumulative = mockHoldings.prefix(idx).reduce(0.0) { $0 + $1.weight }
                    let start = base + Angle(degrees: cumulative * 360)
                    let end   = start + Angle(degrees: item.weight * 360)
                    PieSlice(startAngle: start, endAngle: end)
                        .fill(item.color)
                }
            }
            .frame(width: 140, height: 140)

            // Legend: 2-column grid
            let columns = [GridItem(.flexible(), alignment: .leading),
                           GridItem(.flexible(), alignment: .leading)]
            LazyVGrid(columns: columns, alignment: .leading, spacing: 5) {
                ForEach(mockHoldings) { item in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 7, height: 7)
                        Text(legendLabel(item))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color(.label))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private func legendLabel(_ item: PortfolioHolding) -> String {
        let pct = item.weight * 100
        let formatted = String(format: "%.1f", pct).replacingOccurrences(of: ".", with: ",")
        return "\(item.symbol) (\(formatted)%)"
    }

    // MARK: Search bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(.systemGray))
            TextField("Hisse Arayın...", text: $searchText)
                .font(.system(size: 14))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.characters)
        }
        .padding(.horizontal, 10)
        .frame(height: 38)
        .background(Color(.systemGray6),
                    in: RoundedRectangle(cornerRadius: 9, style: .continuous))
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }

    // MARK: Holdings list

    private var holdingsList: some View {
        LazyVStack(spacing: 0) {
            ForEach(filtered) { item in
                holdingRow(item)
                if item.id != filtered.last?.id {
                    Color(.separator).opacity(0.35).frame(height: 0.5)
                        .padding(.leading, 36)
                }
            }
        }
    }

    @ViewBuilder
    private func holdingRow(_ h: PortfolioHolding) -> some View {
        HStack(alignment: .top, spacing: 8) {
            // Color box
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(h.color)
                .frame(width: 12, height: 12)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 0) {
                // Symbol  +  Adet / Value
                HStack(alignment: .firstTextBaseline) {
                    Text(h.symbol)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(.label))
                    Spacer(minLength: 4)
                    Text("\(h.adet) Adet / \(h.totalValue)")
                        .font(.system(size: 12.5, weight: .regular))
                        .foregroundStyle(Color(.label))
                }

                // Ortalama Maliyet
                HStack(alignment: .firstTextBaseline) {
                    Text("Ortalama Maliyet")
                        .font(.system(size: 11.5, weight: .regular))
                        .foregroundStyle(Color(.systemGray))
                    Spacer(minLength: 4)
                    Text(h.avgCost)
                        .font(.system(size: 11.5, weight: .regular))
                        .foregroundStyle(Color(.label))
                }
                .padding(.top, 3)

                // Kâr/Zarar
                HStack(alignment: .firstTextBaseline) {
                    Text("Kâr/Zarar")
                        .font(.system(size: 11.5, weight: .regular))
                        .foregroundStyle(Color(.systemGray))
                    Spacer(minLength: 4)
                    Text(h.pnl)
                        .font(.system(size: 11.5, weight: .regular))
                        .foregroundStyle(Color(.label))
                }
                .padding(.top, 2)

                // Fiyat  +  %
                HStack(alignment: .firstTextBaseline) {
                    Text("Fiyat: \(h.price)")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(Color(.systemGray))
                    Spacer(minLength: 4)
                    Text(h.pnlPercent)
                        .font(.system(size: 11.5, weight: .semibold))
                        .foregroundStyle(h.isGain
                            ? Color(red: 0.196, green: 0.717, blue: 0.486)
                            : .red)
                }
                .padding(.top, 2)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
    }
}

#Preview {
    NavigationStack {
        PortfolioView()
    }
}
