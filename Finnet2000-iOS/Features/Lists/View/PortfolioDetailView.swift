import SwiftUI
import Charts
import Alamofire
import Combine

// MARK: - PortfolioDetailView

struct PortfolioDetailView: View {
    let detail: PortfolioDetailResponse
    var onBack: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss


    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // ── Navigation Bar ──────────────────────────────────────
                PDNavBar(
                    detail: detail,
                    onBack: onBack ?? { dismiss() },
                    onEdit: { /* TODO: portföy düzenle */ },
                    onDelete: { /* TODO: portföy sil */ }
                )

                ScrollView {
                    VStack(spacing: 0) {

                        // ── Green stats strip ───────────────────────────
                        PDStatsStrip(
                            dailyReturn: detail.dailyReturn,
                            totalReturn: detail.totalReturn
                        )

                        // ── 100 Liram Ne Oldu? ──────────────────────────
                        pdSectionDivider
                        PDPerformanceSection(performance: detail.performance)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)

                        // ── Portföy Ağırlıkları ─────────────────────────
                        pdSectionDivider
                        PDWeightsSection(weights: detail.weights)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)

                        // ── Açık Pozisyonlar ────────────────────────────
                        pdSectionDivider
                        PDOpenPositionsSection(positions: detail.openPositions)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                    }
                    .padding(.bottom, 32)
                }
                .background(Color(.systemBackground))
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var pdSectionDivider: some View {
        Divider().background(Color(.separator).opacity(0.4))
    }
}

private extension Color {
    static let sdGreen      = Color(red: 0.18, green: 0.72, blue: 0.40)
    static let sdRed        = Color(red: 0.85, green: 0.11, blue: 0.18)
    static let sdBlue       = Color(red: 0.11, green: 0.39, blue: 0.78)
    static let sdPink       = Color(red: 1.00, green: 0.38, blue: 0.58)
    static let sdChartGreen = Color(red: 0.30, green: 0.79, blue: 0.49)
}

// MARK: - Navigation Bar

private struct PDNavBar: View {
    let detail: PortfolioDetailResponse
    var onBack: (() -> Void)?
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?


    @State private var showDeleteAlert = false

    private var isPositive: Bool { detail.dailyReturn >= 0 }
    private var returnColor: Color { isPositive ? .midGreen : Color.red }

    var body: some View {
        VStack(spacing: 0) {
            // ── Top row: back + actions ──────────────────────────────
            HStack {
                Button { onBack?() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 40, height: 40)
                        .background(.thinMaterial,
                                    in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)

                Spacer()

                HStack(spacing: 10) {
                    Button { onEdit?() } label: { pdNavButton("square.and.pencil") }
                        .buttonStyle(.plain)
                    Button { showDeleteAlert = true } label: { pdNavButton("trash") }
                        .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)

            // ── Bottom row: avatar + name + value ───────────────────
            HStack(spacing: 12) {
                // Avatar
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(red: 0.22, green: 0.47, blue: 0.80))
                        .frame(width: 44, height: 44)
                    Text(String(detail.name.prefix(1)).uppercased())
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(detail.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.primary)
                    Text(detail.date)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text(detail.totalValueFormatted)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)
                    Text(detail.date)
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                    Text(String(format: "%%%.2f", detail.dailyReturn))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(returnColor)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 16)
        }
        .background(.regularMaterial)
        .frame(maxWidth: .infinity)
        .alert("Portföyü Sil", isPresented: $showDeleteAlert) {
            Button("İptal", role: .cancel) {}
            Button("Sil", role: .destructive) { onDelete?() }
        } message: {
            Text("\"\(detail.name)\" portföyünü silmek istediğinizden emin misiniz?")
        }
    }

    private func pdNavButton(_ systemName: String) -> some View {
        
        Image(systemName: systemName)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.primary)
            .frame(width: 40, height: 40)
            .background(.thinMaterial,
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Stats Strip

private struct PDStatsStrip: View {
    let dailyReturn: Double
    let totalReturn: Double

    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            statItem(label: "Günlük Getiri", value: dailyReturn)
            Spacer()
            // thin separator
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 1, height: 18)
            Spacer()
            statItem(label: "Toplam Getiri", value: totalReturn)
            Spacer()
        }
        .padding(.vertical, 10)
        .background(Color.midGreen)
    }

    private func statItem(label: String, value: Double) -> some View {
        HStack(spacing: 6) {
            Text("\(label):")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
            Text(formatPct(value))
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(value < 0 ? Color(red: 1, green: 0.6, blue: 0.6) : .white)
        }
    }

    private func formatPct(_ v: Double) -> String {
        let sign = v < 0 ? "-" : ""
        return String(format: "%@%%%.2f", sign, abs(v))
    }
}

// MARK: - Performance Section  (100 Liram Ne Oldu?)

private struct PDPerformanceSection: View {
    let performance: PortfolioPerformance

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            PDSectionHeader(title: "100 Liram Ne Oldu ?")

            if #available(iOS 16.0, *) {
                performanceChart
            } else {
                Text("Grafik iOS 16+ gerektirir.")
                    .foregroundColor(.secondary)
            }
        }
    }

    @available(iOS 16.0, *)
    private var performanceChart: some View {
        let values = performance.values
        let count = values.count
        let minVal = values.min() ?? 95.0
        let indices = Array(0..<count)

        return Chart {
            ForEach(indices, id: \.self) { i in
                LineMark(
                    x: .value("Index", i),
                    y: .value("Değer", values[i])
                )
                .foregroundStyle(Color.midGreen)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Index", i),
                    yStart: .value("Base", minVal),
                    yEnd: .value("Değer", values[i])
                )
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.midGreen.opacity(0.35),
                            Color.midGreen.opacity(0.05)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }
        }
        .chartXAxis {
            let stride = max(1, count / 2)
            let ticks = Swift.stride(from: 0, to: count, by: stride).map { $0 }
            AxisMarks(values: ticks) { v in
                if let idx = v.as(Int.self),
                   idx < performance.dates.count {
                    AxisValueLabel(performance.dates[idx])
                        .font(.system(size: 10))
                }
                AxisGridLine()
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { v in
                AxisValueLabel()
                    .font(.system(size: 10))
                AxisGridLine()
            }
        }
        .chartYScale(domain: (values.min() ?? 95) ... (values.max() ?? 100))
        .frame(height: 220)
    }
}

// MARK: - Weights Section  (Portföy Ağırlıkları)

private struct PDWeightsSection: View {
    let weights: [PortfolioWeight]
    @State private var selectedIndex: Int? = nil

    private let palette: [Color] = [
        Color(red: 0.18, green: 0.72, blue: 0.40),
        Color(red: 0.53, green: 0.76, blue: 0.94),
        Color(red: 0.86, green: 0.87, blue: 0.88),
        Color(red: 0.98, green: 0.76, blue: 0.30),
        Color(red: 0.93, green: 0.43, blue: 0.43),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            PDSectionHeader(title: "Portföy Ağırlıkları")

            ZStack {
                PDDonutChart(weights: weights, palette: palette, selectedIndex: $selectedIndex)
                    .frame(height: 240)

                GeometryReader { geo in
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(weights.enumerated()), id: \.element.id) { i, w in
                            HStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(palette[i % palette.count])
                                    .frame(width: 10, height: 10)
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(w.code)
                                        .font(.system(size: 10, weight: selectedIndex == i ? .bold : .semibold))
                                        .foregroundColor(selectedIndex == i ? palette[i % palette.count] : .primary)
                                    Text(String(format: "%%%.0f", w.ratio * 100))
                                        .font(.system(size: 9))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .scaleEffect(selectedIndex == i ? 1.05 : 1.0, anchor: .leading)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedIndex)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 4)
                    .padding(.top, geo.size.height * 0.25)
                }
                .frame(height: 240)
                .allowsHitTesting(false)
            }
        }
    }
}

// MARK: - Donut Chart

private struct PDDonutChart: View {
    let weights: [PortfolioWeight]
    let palette: [Color]
    @Binding var selectedIndex: Int?

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let outerR = size * 0.42
            let innerR = size * 0.28
            let cx = geo.size.width / 2
            let cy = geo.size.height / 2

            ZStack {
                sliceViews(cx: cx, cy: cy, outerR: outerR, innerR: innerR)
                centerLabel
            }
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onEnded { value in
                        let dx = value.location.x - cx
                        let dy = value.location.y - cy
                        let dist = sqrt(dx * dx + dy * dy)
                        guard dist >= innerR * 0.85 && dist <= outerR * 1.15 else {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) { selectedIndex = nil }
                            return
                        }
                        var angle = atan2(dy, dx) * 180 / .pi + 90
                        if angle < 0 { angle += 360 }
                        let total = weights.reduce(0.0) { $0 + $1.ratio }
                        var cumDeg = 0.0
                        var found: Int? = nil
                        for (i, w) in weights.enumerated() {
                            let sweep = (w.ratio / total) * 360
                            if angle < cumDeg + sweep { found = i; break }
                            cumDeg += sweep
                        }
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                            selectedIndex = selectedIndex == found ? nil : found
                        }
                    }
            )
        }
    }

    private func sliceViews(cx: CGFloat, cy: CGFloat,
                            outerR: CGFloat, innerR: CGFloat) -> some View {
        let total = weights.reduce(0.0) { $0 + $1.ratio }
        var startAngles: [Angle] = []
        var cur = Angle(degrees: -90)
        for w in weights {
            startAngles.append(cur)
            cur += Angle(degrees: (w.ratio / total) * 360)
        }
        return ZStack {
            ForEach(Array(weights.enumerated()), id: \.element.id) { i, w in
                let sweep = Angle(degrees: (w.ratio / total) * 360)
                DonutSlice(
                    center: CGPoint(x: cx, y: cy),
                    outerRadius: outerR,
                    innerRadius: innerR,
                    startAngle: startAngles[i],
                    endAngle: startAngles[i] + sweep
                )
                .fill(palette[i % palette.count])
                .scaleEffect(selectedIndex == i ? 1.07 : 1.0)
                .brightness(selectedIndex == i ? 0.06 : 0.0)
                .animation(.spring(response: 0.35, dampingFraction: 0.65), value: selectedIndex)
            }
        }
    }

    private var centerLabel: some View {
        Group {
            if let idx = selectedIndex, idx < weights.count {
                VStack(spacing: 3) {
                    Text(weights[idx].code)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)
                    Text(String(format: "%%%.1f", weights[idx].ratio * 100))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(palette[idx % palette.count])
                }
                .id("sel")
                .transition(.scale(scale: 0.8).combined(with: .opacity))
            } else {
                VStack(spacing: 2) {
                    Text("Portföyünüzün")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    Text("Yüzdesel")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    Text("Ağırlıkları")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .multilineTextAlignment(.center)
                .id("def")
                .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedIndex)
        .allowsHitTesting(false)
    }
}

// Donut slice shape
private struct DonutSlice: Shape {
    let center: CGPoint
    let outerRadius: CGFloat
    let innerRadius: CGFloat
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx = center.x
        let cy = center.y

        p.move(to: CGPoint(
            x: cx + cos(CGFloat(startAngle.radians)) * outerRadius,
            y: cy + sin(CGFloat(startAngle.radians)) * outerRadius
        ))
        p.addArc(center: CGPoint(x: cx, y: cy),
                 radius: outerRadius,
                 startAngle: startAngle,
                 endAngle: endAngle,
                 clockwise: false)
        p.addLine(to: CGPoint(
            x: cx + cos(CGFloat(endAngle.radians)) * innerRadius,
            y: cy + sin(CGFloat(endAngle.radians)) * innerRadius
        ))
        p.addArc(center: CGPoint(x: cx, y: cy),
                 radius: innerRadius,
                 startAngle: endAngle,
                 endAngle: startAngle,
                 clockwise: true)
        p.closeSubpath()
        return p
    }
}

// MARK: - Open Positions Section

private struct PDOpenPositionsSection: View {
    let positions: [OpenPosition]
    @State private var expanded: Set<String> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            PDSectionHeader(title: "Açık Pozisyonlar")

            VStack(spacing: 0) {
                ForEach(positions) { pos in
                    PDPositionCard(
                        position: pos,
                        isExpanded: expanded.contains(pos.id)
                    ) {
                        if expanded.contains(pos.id) {
                            expanded.remove(pos.id)
                        } else {
                            expanded.insert(pos.id)
                        }
                    }
                }
            }
        }
    }
}

private struct PDSelectedLotInfo: Identifiable {
    let position: OpenPosition
    let lot: PositionLot
    var id: String { lot.id }
}

// MARK: - Position Card

private struct PDPositionCard: View {
    let position: OpenPosition
    let isExpanded: Bool
    let onToggle: () -> Void
    @State private var selectedLotInfo: PDSelectedLotInfo? = nil

    private var isPositive: Bool { position.dailyReturn >= 0 }
    private var returnColor: Color { isPositive ? .midGreen : Color.red }

    var body: some View {
        VStack(spacing: 0) {
            // ── Summary row ─────────────────────────────────────────────
            Button(action: onToggle) {
                HStack(spacing: 10) {
                    // Logo square
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color(red: 0.22, green: 0.47, blue: 0.80))
                            .frame(width: 38, height: 38)
                        Text(String(position.stockCode.prefix(1)))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }

                    // Columns header + values
                    VStack(spacing: 4) {
                        // Header labels
                        HStack(spacing: 0) {
                            columnLabel("Kod")
                            Spacer()
                            columnLabel("Maliyet")
                            Spacer()
                            columnLabel("Değer")
                            Spacer()
                            // value + pct column header (empty label, value shown below)
                            columnLabel("")
                        }
                        // Values
                        HStack(spacing: 0) {
                            Text(position.stockCode)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.primary)
                            Spacer()
                            Text(position.costPriceFormatted)
                                .font(.system(size: 12))
                                .foregroundColor(.primary)
                            Spacer()
                            Text(position.currentValueFormatted)
                                .font(.system(size: 12))
                                .foregroundColor(.primary)
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(position.currentValueFormatted)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.primary)
                                Text(String(format: "%%%.2f", position.dailyReturn))
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(returnColor)
                            }
                        }
                    }

                    // Chevron toggle
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // ── Lot detail (expanded) ────────────────────────────────────
            if isExpanded {
                Divider().padding(.horizontal, 12)

                VStack(spacing: 0) {
                    // Column headers
                    HStack(spacing: 0) {
                        columnLabel("Tarih")
                        Spacer()
                        columnLabel("Adet")
                        Spacer()
                        columnLabel("Alım Fiyatı")
                        Spacer()
                        columnLabel("Son Fiyat")
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .padding(.leading, 6)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6).opacity(0.5))

                    // Lot rows
                    ForEach(position.lots) { lot in
                        Divider().padding(.horizontal, 12)
                        Button {
                            selectedLotInfo = PDSelectedLotInfo(position: position, lot: lot)
                        } label: {
                            HStack(spacing: 0) {
                                Text(lot.date)
                                    .font(.system(size: 12))
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(Double(lot.quantity).compactString(fractionDigits: 0))
                                    .font(.system(size: 12))
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(formatPrice(lot.buyPrice))
                                    .font(.system(size: 12))
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(formatPrice(lot.lastPrice))
                                    .font(.system(size: 12))
                                    .foregroundColor(.primary)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.secondary)
                                    .frame(width: 22)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }

                    // Page badge
                    HStack {
                        Spacer()
                        Text("1")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.midGreen)
                            .clipShape(Circle())
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) { Divider() }
        .sheet(item: $selectedLotInfo) { info in
            if #available(iOS 16.0, *) {
                PDPositionDetailSheet(position: info.position, lot: info.lot)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
            } else {
                PDPositionDetailSheet(position: info.position, lot: info.lot)
            }
        }
    }

    private func columnLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11))
            .foregroundColor(.secondary)
    }

    private func formatPrice(_ v: Double) -> String {
        v.compactCurrencyString()
    }
}

// MARK: - Position Detail Sheet

private struct PDPositionDetailSheet: View {
    let position: OpenPosition
    let lot: PositionLot
    @Environment(\.dismiss) private var dismiss

    private var alimMaliyeti: Double { position.costPrice }
    private var topGetiriPct: Double  { lot.totalReturnPct }
    private var gunKazancTL: Double   { lot.dailyProfit }
    private var netKazancTL: Double   { lot.netProfit }

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(Color(.systemGray4))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 4)

            Text("Pozisyon Detayı")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
                .padding(.vertical, 20)

            HStack(spacing: 0) {
                Text("Pozisyon Tarihi : ")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                Text(lot.date)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)

            // Row 1: Adet | Alım Fiyatı | Son Fiyat | Alım Maliyeti
            HStack(spacing: 0) {
                sheetMetricCell(label: "Adet", value: "\(lot.quantity)")
                Divider().frame(height: 40)
                sheetMetricCell(label: "Alım Fiyatı", value: fmtPrice(lot.buyPrice))
                Divider().frame(height: 40)
                sheetMetricCell(label: "Son Fiyat", value: fmtPrice(lot.lastPrice))
                Divider().frame(height: 40)
                sheetMetricCell(label: "Alım Maliyeti", value: fmtPrice(alimMaliyeti))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color(.systemGray6).opacity(0.6))
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)

            // Row 2: Piyasa Değ. | Top. Getiri | Gün. Kazanç | Net Kazanç
            HStack(spacing: 0) {
                sheetMetricCell(label: "Piyasa Değ.", value: fmtPrice(position.currentValue))
                Divider().frame(height: 40)
                sheetMetricCell(
                    label: "Top. Getiri",
                    value: fmtPct(topGetiriPct),
                    valueColor: topGetiriPct < 0 ? .red : .midGreen
                )
                Divider().frame(height: 40)
                sheetMetricCell(label: "Gün. Kazanç", value: fmtPrice(abs(gunKazancTL)))
                Divider().frame(height: 40)
                sheetMetricCell(
                    label: "Net Kazanç",
                    value: fmtPrice(netKazancTL),
                    valueColor: netKazancTL < 0 ? .red : .midGreen
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color(.systemGray6).opacity(0.6))
            .cornerRadius(12)
            .padding(.horizontal, 16)

            Spacer()

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    sheetActionButton("Pozisyon Düzenle", color: .midGreen) {}
                    sheetActionButton("Parçalı Alış/Satış", color: .midGreen) {}
                }
                sheetActionButton(
                    "Pozisyon Kapat",
                    color: Color(red: 0.72, green: 0.12, blue: 0.12)
                ) {}
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
    }

    private func sheetMetricCell(label: String, value: String,
                                 valueColor: Color = .primary) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(valueColor)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private func sheetActionButton(_ title: String, color: Color,
                                   action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(color)
                .cornerRadius(25)
        }
        .buttonStyle(.plain)
    }

    private func fmtPrice(_ v: Double) -> String {
        v.compactCurrencyString()
    }

    private func fmtPct(_ v: Double) -> String {
        let sign = v < 0 ? "-" : ""
        return String(format: "%@%%%.2f", sign, abs(v))
    }
}

// MARK: - Section Header  (shared)

private struct PDSectionHeader: View {
    let title: String

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.primary)
            Image(systemName: "info.circle")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Portfolio Detail Loader

/// Loads real portfolio detail from the API, then renders PortfolioDetailView.
struct PortfolioDetailLoaderView: View {
    let portfolioId: Int
    let logoPath: String

    @StateObject private var vm = PortfolioDetailLoaderVM()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if vm.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Portföy yükleniyor…")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let detail = vm.detail {
                PortfolioDetailView(detail: detail, onBack: { dismiss() })
            } else {
                VStack(spacing: 16) {
                    Text(vm.errorMessage ?? "Bir hata oluştu.")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    Button("Tekrar Dene") {
                        vm.load(portfolioId: portfolioId, logoPath: logoPath)
                    }
                    .foregroundColor(.midGreen)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            if vm.detail == nil && !vm.isLoading {
                vm.load(portfolioId: portfolioId, logoPath: logoPath)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

@MainActor
private final class PortfolioDetailLoaderVM: ObservableObject {

    init() {}

    @Published var detail: PortfolioDetailResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository = ListsRepository()

    func load(portfolioId: Int, logoPath: String) {
        isLoading = true
        errorMessage = nil

        repository.getPortfolioDetail(portfolioId: portfolioId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let apiResponse):
                    self.detail = apiResponse.toPortfolioDetailResponse(portfolioId: portfolioId,
                                                                        logoPath: logoPath)
                case .failure(let error):
                    if let code = error.responseCode, code == 401 { return }
                    self.errorMessage = "Portföy detayı alınamadı."
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    PortfolioDetailView(detail: .mock, onBack: {})
}
